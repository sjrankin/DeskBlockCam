//
//  ProcessingAttributes.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ProcessingAttributes
{
    private var _Shape: Shapes = .Blocks
    public var Shape: Shapes
    {
        get
        {
            return _Shape
        }
        set
        {
            _Shape = newValue
        }
    }
    
    private var _VerticalExaggeration: CGFloat = 1.0
    public var VerticalExaggeration: CGFloat
    {
        get
        {
            return _VerticalExaggeration
        }
        set
        {
            _VerticalExaggeration = newValue
        }
    }
    
    private var _InvertHeight: Bool = false
    public var InvertHeight: Bool
    {
        get
        {
            return _InvertHeight
        }
        set
        {
            _InvertHeight = newValue
        }
    }
    
    private var _Side: CGFloat = 0.5
    public var Side: CGFloat
    {
        get
        {
            return _Side
        }
        set
        {
            _Side = newValue
        }
    }
    
    private var _HorizontalBlocks: Int = 0
    public var HorizontalBlocks: Int
    {
        get
        {
            return _HorizontalBlocks
        }
        set
        {
            _HorizontalBlocks = newValue
        }
    }
    
    private var _VerticalBlocks: Int = 0
    public var VerticalBlocks: Int
    {
        get
        {
            return _VerticalBlocks
        }
        set
        {
            _VerticalBlocks = newValue
        }
    }
    
    private var _Colors: [[NSColor]] = [[NSColor]]()
    public var Colors: [[NSColor]]
    {
        get
        {
            return _Colors
        }
        set
        {
            _Colors = newValue
        }
    }
    
    private var _HeightDeterminate: HeightDeterminates = .Brightness
    public var HeightDeterminate: HeightDeterminates
    {
        get
        {
            return _HeightDeterminate
        }
        set
        {
            _HeightDeterminate = newValue
        }
    }
    
    private var _ShapeOptions: OptionalParameters? = nil
    public var ShapeOptions: OptionalParameters?
    {
        get
        {
            return _ShapeOptions
        }
        set
        {
            _ShapeOptions = newValue
        }
    }
    
    private var _ConditionalColor: ConditionalColorTypes = .None
    public var ConditionalColor: ConditionalColorTypes
    {
        get
        {
            return _ConditionalColor
        }
        set
        {
            _ConditionalColor = newValue
        }
    }
    
    private var _ConditionalColorAction: ConditionalColorActions = .Grayscale
    public var ConditionalColorAction: ConditionalColorActions
    {
        get
        {
            return _ConditionalColorAction
        }
        set
        {
            _ConditionalColorAction = newValue
        }
    }
    
    private var _ConditionalColorThreshold: ConditionalColorThresholds = .Less50
    public var ConditionalColorThreshold: ConditionalColorThresholds
    {
        get
        {
            return _ConditionalColorThreshold
        }
        set
        {
            _ConditionalColorThreshold = newValue
        }
    }
    
    private var _InvertConditionalColorThreshold: Bool = false
    public var InvertConditionalColorThreshold: Bool
    {
        get
        {
            return _InvertConditionalColorThreshold
        }
        set
        {
            _InvertConditionalColorThreshold = newValue
        }
    }
}

enum Shapes: String, CaseIterable
{
    //Built-in 3D shapes.
    case Blocks = "Blocks"
    case Spheres = "Spheres"
    case Cones = "Cones"
    case Rings = "Rings"
    case Tubes = "Tubes"
    case Cylinders = "Cylinders"
    case Pyramids = "Pyramids"
    
    //Non-standard extruded shapes.
    case Triangles = "Triangles"
    case Pentagons = "Pentagons"
    case Hexagons = "Hexagons"
    case Octagons = "Octagons"
    case Stars = "Stars"
    case Diamonds = "Diamonds"
    case Ovals = "Ovals"
    
    //Built-in or slightly modified 3D shapes as 2D shapes.
    case Squares = "Squares"
    case Circles = "Circles"
    case Triangles2D = "2D Triangles"
    case Pentagons2D = "2D Pentagons"
    case Hexagons2D = "2D Hexagons"
    case Octagons2D = "2D Octagons"
    case Stars2D = "2D Stars"
    
    //Combined shapes.
    case CappedLines = "Capped Lines"
    case StackedShapes = "Stacked Shapes"
    case PerpendicularSquares = "Perpendicular Squares"
    case PerpendicularCircles = "Perpendicular Circles"
    case HueVarying = "Hue Varying"
    case SaturationVarying = "Saturation Varying"
    case BrightnessVarying = "Brightness Varying"
    
    //Complex shapes.
    case HueTriangles = "Hue Triangles"
    case Characters = "Characters"
    case RadiatingLines = "Radiating Lines"
}

enum HeightDeterminates: String, CaseIterable
{
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Black = "Black"
    case YUV_Y = "YUV Y"
    case YUV_U = "YUV U"
    case YUV_V = "YUV V"
}

enum ConditionalColorTypes: String, CaseIterable
{
    case None = "None"
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
}

enum ConditionalColorActions: String, CaseIterable
{
    case Grayscale = "Grayscale"
    case IncreaseSaturation = "Increase Saturation"
    case DecreaseSaturation = "Decrease Saturation"
}

enum ConditionalColorThresholds: String, CaseIterable
{
    case Less10 = "10%"
    case Less25 = "25%"
    case Less50 = "50%"
    case Less75 = "75%"
    case Less90 = "90%"
}
