//
//  Parse.swift
//  AVIParser
//
//  Created by ethan on 2018/8/31.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation


enum ParseError: Error {
    case path
    case format
    case size
    case data(String)
}

enum ParseState {
    case start
    case finish([ParsedNode])
    case fail(Error)
}

protocol ParseDelegate {
    func parse(_ parse : Parse, didChangeState state: ParseState)
}

class Parse {
    let path: String
    let fileType: FileType?
    var delegate: ParseDelegate?
    
    
    init(path: String) {
        self.path = path
        self.fileType = FileType.init(path: path)
    }
    
    func process() throws {
        fatalError("overide me")
    }
}

class ParsedNode: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "ParsedNode"
    }
    
    var debugDescription: String {
        return "ParsedNode debug description"
    }
}
