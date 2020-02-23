//
//  CharacterSetOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class CharacterSetOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        InitializeUI()
    }
    
    func InitializeUI()
    {
        CharacterCombo.removeAllItems()
        let AllSets = CharacterSets.allCases.sorted
        {
            $0.rawValue < $1.rawValue
        }
        for CSet in AllSets
        {
            CharacterCombo.addItem(withObjectValue: CSet.rawValue)
        }
        let Current = Settings.GetEnum(ForKey: .CharacterSet, EnumType: CharacterSets.self,
                                       Default: CharacterSets.Latin)
        CharacterCombo.selectItem(withObjectValue: Current.rawValue)
        ShowCharactersFor(Current)
        ExtrudeCharactersCheck.state = Settings.GetBoolean(ForKey: .FullyExtrudeLetters) ? .on : .off
        var Index = 0
        switch Settings.GetEnum(ForKey: .LetterSmoothness, EnumType: LetterSmoothnesses.self,
                                Default: LetterSmoothnesses.Smooth)
        {
            case .Roughest:
                Index = 0
            
            case .Rough:
                Index = 1
            
            case .Medium:
                Index = 2
            
            case .Smooth:
                Index = 3
            
            case .Smoothest:
                Index = 4
        }
        SmoothSegment.selectedSegment = Index
        ShowSample()
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
    
    func ShowCharactersFor(_ SomeSet: CharacterSets)
    {
        let (CharList, FontName) = ShapeManager.GetCharacterSetInfo(SomeSet)
        CharactersView.font = NSFont(name: FontName, size: 14.0)
        var Final = CharList.trimmingCharacters(in: CharacterSet.whitespaces)
        Final = Final.replacingOccurrences(of: "\n", with: "")
        Final = Final.replacingOccurrences(of: " ", with: "")
        CharactersView.string = Final
        CharBox.title = "Characters in set for font \(FontName)"
    }
    
    @IBAction func HandleSmoothnessChanged(_ sender: Any)
    {
        switch SmoothSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(LetterSmoothnesses.Roughest, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
            
            case 1:
                Settings.SetEnum(LetterSmoothnesses.Rough, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
            
            case 2:
                Settings.SetEnum(LetterSmoothnesses.Medium, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
            
            case 3:
                Settings.SetEnum(LetterSmoothnesses.Smooth, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
            
            case 4:
                Settings.SetEnum(LetterSmoothnesses.Smoothest, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
            
            default:
                Settings.SetEnum(LetterSmoothnesses.Smooth, EnumType: LetterSmoothnesses.self,
                                 ForKey: .LetterSmoothness)
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
        ShowSample()
    }
    
    @IBAction func HandleCharacterSetChanged(_ sender: Any)
    {
        if let Selected = CharacterCombo.objectValueOfSelectedItem as? String
        {
            ShowCharactersFor(CharacterSets(rawValue: Selected)!)
            Delegate?.UpdateCurrent(With: CurrentShape)
            ShowSample()
        }
    }
    
    @IBAction func HandleExtrusionChanged(_ sender: Any)
    {
        Settings.SetBoolean(ExtrudeCharactersCheck.state == .on, ForKey: .FullyExtrudeLetters)
        Delegate?.UpdateCurrent(With: CurrentShape)
        ShowSample()
    }
    
    func ShowSample()
    {
        if !SampleInitialized
        {
            SampleInitialized = true
            CharSample.scene = SCNScene()
            CharSample.scene?.background.contents = NSColor.black
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(0.0, 0.0, 15.0)
            CharSample.scene?.rootNode.addChildNode(CameraNode)
            let Light = SCNLight()
            Light.color = NSColor.white
            Light.type = .omni
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-2.0, 2.0, 15.0)
            CharSample.scene?.rootNode.addChildNode(LightNode)
        }
        if CharNode != nil
        {
            CharNode?.removeFromParentNode()
            CharNode = nil
        }
        var Scale: Double = 1.0
        let Geo = Generator.GenerateCharacterFromSet(Prominence: 2.0, FinalScale: &Scale)
        CharNode = SCNNode(geometry: Geo)
        CharNode?.position = SCNVector3(-3.0, -6.0, 0.0)
        CharNode?.scale = SCNVector3(0.6, 0.6, 0.6)
        CharNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
        CharNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
        CharNode?.geometry?.firstMaterial?.lightingModel = Generator.GetLightModel()
        CharSample.scene?.rootNode.addChildNode(CharNode!)
    }
    
    var CharNode: SCNNode? = nil
    
    var SampleInitialized = false
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var CharSample: SCNView!
    @IBOutlet weak var SmoothSegment: NSSegmentedControl!
    @IBOutlet weak var ExtrudeCharactersCheck: NSButton!
    @IBOutlet weak var CharBox: NSBox!
    @IBOutlet var CharactersView: NSTextView!
    @IBOutlet weak var CharacterCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
