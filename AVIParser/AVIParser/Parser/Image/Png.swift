//
//  Png.swift
//  AVIParser
//
//  Created by ethan on 2018/8/30.
//  Copyright © 2018年 ethan. All rights reserved.
//

/* reference:  https://tools.ietf.org/html/rfc2083
 https://www.w3.org/TR/2003/REC-PNG-20031110/#7Integers-and-byte-order
 PNG uses network byte order.
 */

import Foundation
import CryptoSwift

/**
 This table summarizes some properties of the standard chunk types.
 
 Critical chunks (must appear in this order, except PLTE
 is optional):
 
 Name  Multiple  Ordering constraints
 OK?
 
 IHDR    No      Must be first
 PLTE    No      Before IDAT
 IDAT    Yes     Multiple IDATs must be consecutive
 IEND    No      Must be last
 
 Ancillary chunks (need not appear in this order):
 
 Name  Multiple  Ordering constraints
 OK?
 
 cHRM    No      Before PLTE and IDAT
 gAMA    No      Before PLTE and IDAT
 sBIT    No      Before PLTE and IDAT
 bKGD    No      After PLTE; before IDAT
 hIST    No      After PLTE; before IDAT
 tRNS    No      After PLTE; before IDAT
 pHYs    No      Before IDAT
 tIME    No      None
 tEXt    Yes     None
 zTXt    Yes     None
 
 //extensions ftp://ftp.simplesystems.org/pub/libpng/png-group/documents/history/pngextensions.ps.gz
 oFFs    No      Before IDAT
 sCAL    No      Before IDAT
 gIFg    Yes     None
 gIFt    Yes     None
 gIFx    Yes     None
 fRAc    Yes     None
 */
enum PngChunkType: String {
    case IHDR
    case cHRM
    case gAMA
    case sBIT
    case PLTE
    case bKGD
    case hIST
    case tRNS
    case pHYs
    case IDAT
    case IEND
    case tIME
    case tEXt
    case zTXt
    
    //extensions
    case oFFs
    case sCAL
    case gIFg
    case gIFt
    case gIFx
    case fRAc
    
    case iCCP
    case iTXt
    case sPLT
    case sRGB
    
    init?(type: String?) {
        guard let type = type else {
            return nil
        }
        self.init(rawValue: type)
    }
}

// MARK: PngChunk
class PngChunk: ParsedNode {
    let offset: UInt64
    let len: UInt32  //equal to data.count  useless?
    let type: PngChunkType
    let data: Data
    let crc: Data
    init(offset: UInt64, len: UInt32, type: PngChunkType, data: Data, crc: Data) {
        self.offset = offset
        self.len = len
        self.type = type
        self.data = data
        self.crc = crc
    }
}

extension PngChunk: CustomStringConvertible {
    var description: String {
        return "offset: \(offset), data len: \(len), type: \(type.rawValue)\n"
    }
}

// MARK: Png
class Png: Parse {
    fileprivate func readChunkFromHandle(_ handle: FileHandle) throws -> PngChunk {
        let offset = handle.offsetInFile
        guard let len = handle.readData(ofLength: 4).netUInt32 else {
            throw ParseError.data("read chunk length")
        }
        let typeData = handle.readData(ofLength: 4)
        let type = String.init(data: typeData, encoding: .utf8)
        //TODO: if unknown type, suppose continue parse and show unsupported type
        guard let chunkType = PngChunkType.init(type: type) else {
            throw ParseError.data("read chunk type: \(type ?? "")")
        }
        
        let payloadData = handle.readData(ofLength: Int(len))
        guard payloadData.count == Int(len) else {
            throw ParseError.data("read chunk payload, expected: \(len) got: \(payloadData.count)")
        }
        let crcData = handle.readData(ofLength: 4)
        guard crcData.count == 4 else {
            throw ParseError.data("read chunk crc length")
        }
        //TODO: remove CryptoSwift?
        guard (typeData + payloadData).crc32(seed: nil) == crcData else {
            throw ParseError.data("crc, expected: \(crcData) got: \((typeData + payloadData).crc32(seed: nil))")
        }
        return PngChunk.init(offset: offset, len: len, type: chunkType, data: payloadData, crc: crcData)
    }
    
    override func process() throws {
        guard let handle = FileHandle.init(forReadingAtPath: path) else {
            throw ParseError.path
        }
        let size = handle.seekToEndOfFile()
        if size > Config.sharedInstance().maxSize {
            throw ParseError.size
        }
        
        handle.seek(toFileOffset: 0)
        let data = handle.readData(ofLength: 8)
        let headData = Data.init(bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        if data != headData {
            log.error("wrong file header:" + data.description)
            throw ParseError.format
        }
        delegate?.parse(self, didChangeState: .start)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            do {
                var chunks = [PngChunk]()
                while size != handle.offsetInFile {
                    let chunk = try strongSelf.readChunkFromHandle(handle)
                    chunks.append(chunk)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.parse(self!, didChangeState: .finish(chunks))
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.parse(self!, didChangeState: .fail(error))
                }
            }
        }
    }
}
