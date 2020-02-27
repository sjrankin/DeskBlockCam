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
            
            case .ComponentVariable:
                (OptionMap[Shapes.ComponentVariable]!.Controller as? ComponentOptionCode)?.SetShape(.ComponentVariable)
                (OptionMap[Shapes.ComponentVariable]!.Controller as? ComponentOptionCode)?.SetAttributes(CurrentAttributes) 
            
            case .Lines:
                (OptionMap[Shapes.Lines]!.Controller as? LinesOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Lines]!.Controller as? LinesOptionsCode)?.SetShape(.Lines)
            
            case .Polygons:
                (OptionMap[Shapes.Polygons]!.Controller as? PolygonOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Polygons]!.Controller as? PolygonOptionsCode)?.SetShape(.Polygons)
                (OptionMap[Shapes.Polygons]!.Controller as? PolygonOptionsCode)?.SetCaption("Creates a regular polygon in 3D space with the number of sides you specify.")
            
            case .Polygons2D:
                (OptionMap[Shapes.Polygons2D]!.Controller as? PolygonOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Polygons2D]!.Controller as? PolygonOptionsCode)?.SetShape(.Polygons2D)
                (OptionMap[Shapes.Polygons2D]!.Controller as? PolygonOptionsCode)?.SetCaption("Creates a regular 2D polygon with the number of sides you specify.")
            
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
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetCaption("Extruded diamond (parallelogram) shapes.")
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetShape(.Diamonds)
                (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Diamond2D:
                (OptionMap[Shapes.Diamond2D]!.Controller as? DiamondOptionsCode)?.SetCaption("Flat diamond (parallelogram) shapes.")
                (OptionMap[Shapes.Diamond2D]!.Controller as? DiamondOptionsCode)?.SetShape(.Diamond2D)
                (OptionMap[Shapes.Diamond2D]!.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .HueTriangles:
                (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.SetShape(.HueTriangles)
                (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.SetCaption("Extruded arrow shapes that point to the hue of the pixellated color. No options available.")
 
            case .Ovals:
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetCaption("Extruded oval shapes.")
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetShape(.Ovals)
                (OptionMap[Shapes.Ovals]!.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Oval2D:
                                (OptionMap[Shapes.Oval2D]!.Controller as? OvalOptionsCode)?.SetCaption("Flat oval shapes.")
                (OptionMap[Shapes.Oval2D]!.Controller as? OvalOptionsCode)?.SetShape(.Oval2D)
                (OptionMap[Shapes.Oval2D]!.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .PerpendicularCircles:
                (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.SetShape(.PerpendicularCircles)
                (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.SetCaption("Two circles arranged 90° from each other. No options available.")
            
            case .PerpendicularSquares:
                (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.SetShape(.PerpendicularSquares)
                (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.SetCaption("Two Squares arranged 90° from each other. No options available.")
 
            case .ThreeTriangles:
                (OptionMap[Shapes.ThreeTriangles]!.Controller as? ThreeTrianglesOptionsCode)?.SetShape(.ThreeTriangles)
            
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
 
            case .Spheres:
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetShape(.Spheres)
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Spheres]!.Controller as? SphereOptionCode)?.SetCaption("Spheres that vary size or height according to the pixellated color.")
            
            case .Squares:
                (OptionMap[Shapes.Squares]!.Controller as? NoOptionsCode)?.SetShape(.Squares)
                (OptionMap[Shapes.Squares]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional squares. No options available.")
            
            case .Rectangles:
                (OptionMap[Shapes.Rectangles]!.Controller as? NoOptionsCode)?.SetShape(.Rectangles)
                (OptionMap[Shapes.Rectangles]!.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional rectangles. No options available.")
            
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
            
            case .Capsules:
                (OptionMap[Shapes.Capsules]!.Controller as? NoOptionsCode)?.SetShape(.Capsules)
                (OptionMap[Shapes.Capsules]!.Controller as? NoOptionsCode)?.SetCaption("Capsule shapes. No options available.")
            
            case .BlockBases:
                (OptionMap[Shapes.BlockBases]!.Controller as? BlocksWithOptionsCode)?.SetShape(.BlockBases)
            
            case .SphereBases:
                (OptionMap[Shapes.SphereBases]!.Controller as? SpheresWithOptionsCode)?.SetShape(.SphereBases)
            
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
        
        OptionMap[Shapes.BlockBases] = OptionEntry(CreateOptionDialog("BlocksWithOptions"))
        self.addChild(OptionMap[Shapes.BlockBases]!.Controller!)
        (OptionMap[Shapes.BlockBases]!.Controller as? BlocksWithOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.SphereBases] = OptionEntry(CreateOptionDialog("SpheresWithOptions"))
        self.addChild(OptionMap[Shapes.SphereBases]!.Controller!)
        (OptionMap[Shapes.SphereBases]!.Controller as? SpheresWithOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Capsules] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Capsules]!.Controller!)
        (OptionMap[Shapes.Capsules]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Lines] = OptionEntry(CreateOptionDialog("LineOptions"))
        self.addChild(OptionMap[Shapes.Lines]!.Controller!)
        (OptionMap[Shapes.Lines]!.Controller as? LinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Polygons] = OptionEntry(CreateOptionDialog("PolygonOptions"))
        self.addChild(OptionMap[Shapes.Polygons]!.Controller!)
        (OptionMap[Shapes.Polygons]!.Controller as? PolygonOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Polygons2D] = OptionEntry(CreateOptionDialog("PolygonOptions"))
        self.addChild(OptionMap[Shapes.Polygons2D]!.Controller!)
        (OptionMap[Shapes.Polygons2D]!.Controller as? PolygonOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Rectangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Rectangles]!.Controller!)
        (OptionMap[Shapes.Rectangles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Circles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Circles]!.Controller!)
        (OptionMap[Shapes.Circles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Cylinders] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Cylinders]!.Controller!)
        (OptionMap[Shapes.Cylinders]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.HueTriangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.HueTriangles]!.Controller!)
        (OptionMap[Shapes.HueTriangles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Tubes] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.Tubes]!.Controller!)
        (OptionMap[Shapes.Tubes]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularSquares] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.PerpendicularSquares]!.Controller!)
        (OptionMap[Shapes.PerpendicularSquares]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularCircles] = OptionEntry(CreateOptionDialog("NoOptions"))
        self.addChild(OptionMap[Shapes.PerpendicularCircles]!.Controller!)
        (OptionMap[Shapes.PerpendicularCircles]!.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.ThreeTriangles] = OptionEntry(CreateOptionDialog("ThreeTrianglesOptions"))
        self.addChild(OptionMap[Shapes.ThreeTriangles]!.Controller!)
        (OptionMap[Shapes.ThreeTriangles]!.Controller as? ThreeTrianglesOptionsCode)?.Delegate = self
        
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
        
        OptionMap[Shapes.Oval2D] = OptionEntry(CreateOptionDialog("OvalOptions"))
        self.addChild(OptionMap[Shapes.Oval2D]!.Controller!)
        (OptionMap[Shapes.Oval2D]!.Controller as? OvalOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Diamonds] = OptionEntry(CreateOptionDialog("DiamondOptions"))
        self.addChild(OptionMap[Shapes.Diamonds]!.Controller!)
        (OptionMap[Shapes.Diamonds]!.Controller as? DiamondOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Diamond2D] = OptionEntry(CreateOptionDialog("DiamondOptions"))
        self.addChild(OptionMap[Shapes.Diamond2D]!.Controller!)
        (OptionMap[Shapes.Diamond2D]!.Controller as? DiamondOptionsCode)?.Delegate = self
        
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
        
        OptionMap[Shapes.ComponentVariable] = OptionEntry(CreateOptionDialog("ComponentOptions"))
        self.addChild(OptionMap[Shapes.ComponentVariable]!.Controller!)
        (OptionMap[Shapes.ComponentVariable]!.Controller as? ComponentOptionCode)?.Delegate = self
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
