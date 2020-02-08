//
//  +Lighting.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension ShapeOptionsCode
{
    func InitializeLighting()
    {
        LightColorCombo.removeAllItems()
        LightColorCombo.addItems(withObjectValues: ["White", "Yellow", "Orange", "Teal", "Blue", "Black"])
        DrawLightingSample()
    }
    
    func DrawLightingSample()
    {
        if !LightingSampleInitialized
        {
            LightingSampleInitialized = true
            LightingSample.scene = SCNScene()
            
        }
    }
}
