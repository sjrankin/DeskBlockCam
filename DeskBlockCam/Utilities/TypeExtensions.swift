//
//  Extensions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Extension to add Png data exports and writing of images to `NSImage`. Found on the internet but
/// forgot to save the link.
extension NSImage
{
    /// Returns the image data in the instance as a Png representation.
    var Png: Data?
    {
        guard let Tiff = tiffRepresentation,
            let BImage = NSBitmapImageRep(data: Tiff) else
        {
            return nil
        }
        return BImage.representation(using: .png, properties: [:])
    }
    
    /// Write the instance data to the path in `To` as a Png file.
    /// - Parameter To: The path where the image will be written.
    /// - Parameter Options: Data writing options. Defaults to `.atomic`.
    /// - Returns: True on success, false on failure.
    func Write(To: String, Options: Data.WritingOptions = .atomic) -> Bool
    {
        do
        {
            try Png?.write(to: URL(fileURLWithPath: To), options: Options)
            return true
        }
        catch
        {
            print("Error writing image to \(To): \(error)")
            return false
        }
    }
}

/// Extension to convert a path from NSBezierPath to a CGPath.
/// - Note: See [Convert NSBezierPath to cgPath](https://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath)
extension NSBezierPath
{
    /// Returns a `CGPath` equivalent based on the current path of the instance `NSBezierPath`.
    /// - Note: See [Convert NSBezierPath to cgPath](https://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath)
    var cgPath: CGPath
    {
        let Path = CGMutablePath()
        var Points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount
        {
            let Type = self.element(at: i, associatedPoints: &Points)
            switch Type
            {
                case .moveTo:
                    Path.move(to: Points[0])
                
                case .lineTo:
                    Path.addLine(to: Points[0])
                
                case .curveTo:
                    Path.addCurve(to: Points[2], control1: Points[0], control2: Points[1])
                
                case .closePath:
                    Path.closeSubpath()
                
                @unknown default:
                    break
            }
        }
        return Path
    }
}

extension CIImage
{
    /// Returns a `CGImage` version of the instance `CIImage`.
    var AsCGImage: CGImage?
    {
        let Context = CIContext(options: nil)
        return Context.createCGImage(self, from: self.extent)
    }
}

extension UInt8
{
    /// Returns the size of the instance `UInt8`
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the size of a `UInt8`.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt(0))
    }
}

extension NSColor
{
    /// Create an NSColor from the passed integer.
    /// - Parameter With: The integer value of the color.
    /// - Parameter ForceAlpha1: If true, alpha is forced to 1.0 in the final color. Otherwise, the
    ///                          value in `With` is used.
    static func MakeColor(With Value: Int, ForceAlpha1: Bool = true) -> NSColor
    {
        let Alpha = (Value & 0xff000000) >> 24
        let Red = (Value & 0x00ff0000) >> 16
        let Green = (Value & 0x0000ff00) >> 8
        let Blue = (Value * 0x000000ff)
        let Color = NSColor(red: CGFloat(Red) / 255.0, green: CGFloat(Green) / 255.0, blue: CGFloat(Blue) / 255.0,
                            alpha: ForceAlpha1 ? 1.0 : CGFloat(Alpha) / 255.0)
        return Color
    }
    
