//
//  CurrentCategory.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CurrentCategory
{
    var ValueItems: [ValueItem] = []
    
    var Name: String = ""
    var Icon: NSImage? = nil
    
    init(Name: String, Icon: NSImage? = nil, Values: [ValueItem])
    {
        self.Name = Name
        self.Icon = Icon
        ValueItems = Values
    }
}
