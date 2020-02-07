//
//  OptionsDialogs.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ShapeOptionsCode
{
    //https://stackoverflow.com/questions/40790267/swift-switch-between-nsviewcontroller-inside-container-view-nsview
    func  DisplayShapeOptions(For Shape: Shapes)
    {
        for SomeView in OptionsContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        
        var FinalShape = Shapes.NoShape
        switch Shape
        {
            case .Blocks:
                FinalShape = Shapes.Blocks
                (OptionMap[Shapes.Blocks]!.Controller as? BlockOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .BrightnessVarying:
                FinalShape = Shapes.StackedShapes
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
            
            case .CappedLines:
                FinalShape = Shapes.CappedLines
                (OptionMap[Shapes.CappedLines]!.Controller as? CappedLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Characters:
                FinalShape = Shapes.Characters
                (OptionMap[Shapes.Characters]!.Controller as? CharacterSetOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Circles:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional circles. No options available.")
            
            case .Cones:
                FinalShape = Shapes.Cones
                (OptionMap[Shapes.Cones]!.Controller as? ConeOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Cylinders:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D cylinders. No options available.")
            
            case .Diamonds:
                FinalShape = Shapes.Diamonds
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Hexagons:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D hexagons. No options available.")
            
            case .Hexagons2D:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional hexagons. No options available.")
            
            case .HueTriangles:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded arrow shapes that point to the hue of the pixellated color. No options available.")
            
            case .HueVarying:
                FinalShape = Shapes.StackedShapes
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
            
            case .Octagons:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D octagons. No options available.")
            
            case .Octagons2D:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional octagons. No options available.")
            
            case .Ovals:
                FinalShape = Shapes.Ovals
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Pentagons:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D pentagons. No options available.")
            
            case .Pentagons2D:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional pentagons. No options available.")
            
            case .PerpendicularCircles:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two circles arranged 90° from each other. No options available.")
            
            case .PerpendicularSquares:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two Squares arranged 90° from each other. No options available.")
            
            case .Pyramids:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Pyramid solid. No options available.")
            
            case .RadiatingLines:
                FinalShape = Shapes.RadiatingLines
                (OptionMap[Shapes.RadiatingLines]!.Controller as? RadiatingLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Rings:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Ring or donut shaped solids. No options available.")
            
            case .SaturationVarying:
                FinalShape = Shapes.StackedShapes
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
            
            case .Spheres:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Spheres that vary size according to the pixellated color. No options available.")
            
            case .Squares:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional squares. No options available.")
            
            case .StackedShapes:
                FinalShape = Shapes.StackedShapes
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
            
            case .Stars:
                FinalShape = Shapes.Stars
                (OptionMap[Shapes.Stars]!.Controller as? StarOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Stars2D:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional stars. No options available.")
            
            case .Triangles:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D triangles. No options available.")
            
            case .Triangles2D:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional triangles. No options available.")
            
            case .Tubes:
                (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.SetCaption("Tube shaped nodes. No options available.")
            
            case .NoShape:
                break
        }
        
        OptionMap[FinalShape]!.Controller?.view.frame = OptionsContainer.bounds
        OptionsContainer.addSubview(OptionMap[FinalShape]!.Controller!.view)
    }
    
    func CreateOptionDialogs()
    {
        OptionMap[Shapes.NoShape] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.NoShape]!.Controller!)
        (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Blocks] = OptionEntry(CreateOptionDialog("BlockOptions"))
        self.addChild(OptionMap[Shapes.Blocks]!.Controller!)
        (OptionMap[Shapes.Blocks]!.Controller as? BlockOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Blocks] = OptionEntry(CreateOptionDialog("BlockOptions"))
        self.addChild(OptionMap[Shapes.Blocks]!.Controller!)
        (OptionMap[Shapes.Blocks]!.Controller as? BlockOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Ovals] = OptionEntry(CreateOptionDialog("OvalOptions"))
        self.addChild(OptionMap[Shapes.Ovals]!.Controller!)
        (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Diamonds] = OptionEntry(CreateOptionDialog("DiamondOptions"))
        self.addChild(OptionMap[Shapes.Diamonds]!.Controller!)
        (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Cones] = OptionEntry(CreateOptionDialog("ConeOptions"))
        self.addChild(OptionMap[Shapes.Cones]!.Controller!)
        (OptionMap[Shapes.Cones]!.Controller as? ConeOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Stars] = OptionEntry(CreateOptionDialog("StarOptions"))
        self.addChild(OptionMap[Shapes.Stars]!.Controller!)
        (OptionMap[Shapes.Stars]!.Controller as? StarOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.RadiatingLines] = OptionEntry(CreateOptionDialog("RadiatingLineOptions"))
        self.addChild(OptionMap[Shapes.RadiatingLines]!.Controller!)
        (OptionMap[Shapes.RadiatingLines]!.Controller as? RadiatingLinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Characters] = OptionEntry(CreateOptionDialog("CharacterSetOptions"))
        self.addChild(OptionMap[Shapes.Characters]!.Controller!)
        (OptionMap[Shapes.Characters]!.Controller as? CharacterSetOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.CappedLines] = OptionEntry(CreateOptionDialog("CappedLineOptions"))
        self.addChild(OptionMap[Shapes.CappedLines]!.Controller!)
        (OptionMap[Shapes.CappedLines]!.Controller as? CappedLinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.StackedShapes] = OptionEntry(CreateOptionDialog("StackedShapeOptions"))
        self.addChild(OptionMap[Shapes.StackedShapes]!.Controller!)
        (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.Delegate = self
    }
    
    func CreateOptionDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            return Controller
        }
        else
        {
            return nil
        }
    }
}
