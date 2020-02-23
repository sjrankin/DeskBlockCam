//
//  Enums.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

enum VerticalExaggerations: String, CaseIterable
{
    case None = "None"
    case Small = "Small"
    case Medium = "Medium"
    case Large = "Large"
}

enum HeightDeterminations: String, CaseIterable
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
    case GreatestRGB = "Greatest RGB Channel"
    case LeastRGB = "Least RGB Channel"
    case GreatestCMYK = "Greatest CMYK Channel"
    case LeastCMYK = "Least CMYK Channel"
}

enum HSBChannels: String, CaseIterable
{
    case HSB_Hue = "Hue"
    case HSB_Saturation = "Saturation"
    case HSB_Brightness = "Brightness"
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
    /// Flower shapes.
    case Flowers = "Flowers"
    /// Snowflake (or snow-related) shapes.
    case Snowflakes = "Snowflakes"
    /// Arrow shapes.
    case Arrows = "Arrows"
    /// Small geometric figures.
    case SmallGeometry = "Small Geometric Shapes"
    /// Star and sun shapes.
    case Stars = "Stars"
    /// Ornamental characters.
    case Ornamental = "Ornamental"
    /// Miscellaneous things.
    case Things = "Things"
    /// Comptuer-related shapes.
    case Computers = "Computer-Related"
    /// Hiragana characters.
    case Hiragana = "Hiragana"
    /// Katakana characters.
    case Katakana = "Katakana"
    /// Grade school kanji.
    case KyoikuKanji = "Grade School Kanji"//"Kyōiku Kanji"
    /// Hangul characters.
    case Hangul = "Hangul"
    /// Bodoni ornaments.
    case Bodoni = "Bodoni Ornaments"
    /// Latin characters.
    case Latin = "Latin Letters"
    /// Greek characters.
    case Greek = "Greek Letters"
    /// Cyrillic characters.
    case Cyrillic = "Cyrillic Letters"
    /// Emoji charactes.
    case Emoji = "Emoji"
    /// Punctuation marks.
    case Punctuation = "Punctuation"
    /// Symbols used to draw boxes.
    case BoxSymbols = "Box Symbols"
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

enum MainModes: String, CaseIterable
{
    case LiveView = "Live View"
    case ImageView = "Image View"
    case VideoView = "Video View"
}

/// Program modes for the main window.
enum ProgramModes: String, CaseIterable
{
    /// Video/live view.
    case LiveView = "Live View"
    /// Live view/snapshot.
    case VideoView = "Video View"
    /// Still image (drag/drop or file operations).
    case ImageView = "Image View"
}

/// Rows for stat table.
enum StatRows: Int, CaseIterable
{
    case CurrentFrame = 0
    case SkippedFrames = 1
    case CalculatedFramesPerSecond = 2
    case LastFrameDuration = 3
    case RollingMeanFrameDuration = 4
    case FrameDurationDelta = 5
    case DroppedFrames = 7
    case RenderedFrames = 8
    case RenderDuration = 9
    case ThrottleValue = 10
}

enum SphereBehaviors: String, CaseIterable
{
    case Size = "Size"
    case Height = "Height"
}

enum RingOrientations: String, CaseIterable
{
    case Rotated = "Rotated"
    case Flat = "Flat"
}

enum DonutHoleSizes: String, CaseIterable
{
    case Small = "Small"
    case Medium = "Medium"
    case Large = "Large"
}

enum BasicColors: String, CaseIterable
{
    case Black = "Black"
    case White = "White"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Gray = "Gray"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Orange = "Orange"
    case Indigo = "Indigo"
    case Purple = "Purple"
    case Brown = "Brown"
    case Yellow2 = "Yellow 2"
    case Orange2 = "Orange 2"
    case Brown2 = "Brown 2"
    case Teal = "Teal"
}

enum AntialiasingModes: String, CaseIterable
{
    case None = "None"
    case x2 = "2x"
    case x4 = "4x"
    case x8 = "8x"
    case x16 = "16x"
}

enum LetterSmoothnesses: String, CaseIterable
{
    case Smoothest = "Smoothest"
    case Smooth = "Smooth"
    case Medium = "Medium"
    case Rough = "Rough"
    case Roughest = "Roughest"
}
