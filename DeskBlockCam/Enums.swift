//
//  Enums.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Exaggerations for vertical height/shape sizes. Actual values are determined at run-time.
enum VerticalExaggerations: String, CaseIterable
{
    /// No exaggeration.
    case None = "None"
    /// Small exaggeration.
    case Small = "Small"
    /// Medium exaggeration.
    case Medium = "Medium"
    /// Large exaggeration.
    case Large = "Large"
}

/// The color component used to determine the height/size of the shape. All values are normalized
/// before being returned.
enum HeightDeterminations: String, CaseIterable
{
    /// The hue of the color.
    case Hue = "Hue"
    /// The saturation of the color.
    case Saturation = "Saturation"
    /// The brightness of the color.
    case Brightness = "Brightness"
    /// The red channel value of the color.
    case Red = "Red"
    /// The green channel value of the color.
    case Green = "Green"
    /// The blue channel value of the color.
    case Blue = "Blue"
    /// The synthesized cyan channel value of the color.
    case Cyan = "Cyan"
    /// The synthesized magenta channel value of the color.
    case Magenta = "Magenta"
    /// The synthesized yellow channel value of the color.
    case Yellow = "Yellow"
    /// The synthesized black channel value of the color.
    case Black = "Black"
    /// The synthesized Y channel value of the color.
    case YUV_Y = "YUV Y"
    /// The synthesized U channel value of the color.
    case YUV_U = "YUV U"
    /// The synthesized V channel value of the color.
    case YUV_V = "YUV V"
    /// The RGB channel with the greatest value.
    case GreatestRGB = "Greatest RGB Channel"
    /// The RGB channel with the least value.
    case LeastRGB = "Least RGB Channel"
    /// The synthesized CMYK channel with the greatest value.
    case GreatestCMYK = "Greatest CMYK Channel"
    /// The synthesized CMYK channel with the least value.
    case LeastCMYK = "Least CMYK Channel"
}

/// HSB channels.
enum HSBChannels: String, CaseIterable
{
    /// Hue.
    case HSB_Hue = "Hue"
    /// Saturation.
    case HSB_Saturation = "Saturation"
    /// Brightness.
    case HSB_Brightness = "Brightness"
}

/// Processed image background types.
enum Backgrounds: String, CaseIterable
{
    /// Solid color background.
    case Color = "Color"
    /// Two-color gradient background.
    case Gradient = "Gradient"
    /// Source image background.
    case Image = "Image"
}

/// Types of conditional colors.
enum ConditionalColorTypes: String, CaseIterable
{
    /// No conditional colors.
    case None = "None"
    /// Conditional colors based on the hue.
    case Hue = "Hue"
    /// Conditional colors base on the saturation.
    case Saturation = "Saturation"
    /// Conditional colors based on the brightness.
    case Brightness = "Brightness"
}

/// Actions for conditional colors.
enum ConditionalColorActions: String, CaseIterable
{
    /// Convert the color to grayscale.
    case Grayscale = "Grayscale"
    /// Increase the saturation of the color.
    case IncreaseSaturation = "Increase Saturation"
    /// Decrease the saturation of the color.
    case DecreaseSaturation = "Decrease Saturation"
}

/// Action thresholds for conditional colors. If the user sets an appropriate setting, the threshold
/// values here are inverted.
enum ConditionalColorThresholds: String, CaseIterable
{
    /// Take action if less than 10%.
    case Less10 = "10%"
    /// Take action if less than 25%.
    case Less25 = "25%"
    /// Take action if less than 50%.
    case Less50 = "50%"
    /// Take action if less than 75%.
    case Less75 = "75%"
    /// Take action if less than 90%.
    case Less90 = "90%"
}

/// Types of lights.
enum LightingTypes: String, CaseIterable
{
    /// Omni light.
    case Omni = "Omni"
    /// Spot light.
    case Spot = "Spot"
    /// Directional light.
    case Directional = "Directional"
    /// Ambient light.
    case Ambient = "Ambient"
}

/// Light intensities.
enum LightIntensities: String, CaseIterable
{
    /// Really dark.
    case Darkest = "Darkest"
    /// Dark.
    case Dim = "Dim"
    /// Normal intensity.
    case Normal = "Normal"
    /// Bright.
    case Bright = "Bright"
    /// Greatest intensity.
    case Brightest = "Brightest"
}