    /// Converts the passed color to an integer value.
    /// - Parameter Value: The color to convert.
    /// - Returns: Integer equivalent of the passed color.
    static func AsInt(_ Value: NSColor) -> Int
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Value.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let Final: Int = Int(Alpha * 255.0) << 24 +
            Int(Red * 255.0) << 16 +
            Int(Green * 255.0) << 8 +
            Int(Blue * 255.0)
        return Final
    }
    
    /// Given a color, return its name. If no name is known, return its hex value.
    /// - Parameter NameFor: The color whose name will be returned.
    /// - Returns: Name of the color if available, hex string of the value of the color if not.
    static func NameFor(Color: NSColor) -> String
    {
        switch NSColor.AsInt(Color)
        {
            case 0xff000000:
                return "Black"
            
            case 0xffffffff:
                return "White"
            
            case 0xffff0000:
                return "Red"
            
            case 0xff00ff00:
                return "Green"
            
            case 0xff0000ff:
                return "Blue"
            
            case 0xff00ffff:
                return "Cyan"
            
            case 0xffff00ff:
                return "Magenta"
            
            case 0xffffff00:
                return "Yellow"
            
            default:
                let Converted = String(NSColor.AsInt(Color), radix: 16, uppercase: false)
                return "0x\(Converted)"
        }
    }

    /// Returns a brightened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Brightened color.
    func Brighten(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = 1.0 + Percent
        Brightness = Brightness * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns a darkened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Darkened color.
    func Darken(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = Percent
        Brightness = Brightness * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }

    /// Returns the YUV equivalent of the instance color, in Y, U, V order.
    /// - See
    ///   - [YUV](https://en.wikipedia.org/wiki/YUV)
    ///   - [FourCC YUV to RGB Conversion](http://www.fourcc.org/fccyvrgb.php)
    var YUV: (Y: CGFloat, U: CGFloat, V: CGFloat)
    {
        get
        {
            let Wr: CGFloat = 0.299
            let Wg: CGFloat = 0.587
            let Wb: CGFloat = 0.114
            let Umax: CGFloat = 0.436
            let Vmax: CGFloat = 0.615
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Y = (Wr * Red) + (Wg * Green) + (Wb * Blue)
            let U = Umax * ((Blue - Y) / (1.0 - Wb))
            let V = Vmax * ((Red - Y) / (1.0 - Wr))
            return (Y, U, V)
        }
    }
    
    /// Returns the CMYK equivalent of the instance color, in C, M, Y, K order.
    var CMYK: (C: CGFloat, Y: CGFloat, M: CGFloat, K: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let K: CGFloat = 1.0 - max(Red, max(Green, Blue))
            var C: CGFloat = 0.0
            var M: CGFloat = 0.0
            var Y: CGFloat = 0.0
            if K == 1.0
            {
                C = 1.0
            }
            else
            {
                C = abs((1.0 - Red - K) / (1.0 - K))
            }
            if K == 1.0
            {
                M = 1.0
            }
            else
            {
                M = abs((1.0 - Green - K) / (1.0 - K))
            }
            if K == 1.0
            {
                Y = 1.0
            }
            else
            {
                Y = abs((1.0 - Blue - K) / (1.0 - K))
            }
            return (C, M, Y, K)
        }
    }
    
    /// Returns the CIE LAB equivalent of the instance color, in L, A, B order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var LAB: (L: CGFloat, A: CGFloat, B: CGFloat)
    {
        get
        {
            let (X, Y, Z) = self.XYZ
            var Xr = X / 111.144                //X referent is X10 incandescent/tungsten
            var Yr = Y / 100.0                  //Y referent is X10 incandescent/tungsten
            var Zr = Z / 35.2                   //Z referent is X10 incandescent/tungsten
            if Xr > 0.008856
            {
                Xr = pow(Xr, (1.0 / 3.0))
            }
            else
            {
                Xr = (7.787 * Xr) + (16.0 / 116.0)
            }
            if Yr > 0.008856
            {
                Yr = pow(Yr, (1.0 / 3.0))
            }
            else
            {
                Yr = (7.787 * Yr) + (16.0 / 116.0)
            }
            if Zr > 0.008856
            {
                Zr = pow(Zr, (1.0 / 3.0))
            }
            else
            {
                Zr = (7.787 * Zr) + (16.0 / 116.0)
            }
            let L = (Xr * 116.0) - 16.0
            let A = 500.0 * (Xr - Yr)
            let B = 200.0 * (Yr - Zr)
            return (L, A, B)
        }
    }
    
    /// Returns the XYZ equivalent of the instance color, in X, Y, Z order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var XYZ: (X: CGFloat, Y: CGFloat, Z: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            if Red > 0.04045
            {
                Red = pow(((Red + 0.055) / 1.055), 2.4)
            }
            else
            {
                Red = Red / 12.92
            }
            if Green > 0.04045
            {
                Green = pow(((Green + 0.055) / 1.055), 2.4)
            }
            else
            {
                Green = Green / 12.92
            }
            if Blue > 0.04045
            {
                Blue = pow(((Blue + 0.055) / 1.055), 2.4)
            }
            else
            {
                Blue = Blue / 12.92
            }
            Red = Red * 100.0
            Green = Green * 100.0
            Blue = Blue * 100.0
            let X = (Red * 0.4124) + (Green * 0.3576) * (Blue * 0.1805)
            let Y = (Red * 0.2126) + (Green * 0.7152) * (Blue * 0.0722)
            let Z = (Red * 0.0193) + (Green * 0.1192) * (Blue * 0.9505)
            return (X, Y, Z)
        }
    }
    
    /// Returns the HSL equivalent of the instance color, in H, S, L order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var HSL: (H: CGFloat, S: CGFloat, L: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Min = min(Red, Green, Blue)
            let Max = max(Red, Green, Blue)
            let Delta = Max - Min
            let L: CGFloat = (Max + Min) / 2.0
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            if Delta != 0.0
            {
                if L < 0.5
                {
                    S = Max / (Max + Min)
                }
                else
                {
                    S = Max / (2.0 - Max - Min)
                }
                let DeltaR = (((Max - Red) / 6.0) + (Max / 2.0)) / Max
                let DeltaG = (((Max - Green) / 6.0) + (Max / 2.0)) / Max
                let DeltaB = (((Max - Blue) / 6.0) + (Max / 2.0)) / Max
                if Red == Max
                {
                    H = DeltaB - DeltaG
                }
                else
                    if Green == Max
                    {
                        H = (1.0 / 3.0) + (DeltaR - DeltaB)
                    }
                    else
                        if Blue == Max
                        {
                            H = (2.0 / 3.0) + (DeltaG - DeltaR)
                }
                if H < 0.0
                {
                    H = H + 1.0
                }
                if H > 1.0
                {
                    H = H - 1.0
                }
            }
            return (H, S, L)
        }
    }
}


extension SCNNode
{
    /// Frees the memory of a node to be deleted by setting its geometry to nil. Also frees all
    /// child nodes as well.
    /// - Note: See [Removing SCNNode Does Not Free Memory](https://stackoverflow.com/questions/32997711/removing-scnnode-does-not-free-memory-before-creating-new-scnnode)
    func CleanUp()
    {
        for Child in childNodes
        {
            Child.CleanUp()
        }
        geometry = nil
    }
}

