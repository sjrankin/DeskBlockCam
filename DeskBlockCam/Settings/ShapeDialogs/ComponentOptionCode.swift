//
//  ComponentOptionCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ComponentOptionCode: NSViewController, NSTableViewDelegate,
    NSTableViewDataSource, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        InitializeComponentCombo()
        InitializeShapeCombo()
        InitializeTable()
    }
    
    func InitializeTable()
    {
    }
    
    var ShapeList = [String]()
    
    func InitializeComponentCombo()
    {
        ComponentCombo.removeAllItems()
        ComponentCombo.addItems(withObjectValues:
            [
                VaryingComponents.Hue.rawValue,
                VaryingComponents.Saturation.rawValue,
                VaryingComponents.Brightness.rawValue,
                VaryingComponents.Red.rawValue,
                VaryingComponents.Green.rawValue,
                VaryingComponents.Blue.rawValue,
                VaryingComponents.Cyan.rawValue,
                VaryingComponents.Magenta.rawValue,
                VaryingComponents.Yellow.rawValue,
                VaryingComponents.Black.rawValue
        ])
        let VCom = Settings.GetEnum(ForKey: .VaryingComponent, EnumType: VaryingComponents.self,
                                    Default: VaryingComponents.Hue)
        ComponentCombo.selectItem(withObjectValue: VCom.rawValue)
        UpdateUI(With: VCom)
    }
    
    func InitializeShapeCombo()
    {
        ShapeCombo.removeAllItems()
        ShapeCombo.addItems(withObjectValues:
            [Shapes.Blocks.rawValue, Shapes.CappedLines.rawValue, Shapes.Characters.rawValue,
             Shapes.Circles.rawValue, Shapes.Cones.rawValue, Shapes.Cylinders.rawValue,
             Shapes.Polygons.rawValue, Shapes.Polygons2D.rawValue,
             Shapes.Pyramids.rawValue, Shapes.Spheres.rawValue, Shapes.Stars.rawValue,
             Shapes.Stars2D.rawValue, Shapes.Squares.rawValue, Shapes.Triangles.rawValue,
             Shapes.Triangles2D.rawValue, Shapes.Tubes.rawValue])
        ShapeCombo.selectItem(at: 0)
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
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return ShapeList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellIdentifier = ""
        var CellContents = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ShapeColumn"
            CellContents = ShapeList[row]
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleAddButtonPressed(_ sender: Any)
    {
        if let Raw = ShapeCombo.objectValueOfSelectedItem as? String
        {
            if let ActualShape = Shapes(rawValue: Raw)
            {
                ShapeList.append(ActualShape.rawValue)
                ShapeTable.reloadData()
                SaveShapeList()
                Delegate?.UpdateCurrent(With: CurrentShape)
            }
        }
    }
    
    @IBAction func HandleRemoveButtonPressed(_ sender: Any)
    {
        let Index = ShapeTable.selectedRow
        if Index < 0
        {
            return
        }
        ShapeList.remove(at: Index)
        ShapeTable.reloadData()
        SaveShapeList()
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    func SaveShapeList()
    {
        var Final = ""
        for Shape in ShapeList
        {
            Final.append(Shape)
            Final.append(",")
        }
        Final.removeLast(1)
        let Component = Settings.GetEnum(ForKey: .VaryingComponent, EnumType: VaryingComponents.self,
                                         Default: VaryingComponents.Hue)
        if let Key = ComponentShapeMap[Component]
        {
            Settings.SetString(Final, ForKey: Key)
        }
        else
        {
            fatalError("Did not find \(Component.rawValue) in ComponentShapeMap")
        }
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    let ComponentShapeMap: [VaryingComponents: SettingKeys] =
        [
            .Hue: .HueShapes,
            .Saturation: .SaturationShapes,
            .Brightness: .BrightnessShapes,
            .Red: .RedShapes,
            .Green: .GreenShapes,
            .Blue: .BlueShapes,
            .Cyan: .CyanShapes,
            .Magenta: .MagentaShapes,
            .Yellow: .YellowShapes,
            .Black: .BlackShapes
    ]
    
    func UpdateUI(With Component: VaryingComponents)
    {
        if let Key = ComponentShapeMap[Component]
        {
            ShapeList.removeAll()
            let RawList = Settings.GetString(ForKey: Key, Shapes.Blocks.rawValue)
            let Parts = RawList.split(separator: ",", omittingEmptySubsequences: true)
            for Part in Parts
            {
                ShapeList.append(String(Part))
            }
            ShapeTable.reloadData()
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
        InitializeTable()
    }
    
    @IBAction func HandleComponentChanged(_ sender: Any)
    {
        if let ComponentName = ComponentCombo.objectValueOfSelectedItem as? String
        {
            if let VCom = VaryingComponents(rawValue: ComponentName)
            {
                Settings.SetEnum(VCom, EnumType: VaryingComponents.self, ForKey: .VaryingComponent)
                UpdateUI(With: VCom)
                Delegate?.UpdateCurrent(With: CurrentShape)
            }
            else
            {
                fatalError("Found unexpected color component: \(ComponentName)")
            }
        }
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var ComponentCombo: NSComboBox!
    @IBOutlet weak var ShapeTable: NSTableView!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
