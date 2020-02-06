//
//  RadiatingLinesOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RadiatingLinesOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .RadiatingLines)
    }
    
    init(LineCount: Int, Thickness: LineThickenesses)
    {
        super.init(WithShape: .RadiatingLines)
        _LineCount = LineCount
        _Thickness = Thickness
    }
    
    private var _LineCount: Int = 4
    public var LineCount: Int
    {
        get
        {
            return _LineCount
        }
        set
        {
            _LineCount = newValue
        }
    }
    
    private var _Thickness: LineThickenesses = .Thin
    public var Thickness: LineThickenesses
    {
        get
        {
            return _Thickness
        }
        set
        {
            _Thickness = newValue
        }
    }
}

enum LineThickenesses: String, CaseIterable
{
    case Thin = "Thin"
    case Medium = "Medium"
    case Thick = "Thick"
}
