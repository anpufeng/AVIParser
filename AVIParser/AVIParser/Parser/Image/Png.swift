//
//  Png.swift
//  AVIParser
//
//  Created by ethan on 2018/8/30.
//  Copyright © 2018年 ethan. All rights reserved.
//

/* reference:  https://tools.ietf.org/html/rfc2083 */

import Foundation

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
    
    init?(type: String?) {
        guard let type = type else {
            return nil
        }
        self.init(rawValue: type)
    }
}

class PngChunk {
    let length: Int32
    let type: PngChunkType
    let data: Data
    let crc: Int32
    init(length: Int32, type: PngChunkType, data: Data, crc: Int32) {
        self.length = length
        self.type = type
        self.data = data
        self.crc = crc
    }
}

class Png: Parse, ParseProtocol {
    func read() throws {
        guard let handle = FileHandle.init(forReadingAtPath: self.path) else {
            throw ParseError.wrongPath
        }
        if handle.seekToEndOfFile() > Config.sharedInstance().maxSize {
            throw ParseError.tooBig
        }
        
        handle.seek(toFileOffset: 0)
        let data = handle.readData(ofLength: 8)
        let headData = Data.init(bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        if data != headData {
            log.error("wrong file header:" + data.description)
            throw ParseError.wrongFormat
        }
        self.delegate?.parse(self, didChangeState: .ParseDidStart)
        DispatchQueue.global(qos: .userInitiated).async {
            //do png parse stuff
            func readOneChunk() throws {
                let lenData = handle.readData(ofLength: 4)
                guard lenData.count == 4 else {
                    throw ParseError.wrongFormat
                }
                let typeData = handle.readData(ofLength: 4)
                guard lenData.count == 4 else {
                    throw ParseError.wrongFormat
                }
                guard let chunkType = PngChunkType.init(type: String.init(data: typeData, encoding: .utf8)) else {
                    throw ParseError.wrongFormat
                }
                let len: Int32 = lenData.withUnsafeBytes {
                    (pointer: UnsafePointer<Int32>) -> Int32 in
                    return pointer.pointee
                }
                let payloadData = handle.readData(ofLength: Int(len))
                guard payloadData.count == Int(len) else {
                    throw ParseError.wrongFormat
                }
                let crcData = handle.readData(ofLength: 4)
                guard crcData.count == 4 else {
                    throw ParseError.wrongFormat
                }
                let crc: Int32 = crcData.withUnsafeBytes {
                    (pointer: UnsafePointer<Int32>) -> Int32 in
                    return pointer.pointee
                }
                let chunk = PngChunk.init(length: len, type: chunkType, data: payloadData, crc: crc)
            }
            
            do {
                try readOneChunk()
            } catch {
                log.error("parse error\(error)")
            }
        
//            DispatchQueue.main.async { [self self] in
//                self?.delegate?.parseState(_parser: self, _state: .ParseDidFinish)
//            }
        }
    }
}
