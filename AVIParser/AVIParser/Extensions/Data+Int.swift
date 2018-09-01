//
//  DataExtensions.swift
//  AVIParser
//
//  Created by ethan on 2018/9/1.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation

extension Data {
    public var int32: Int32? {
        guard self.count == 4 else {
            return nil
        }
        
        return self.withUnsafeBytes {
            (pointer: UnsafePointer<Int32>) -> Int32 in
            return pointer.pointee
        }
    }
    
    public var netInt32: Int32? {
        guard let n = self.int32 else {
            return nil
        }
        
        return n.bigEndian
    }
    
    public var uint32: UInt32? {
        guard self.count == 4 else {
            return nil
        }
        
        return self.withUnsafeBytes {
            (pointer: UnsafePointer<UInt32>) -> UInt32 in
            return pointer.pointee
        }
    }
    
    public var netUInt32: UInt32? {
        guard let n = self.uint32 else {
            return nil
        }
        
        return n.bigEndian
    }
}

