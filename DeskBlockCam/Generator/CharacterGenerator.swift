//
//  CharacterGenerator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Generator
{
    private static func GetCharSet() -> (Random: String, Font: String)
    {
        let CharacterClass = Settings.GetEnum(ForKey: .CharacterSet, EnumType: CharacterSets.self,
                                              Default: CharacterSets.Latin)
        if let Series = ShapeManager.CharacterSetMap[CharacterClass]
        {
            let Characters = Series.rawValue
            let Font = ShapeManager.FontMap[Series]!
            return (String(Characters.randomElement()!), Font)
        }
        return ("?", "Avenir")
    }
    
    public static func GenerateCharacterFromSet(Prominence: CGFloat, FinalScale: inout Double) -> SCNGeometry
    {
        FinalScale = 1.0
        var ProminenceMultiplier = 1.0
        if Settings.GetBoolean(ForKey: .FullyExtrudeLetters)
        {
            ProminenceMultiplier = 20.0
        }
        let (RandomCharacter, FontName) = GetCharSet()
        let FinalShape = SCNText(string: RandomCharacter,
                                 extrusionDepth: Prominence * 2 * CGFloat(ProminenceMultiplier))
        var Size = Settings.GetInteger(ForKey: .FontSize)
        if Size < 5
        {
            Size = 36
            Settings.SetInteger(36, ForKey: .FontSize)
        }
        FinalShape.font = NSFont(name: FontName, size: CGFloat(Size))
        if let Smoothness = Settings.GetString(ForKey: .LetterSmoothness)
        {
            switch Smoothness
            {
                case "Roughest":
                    FinalShape.flatness = 1.2
                
                case "Rough":
                    FinalShape.flatness = 0.8
                
                case "Medium":
                    FinalShape.flatness = 0.5
                
                case "Smooth":
                    FinalShape.flatness = 0.25
                
                case "Smoothest":
                    FinalShape.flatness = 0.0
                
                default:
                    FinalShape.flatness = 0.5
            }
        }
        else
        {
            Settings.SetString("Smooth", ForKey: .LetterSmoothness)
            FinalShape.flatness = 0.0
        }
        FinalScale = 0.035
        return FinalShape
    }
}
