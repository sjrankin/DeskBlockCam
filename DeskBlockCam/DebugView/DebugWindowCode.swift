//
//  DebugWindowCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebugWindowCode: NSWindowController, NSWindowDelegate
{
    weak var Delegate: AncillaryWindowProtocol? = nil
    
    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        Delegate?.ClosedAncillaryWindow(WindowName: "DebugWindow")
        return true
    }
    
    func AddStat(ForItem: StatRows, NewValue: String)
    {
        OperationQueue.main.addOperation
            {
                if let DebugController = self.contentViewController as? DebugControllerCode
                {
                    DebugController.AddStat(ForItem: ForItem, NewValue: NewValue)
                }
        }
    }
    
    func AddStats(_ List: [(StatRows, String)])
    {
        OperationQueue.main.addOperation
            {
                if let DebugController = self.contentViewController as? DebugControllerCode
                {
                    DebugController.AddStats(List)
                }
        }
    }
    
    func AddImage(Type: DebugImageTypes, _ Image: NSImage)
    {
        OperationQueue.main.addOperation
            {
        if let DebugController = self.contentViewController as? DebugControllerCode
        {
            DebugController.AddImage(Type: Type, Image)
        }
        }
    }
    
    func CloseWindow()
    {
        self.close()
    }
}
