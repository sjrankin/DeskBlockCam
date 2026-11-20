//
//  ParticleWithOptionCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/22/23.
//  Copyright © 2023 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Options for the particles shape.
///
/// The outlets and actions here must match the "ParticleOptions" scene in `Settings.storyboard`, which was made by
/// copying the capped lines dialog. If one is missing, loading the scene throws a key-value coding exception and the app
/// crashes as soon as Dynamic > Particles is chosen.
class ParticlesWithOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        CapShapeCombo.removeAllItems()
        CapShapeCombo.addItems(withObjectValues:
                                [
                                    Shapes.Spheres.rawValue,
                                    Shapes.Cones.rawValue,
                                    Shapes.Pyramids.rawValue,
                                    Shapes.Lines.rawValue,
                                    Shapes.Capsules.rawValue
                                ])
        let ExShape = Settings.GetEnum(ForKey: .BlockWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
        if CapShapeCombo.objectValues.contains(where: {($0 as? String) == ExShape.rawValue})
        {
            CapShapeCombo.selectItem(withObjectValue: ExShape.rawValue)
        }
        else
        {
            CapShapeCombo.selectItem(withObjectValue: Shapes.Cones.rawValue)
        }
        // The storyboard scene was copied from the capped lines dialog; these two controls do not apply to particles.
        ShapeLocationSegment.isEnabled = false
        LineColorSegment.isEnabled = false
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
    
    /// The particle shape was chosen.
    @IBAction func HandleShapeChanged(_ sender: Any)
    {
        if let Selected = CapShapeCombo.objectValueOfSelectedItem as? String,
           let NewShape = Shapes(rawValue: Selected)
        {
            Settings.SetEnum(NewShape, EnumType: Shapes.self, ForKey: .BlockWithShape)
            Delegate?.UpdateCurrent(With: CurrentShape)
        }
    }
    
    /// Not used for particles (the control is disabled); present because the storyboard connects it.
    @IBAction func HandleLocationChanged(_ sender: Any)
    {
    }
    
    /// Not used for particles (the control is disabled); present because the storyboard connects it.
    @IBAction func HandleLineColorChanged(_ sender: Any)
    {
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var CapShapeCombo: NSComboBox!
    @IBOutlet weak var LineColorSegment: NSSegmentedControl!
    @IBOutlet weak var ShapeLocationSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
