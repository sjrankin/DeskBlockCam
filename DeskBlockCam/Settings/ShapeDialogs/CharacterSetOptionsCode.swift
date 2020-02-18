//
//  CharacterSetOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

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
    
    @IBAction func HandleCharacterSetChanged(_ sender: Any)
    {
        if let Selected = CharacterCombo.objectValueOfSelectedItem as? String
        {
            ShowCharactersFor(CharacterSets(rawValue: Selected)!)
        }
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var CharBox: NSBox!
    @IBOutlet var CharactersView: NSTextView!
    @IBOutlet weak var CharacterCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
