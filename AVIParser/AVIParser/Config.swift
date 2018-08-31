//
//  Config.swift
//  AVIParser
//
//  Created by ethan on 2018/8/31.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation

class Config {
    private static var instance: Config?
    static func sharedInstance() -> Config {
        if instance == nil {
            instance = Config()
        }
        return instance!
    }
    
    let maxSize = 1024*1024*100
    
}
