//
//  ShapeOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ShapeOptionsCode: NSViewController, NSTabViewDelegate,
    NSOutlineViewDataSource, NSOutlineViewDelegate,
    ToOptionsParentProtocol
{
    private let ShapeTableTag = 100
    private let ShapesOutlineTag = 100
    private let CurrentSettingsTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeShapes()
        ShapeOutlineView.reloadData()
    }
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
        CurrentAttributes = Attributes
    }
    
    func GetCurrentAttributeData(From: ProcessingAttributes) -> [CurrentTreeNode]
    {
        let Results = [CurrentTreeNode]()
        return Results
    }
    
    func InitializeShapes()
    {
        AllShapes = [ShapeTreeNode]()
        for Category in Categories
        {
            let NewNode = ShapeTreeNode(Category: Category.Name, Shapes: Category.Shapes)
            AllShapes!.append(NewNode)
        }
        CreateOptionDialogs()
    }
    
    var AllShapes: [ShapeTreeNode]!

    
    // MARK: - Outline view functions.
    
    //https://qtsoftware.co.uk/programming/swift/solved-how-to-use-outline-views-in-swift-4/
    let Categories =
        [
            ShapeCategory(Name: "Standard", Shapes: [Shapes.Blocks.rawValue, Shapes.Spheres.rawValue, Shapes.Cones.rawValue,
                                                     Shapes.Rings.rawValue, Shapes.Tubes.rawValue, Shapes.Cylinders.rawValue,
                                                     Shapes.Pyramids.rawValue]),
            ShapeCategory(Name: "Non-Standard", Shapes: [Shapes.Triangles.rawValue, Shapes.Pentagons.rawValue,
                                                         Shapes.Hexagons.rawValue, Shapes.Octagons.rawValue,
                                                         Shapes.Stars.rawValue, Shapes.Diamonds.rawValue,
                                                         Shapes.Ovals.rawValue]),
            ShapeCategory(Name: "2D Shapes", Shapes: [Shapes.Squares.rawValue, Shapes.Circles.rawValue, Shapes.Triangles2D.rawValue,
                                                      Shapes.Pentagons2D.rawValue, Shapes.Hexagons2D.rawValue,
                                                      Shapes.Octagons2D.rawValue, Shapes.Stars2D.rawValue]),
            ShapeCategory(Name: "Combined", Shapes: [Shapes.CappedLines.rawValue, Shapes.StackedShapes.rawValue,
                                                     Shapes.PerpendicularSquares.rawValue, Shapes.PerpendicularCircles.rawValue,
                                                     Shapes.HueVarying.rawValue, Shapes.SaturationVarying.rawValue,
                                                     Shapes.BrightnessVarying.rawValue]),
            ShapeCategory(Name: "Complex", Shapes: [Shapes.HueTriangles.rawValue, Shapes.Characters.rawValue, Shapes.RadiatingLines.rawValue])
    ]

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        switch outlineView.tag
        {
            case ShapeTableTag:
                if let SomeShape = item as? ShapeTreeNode
                {
                    return SomeShape.Shapes[index]
                }
                return AllShapes![index]
            
            case CurrentSettingsTag:
            return 0
            
            default:
            return 0
        }

    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        switch outlineView.tag
        {
            case ShapeTableTag:
                if let SomeShape = item as? ShapeTreeNode
                {
                    return SomeShape.Shapes.count > 0
                }
                return false
            
            case CurrentSettingsTag:
            return false
            
            default:
            return false
        }

    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        switch outlineView.tag
        {
            case ShapeTableTag:
                if AllShapes == nil
                {
                    return 0
                }
                if let SomeShape = item as? ShapeTreeNode
                {
                    return SomeShape.Shapes.count
                }
                return AllShapes!.count
            
            case CurrentSettingsTag:
            return 0
            
            default:
            return 0
        }

    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        switch outlineView.tag
        {
            case ShapeTableTag:
                var Text = ""
                if let SomeShape = item as? ShapeTreeNode
                {
                    Text = SomeShape.Category
                }
                else
                {
                    Text = item as! String
                }
                
                let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryCell"), owner: self) as! NSTableCellView
                tableCell.textField!.stringValue = Text
                return tableCell
            
            case CurrentSettingsTag:
            return nil
            
            default:
            return nil
        }

    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outView = notification.object as? NSOutlineView else
        {
            return
        }
        switch outView.tag
        {
            case ShapeTableTag:
                let SelectedIndex = outView.selectedRow
                if let ShapeName = outView.item(atRow: SelectedIndex) as? String
                {
                    if let SelectedShape = Shapes(rawValue: ShapeName)
                    {
                        DisplayShapeOptions(For: SelectedShape)
                        OptionBox.title = "Options for \(ShapeName)"
                    }
            }
            
            case CurrentSettingsTag:
            break
            
            default:
            break
        }

    }
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
    {
        CurrentAttributes = Updated
    }
    
    var CurrentAttributes: ProcessingAttributes = ProcessingAttributes()
    
    // MARK: - Option dialog variables.
    
    var OptionMap = [Shapes: OptionEntry]()
    
    // MARK: - Infrastructure functions.
    
    @IBAction func HandleApplyPressed(_ sender: Any)
    {
    }
    
    // MARK: - Handle tab view events.
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?)
    {
        
    }
    
    // MARK: - Options interface builder outlets.
    
    @IBOutlet weak var OptionBox: NSBox!
    @IBOutlet weak var OptionsContainer: NSView!
    @IBOutlet weak var ShapeOutlineView: NSOutlineView!
    
    // MARK: - Current settings outline
    
    @IBOutlet weak var CurrentSettingsTable: NSOutlineView!
    
    // MARK: - TabView interface builder outlets.
    
    @IBOutlet weak var TabView: NSTabView!
    
    // MARK: - General interface builder outlets.
    
    @IBOutlet weak var ApplyButton: NSButton!
}

class ShapeTreeNode
{
    var Category: String!
    var Shapes: [String]!
    
    init(Category: String, Shapes: [String])
    {
        self.Category = Category
        self.Shapes = Shapes
    }
}

class CurrentTreeNode
{
    var Category: String!
    var Properties: [(Key: String, Value: String)]!
    
    init(Category: String, Properties: [(Key: String, Value: String)])
    {
        self.Category = Category
        self.Properties = Properties
    }
}

class ShapeCategory
{
    var Name: String!
    var Shapes: [String]!
    
    init(Name: String, Shapes: [String])
    {
        self.Name = Name
        self.Shapes = Shapes
    }
}

class OptionEntry
{
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    public var Controller: NSViewController? = nil
}
