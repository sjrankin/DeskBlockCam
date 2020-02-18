//
//  Open.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController
{
    /// Returns the URL of a file. This is the file the user wants to open.
    /// - Returns: URL of where to save the file. Nil if the user canceled.
    func GetImageFileToOpen() -> URL?
    {
        let OpenPanel = NSOpenPanel()
        OpenPanel.showsTagField = false
        OpenPanel.title = "Open Image"
        OpenPanel.allowsMultipleSelection = false
        OpenPanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
        OpenPanel.canCreateDirectories = false
        OpenPanel.nameFieldStringValue = ""
        OpenPanel.level = .modalPanel
        if OpenPanel.runModal() == .OK
        {
            return OpenPanel.url
        }
        else
        {
            return nil
        }
    }
}

