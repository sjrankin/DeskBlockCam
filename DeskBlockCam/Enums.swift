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
    case Greatest = "Greatest Channel"
    case Least = "Least Channel"
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
    case Video = "Video"
    /// Live view/snapshot.
    case Snapshot = "Snapshot"
    /// Still image (drag/drop or file operations).
    case StillImage = "StillImage"
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
