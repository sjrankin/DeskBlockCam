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
    }
    
    func InitializeShapeCombo()
    {
        ShapeCombo.removeAllItems()
        ShapeCombo.addItems(withObjectValues:
            [Shapes.Blocks.rawValue, Shapes.CappedLines.rawValue, Shapes.Characters.rawValue,
             Shapes.Circles.rawValue, Shapes.Cones.rawValue, Shapes.Cylinders.rawValue,
             Shapes.Hexagons.rawValue, Shapes.Hexagons2D.rawValue, Shapes.Octagons.rawValue,
             Shapes.Octagons2D.rawValue, Shapes.Pentagons.rawValue, Shapes.Pentagons2D.rawValue,
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
    
    var StackedShapes = [Shapes]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return StackedShapes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellIdentifier = ""
        var CellContents = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ShapeColumn"
            CellContents = StackedShapes[row].rawValue
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
                StackedShapes.append(ActualShape)
                ShapeTable.reloadData()
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
        StackedShapes.remove(at: Index)
        ShapeTable.reloadData()
    }
    
    @IBOutlet weak var ShapeTable: NSTableView!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
