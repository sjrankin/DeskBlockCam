//
//  ProcessingAttributes.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains all data needed to create and display processed images.
class ProcessingAttributes
{
    /// Holds the shape of each 3D node.
    private var _Shape: Shapes = .Blocks
    /// Get or set the shape of each 3D node. Note the type of shape may be variable.
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
    
    /// Holds the vertical exaggeration of the extrusion/size.
    private var _VerticalExaggeration: VerticalExaggerations = .None
    /// Get or set the vertical exaggeration of each shape.
    public var VerticalExaggeration: VerticalExaggerations
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
    
    /// Holds the invert height flag.
    private var _InvertHeight: Bool = false
    /// Get or set the invert height of shape flag.
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
    
    /// Holds the length of one side of a 3D shape.
    private var _Side: CGFloat = 0.5
    /// Get or set the length of a side of the shape. This is the physical size for the
    /// shape when rendered.
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
    
    /// Holds the number of horizontal blocks for a given image.
    private var _HorizontalBlocks: Int = 0
    /// Get or set the number of horizontal blocks for the current image.
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
    
    /// Holds the number of vertical blocks for a given image.
    private var _VerticalBlocks: Int = 0
    /// Get or set the number of vertical blocks for the current image.
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
    
    /// Holds the generated colors for a given image.
    private var _Colors: [[NSColor]] = [[NSColor]]()
    /// Get or set the pixellated colors for the current image.
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
    
    /// Holds the method used to determine height of the shape.
    private var _HeightDeterminate: HeightDeterminations = .Brightness
    /// Get or set the method used to determine the height of the shape.
    public var HeightDeterminate: HeightDeterminations
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
    
    /// Holds an array of optional parameters.
    private var _ShapeOptions: [OptionalParameters]? = nil
    /// Get or set the set of optional parameters. Each shape that may be used within
    /// this set of attributes may have an optional parameter here. For example, a stacked
    /// shape consisting of several different shapes may have necessary optional parameters
    /// here, one for each shape that has optional parameters.
    public var ShapeOptions: [OptionalParameters]?
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
    
    /// Return any optional parameters for the main shape.
    /// - Returns: Optional parameters. Nil if none exists.
    func GetPrimaryOptions() -> OptionalParameters?
    {
        return GetOptionsFor(Shape)
    }
    
    /// Get optional parameters for the specified shape.
    /// - Note: Some shapes have sub-shapes. This function provides a method to return
    ///         optional parameters (if they exist) for the given sub-shapes.
    /// - Parameter Shape: The shape whose optional parameters (if any) are returned.
    /// - Returns: The optional parameters for the specified shape. Nil if none exists.
    func GetOptionsFor(_ Shape: Shapes) -> OptionalParameters?
    {
        if let Optionals = ShapeOptions
        {
            for Optional in Optionals
            {
                if Optional.ForShape == Shape
                {
                    return Optional
                }
            }
        }
        return nil
    }
    
    /// Holds the conditional color determination method.
    private var _ConditionalColor: ConditionalColorTypes = .None
    /// Get or set the conditional color determination.
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
    
    /// Holds the conditional color action.
    private var _ConditionalColorAction: ConditionalColorActions = .Grayscale
    /// Get or set the conditional color action.
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
    
    /// Holds the conditional color threshold.
    private var _ConditionalColorThreshold: ConditionalColorThresholds = .Less50
    /// Get or set the conditional color threshold
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
    
    /// Holds the invert conditional color threshold flag.
    private var _InvertConditionalColorThreshold: Bool = false
    /// Get or set the invert conditional color threshold flag.
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
    
    /// Holds the background style.
    private var _Background: Backgrounds = .Color
    /// Get or set the type of background to use.
    public var Background: Backgrounds
    {
        get
        {
            return _Background
        }
        set
        {
            _Background = newValue
        }
    }
    
    /// Holds the color of the background.
    private var _BackgroundColor: NSColor = NSColor.black
    /// Get or set the background color.
    public var BackgroundColor: NSColor
    {
        get
        {
            return _BackgroundColor
        }
        set
        {
            _BackgroundColor = newValue
        }
    }
    
