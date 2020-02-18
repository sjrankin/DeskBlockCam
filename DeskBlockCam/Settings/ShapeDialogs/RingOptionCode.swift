//
//  RingOptionCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RingOptionCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let HoleSize = Settings.GetEnum(ForKey: .DonutHoleSize, EnumType: DonutHoleSizes.self,
                                        Default: .Medium)
        switch HoleSize
        {
            case .Small:
                DonutHoleSegment.selectedSegment = 0
            
            case .Medium:
                DonutHoleSegment.selectedSegment = 1
            
            case .Large:
                DonutHoleSegment.selectedSegment = 2
        }
        let Orientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self,
                                           Default: .Flat)
        switch Orientation
        {
            case .Flat:
                OrientationSegment.selectedSegment = 0
            
            case .Rotated:
                OrientationSegment.selectedSegment = 1
        }
    }
    
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
    
    @IBAction func HandleRingOrientationChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(RingOrientations.Flat, EnumType: RingOrientations.self, ForKey: .RingOrientation)
                
                case 1:
                    Settings.SetEnum(RingOrientations.Rotated, EnumType: RingOrientations.self, ForKey: .RingOrientation)
                
                default:
                    Settings.SetEnum(RingOrientations.Flat, EnumType: RingOrientations.self, ForKey: .RingOrientation)
            }
            Delegate?.UpdateCurrent(With: CurrentShape)
        }
    }
    
    @IBAction func HandleDonutHoleSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(DonutHoleSizes.Small, EnumType: DonutHoleSizes.self, ForKey: .DonutHoleSize)
                
                case 1:
                    Settings.SetEnum(DonutHoleSizes.Medium, EnumType: DonutHoleSizes.self, ForKey: .DonutHoleSize)
                
                case 2:
                    Settings.SetEnum(DonutHoleSizes.Large, EnumType: DonutHoleSizes.self, ForKey: .DonutHoleSize)
                
                default:
                    Settings.SetEnum(DonutHoleSizes.Medium, EnumType: DonutHoleSizes.self, ForKey: .RingOrientation)
            }
            Delegate?.UpdateCurrent(With: CurrentShape)
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var DonutHoleSegment: NSSegmentedControl!
    @IBOutlet weak var OrientationSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}

