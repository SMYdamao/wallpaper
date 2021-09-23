//
//  WAEventMonitor.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa

class WAEventMonitor: NSObject {
    private var mask: NSEvent.EventTypeMask!
    private var handler: ((NSEvent)->(Void))!
    private var monitor: Any?
    
    init(_ mask: NSEvent.EventTypeMask, _ handler: @escaping ((NSEvent?)->(Void))) {
        super.init()
        self.mask = mask
        self.handler = handler
    }
    
    func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: self.handler)
    }
    
    func stop() {
        if let m = self.monitor {
            NSEvent.removeMonitor(m)
            self.monitor = nil
        }
    }
}
