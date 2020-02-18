//
//  RadiatingLinesOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RadiatingLinesOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Thick = Settings.GetEnum(ForKey: .LineThickness, EnumType: LineThickenesses.self, Default: .Medium)
        let Count = Settings.GetInteger(ForKey: .LineCount)
        switch Thick
        {
            case .Thin:
                LineThickSegments.selectedSegment = 0
            
            case .Medium:
                LineThickSegments.selectedSegment = 1
            
            case .Thick:
                LineThickSegments.selectedSegment = 2
        }
        switch Count
        {
            case 4:
                LineCountSegment.selectedSegment = 0
            
            case 8:
                LineCountSegment.selectedSegment = 1
            
            case 16:
                LineCountSegment.selectedSegment = 2
            
            default:
                LineCountSegment.selectedSegment = 0
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
    
    @IBAction func HandleLineCountChanged(_ sender: Any)
    {
        switch LineCountSegment.selectedSegment
        {
            case 0:
                Settings.SetInteger(4, ForKey: .LineCount)
            
            case 1:
                Settings.SetInteger(8, ForKey: .LineCount)
            
            case 2:
                Settings.SetInteger(16, ForKey: .LineCount)
            
            default:
                Settings.SetInteger(4, ForKey: .LineCount)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleLineThicknessChanged(_ sender: Any)
    {
        switch LineThickSegments.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Thin, EnumType: LineThickenesses.self, ForKey: .LineThickness)
            
            case 1:
                Settings.SetEnum(.Medium, EnumType: LineThickenesses.self, ForKey: .LineThickness)
            
            case 2:
                Settings.SetEnum(.Thick, EnumType: LineThickenesses.self, ForKey: .LineThickness)
            
            default:
                Settings.SetEnum(.Thin, EnumType: LineThickenesses.self, ForKey: .LineThickness)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var LineCountSegment: NSSegmentedControl!
    @IBOutlet weak var LineThickSegments: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