    /// Holds the array of color for the background gradient.
    private var _BackgroundGradientColors: [NSColor] = [NSColor.white, NSColor.black]
    /// Get or set the array of background gradient colors.
    public var BackgroundGradientColors: [NSColor]
    {
        get
        {
            return _BackgroundGradientColors
        }
        set
        {
            _BackgroundGradientColors = newValue
        }
    }
    
    /// Holds the size of the pixellated region.
    private var _PixelSize: Int = 16
    /// Get or set the pixellated region size. Each pixellated region is square.
    public var PixelSize: Int
    {
        get
        {
            return _PixelSize
        }
        set
        {
            _PixelSize = newValue
        }
    }
    
    /// Holds the color of the light.
    private var _LightColor: NSColor = NSColor.white
    /// Get or set the color of the light.
    public var LightColor: NSColor
    {
        get
        {
            return _LightColor
        }
        set
        {
            _LightColor = newValue
        }
    }
    
    /// Holds the type of light for the scene.
    private var _LightType: LightingTypes = .Omni
    /// Get or set the light type for the scene.
    public var LightType: LightingTypes
    {
        get
        {
            return _LightType
        }
        set
        {
            _LightType = newValue
        }
    }
    
    /// Holds the relative intensity of the light.
    private var _LightIntensity: LightIntensities = .Normal
    /// Get or set the relative intensity of the light.
    public var LightIntensity: LightIntensities
    {
        get
        {
            return _LightIntensity
        }
        set
        {
            _LightIntensity = newValue
        }
    }
    
    /// Holds the lighting model.
    private var _LightModel: LightModels = .Phong
    /// Get or set the lighting model.
    public var LightModel: LightModels
    {
        get
        {
            return _LightModel
        }
        set
        {
            _LightModel = newValue
        }
    }
}

/// Shapes the program supports.
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
    
    //Special case for no shape.
    case NoShape = "NoShape"
}

/// Processed image background types.
enum Backgrounds: String, CaseIterable
{
    case Color = "Color"
    case Gradient = "Gradient"
    case Image = "Image"
}

/// Types of conditional colors.
enum ConditionalColorTypes: String, CaseIterable
{
    case None = "None"
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
}

/// Actions for conditional colors.
enum ConditionalColorActions: String, CaseIterable
{
    case Grayscale = "Grayscale"
    case IncreaseSaturation = "Increase Saturation"
    case DecreaseSaturation = "Decrease Saturation"
}

/// Action thresholds for conditional colors.
enum ConditionalColorThresholds: String, CaseIterable
{
    case Less10 = "10%"
    case Less25 = "25%"
    case Less50 = "50%"
    case Less75 = "75%"
    case Less90 = "90%"
}

/// Types of lights.
enum LightingTypes: String, CaseIterable
{
    case Omni = "Omni"
    case Spot = "Spot"
    case Directional = "Directional"
    case Ambient = "Ambient"
}

/// Light intensities.
enum LightIntensities: String, CaseIterable
{
    case Darkest = "Darkest"
    case Dim = "Dim"
    case Normal = "Normal"
    case Bright = "Bright"
    case Brightest = "Brightest"
}

/// Lighting material models.
enum LightModels: String, CaseIterable
{
    case Blinn = "Blinn"
    case Constant = "Constant"
    case Lambert = "Lambert"
    case Phong = "Phong"
    case Physical = "Physical"
}

enum BlockChamferSizes: String, CaseIterable
{
    case None = "None"
    case Small = "Small"
    case Medium = "Medium"
    case Heavy = "Heavy"
}

enum Orientations: String, CaseIterable
{
    case Horizontal = "Horizontal"
    case Vertical = "Vertical"
}

enum Distances: String, CaseIterable
{
    case Short = "Short"
    case Medium = "Medium"
    case Long = "Long"
}

enum CapLocations: String, CaseIterable
{
    case Top = "Top"
    case Middle = "Middle"
    case Bottom = "Bottom"
}

enum LineThickenesses: String, CaseIterable
{
    case Thin = "Thin"
    case Medium = "Medium"
    case Thick = "Thick"
}

enum CharacterSets: String, CaseIterable
{
    case Latin = "Latin"
    case Hiragana = "Hiragana"
    case Katakana = "Katakana"
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
