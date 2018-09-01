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
    var parser: Parse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dragImgView.didSelecedHandler = {[weak self] (filePath: String) -> () in
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
        case .fail(let err):
            log.error("parse error: \(err)")
            
        }
    }
}
