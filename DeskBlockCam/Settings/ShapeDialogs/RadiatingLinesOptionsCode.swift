//
//  RadiatingLinesOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

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
        let Thick = Settings.GetEnum(ForKey: .RadialLineThickness, EnumType: LineThicknesses.self, Default: .Medium)
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
        ShowSample(WithCount: Count)
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
        ShowSample(WithCount: Settings.GetInteger(ForKey: .LineCount))
    }
    
    @IBAction func HandleLineThicknessChanged(_ sender: Any)
    {
        switch LineThickSegments.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Thin, EnumType: LineThicknesses.self, ForKey: .RadialLineThickness)
            
            case 1:
                Settings.SetEnum(.Medium, EnumType: LineThicknesses.self, ForKey: .RadialLineThickness)
            
            case 2:
                Settings.SetEnum(.Thick, EnumType: LineThicknesses.self, ForKey: .RadialLineThickness)
            
            default:
                Settings.SetEnum(.Thin, EnumType: LineThicknesses.self, ForKey: .RadialLineThickness)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
         ShowSample(WithCount: Settings.GetInteger(ForKey: .LineCount))
    }
    
    var SampleInitialized = false
    
    func ShowSample(WithCount: Int)
    {
        if !SampleInitialized
        {
            SampleInitialized = true
            LineSample.scene = SCNScene()
            LineSample.scene?.background.contents = NSColor.black
            let Light = SCNLight()
            Light.color = NSColor.white
            Light.type = .omni
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-4.0, 4.0, 15.0)
            LineSample.scene?.rootNode.addChildNode(LightNode)
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(1.0, 1.0, 15.0)
            LineSample.scene?.rootNode.addChildNode(CameraNode)
        }
        if SampleLine != nil
        {
            SampleLine?.removeFromParentNode()
            SampleLine = nil
        }
        SampleLine = Generator.SingleShape(.RadiatingLines, Color: NSColor.yellow, Side: 2.0)
        SampleLine?.position = SCNVector3(0.0, 0.0, 0.0)
        LineSample.scene?.rootNode.addChildNode(SampleLine!)
    }
    
    var SampleLine: PSCNNode? = nil
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var LineSample: SCNView!
    @IBOutlet weak var LineCountSegment: NSSegmentedControl!
    @IBOutlet weak var LineThickSegments: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
