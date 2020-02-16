//
//  CurrentTreeNode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CurrentTreeNode 
{
    var Category: String!
    var Shapes: [String]!
    
    init(Category: String, Shapes: [String])
    {
        self.Category = Category
        self.Shapes = Shapes
    }
}
