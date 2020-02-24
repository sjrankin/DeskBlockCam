//
//  StackedShapesOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StackedShapesOptionCode: NSViewController, NSTableViewDelegate,
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
        InitializeShapeCombo()
        InitializeTable()
    }
    
    func InitializeTable()
    {
        if CurrentShape == .NoShape
        {
            return
        }
        let RawShapeList: String = Settings.GetString(ForKey: .StackedShapeList, Shapes.Blocks.rawValue)
        let Parts = RawShapeList.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            ShapeList.append(String(Part))
        }
        
    }
    
    var ShapeList = [String]()
    
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
        Settings.SetString(Final, ForKey: .StackedShapeList)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
        InitializeTable()
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var ShapeTable: NSTableView!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
