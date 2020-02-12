//
//  DebugUIHandling.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController
{
    /// Open the debug window.
    func OpenDebug()
    {
        let Storyboard = NSStoryboard(name: "DebugWindow", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "DebugWindowID") as? DebugWindowCode
        {
            WindowController.showWindow(nil)
            WindowController.Delegate = self
            DebugWindow = WindowController
        }
    }
    
    func AddStat(ForItem: StatRows, NewValue: String)
    {
        if let DebugSink = DebugWindow
        {
            DebugSink.AddStat(ForItem: ForItem, NewValue: NewValue)
        }
    }
    
    func AddStats(_ List: [(StatRows, String)]) 
    {
        if let DebugSink = DebugWindow
        {
            DebugSink.AddStats(List)
        }
    }
    
    func AddImage(Type: DebugImageTypes, _ Image: NSImage)
    {
        if let DebugSink = DebugWindow
        {
            DebugSink.AddImage(Type: Type, Image)
        }
    }
}

enum DebugImageTypes: String, CaseIterable
{
    case Original = "Original"
    case Snapshot = "Snapshot"
    case Pixellated = "Pixellated"
    case Histogram = "Histogram"
}
