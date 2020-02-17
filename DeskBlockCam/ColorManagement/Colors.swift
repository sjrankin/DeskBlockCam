//
//  Colors.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Manages colors.
class Colors
{
    /// Initialize the class.
    public static func Initialize()
    {
    }
    
    /// Convert an integer into a color.
    /// - Parameter Value: The integer to convert to a color. Assumes the value is 32 bits in size
    ///                    in AARRGGBB format.
    /// - Returns: NSColor equivalent of the passed integer.
    public static func IntToColor(_ Value: Int) -> NSColor
    {
        let Alpha = (Value & 0xff000000) >> 24
        let Red = (Value & 0x00ff0000) >> 16
        let Green = (Value & 0x0000ff00) >> 8
        let Blue = (Value & 0x000000ff)
        return NSColor(calibratedRed: CGFloat(Red) / 255.0,
                       green: CGFloat(Green) / 255.0,
                       blue: CGFloat(Blue) / 255.0,
                       alpha: CGFloat(Alpha) / 255.0)
    }
    
    /// Convert an integer into a color.
    /// - Parameter Value: The integer to convert to a color. Assumes the value is 24 bits in size
    ///                    in RRGGBB format. Alpha is set to 1.0.
    /// - Returns: NSColor equivalent of the passed integer.
    public static func IntToColor24(_ Value: Int) -> NSColor
    {
        let Red = (Value & 0xff0000) >> 16
        let Green = (Value & 0x00ff00) >> 8
        let Blue = (Value & 0x0000ff)
        return NSColor(calibratedRed: CGFloat(Red) / 255.0,
                       green: CGFloat(Green) / 255.0,
                       blue: CGFloat(Blue) / 255.0,
                       alpha: 1.0)
    }
    
    /// Converts a hex string (presumably holding a color value) into a color.
    /// - Parameter HexString: The string to convert. The prefixes `0x` and `#` are removed.
    /// - Returns: The color based on the passed hex string.
    public static func HexToColor(_ HexString: String) -> NSColor
    {
        var Working = HexString.uppercased()
        if Working.starts(with: "0X")
        {
            Working.removeFirst(2)
        }
        if Working.starts(with: "#")
        {
            Working.removeFirst(1)
        }
        if Working.count != 6 && Working.count != 8
        {
            fatalError("Bad hex string: \(HexString)")
        }
        let IntVal = Int(Working, radix: 16) ?? 0
        return IntToColor(IntVal)
    }
    
    /// Given a color name, return the equivalent color. Names must match exactly.
    /// - Parameter Name: The name of the color to return. Must match exactly.
    /// - Returns: The color associated with the passed name on success, nil if not found.
    public static func Color(Name: String) -> NSColor?
    {
        for SomeColor in Table
        {
            if SomeColor.Name == Name
            {
                return SomeColor.Color
            }
        }
        return nil
    }
    
    /// Given a color name, return the equivalent color. Names must match exactly.
    /// - Parameter Name: The name of the color to return. Must match exactly.
    /// - Parameter Default: The color to return if the requested color was not found.
    /// - Returns: The color name associated with the passed name on success, the default value
    ///            if not found.
    public static func Color(Name: String, Default: NSColor) -> NSColor
    {
        for SomeColor in Table
        {
            if SomeColor.Name == Name
            {
                return SomeColor.Color
            }
        }
        return Default
    }
    
    /// Given a standard color, return the actual color.
    /// - Parameter For: The standard color to return.
    /// - Returns: The color associated with the passed standard color on success, nil if not found.
    public static func Color(For: StandardColors) -> NSColor?
    {
        return Color(Name: For.rawValue)
    }
    
    /// Return the name of the passed color.
    /// - Parameter Color: The color whose name will be returned.
    /// - Returns: The name of the color if found, value of the color as a string if not found.
    public static func NameFor(_ Color: NSColor) -> String
    {
        if let Record = ColorRecord(For: Color)
        {
            return Record.Name
        }
        return ColorToIntString(Color)
    }
    
    /// Returns the color record/description for the passed color.
    /// - Parameter For: The color whose description will be returned.
    /// - Returns: The color description for the passed color if found, nil if not.
    public static func ColorRecord(For Color: NSColor) -> ColorDescription?
    {
        for SomeColor in Table
        {
            if SomeColor.Color == Color
            {
                return SomeColor
            }
        }
        return nil
    }
    
    /// Converts the value of the color to a hex string.
    /// - Parameter Color: The color whose value will be converted and returned.
    /// - Parameter IncludeAlpha: If true, the alpha component will be returned. Default is false.
    /// - Parameter Prefix: String to use as prefix of the value. Defaults to "0x".
    /// - Returns: String value of the contents of the color.
    public static func ColorToIntString(_ Color: NSColor, IncludeAlpha: Bool = false, Prefix: String = "0x") -> String
    {
        let ColorInt = ColorToInt(Color)
        let ColorIntString = Prefix + String(ColorInt, radix: 16, uppercase: false)
        return ColorIntString
    }
    
    /// Converts the passed color to an integer value.
    /// - Parameter Color: The color whose value will be returned.
    /// - Parameter IncludeAlpha: If true, the alpha component is returned. Defaults to false.
    /// - Returns: The integer value of the passed color.
    public static func ColorToInt(_ Color: NSColor, IncludeAlpha: Bool = false) -> Int
    {
        var Alpha: CGFloat = 0.0
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        Color.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let iAlpha = Int(Alpha * 255.0)
        let iRed = Int(Red * 255.0)
        let iGreen = Int(Green * 255.0)
        let iBlue = Int(Blue * 255.0)
        var Final: Int = 0
        if IncludeAlpha
        {
            Final = iAlpha << 24
        }
        Final = Final | iRed << 16
        Final = Final | iGreen << 8
        Final = Final | iBlue
        return Final
    }
    
    /// Holds all colors directly managed.
    public static var Table: [ColorDescription] =
        [
            ColorDescription(Name: "Black", Source: NSColor.black),
            ColorDescription(Name: "White", Source: NSColor.white),
            ColorDescription(Name: "Red", Source: NSColor.red),
            ColorDescription(Name: "Green", Source: NSColor.green),
            ColorDescription(Name: "Blue", Source: NSColor.blue),
            ColorDescription(Name: "Cyan", Source: NSColor.cyan),
            ColorDescription(Name: "Magenta", Source: NSColor.magenta),
            ColorDescription(Name: "Yellow", Source: NSColor.yellow),
            ColorDescription(Name: "Orange", Source: NSColor.orange),
            ColorDescription(Name: "Gray", Source: NSColor.gray)
    ]
}

/// Standard colors known by the color manager.
enum StandardColors: String, CaseIterable
{
    case Black = "Black"
    case White = "White"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Orange = "Orange"
    case Gray = "Gray"
}
