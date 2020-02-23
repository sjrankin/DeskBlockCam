//
//  StarOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class StarOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Varies = Settings.GetBoolean(ForKey: .ApexesIncrease)
        let Apexes = Settings.GetInteger(ForKey: .StarApexCount)
        ApexSegment.selectedSegment = Apexes - 4
        VariableApexesCheck.state = Varies ? .on : .off
        ShowSample(Apexes)
    }
    
    var NewCaption: String = ""
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
    }
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
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
    
    @IBAction func HandleVariableApexesChanged(_ sender: Any)
    {
        Settings.SetBoolean(VariableApexesCheck.state == .on, ForKey: .ApexesIncrease)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleApexCountChanged(_ sender: Any)
    {
        let Index = ApexSegment.selectedSegment + 4
        Settings.SetInteger(Index, ForKey: .StarApexCount)
        Delegate?.UpdateCurrent(With: CurrentShape)
        ShowSample(Index)
    }
    
        var SampleInitialized = false
    
    func ShowSample(_ ApexCount: Int)
    {
        if !SampleInitialized
        {
            SampleInitialized = true
            StarSample.scene = SCNScene()
            StarSample.scene?.background.contents = NSColor.black
            let Light = SCNLight()
            Light.color = NSColor.white
            Light.type = .omni
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-4.0, 4.0, 15.0)
            StarSample.scene?.rootNode.addChildNode(LightNode)
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(1.0, 1.0, 15.0)
            StarSample.scene?.rootNode.addChildNode(CameraNode)
        }
        if SampleStar != nil
        {
            SampleStar?.removeFromParentNode()
            SampleStar = nil
        }
  
        SampleStar = SCNStar(VertexCount: ApexCount, Height: 10.0, Base: 5.0, ZHeight: 5.0)
        SampleStar?.geometry?.firstMaterial?.lightingModel = .lambert
        SampleStar?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
        SampleStar?.geometry?.firstMaterial?.specular.contents = NSColor.white
        StarSample.scene?.rootNode.addChildNode(SampleStar!)
    }
    
    var SampleStar: SCNStar? = nil
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var StarSample: SCNView!
    @IBOutlet weak var VariableApexesCheck: NSButton!
    @IBOutlet weak var ApexSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
