//
//  File.swift
//  AVIParser
//
//  Created by ethan on 2018/8/30.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation

enum FileType: String {
    case mp4
    case flv
    case avi
    case mov
    case mkv
    case jpeg
    case jpg
    case png
    case gif
    case mp3
    case aac
    
    init?(path: String) {
        let ext = (path as NSString).pathExtension.lowercased()
        self.init(rawValue: ext)
    }
    
    func parser(path: String) -> Parse {
        switch self {
        case .mp4:
            return Mp4.init(path: path)
        case .png:
            return Png.init(path: path)
        default:
            return Png.init(path: path)
        }
        
    }
}

