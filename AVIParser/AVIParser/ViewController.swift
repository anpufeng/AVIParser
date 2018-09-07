//
//  ViewController.swift
//  AVIParser
//
//  Created by ethan on 2018/8/30.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var dragImgView: DragDropImageView!
    @IBOutlet weak var outlineScrollView: NSScrollView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var textScrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    var parsedNodes: [ParsedNode] = []
    var parser: Parse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        outlineView.delegate = self
        outlineView.dataSource = self
        dragImgView.isHidden = false
        outlineScrollView.isHidden = true
        textScrollView.isHidden = true
        
        dragImgView.didSelecedHandler = {[weak self] (filePath: String) -> () in
            let file = FileType.init(path: filePath)
            self?.parser = file?.parser(path: filePath)
            self?.parser?.delegate = self
            do {
                try self?.parser?.process()
            } catch {
                log.error(error)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: ParseDelegate {
    func parse(_ parse: Parse, didChangeState state: ParseState) {
        switch state {
        case .start:
            log.info("parse start")
        case .finish(let data):
            log.info("parse finish:\(data)")
            dragImgView.isHidden = true
            textScrollView.isHidden = false
            outlineScrollView.isHidden = false
            textView.isRulerVisible = true
            parsedNodes = data
            outlineView.reloadData()
            let url = URL.init(fileURLWithPath: parse.path)
            do {
                let fileData = try Data.init(contentsOf: url, options: .mappedIfSafe)
                var str = String.init(data: fileData, encoding: .ascii)
                str = fileData.toHexString()
                textView.textStorage?.insert(NSAttributedString.init(string: str ?? ""), at: 0)
            } catch {
                log.error("read file error: \(error), path: \(parse.path)")
            }
        case .fail(let err):
            log.error("parse error: \(err)")
            
        }
    }
}

// MARK: NSOutlineView DataSource
extension ViewController : NSOutlineViewDataSource {
    //item nil if root node
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        if  let item = item as? ParsedNode {
//            return item.children.count
//        }
        return parsedNodes.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        return item is ParsedNode
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        if let item = item as? ParsedNode {
//            return item.children[index]
//        }
        return parsedNodes[index]
    }
}

// MARK: NSOutlineViewDelegate
extension ViewController : NSOutlineViewDelegate{
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell : NSTableCellView?
        if item is ParsedNode {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! ParsedNode).description//(item as? ParsedNode)?.name ?? ""
        } else {
            log.info("==============")
//            cell = outlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
//            cell?.textField?.stringValue = (item as? LeafModel)?.leafName ?? ""
        }
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
}

