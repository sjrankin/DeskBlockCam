//
//  BlockOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BlockOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Blocks)
    }
    
    init(WithChamfer: CGFloat)
    {
        super.init(WithShape: .Blocks)
        _Chamfer = WithChamfer
    }
    
    private var _Chamfer: CGFloat = 0.0
    public var Chamfer: CGFloat
    {
        get
        {
            return _Chamfer
        }
        set
        {
            _Chamfer = newValue
        }
    }
}
