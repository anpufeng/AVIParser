//
//  AppDelegate.swift
//  AVIParser
//
//  Created by ethan on 2018/8/30.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Cocoa
import XCGLogger

let log = XCGLogger.default

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let path = "/Users/33/Desktop/sdk_weibo_logo.png"
        let file = FileType.init(path: path)
        let parser = file?.parser(path: path)
        do {
            try parser?.read()
        } catch {
            log.error(error)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

