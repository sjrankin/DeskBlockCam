//
//  ConeOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ConeOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        SwapTopBottomCheck.state = Settings.GetBoolean(ForKey: .ConeSwapTopBottom) ? .on : .off
        TopSizeCombo.removeAllItems()
        var TopSizes = [String]()
        for Top in ConeTopSizes.allCases
        {
            TopSizes.append(Top.rawValue)
        }
        TopSizeCombo.addItems(withObjectValues: TopSizes)
        let TopSize = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: .Zero)
        TopSizeCombo.selectItem(withObjectValue: TopSize.rawValue)
        
        BottomSizeCombo.removeAllItems()
        var BottomSizes = [String]()
        for Bottom in ConeBottomSizes.allCases
        {
            BottomSizes.append(Bottom.rawValue)
        }
        BottomSizeCombo.addItems(withObjectValues: BottomSizes)
        let BottomSize = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: .Side)
        BottomSizeCombo.selectItem(withObjectValue: BottomSize.rawValue)
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
    
    @IBAction func HandleSwapTopBottomChanged(_ sender: Any)
    {
        Settings.SetBoolean(SwapTopBottomCheck.state == .on, ForKey: .ConeSwapTopBottom)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    @IBAction func HandleTopSizeChanged(_ sender: Any)
    {
        if let Top = TopSizeCombo.objectValueOfSelectedItem as? String
        {
            if let TopSize = ConeTopSizes(rawValue: Top)
            {
                Settings.SetEnum(TopSize, EnumType: ConeTopSizes.self, ForKey: .ConeTopSize)
                Delegate?.UpdateCurrent(With: CurrentShape)
            }
        }
    }
    
    @IBAction func HandleBottomSizeChanged(_ sender: Any)
    {
        if let Bottom = BottomSizeCombo.objectValueOfSelectedItem as? String
        {
            if let BottomSize = ConeBottomSizes(rawValue: Bottom)
            {
                Settings.SetEnum(BottomSize, EnumType: ConeBottomSizes.self, ForKey: .ConeBottomSize)
                Delegate?.UpdateCurrent(With: CurrentShape)
            }
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var BottomSizeCombo: NSComboBox!
    @IBOutlet weak var TopSizeCombo: NSComboBox!
    @IBOutlet weak var SwapTopBottomCheck: NSButton!
    @IBOutlet weak var Caption: NSTextField!
}
