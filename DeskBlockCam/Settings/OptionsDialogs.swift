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
                (OptionMap[Shapes.Blocks]?.Controller as? BlockOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Blocks]?.Controller as? BlockOptionsCode)?.SetShape(.Blocks)
            
            case .ComponentVariable:
                (OptionMap[Shapes.ComponentVariable]?.Controller as? ComponentOptionCode2)?.SetShape(.ComponentVariable)
                (OptionMap[Shapes.ComponentVariable]?.Controller as? ComponentOptionCode2)?.SetAttributes(CurrentAttributes) 
            
            case .Lines:
                (OptionMap[Shapes.Lines]?.Controller as? LinesOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Lines]?.Controller as? LinesOptionsCode)?.SetShape(.Lines)
            
            case .Polygons:
                (OptionMap[Shapes.Polygons]?.Controller as? PolygonOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Polygons]?.Controller as? PolygonOptionsCode)?.SetShape(.Polygons)
                (OptionMap[Shapes.Polygons]?.Controller as? PolygonOptionsCode)?.SetCaption("Creates a regular polygon in 3D space with the number of sides you specify.")
            
            case .Polygons2D:
                (OptionMap[Shapes.Polygons2D]?.Controller as? PolygonOptionsCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Polygons2D]?.Controller as? PolygonOptionsCode)?.SetShape(.Polygons2D)
                (OptionMap[Shapes.Polygons2D]?.Controller as? PolygonOptionsCode)?.SetCaption("Creates a regular 2D polygon with the number of sides you specify.")
            
            case .CappedLines:
                (OptionMap[Shapes.CappedLines]?.Controller as? CappedLinesOptionsCode)?.SetShape(.CappedLines)
                (OptionMap[Shapes.CappedLines]?.Controller as? CappedLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Characters:
                (OptionMap[Shapes.Characters]?.Controller as? CharacterSetOptionsCode)?.SetShape(.Characters)
                (OptionMap[Shapes.Characters]?.Controller as? CharacterSetOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Circles:
                (OptionMap[Shapes.Circles]?.Controller as? General2DOptionsCode)?.SetShape(.Circles)
                (OptionMap[Shapes.Circles]?.Controller as? General2DOptionsCode)?.SetCaption("Two-dimensional circles options.")
            
            case .Cones:
                (OptionMap[Shapes.Cones]?.Controller as? ConeOptionsCode)?.SetShape(.Cones)
                (OptionMap[Shapes.Cones]?.Controller as? ConeOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Cylinders:
                (OptionMap[Shapes.Cylinders]?.Controller as? LongShapesOptionsCode)?.SetShape(.Cylinders)
                (OptionMap[Shapes.Cylinders]?.Controller as? LongShapesOptionsCode)?.SetCaption("Extruded cylinder options.")
            
            case .Diamonds:
                (OptionMap[Shapes.Diamonds]?.Controller as? DiamondOptionsCode)?.SetCaption("Extruded diamond (parallelogram) shapes.")
                (OptionMap[Shapes.Diamonds]?.Controller as? DiamondOptionsCode)?.SetShape(.Diamonds)
                (OptionMap[Shapes.Diamonds]?.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Diamond2D:
                (OptionMap[Shapes.Diamond2D]?.Controller as? DiamondOptionsCode)?.SetCaption("Flat diamond (parallelogram) shapes.")
                (OptionMap[Shapes.Diamond2D]?.Controller as? DiamondOptionsCode)?.SetShape(.Diamond2D)
                (OptionMap[Shapes.Diamond2D]?.Controller as? DiamondOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .HueTriangles:
                (OptionMap[Shapes.HueTriangles]?.Controller as? NoOptionsCode)?.SetShape(.HueTriangles)
                (OptionMap[Shapes.HueTriangles]?.Controller as? NoOptionsCode)?.SetCaption("Extruded arrow shapes that point to the hue of the pixellated color. No options available.")
 
            case .Ovals:
                (OptionMap[Shapes.Ovals]?.Controller as? OvalOptionsCode)?.SetCaption("Extruded oval shapes.")
                (OptionMap[Shapes.Ovals]?.Controller as? OvalOptionsCode)?.SetShape(.Ovals)
                (OptionMap[Shapes.Ovals]?.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Oval2D:
                (OptionMap[Shapes.Oval2D]?.Controller as? OvalOptionsCode)?.SetCaption("Flat oval shapes.")
                (OptionMap[Shapes.Oval2D]?.Controller as? OvalOptionsCode)?.SetShape(.Oval2D)
                (OptionMap[Shapes.Oval2D]?.Controller as? OvalOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .PerpendicularCircles:
                (OptionMap[Shapes.PerpendicularCircles]?.Controller as? NoOptionsCode)?.SetShape(.PerpendicularCircles)
                (OptionMap[Shapes.PerpendicularCircles]?.Controller as? NoOptionsCode)?.SetCaption("Two circles arranged 90° from each other. No options available.")
            
            case .PerpendicularSquares:
                (OptionMap[Shapes.PerpendicularSquares]?.Controller as? NoOptionsCode)?.SetShape(.PerpendicularSquares)
                (OptionMap[Shapes.PerpendicularSquares]?.Controller as? NoOptionsCode)?.SetCaption("Two Squares arranged 90° from each other. No options available.")
 
            case .ThreeTriangles:
                (OptionMap[Shapes.ThreeTriangles]?.Controller as? ThreeTrianglesOptionsCode)?.SetShape(.ThreeTriangles)
            
            case .Pyramids:
                (OptionMap[Shapes.Pyramids]?.Controller as? NoOptionsCode)?.SetShape(.Pyramids)
                (OptionMap[Shapes.Pyramids]?.Controller as? NoOptionsCode)?.SetCaption("Pyramid solid. No options available.")
            
            case .RadiatingLines:
                (OptionMap[Shapes.RadiatingLines]?.Controller as? RadiatingLinesOptionsCode)?.SetShape(.RadiatingLines)
                (OptionMap[Shapes.RadiatingLines]?.Controller as? RadiatingLinesOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Rings:
                (OptionMap[Shapes.Rings]?.Controller as? RingOptionCode)?.SetShape(.Rings)
                (OptionMap[Shapes.Rings]?.Controller as? RingOptionCode)?.SetCaption("Creates a rounded ring (or donut, or torus) shape whose size and position is determined by the base color.")
                (OptionMap[Shapes.Rings]?.Controller as? RingOptionCode)?.SetAttributes(CurrentAttributes)
 
            case .Spheres:
                (OptionMap[Shapes.Spheres]?.Controller as? SphereOptionCode)?.SetShape(.Spheres)
                (OptionMap[Shapes.Spheres]?.Controller as? SphereOptionCode)?.SetAttributes(CurrentAttributes)
                (OptionMap[Shapes.Spheres]?.Controller as? SphereOptionCode)?.SetCaption("Spheres that vary size or height according to the pixellated color.")
            
            case .Squares:
                (OptionMap[Shapes.Squares]?.Controller as? General2DOptionsCode)?.SetShape(.Squares)
                (OptionMap[Shapes.Squares]?.Controller as? General2DOptionsCode)?.SetCaption("Two-dimensional squares options.")
            
            case .Rectangles:
                (OptionMap[Shapes.Rectangles]?.Controller as? General2DOptionsCode)?.SetShape(.Rectangles)
                (OptionMap[Shapes.Rectangles]?.Controller as? General2DOptionsCode)?.SetCaption("Two-dimensional rectangles options.")
            
            case .Stars:
                (OptionMap[Shapes.Stars]?.Controller as? StarOptionsCode)?.SetShape(.Stars)
                (OptionMap[Shapes.Stars]?.Controller as? StarOptionsCode)?.SetAttributes(CurrentAttributes)
            
            case .Stars2D:
                (OptionMap[Shapes.Stars2D]?.Controller as? General2DOptionsCode)?.SetShape(.Stars2D)
                (OptionMap[Shapes.Stars2D]?.Controller as? General2DOptionsCode)?.SetCaption("Two-dimensional star options.")
            
            case .Triangles:
                (OptionMap[Shapes.Triangles]?.Controller as? NoOptionsCode)?.SetShape(.Triangles)
                (OptionMap[Shapes.Triangles]?.Controller as? NoOptionsCode)?.SetCaption("Extruded 3D triangles. No options available.")
            
            case .Triangles2D:
                (OptionMap[Shapes.Triangles2D]?.Controller as? NoOptionsCode)?.SetShape(.Triangles2D)
                (OptionMap[Shapes.Triangles2D]?.Controller as? NoOptionsCode)?.SetCaption("Two-dimensional triangles. No options available.")
            
            case .Tubes:
                (OptionMap[Shapes.Tubes]?.Controller as? NoOptionsCode)?.SetShape(.Tubes)
                (OptionMap[Shapes.Tubes]?.Controller as? NoOptionsCode)?.SetCaption("Tube shaped nodes. No options available.")
            
            case .Capsules:
                (OptionMap[Shapes.Capsules]?.Controller as? LongShapesOptionsCode)?.SetShape(.Capsules)
                (OptionMap[Shapes.Capsules]?.Controller as? LongShapesOptionsCode)?.SetCaption("Extruded capsule options.")
            
            case .BlockBases:
                (OptionMap[Shapes.BlockBases]?.Controller as? BlocksWithOptionsCode)?.SetShape(.BlockBases)
            
            case .SphereBases:
                (OptionMap[Shapes.SphereBases]?.Controller as? SpheresWithOptionsCode)?.SetShape(.SphereBases)
            
            case .Particles:
                (OptionMap[Shapes.Particles]?.Controller as? ParticlesWithOptionsCode)?.SetShape(.Particles)
                
            case .NoShape:
                break
        }
        
        // A shape with no dialog (or one that could not be loaded) gets the "no options" dialog instead of crashing.
        guard let Dialog = OptionMap[Shape]?.Controller ?? OptionMap[Shapes.NoShape]?.Controller else
        {
            return
        }
        Dialog.view.frame = OptionsContainer.bounds
        OptionsContainer.addSubview(Dialog.view)
    }
    
    /// Create all of the optional dialogs for shapes with options.
    func CreateOptionDialogs()
    {
        OptionMap[Shapes.NoShape] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.NoShape]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.NoShape]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.BlockBases] = OptionEntry(CreateOptionDialog("BlocksWithOptions"))
        if let Dialog = OptionMap[Shapes.BlockBases]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.BlockBases]?.Controller as? BlocksWithOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.SphereBases] = OptionEntry(CreateOptionDialog("SpheresWithOptions"))
        if let Dialog = OptionMap[Shapes.SphereBases]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.SphereBases]?.Controller as? SpheresWithOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Capsules] = OptionEntry(CreateOptionDialog("LongShapeOptions"))
        if let Dialog = OptionMap[Shapes.Capsules]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Capsules]?.Controller as? LongShapesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Lines] = OptionEntry(CreateOptionDialog("LineOptions"))
        if let Dialog = OptionMap[Shapes.Lines]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Lines]?.Controller as? LinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Polygons] = OptionEntry(CreateOptionDialog("PolygonOptions"))
        if let Dialog = OptionMap[Shapes.Polygons]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Polygons]?.Controller as? PolygonOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Polygons2D] = OptionEntry(CreateOptionDialog("PolygonOptions"))
        if let Dialog = OptionMap[Shapes.Polygons2D]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Polygons2D]?.Controller as? PolygonOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Rectangles] = OptionEntry(CreateOptionDialog("General2DShapeOptions"))
        if let Dialog = OptionMap[Shapes.Rectangles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Rectangles]?.Controller as? General2DOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Circles] = OptionEntry(CreateOptionDialog("General2DShapeOptions"))
        if let Dialog = OptionMap[Shapes.Circles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Circles]?.Controller as? General2DOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Cylinders] = OptionEntry(CreateOptionDialog("LongShapeOptions"))
        if let Dialog = OptionMap[Shapes.Cylinders]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Cylinders]?.Controller as? LongShapesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.HueTriangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.HueTriangles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.HueTriangles]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Tubes] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.Tubes]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Tubes]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularSquares] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.PerpendicularSquares]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.PerpendicularSquares]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.PerpendicularCircles] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.PerpendicularCircles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.PerpendicularCircles]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.ThreeTriangles] = OptionEntry(CreateOptionDialog("ThreeTrianglesOptions"))
        if let Dialog = OptionMap[Shapes.ThreeTriangles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.ThreeTriangles]?.Controller as? ThreeTrianglesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Pyramids] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.Pyramids]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Pyramids]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Squares] = OptionEntry(CreateOptionDialog("General2DShapeOptions"))
        if let Dialog = OptionMap[Shapes.Squares]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Squares]?.Controller as? General2DOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Tubes] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.Tubes]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Tubes]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Triangles] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.Triangles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Triangles]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Triangles2D] = OptionEntry(CreateOptionDialog("NoOptions"))
        if let Dialog = OptionMap[Shapes.Triangles2D]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Triangles2D]?.Controller as? NoOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Stars2D] = OptionEntry(CreateOptionDialog("General2DShapeOptions"))
        if let Dialog = OptionMap[Shapes.Stars2D]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Stars2D]?.Controller as? General2DOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Blocks] = OptionEntry(CreateOptionDialog("BlockOptions"))
        if let Dialog = OptionMap[Shapes.Blocks]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Blocks]?.Controller as? BlockOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Ovals] = OptionEntry(CreateOptionDialog("OvalOptions"))
        if let Dialog = OptionMap[Shapes.Ovals]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Ovals]?.Controller as? OvalOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Oval2D] = OptionEntry(CreateOptionDialog("OvalOptions"))
        if let Dialog = OptionMap[Shapes.Oval2D]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Oval2D]?.Controller as? OvalOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Diamonds] = OptionEntry(CreateOptionDialog("DiamondOptions"))
        if let Dialog = OptionMap[Shapes.Diamonds]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Diamonds]?.Controller as? DiamondOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Diamond2D] = OptionEntry(CreateOptionDialog("DiamondOptions"))
        if let Dialog = OptionMap[Shapes.Diamond2D]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Diamond2D]?.Controller as? DiamondOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Cones] = OptionEntry(CreateOptionDialog("ConeOptions"))
        if let Dialog = OptionMap[Shapes.Cones]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Cones]?.Controller as? ConeOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Stars] = OptionEntry(CreateOptionDialog("StarOptions"))
        if let Dialog = OptionMap[Shapes.Stars]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Stars]?.Controller as? StarOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.RadiatingLines] = OptionEntry(CreateOptionDialog("RadiatingLineOptions"))
        if let Dialog = OptionMap[Shapes.RadiatingLines]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.RadiatingLines]?.Controller as? RadiatingLinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Characters] = OptionEntry(CreateOptionDialog("CharacterSetOptions"))
        if let Dialog = OptionMap[Shapes.Characters]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Characters]?.Controller as? CharacterSetOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.CappedLines] = OptionEntry(CreateOptionDialog("CappedLineOptions"))
        if let Dialog = OptionMap[Shapes.CappedLines]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.CappedLines]?.Controller as? CappedLinesOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.Spheres] = OptionEntry(CreateOptionDialog("SphereOptions"))
        if let Dialog = OptionMap[Shapes.Spheres]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Spheres]?.Controller as? SphereOptionCode)?.Delegate = self
        
        OptionMap[Shapes.Rings] = OptionEntry(CreateOptionDialog("RingOptions"))
        if let Dialog = OptionMap[Shapes.Rings]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Rings]?.Controller as? RingOptionCode)?.Delegate = self
        
        OptionMap[Shapes.Particles] = OptionEntry(CreateOptionDialog("ParticleOptions"))
        if let Dialog = OptionMap[Shapes.Particles]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.Particles]?.Controller as? ParticlesWithOptionsCode)?.Delegate = self
        
        OptionMap[Shapes.ComponentVariable] = OptionEntry(CreateOptionDialog("ComponentOptions2"))
        if let Dialog = OptionMap[Shapes.ComponentVariable]?.Controller { self.addChild(Dialog) }
        (OptionMap[Shapes.ComponentVariable]?.Controller as? ComponentOptionCode2)?.Delegate = self
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
