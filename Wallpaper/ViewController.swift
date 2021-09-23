//
//  ViewController.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        WADataManager.shared.setDesktopImage(URL(fileURLWithPath: Bundle.main.path(forResource: "001", ofType: "jpeg")!))
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

