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
        let Angle = Settings.GetDouble(ForKey: .LineZAngle)
        switch Int(Angle)
        {
            case 0:
                AngleSegment.selectedSegment = 0
            
            case 30:
                AngleSegment.selectedSegment = 1
            
            case 60:
                AngleSegment.selectedSegment = 2
            
            case 90:
                AngleSegment.selectedSegment = 3
            
            default:
                AngleSegment.selectedSegment = 0
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
        var NewAngle: Double = 0
        switch AngleSegment.selectedSegment
        {
            case 0:
                NewAngle = 0.0
            
            case 1:
                NewAngle = 30.0
            
            case 2:
                NewAngle = 60.0
            
            case 3:
                NewAngle = 90.0
            
            default:
                NewAngle = 0.0
        }
        Settings.SetDouble(NewAngle, ForKey: .LineZAngle)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var AngleSegment: NSSegmentedControl!
    @IBOutlet weak var LineThickSegments: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
