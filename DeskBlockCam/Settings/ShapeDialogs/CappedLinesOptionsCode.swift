//
//  CappedLinesOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CappedLinesOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Loc = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self, Default: CapLocations.Top)
        let Shp = Settings.GetEnum(ForKey: .CapShape, EnumType: Shapes.self, Default: Shapes.Spheres)
        switch Loc
        {
            case .Bottom:
                ShapeLocationSegment.selectedSegment = 0
            
            case .Middle:
                ShapeLocationSegment.selectedSegment = 1
            
            case .Top:
                ShapeLocationSegment.selectedSegment = 2
        }
        CapShapeCombo.removeAllItems()
        CapShapeCombo.addItems(withObjectValues: [Shapes.Spheres.rawValue, Shapes.Blocks.rawValue,
                                                  Shapes.Cones.rawValue, Shapes.Squares.rawValue,
                                                  Shapes.Circles.rawValue])
        switch Shp
        {
            case .Spheres:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Spheres.rawValue)
            
            case .Blocks:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Blocks.rawValue)
            
            case .Cones:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Cones.rawValue)
            
            case .Squares:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Squares.rawValue)
            
            case .Circles:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Circles.rawValue)
            
            default:
                CapShapeCombo.selectItem(withObjectValue: Shapes.Spheres.rawValue)
        }
    }
    
    var NewCaption: String = ""
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
    }
    
    func SetCaption(_ CaptionText: String)
    {
        NewCaption = CaptionText
        if Caption != nil
        {
            Caption.stringValue = NewCaption
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    @IBAction func HandleLocationChanged(_ sender: Any)
    {
        switch ShapeLocationSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Bottom, EnumType: CapLocations.self, ForKey: .CapLocation)
            
            case 1:
                Settings.SetEnum(.Middle, EnumType: CapLocations.self, ForKey: .CapLocation)
            
            case 2:
                Settings.SetEnum(.Top, EnumType: CapLocations.self, ForKey: .CapLocation)
            
            default:
                Settings.SetEnum(.Top, EnumType: CapLocations.self, ForKey: .CapLocation)
        }
        Delegate?.UpdateCurrent()
    }
    
    @IBAction func HandleShapeChanged(_ sender: Any)
    {
        if let Shp = CapShapeCombo.objectValueOfSelectedItem as? String
        {
            if let FinalShape = Shapes(rawValue: Shp)
            {
                Settings.SetEnum(FinalShape, EnumType: Shapes.self, ForKey: .CapShape)
                Delegate?.UpdateCurrent()
            }
        }
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var ShapeLocationSegment: NSSegmentedControl!
    @IBOutlet weak var CapShapeCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
