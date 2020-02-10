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
    
    init(WithChamfer: BlockChamferSizes)
    {
        super.init(WithShape: .Blocks)
        _Chamfer = WithChamfer
    }
    
    private var _Chamfer: BlockChamferSizes = .None
    public var Chamfer: BlockChamferSizes
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
    
    public static func ChamferSize(From: BlockChamferSizes) -> CGFloat
    {
        switch From
        {
            case .None:
                return 0.0
            
            case .Small:
                return 0.01
            
            case .Medium:
                return 0.1
            
            case .Heavy:
                return 0.4
        }
    }
}
