//
//  Save.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController
{
    /// Returns the URL of a file. This is where the user wants to save an image.
    /// - Returns: URL of where to save the file. Nil if the user canceled.
    func GetSaveImageLocation() -> URL?
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = false
        SavePanel.title = "Save Image"
        SavePanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
        SavePanel.canCreateDirectories = true
        SavePanel.nameFieldStringValue = "BlockCamImage.png"
        SavePanel.level = .modalPanel
        if SavePanel.runModal() == .OK
        {
            return SavePanel.url
        }
        else
        {
            return nil
        }
    }
}

