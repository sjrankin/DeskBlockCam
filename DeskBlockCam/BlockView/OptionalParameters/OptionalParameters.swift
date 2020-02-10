//
//  OptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class OptionalParameters
{
    init(WithShape: Shapes)
    {
        _ForShape = WithShape
    }
    
    private var _ForShape: Shapes = .Blocks
    public var ForShape: Shapes
    {
        get
        {
            return _ForShape
        }
    }
    
    public func Write()
    {
    }
    
    public func Read()
    {
    }
}
