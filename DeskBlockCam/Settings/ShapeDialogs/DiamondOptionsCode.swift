//
//  DiamondOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DiamondOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Ori = Settings.GetEnum(ForKey: .DiamondOrientation, EnumType: Orientations.self, Default: .Horizontal)
        let Len = Settings.GetEnum(ForKey: .DiamondLength, EnumType: Distances.self, Default: .Medium)
        switch Ori
        {
            case .Horizontal:
                ShapeOrientation.selectedSegment = 0
            
            case .Vertical:
                ShapeOrientation.selectedSegment = 1
        }
        switch Len
        {
            case .Short:
                AxisSize.selectedSegment = 0
            
            case .Medium:
                AxisSize.selectedSegment = 1
            
            case .Long:
                AxisSize.selectedSegment = 2
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
    
    @IBAction func HandleOrientationChanged(_ sender: Any)
    {
        switch ShapeOrientation.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Horizontal, EnumType: Orientations.self, ForKey: .DiamondOrientation)
            
            case 1:
                Settings.SetEnum(.Vertical, EnumType: Orientations.self, ForKey: .DiamondOrientation)
            
            default:
                Settings.SetEnum(.Horizontal, EnumType: Orientations.self, ForKey: .DiamondOrientation)
        }
        Delegate?.UpdateCurrent()
    }
    
    @IBAction func HandleAxisSizeChanged(_ sender: Any)
    {
        switch AxisSize.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Short, EnumType: Distances.self, ForKey: .DiamondLength)
            
            case 1:
                Settings.SetEnum(.Medium, EnumType: Distances.self, ForKey: .DiamondLength)
            
            case 2:
                Settings.SetEnum(.Long, EnumType: Distances.self, ForKey: .DiamondLength)
            
            default:
                Settings.SetEnum(.Short, EnumType: Distances.self, ForKey: .DiamondLength)
        }
        Delegate?.UpdateCurrent()
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var AxisSize: NSSegmentedControl!
    @IBOutlet weak var ShapeOrientation: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
