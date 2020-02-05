//
//  ViewControllerWindow.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ViewControllerWindow: NSWindowController, NSWindowDelegate
{
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        let VC = window?.contentViewController as? ViewController
        VC?.WindowResized(To: frameSize) 
        return frameSize
    }
    
    func windowWillClose(_ notification: Notification)
    {
        let VC = window?.contentViewController as? ViewController
        VC?.WillClose() 
    }
}
