//
//  ValueItem.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ValueItem
{
    var Description: String = ""
    var Value: String = ""
    var Icon: NSImage? = nil
    var TextColor: NSColor = NSColor.black
    
    init(Description: String, Value: String, Icon: NSImage?)
    {
        self.Description = Description
        self.Value = Value
        self.Icon = Icon
    }
    
    init(Description: String, Value: String)
    {
        self.Description = Description
        self.Value = Value
        self.Icon = nil
    }
    
    init(Description: String, Value: String, Color: NSColor)
    {
        self.Description = Description
        self.Value = Value
        self.Icon = nil
        self.TextColor = Color
    }
}
