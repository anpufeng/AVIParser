//
//  Parse.swift
//  AVIParser
//
//  Created by ethan on 2018/8/31.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation


enum ParseError: Error {
    case wrongPath
    case wrongFormat
    case tooBig
    
}

enum ParseState {
    case ParseDidStart
    case ParseDidFinish
    case ParseDidEncounterError
}

protocol ParseProtocol {
    func read() throws 
}

protocol ParseDelegate {
    func parse(_ parse : ParseProtocol, didChangeState: ParseState)
}

class Parse {
    let path: String
    var delegate: ParseDelegate?
    
    
    init(path: String) {
        self.path = path
    }
    
    
}
