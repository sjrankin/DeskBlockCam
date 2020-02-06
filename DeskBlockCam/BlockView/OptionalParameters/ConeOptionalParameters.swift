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
}

enum ConeTopSizes: String, CaseIterable
{
    case Side = "Side value"
    case Saturation = "Saturation"
    case Hue = "Hue"
    case Side10 = "Side 10%"
    case Side50 = "Side 50%"
    case TenPercent = "10%"
    case FiftyPercent = "50%"
    case Zero = "Zero"
}

enum ConeBottomSizes: String, CaseIterable
{
    case Side = "Side value"
    case Saturation = "Saturation"
    case Hue = "Hue"
    case Side10 = "Side 10%"
    case Side50 = "Side 50%"
}
