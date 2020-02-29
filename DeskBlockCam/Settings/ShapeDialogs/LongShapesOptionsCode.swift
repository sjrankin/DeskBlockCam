//
//  LongShapesOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LongShapesOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        var AxisKey: SettingKeys = .CylinderAxis
        switch CurrentShape
        {
            case .Cylinders:
                AxisKey = .CylinderAxis
            
            case .Capsules:
                AxisKey = .CapsuleAxis
            
            default:
                fatalError("Unexpected shape encountered: \(LongShape.rawValue)")
        }
        let Axis = Settings.GetEnum(ForKey: AxisKey, EnumType: LongAxes.self, Default: LongAxes.Z)
        switch Axis
        {
            case .X:
                AxisSegment.selectedSegment = 0
            
            case .Y:
                AxisSegment.selectedSegment = 1
            
            case .Z:
                AxisSegment.selectedSegment = 2
        }
    }
    
    var LongShape: Shapes = .NoShape
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
        var AxisKey: SettingKeys = .CylinderAxis
        switch CurrentShape
        {
            case .Cylinders:
                AxisKey = .CylinderAxis
            
            case .Capsules:
                AxisKey = .CapsuleAxis
            
            default:
                fatalError("Unexpected shape encountered: \(LongShape.rawValue)")
        }
        switch AxisSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.X, EnumType: LongAxes.self, ForKey: AxisKey)
            
            case 1:
                Settings.SetEnum(.Y, EnumType: LongAxes.self, ForKey: AxisKey)
            
            case 2:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: AxisKey)
            
            default:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: AxisKey)
        }
    }
    
    @IBOutlet weak var AxisSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}

