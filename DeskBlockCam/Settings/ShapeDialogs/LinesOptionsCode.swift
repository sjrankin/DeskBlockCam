//
//  LineOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LinesOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Thick = Settings.GetEnum(ForKey: .LineThickness, EnumType: LineThicknesses.self, Default: .Medium)
        switch Thick
        {
            case .Thin:
                LineThickSegments.selectedSegment = 0
            
            case .Medium:
                LineThickSegments.selectedSegment = 1
            
            case .Thick:
                LineThickSegments.selectedSegment = 2
        }
        let Axis = Settings.GetEnum(ForKey: .LineAxis, EnumType: LongAxes.self, Default: LongAxes.Z)
        switch Axis
        {
            case .X:
                AngleSegment.selectedSegment = 0
            
            case .Y:
                AngleSegment.selectedSegment = 1
            
            case .Z:
                AngleSegment.selectedSegment = 2
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
    
    @IBAction func HandleLineThicknessChanged(_ sender: Any)
    {
        switch LineThickSegments.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Thin, EnumType: LineThicknesses.self, ForKey: .LineThickness)
            
            case 1:
                Settings.SetEnum(.Medium, EnumType: LineThicknesses.self, ForKey: .LineThickness)
            
            case 2:
                Settings.SetEnum(.Thick, EnumType: LineThicknesses.self, ForKey: .LineThickness)
            
            default:
                Settings.SetEnum(.Thin, EnumType: LineThicknesses.self, ForKey: .LineThickness)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleAngleChanged(_ sender: Any)
    {
        switch AngleSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.X, EnumType: LongAxes.self, ForKey: .LineAxis)
            
            case 1:
                Settings.SetEnum(.Y, EnumType: LongAxes.self, ForKey: .LineAxis)
            
            case 2:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: .LineAxis)
            
            default:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: .LineAxis)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var AngleSegment: NSSegmentedControl!
    @IBOutlet weak var LineThickSegments: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
