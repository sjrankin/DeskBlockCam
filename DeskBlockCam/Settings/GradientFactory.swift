//
//  GradientFactory.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Methods to create gradient layers.
class GradientFactory
{
    /// Create a vertical gradient layer out of two colors.
    /// - Parameter Color1: First color. At the top of the gradient.
    /// - Parameter Color2: Second color. At the bottom of the gradient.
    /// - Parameter Size: Size of the gradient.
    /// - Returns: Gradient layer created from the passed colors.
    public static func CreateGradient(_ Color1: NSColor, _ Color2: NSColor, Size: NSSize) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.bounds = CGRect(x: 0, y: 0, width: Size.width, height: Size.height)
        Layer.colors = [Color1.cgColor, Color2.cgColor]
        Layer.transform = CATransform3DMakeRotation(180.0 * CGFloat.pi / 180.0, 0, 0, 1)
        return Layer
    }
    
    /// Create a vertical gradient layer from the list of colors and locations.
    /// - Parameter Colors: Array of colors and their associated locations in the gradient.
    /// - Parameter Size: Size of the gradient.
    /// - Returns: Gradient layer created from the passed set of colors.
    public static func CreateGradient(_ Colors: [(Color: NSColor, Location: Double)], Size: NSSize) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.bounds = CGRect(x: 0, y: 0, width: Size.width, height: Size.height)
        var LocationList = [NSNumber]()
        var ColorList = [CGColor]()
        for (Color, Location) in Colors
        {
            ColorList.append(Color.cgColor)
            LocationList.append(NSNumber(value: Location))
        }
        Layer.locations = LocationList
        Layer.colors = ColorList
        Layer.transform = CATransform3DMakeRotation(180.0 * CGFloat.pi / 180.0, 0, 0, 1)
        return Layer
    }
}
