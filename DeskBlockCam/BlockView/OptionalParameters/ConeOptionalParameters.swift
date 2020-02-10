//
//  ConeOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ConeOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Cones)
        self.Read()
    }
    
    init(WithTopSize: ConeTopSizes, BottomSize: ConeBottomSizes, Swap: Bool)
    {
        super.init(WithShape: .Cones)
        _SwapTopAndBottom = Swap
        _ConeTopSize = WithTopSize
        _ConeBottomSize = BottomSize
    }
    
    private var _SwapTopAndBottom: Bool = false
    public var SwapTopAndBottom: Bool
    {
        get
        {
            return _SwapTopAndBottom
        }
        set
        {
            _SwapTopAndBottom = newValue
        }
    }
    
    private var _ConeTopSize: ConeTopSizes = .Zero
    public var ConeTopSize: ConeTopSizes
    {
        get
        {
            return _ConeTopSize
        }
        set
        {
            _ConeTopSize = newValue
        }
    }
    
    private var _ConeBottomSize: ConeBottomSizes = .Side
    public var ConeBottomSize: ConeBottomSizes
    {
        get
        {
            return _ConeBottomSize
        }
        set
        {
            _ConeBottomSize = newValue
        }
    }
    
    override public func Read()
    {
        _SwapTopAndBottom = Settings.GetBoolean(ForKey: .ConeSwapTopBottom)
        _ConeTopSize = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: ConeTopSizes.Zero)
        _ConeBottomSize = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: ConeBottomSizes.Side)
    }
    
    override public func Write()
    {
        Settings.SetBoolean(SwapTopAndBottom, ForKey: .ConeSwapTopBottom)
        Settings.SetEnum(ConeTopSize, EnumType: ConeTopSizes.self, ForKey: .ConeTopSize)
        Settings.SetEnum(ConeBottomSize, EnumType: ConeBottomSizes.self, ForKey: .ConeBottomSize)
    }
}