/// Lighting material models.
enum LightModels: String, CaseIterable
{
    /// Blinn material lighting.
    case Blinn = "Blinn"
    /// Constant material lighting.
    case Constant = "Constant"
    /// Lambert material lighting.
    case Lambert = "Lambert"
    /// Phong material lighting.
    case Phong = "Phong"
    /// Physical material lighting.
    case Physical = "Physical"
}

/// Chamfer sizes for blocks. Actual value determined at run-time. Using chamfer for blocks has a
/// negative performance impact.
enum BlockChamferSizes: String, CaseIterable
{
    /// No chamfer.
    case None = "None"
    /// Small chamfer value.
    case Small = "Small"
    /// Medium chamfer value.
    case Medium = "Medium"
    /// Heavy chamfer value.
    case Heavy = "Heavy"
}

/// General orientations.
enum Orientations: String, CaseIterable
{
    /// Horizontal orientation.
    case Horizontal = "Horizontal"
    /// Vertical orientation.
    case Vertical = "Vertical"
}

/// Distances/lengths used for some shapes. Actual lengths are determined at run-time.
enum Distances: String, CaseIterable
{
    /// Short length.
    case Short = "Short"
    /// Medium length.
    case Medium = "Medium"
    /// Long length.
    case Long = "Long"
}

/// Capped-line cap shape locations. The actual location will vary depending on how the height of
/// the shape is determined.
enum CapLocations: String, CaseIterable
{
    /// Shape is at the top of the line.
    case Top = "Top"
    /// Shape is in the middle of the line.
    case Middle = "Middle"
    /// Shape is at the bottom of the line.
    case Bottom = "Bottom"
}

/// Line thicknesses for shapes that use lines. Line thicknesses determined at run-time.
enum LineThicknesses: String, CaseIterable
{
    /// Thin lines.
    case Thin = "Thin"
    /// Medium lines.
    case Medium = "Medium"
    /// Thick lines.
    case Thick = "Thick"
}

/// Character sets from which random characters are selected. Sets of characters are defined
/// in the `ShapeManager` class.
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

/// Sizes for the top of cone shapes.
enum ConeTopSizes: String, CaseIterable
{
    /// The top of the cone is the same as the side value.
    case Side = "Side value"
    /// The top of the cone is based on the saturation of the color.
    case Saturation = "Saturation"
    /// The top of the cone is based on the hue of the color.
    case Hue = "Hue"
    /// The top of the cone is 10% of the side value.
    case Side10 = "Side 10%"
    /// The top of the cone is 50% of the side value.
    case Side50 = "Side 50%"
    /// The top of the cone is 10% of the bottom of the cone.
    case TenPercent = "10%"
    /// the top of the cone is 50% of the bottom of the cone.
    case FiftyPercent = "50%"
    /// The top of the cone has zero size (which is intuitively what people would think).
    case Zero = "Zero"
}

/// Sizes for the bottom of cone shapes.
enum ConeBottomSizes: String, CaseIterable
{
    /// The bottom of the cone has zero size.
    case Zero = "Zero"
    /// The bottom of the cone is the same as the side value.
    case Side = "Side value"
    /// The bottom of the cone is based on the saturation of the color.
    case Saturation = "Saturation"
    /// The bottom of the cone is based on the hue of the color.
    case Hue = "Hue"
    /// The bottom of the cone is 10% of the side value.
    case Side10 = "Side 10%"
    /// The bottom on the cone is 50% of the side value.
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
    /// Current frame index.
    case CurrentFrame = 0
    /// Number of skipped frames.
    case SkippedFrames = 1
    /// Calculated frames per second.
    case CalculatedFramesPerSecond = 2
    /// Length of last frame's duration.
    case LastFrameDuration = 3
    /// Rolling mean for frame durations.
    case RollingMeanFrameDuration = 4
    /// Delta between the current frame duration and the rolling mean duration.
    case FrameDurationDelta = 5
    /// Number of dropped frames.
    case DroppedFrames = 7
    /// Number of rendered frames.
    case RenderedFrames = 8
    /// Total render duration.
    case RenderDuration = 9
    /// Current throttle value.
    case ThrottleValue = 10
}

