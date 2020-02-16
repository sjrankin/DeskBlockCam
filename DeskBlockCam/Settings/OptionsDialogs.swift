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
    /// Display the options for the passed shape.
    /// - Note: See [Switch between NSViewControllers](https://stackoverflow.com/questions/40790267/swift-switch-between-nsviewcontroller-inside-container-view-nsview)
    /// - Parameter For: The shape whose options will be shown. If a given shape does not have any options, a generic
    ///                  "no options" view will be shown.
    func DisplayShapeOptions(For Shape: Shapes)
    {
        for SomeView in OptionsContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        
        switch Shape
        {
            case .Blocks:
                (OptionMap[Shapes.Blocks]!.Controller as? BlockOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Blocks]!.Controller as? BlockOptionsCode)?.SetShape(.Blocks)
            
            case .BrightnessVarying:
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetShape(.BrightnessVarying)
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetCaption("Sets the shape based on the brightness of the location of the shape. Shapes are distributed equally in the brightness range.")
            
            case .CappedLines:
                (OptionMap[Shapes.CappedLines]!.Controller as? CappedLinesOptionsCode)?.SetShape(.CappedLines)
                (OptionMap[Shapes.CappedLines]!.Controller as? CappedLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Characters:
                (OptionMap[Shapes.Characters]!.Controller as? CharacterSetOptionsCode)?.SetShape(.Characters)
                (OptionMap[Shapes.Characters]!.Controller as? CharacterSetOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Circles:
                (OptionMap[Shapes.Circles]!.Controller as? NoOptionsCode)?.SetShape(.Circles)
                (OptionMap[Shapes.Circles]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional circles. No options available.")
            
            case .Cones:
                (OptionMap[Shapes.Cones]!.Controller as? ConeOptionsCode)?.SetShape(.Cones)
                (OptionMap[Shapes.Cones]!.Controller as? ConeOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Cylinders:
                (OptionMap[Shapes.Cylinders]!.Controller as? NoOptionsCode)?.SetShape(.Cylinders)
                (OptionMap[Shapes.Cylinders]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D cylinders. No options available.")
            
            case .Diamonds:
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetShape(.Diamonds)
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Hexagons:
                (OptionMap[Shapes.Hexagons]!.Controller as? NoOptionsCode)?.SetShape(.Hexagons)
                (OptionMap[Shapes.Hexagons]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D hexagons. No options available.")
            
            case .Hexagons2D:
                (OptionMap[Shapes.Hexagons2D]!.Controller as? NoOptionsCode)?.SetShape(.Hexagons2D)
                (OptionMap[Shapes.Hexagons2D]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional hexagons. No options available.")
            
            case .HueTriangles:
                (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.SetShape(.HueTriangles)
                (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.SetCaption("Extruded arrow shapes that point to the hue of the pixellated color. No options available.")
            
            case .HueVarying:
                (OptionMap[Shapes.HueVarying]!.Controller as? StackedShapesOptionCode)?.SetShape(.HueVarying)
                (OptionMap[Shapes.HueVarying]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.HueVarying]!.Controller as? StackedShapesOptionCode)?.SetCaption("Sets the shape based on the hue of the location of the shape. Shapes are distributed equally in the hue range.")
            
            case .Octagons:
                (OptionMap[Shapes.Octagons]!.Controller as? NoOptionsCode)?.SetShape(.Octagons)
                (OptionMap[Shapes.Octagons]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D octagons. No options available.")
            
            case .Octagons2D:
                (OptionMap[Shapes.Octagons2D]!.Controller as? NoOptionsCode)?.SetShape(.Octagons2D)
                (OptionMap[Shapes.Octagons2D]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional octagons. No options available.")
            
            case .Ovals:
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetShape(.Ovals)
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Pentagons:
                (OptionMap[Shapes.Pentagons]!.Controller as? NoOptionsCode)?.SetShape(.Pentagons)
                (OptionMap[Shapes.Pentagons]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D pentagons. No options available.")
            
            case .Pentagons2D:
                (OptionMap[Shapes.Pentagons2D]!.Controller as? NoOptionsCode)?.SetShape(.Pentagons2D)
                (OptionMap[Shapes.Pentagons2D]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional pentagons. No options available.")
            
            case .PerpendicularCircles:
                (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.SetShape(.PerpendicularCircles)
                (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.SetCaption("Two circles arranged 90° from each other. No options available.")
            
            case .PerpendicularSquares:
                (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.SetShape(.PerpendicularSquares)
                (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.SetCaption("Two Squares arranged 90° from each other. No options available.")
            
            case .Pyramids:
                (OptionMap[Shapes.Pyramids]!.Controller as? NoOptionsCode)?.SetShape(.Pyramids)
                (OptionMap[Shapes.Pyramids]!.Controller as? NoOptionsCode)?.SetCaption("Pyramid solid. No options available.")
            
            case .RadiatingLines:
                (OptionMap[Shapes.RadiatingLines]!.Controller as? RadiatingLinesOptionsCode)?.SetShape(.RadiatingLines)
                (OptionMap[Shapes.RadiatingLines]!.Controller as? RadiatingLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Rings:
                (OptionMap[Shapes.Rings]!.Controller as? RingOptionCode)?.SetShape(.Rings)
                (OptionMap[Shapes.Rings]!.Controller as? RingOptionCode)?.SetCaption("Creates a rounded ring (or donut, or torus) shape whose size and position is determined by the base color.")
                (OptionMap[Shapes.Rings]!.Controller as? RingOptionCode)?.SetAttributes(CurrentAttributes)
            
            case .SaturationVarying:
                (OptionMap[Shapes.SaturationVarying]!.Controller as? StackedShapesOptionCode)?.SetShape(.SaturationVarying)
                (OptionMap[Shapes.SaturationVarying]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.SaturationVarying]!.Controller as? StackedShapesOptionCode)?.SetCaption("Sets the shape based on the saturation of the location of the shape. Shapes are distributed equally in the saturation range.")
            
            case .Spheres:
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetShape(.Spheres)
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetCaption("Spheres that vary size or height according to the pixellated color.")
            
            case .Squares:
                (OptionMap[Shapes.Squares]!.Controller as? NoOptionsCode)?.SetShape(.Squares)
                (OptionMap[Shapes.Squares]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional squares. No options available.")
            
            case .StackedShapes:
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetShape(.StackedShapes)
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.SetCaption("Creates a stack of shapes you specify. If not enough shapes, they are recycled in order.")
            
            case .Stars:
                (OptionMap[Shapes.Stars]!.Controller as? StarOptionsCode)?.SetShape(.Stars)
                (OptionMap[Shapes.Stars]!.Controller as? StarOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Stars2D:
                (OptionMap[Shapes.Stars2D]!.Controller as? NoOptionsCode)?.SetShape(.Stars2D)
                (OptionMap[Shapes.Stars2D]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional stars. No options available.")
            
            case .Triangles:
                (OptionMap[Shapes.Triangles]!.Controller as? NoOptionsCode)?.SetShape(.Triangles)
                (OptionMap[Shapes.Triangles]!.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D triangles. No options available.")
            
            case .Triangles2D:
                (OptionMap[Shapes.Triangles2D]!.Controller as? NoOptionsCode)?.SetShape(.Triangles2D)
                (OptionMap[Shapes.Triangles2D]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional triangles. No options available.")
            
            case .Tubes:
                (OptionMap[Shapes.Tubes]!.Controller as? NoOptionsCode)?.SetShape(.Tubes)
                (OptionMap[Shapes.Tubes]!.Controller as? NoOptionsCode)?.SetCaption("Tube shaped nodes. No options available.")
            
            case .NoShape:
                break
        }
        
        OptionMap[Shape]!.Controller?.view.frame = OptionsContainer.bounds
        OptionsContainer.addSubview(OptionMap[Shape]!.Controller!.view)
    }
    
    /// Create all of the optional dialogs for shapes with options.
    func CreateOptionDialogs()
    {
        OptionMap[Shapes.NoShape] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.NoShape]!.Controller!)
        (OptionMap[Shapes.NoShape]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Circles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Circles]!.Controller!)
        (OptionMap[Shapes.Circles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Cylinders] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Cylinders]!.Controller!)
        (OptionMap[Shapes.Cylinders]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Hexagons] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Hexagons]!.Controller!)
        (OptionMap[Shapes.Hexagons]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Hexagons2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Hexagons2D]!.Controller!)
        (OptionMap[Shapes.Hexagons2D]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.HueTriangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.HueTriangles]!.Controller!)
        (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Octagons] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Octagons]!.Controller!)
        (OptionMap[Shapes.Octagons]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Octagons2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Octagons2D]!.Controller!)
        (OptionMap[Shapes.Octagons2D]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Pentagons] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Pentagons]!.Controller!)
        (OptionMap[Shapes.Pentagons]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Pentagons2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Pentagons2D]!.Controller!)
        (OptionMap[Shapes.Pentagons2D]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Tubes] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Tubes]!.Controller!)
        (OptionMap[Shapes.Tubes]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularSquares] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.PerpendicularSquares]!.Controller!)
        (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularCircles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.PerpendicularCircles]!.Controller!)
        (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Pyramids] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Pyramids]!.Controller!)
        (OptionMap[Shapes.Pyramids]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Squares] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Squares]!.Controller!)
        (OptionMap[Shapes.Squares]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Tubes] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Tubes]!.Controller!)
        (OptionMap[Shapes.Tubes]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Triangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Triangles]!.Controller!)
        (OptionMap[Shapes.Triangles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Triangles2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Triangles2D]!.Controller!)
        (OptionMap[Shapes.Triangles2D]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Stars2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Stars2D]!.Controller!)
        (OptionMap[Shapes.Stars2D]!.Controller as? NoOptionsCode)?.Delegate = self
        
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
        
        OptionMap[Shapes.Spheres] = OptionEntry(CreateOptionDialog("SphereOptions"))
        self.addChild(OptionMap[Shapes.Spheres]!.Controller!)
        (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.Delegate = self
        
        OptionMap[Shapes.StackedShapes] = OptionEntry(CreateOptionDialog("StackedShapeOptions"))
        self.addChild(OptionMap[Shapes.StackedShapes]!.Controller!)
        (OptionMap[Shapes.StackedShapes]!.Controller as? StackedShapesOptionCode)?.Delegate = self
        
        OptionMap[Shapes.Rings] = OptionEntry(CreateOptionDialog("RingOptions"))
        self.addChild(OptionMap[Shapes.Rings]!.Controller!)
        (OptionMap[Shapes.Rings]!.Controller as? RingOptionCode)?.Delegate = self
        
        OptionMap[Shapes.HueVarying] = OptionEntry(CreateOptionDialog("StackedShapeOptions"))
        self.addChild(OptionMap[Shapes.HueVarying]!.Controller!)
        (OptionMap[Shapes.HueVarying]!.Controller as? StackedShapesOptionCode)?.Delegate = self
        
        OptionMap[Shapes.BrightnessVarying] = OptionEntry(CreateOptionDialog("StackedShapeOptions"))
        self.addChild(OptionMap[Shapes.BrightnessVarying]!.Controller!)
        (OptionMap[Shapes.BrightnessVarying]!.Controller as? StackedShapesOptionCode)?.Delegate = self
        
        OptionMap[Shapes.SaturationVarying] = OptionEntry(CreateOptionDialog("StackedShapeOptions"))
        self.addChild(OptionMap[Shapes.SaturationVarying]!.Controller!)
        (OptionMap[Shapes.SaturationVarying]!.Controller as? StackedShapesOptionCode)?.Delegate = self
    }
    
    /// Create the optional settings view.
    /// - Parameter IDName: The name of the optional controller.
    /// - Returns: View controller for the optional settings.
    func CreateOptionDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "Settings", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            return Controller
        }
        else
        {
            return nil
        }
    }
}
