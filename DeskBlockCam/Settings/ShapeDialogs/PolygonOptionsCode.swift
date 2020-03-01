//
//  PolygonOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class PolygonOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Count = GetPolygonSideCount()
        SideCountSegment.selectedSegment = Count - 3
        ShowSample(WithCount: Count)
        switch CurrentShape
        {
            case .Polygons:
                Option2DBox.isHidden = true
            
            case .Polygons2D:
                Option2DBox.isHidden = false
                let Orientation = Settings.GetEnum(ForKey: .PolygonAxis, EnumType: LongAxes.self, Default: .Z)
                switch Orientation
                {
                    case .X:
                        AxisSegment.selectedSegment = 0
                    
                    case .Y:
                        AxisSegment.selectedSegment = 1
                    
                    case .Z:
                        AxisSegment.selectedSegment = 2
                }
                let ColorAffect = Settings.GetEnum(ForKey: .PolygonColorControl, EnumType: ColorControls.self, Default: .Height)
                switch ColorAffect
                {
                    case .Size:
                        ColorSegment.selectedSegment = 0
                    
                    case .Height:
                        ColorSegment.selectedSegment = 1
            }
            
            default:
                fatalError("Invalid shape \(CurrentShape.rawValue) encountered in PolygonOptionsCode")
        }
    }
    
    func GetPolygonSideCount() -> Int
    {
        var Setting = SettingKeys.PolygonSideCount
        if CurrentShape == .Polygons2D
        {
            Setting = .Polygon2DSideCount
        }
        let Count = Settings.GetInteger(ForKey: Setting)
        if Count < 1
        {
            Settings.SetInteger(6, ForKey: Setting)
            return 6
        }
        return Count
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
    
    @IBAction func HandleSideCountChanged(_ sender: Any)
    {
        let Index = SideCountSegment.selectedSegment + 3
        var Setting = SettingKeys.PolygonSideCount
        if CurrentShape == .Polygons2D
        {
            Setting = .Polygon2DSideCount
        }
        Settings.SetInteger(Index, ForKey: Setting)
        ShowSample(WithCount: Index)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var SampleInitialized = false
    
    func ShowSample(WithCount: Int)
    {
        if !SampleInitialized
        {
            SampleInitialized = true
            PolygonSample.scene = SCNScene()
            PolygonSample.scene?.background.contents = NSColor.black
            let Light = SCNLight()
            Light.color = NSColor.white
            Light.type = .omni
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-4.0, 4.0, 15.0)
            PolygonSample.scene?.rootNode.addChildNode(LightNode)
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(1.0, 1.0, 15.0)
            PolygonSample.scene?.rootNode.addChildNode(CameraNode)
        }
        if SamplePolygon != nil
        {
            SamplePolygon?.removeFromParentNode()
            SamplePolygon = nil
        }
        var PolygonDepth = 1.0
        var DiffuseColor = NSColor.systemYellow
        switch CurrentShape
        {
            case .Polygons:
                DiffuseColor = NSColor.systemYellow
                PolygonDepth = 5.0
            
            case .Polygons2D:
                DiffuseColor = NSColor.systemBlue
                PolygonDepth = 0.1
            
            default:
                fatalError("Unexpected shape \(CurrentShape.rawValue) encountered.")
        }
        SamplePolygon = SCNPolygon(VertexCount: WithCount, Radius: 10.0, Depth: CGFloat(PolygonDepth))
        SamplePolygon?.geometry?.firstMaterial?.lightingModel = .lambert
        SamplePolygon?.geometry?.firstMaterial?.diffuse.contents = DiffuseColor
        SamplePolygon?.geometry?.firstMaterial?.specular.contents = NSColor.white
        PolygonSample.scene?.rootNode.addChildNode(SamplePolygon!)
    }
    
    var SamplePolygon: SCNPolygon? = nil
    
    var CurrentShape: Shapes = .NoShape
    
    @IBAction func HandleAxisChanged(_ sender: Any)
    {
        switch AxisSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.X, EnumType: LongAxes.self, ForKey: .PolygonAxis)
            
            case 1:
                Settings.SetEnum(.Y, EnumType: LongAxes.self, ForKey: .PolygonAxis)
            
            case 2:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: .PolygonAxis)
            
            default:
                Settings.SetEnum(.Z, EnumType: LongAxes.self, ForKey: .PolygonAxis)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleColorChanged(_ sender: Any)
    {
        switch ColorSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Size, EnumType: ColorControls.self, ForKey: .PolygonColorControl)
            
            case 1:
                Settings.SetEnum(.Height, EnumType: ColorControls.self, ForKey: .PolygonColorControl)
            
            default:
                Settings.SetEnum(.Height, EnumType: ColorControls.self, ForKey: .PolygonColorControl)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBOutlet weak var ColorSegment: NSSegmentedControl!
    @IBOutlet weak var AxisSegment: NSSegmentedControl!
    @IBOutlet weak var Option2DBox: NSBox!
    @IBOutlet weak var PolygonSample: SCNView!
    @IBOutlet weak var SideCountSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
