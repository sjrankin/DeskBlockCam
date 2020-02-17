//
//  ColorDescription.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Describes a single color managed by the color manager.
class ColorDescription
{
    /// Initializer.
    /// - Parameter Name: Name of the color.
    /// - Parameter Value: Integer value of the color
    init(Name: String, Value: Int)
    {
        _Name = Name
        _Color = Colors.IntToColor(Value)
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter Source: The actual color source.
    init(Name: String, Source: NSColor)
    {
        _Name = Name
        _Color = Source
    }
    
    /// Holds the name of the color.
    private var _Name: String = "White"
    /// Get or set the name of the color.
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    /// Holds the value of the color.
    private var _Color: NSColor = NSColor.white
    /// Get or set the value of the color.
    public var Color: NSColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    /// Returns the value of the color as hex string.
    public func ValueAsString() -> String
    {
        return Colors.ColorToIntString(_Color, IncludeAlpha: false, Prefix: "0x")
    }
}
