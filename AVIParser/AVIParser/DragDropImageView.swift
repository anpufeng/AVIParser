//
//  DragDropImageView.swift
//  AVIParser
//
//  Created by ethan on 2018/9/1.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Cocoa

class DragDropImageView: NSImageView {
    var filePath: String?
    var didSelecedHandler: ((_ filePath: String) -> ())?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 3.0
        self.layer?.borderColor = NSColor.gray.cgColor
        self.layer?.borderWidth = 1.0
        
        //TODO: only 10.13 support, replace this 
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}


//MARK: drap drop protocol
extension DragDropImageView {
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) {
            self.layer?.backgroundColor = NSColor.gray.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    var fileNamesType: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard().propertyList(forType: fileNamesType) as? NSArray,
            let path = board[0] as? String else {
                return false
        }
        
        guard let _ = FileType.init(path: path) else {
            return false
        }
        
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
        guard let filePath = self.filePath else {
            return
        }
        self.didSelecedHandler?(filePath)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType:fileNamesType) as? NSArray,
            let path = pasteboard[0] as? String else {
                return false
        }
        
        self.filePath = path
        log.info("drag filePath: \(path)")
        return true
    }
    
}