/// Determines how spheres use the height/vertical exaggeration values.
enum SphereBehaviors: String, CaseIterable
{
    /// Spheres use height as the radial value.
    case Size = "Size"
    /// Spheres use height as the Z axis value.
    case Height = "Height"
}

/// Orientations for rings.
enum RingOrientations: String, CaseIterable
{
    /// Rotated such that the hole faces upwards (eg, along the Y axis).
    case Rotated = "Rotated"
    /// Rotated such that the hole faces outwards (eg, along the Z axis).
    case Flat = "Flat"
}

/// Sizes of ring/donut holes. Actual size determined at run-time.
enum DonutHoleSizes: String, CaseIterable
{
    /// Small holes.
    case Small = "Small"
    /// Medium holes.
    case Medium = "Medium"
    /// Large holes.
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

/// Antialiasing modes (based on SceneKit). Antialiasing decreases performance.
enum AntialiasingModes: String, CaseIterable
{
    /// No antialiasing.
    case None = "None"
    /// 2x.
    case x2 = "2x"
    /// 4x.
    case x4 = "4x"
    /// 8x.
    case x8 = "8x"
    /// 16x.
    case x16 = "16x"
}

/// Determines the smoothless of extruded letters and characters. Actual value determined at run-time.
/// Increasing smoothness decreases performance.
enum LetterSmoothnesses: String, CaseIterable
{
    /// Smoothest letters/slowest peformance.
    case Smoothest = "Smoothest"
    /// Smooth letters.
    case Smooth = "Smooth"
    /// Medium letters.
    case Medium = "Medium"
    /// Rough letters.
    case Rough = "Rough"
    /// Roughest letters, best performance.
    case Roughest = "Roughest"
}

/// Color components that vary for varying component shapes.
enum VaryingComponents: String, CaseIterable
{
    /// Hue channel.
    case Hue = "Hue"
    /// Saturation channel.
    case Saturation = "Saturation"
    /// Brightness channel.
    case Brightness = "Brightness"
    /// Red channel.
    case Red = "Red"
    /// Green channel.
    case Green = "Green"
    /// Blue channel.
    case Blue = "Blue"
    /// Synthesized cyan channel.
    case Cyan = "Cyan"
    /// Synthesized magenta channel.
    case Magenta = "Magenta"
    /// Synthesized yellow channel.
    case Yellow = "Yellow"
    /// Synthesized black channel.
    case Black = "Black"
}

/// How to determine the color of the line for capped-line shapes.
enum CappedLineLineColors: String, CaseIterable
{
    /// Same color as the sphere.
    case Same = "Same"
    /// Darker than the sphere.
    case Darker = "Darker"
    /// Ligher than the sphere.
    case Lighter = "Lighter"
    /// Black.
    case Black = "Black"
    /// White.
    case White = "White"
}

/// How to resize live view images for performance reasons. The smaller the image size, the greater
/// the performance. Actual values determined at run-time.
enum LiveViewImageSizes: String, CaseIterable
{
    /// Do not resize live view image sizes.
    case Native = "Native"
    /// Smallest image.
    case Small = "Small"
    /// Medium-sized image.
    case Medium = "Medium"
    /// Largest image.
    case Large = "Large"
}

/// Orders in which the histogram display can be shown.
enum HistogramOrders: String, CaseIterable
{
    /// Red, green, blue order.
    case RGB = "RGB"
    /// Red, blue, green order.
    case RBG = "RBG"
    /// Green, red, blue order.
    case GRB = "GRB"
    /// Green, blue, red order.
    case GBR = "GBR"
    /// Blue, red, green order.
    case BRG = "BRG"
    /// Blue, green, red order.
    case BGR = "BGR"
    /// Grayscale (showing synthetic brightness).
    case Gray = "Gray"
}

/// Used to determine which axis long shapes should lie on.
enum LongAxes: String, CaseIterable
{
    /// Long shapes use the X axis.
    case X = "X"
    /// Long shapes use the Y axis.
    case Y = "Y"
    /// Long shapes use the Z axis.
    case Z = "Z"
}
