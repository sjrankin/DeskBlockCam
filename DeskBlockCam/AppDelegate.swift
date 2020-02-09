//
//  AppDelegate.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
        Settings.Initialize()
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }
    
    // Don't let orphan windows stop the app from terminating.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
}

