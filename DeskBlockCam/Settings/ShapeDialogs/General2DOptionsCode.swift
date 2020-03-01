//
//  General2DOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class General2DOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        
        switch CurrentShape
        {
            case .Squares:
                ShapeColorKey = .SquareColorControl
                ShapeAxisKey = .SquareAxis
            
            case .Rectangles:
                ShapeColorKey = .SquareColorControl
                ShapeAxisKey = .SquareAxis
            
            case .Circles:
                ShapeColorKey = .SquareColorControl
                ShapeAxisKey = .SquareAxis
            
            case .Stars2D:
                ShapeColorKey = .StarColorControl
                ShapeAxisKey = .StarAxis
            
            default:
                fatalError("Invalid shape (\(CurrentShape.rawValue)) passed to General2DOptionsCode.")
        }
        
        let ShapeColor = Settings.GetEnum(ForKey: ShapeColorKey, EnumType: ColorControls.self, Default: ColorControls.Height)
        switch ShapeColor
        {
            case .Size:
                ColorSegment.selectedSegment = 0
            
            case .Height:
                ColorSegment.selectedSegment = 1
        }
        
        let ShapeAxis = Settings.GetEnum(ForKey: ShapeAxisKey, EnumType: LongAxes.self, Default: .Z)
        switch ShapeAxis
        {
            case .X:
                AxisSegment.selectedSegment = 0
            
            case .Y:
                AxisSegment.selectedSegment = 1
            
            case .Z:
                AxisSegment.selectedSegment = 2
        }
    }
    
    var ShapeColorKey = SettingKeys.CircleColorControl
    var ShapeAxisKey = SettingKeys.CircleAxis
    var NewCaption: String = ""
    
    func ApplyAttributes(_ NewAttributes: ProcessingAttributes)
    {
    }
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
        ApplyAttributes(Attributes)
    }
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
    {
        ApplyAttributes(Updated)
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
    
    var CurrentShape: Shapes = .NoShape
    
    @IBAction func HandleAxisChanged(_ sender: Any)
    {
        switch AxisSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.X, EnumType: LongAxes.self, ForKey: ShapeAxisKey)
            
            case 1:
                Settings.SetEnum(.Y, EnumType: LongAxes.self, ForKey: ShapeAxisKey)
            
            case 2:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: ShapeAxisKey)
            
            default:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: ShapeAxisKey)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleColorSegmentChanged(_ sender: Any)
    {
        switch ColorSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Size, EnumType: ColorControls.self, ForKey: ShapeAxisKey)
            
            case 1:
                Settings.SetEnum(.Height, EnumType: ColorControls.self, ForKey: ShapeAxisKey)
            
            default:
                Settings.SetEnum(.Size, EnumType: ColorControls.self, ForKey: ShapeAxisKey)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBOutlet weak var ColorSegment: NSSegmentedControl!
    @IBOutlet weak var AxisSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}

