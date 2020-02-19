//
//  CurrentSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Descriptions of how to render. Intended for human readability.
class CurrentSettings
{
    /// Returns each setting used to render the image in a tuple.
    /// - Returns: Tuple with the user-facing setting name and its value.
    public static func DescriptionComponents() -> [(String, String)]
    {
        var Results = [(String, String)]()
        Results.append(("Shape", Settings.GetString(ForKey: .Shape)!))
        switch Settings.GetString(ForKey: .Shape)!
        {
            case Shapes.Blocks.rawValue:
                Results.append(("Edge smoothing", Settings.GetString(ForKey: .BlockChamfer)!))
            
            case Shapes.CappedLines.rawValue:
                Results.append(("Cap location", Settings.GetString(ForKey: .CapLocation)!))
                Results.append(("Cap shape", Settings.GetString(ForKey: .CapShape)!))
            
            case Shapes.Stars.rawValue:
                Results.append(("Apex count", "\(Settings.GetInteger(ForKey: .StarApexCount))"))
                Results.append(("Prominence determines apex count", "\(Settings.GetBoolean(ForKey: .ApexesIncrease))"))
            
            case Shapes.Cones.rawValue:
                Results.append(("Invert cone", "\(Settings.GetBoolean(ForKey: .ConeSwapTopBottom))"))
                Results.append(("Top radius", Settings.GetString(ForKey: .ConeTopSize)!))
                Results.append(("Base radius", Settings.GetString(ForKey: .ConeBottomSize)!))
            
            case Shapes.Ovals.rawValue:
                Results.append(("Oval orientation", "\(Settings.GetString(ForKey: .OvalOrientation)!)"))
                Results.append(("Oval length", "\(Settings.GetString(ForKey: .OvalLength)!)"))
            
            case Shapes.Diamonds.rawValue:
                Results.append(("Diamond orientation", "\(Settings.GetString(ForKey: .DiamondOrientation)!)"))
                Results.append(("Diamond length", "\(Settings.GetString(ForKey: .DiamondLength)!)"))
            
            case Shapes.HueVarying.rawValue:
                Results.append(("Hue shape list", "\(Settings.GetString(ForKey: .HueShapes)!)"))
            
            case Shapes.SaturationVarying.rawValue:
                Results.append(("Saturation shape list", "\(Settings.GetString(ForKey: .SaturationShapes)!)"))
            
            case Shapes.BrightnessVarying.rawValue:
                Results.append(("Brightness shape list", "\(Settings.GetString(ForKey: .BrightnessShapes)!)"))
            
            case Shapes.Characters.rawValue:
                Results.append(("Character set", "\(Settings.GetString(ForKey: .CharacterSet)!)"))
            
            case Shapes.RadiatingLines.rawValue:
                Results.append(("Radiating line count","\(Settings.GetInteger(ForKey: .LineCount))"))
                Results.append(("Radiating line thickness", Settings.GetString(ForKey: .LineThickness)!))
            
            default:
                break
        }
        Results.append(("Shape size", "\(Settings.GetInteger(ForKey: .ShapeSize))"))
        Results.append(("Maximum image size", "\(Settings.GetInteger(ForKey: .MaximumLength))"))
        Results.append(("Height determination", Settings.GetString(ForKey: .HeightDetermination)!))
        Results.append(("Vertical exaggeration", Settings.GetString(ForKey: .VerticalExaggeration)!))
        Results.append(("Invert node height", "\(Settings.GetBoolean(ForKey: .InvertHeight))"))
        Results.append(("Antialiasing", "\(Settings.GetString(ForKey: .Antialiasing)!)"))
        Results.append(("Light color", "\(Settings.GetInteger(ForKey: .LightColor))"))
        Results.append(("Light type", Settings.GetString(ForKey: .LightType)!))
        Results.append(("Light intensity", Settings.GetString(ForKey: .LightIntensity)!))
        Results.append(("Light model", Settings.GetString(ForKey: .LightModel)!))
        if Settings.GetEnum(ForKey: .ConditionalColor, EnumType: ConditionalColorTypes.self, Default: ConditionalColorTypes.None) != .None
        {
            Results.append(("Conditional color type", Settings.GetString(ForKey: .ConditionalColor)!))
            Results.append(("Conditional color action", Settings.GetString(ForKey: .ConditionalColorAction)!))
            Results.append(("Conditional color threshold", Settings.GetString(ForKey: .ConditionalColorThreshold)!))
            Results.append(("Invert conditional color threshold", "\(Settings.GetBoolean(ForKey: .InvertConditionalColor))"))
        }
        return Results
    }
    
    /// Returns the current description of how to render images in human-readable form.
    public static var Description: String
    {
        get
        {
            var Result = ""
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("\(Title): \(Value)\n")
            }
            return Result
        }
    }
    
    /// Returns the current settings as an XML fragment.
    public static var XMLDescription: String
    {
        get
        {
            var Result = "<Settings>\n"
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("  <Setting Name=\"\(Title)\", Value=\"\(Value)\"/>\n")
            }
            Result.append("</Settings>")
            return Result
        }
    }
    
    /// Returns the current settings as a JSON fragment.
    public static var JSONDescription: String
    {
        get
        {
            var Result = "{\n\"Settings\":\n {\n"
            Result.append("    [\n")
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("      {\n")
                Result.append("        \"Title\": \"\(Title)\",\n")
                Result.append("        \"Value\": \"\(Value)\"\n")
                Result.append("      },\n")
            }
            Result.append("    ]\n")
            Result.append("  }\n")
            Result.append("}\n")
            return Result
        }
    }
    
    /// Returns the current settings as a list of semi-colon-separated key-value pairs.
    public static var KVPs: String
    {
        get
        {
            var Result = ""
            let Current = DescriptionComponents()
            for (Name, Value) in Current
            {
                Result.append("\(Name)=\(Value);")
            }
            return Result
        }
    }
    
    /// Returns the current settings as a list of semi-colon-separated key-value pairs, appended with extra information.
    /// - Parameter AppendWith: Extra information to append.
    /// - Returns: String of semi-colon-separated key value pairs of current settings plus passed data.
    public static func KVPs(AppendWith: [(String, String)]) -> String
    {
        var StandardKVPs = KVPs
        for (Key, Value) in AppendWith
        {
            StandardKVPs.append("\(Key)=\(Value);")
        }
        return StandardKVPs
    }
}
