//
//  ComponentOptionsCode2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ComponentOptionCode2: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource,
    ToOptionsDialogProtocol
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
    
    var ShapeList = [(Name: String, ID: UUID)]()
    
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
        
        CurrentShapes.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
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
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return ShapeList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        let Item = CurrentShapes.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShapeSwatchItem"), for: indexPath)
        guard let SomeItem = Item as? ShapeSwatchItem else
        {
            return Item
        }
        SomeItem.SetShape(ShapeList[indexPath.item].Name, Index: indexPath.item + 1, ID: ShapeList[indexPath.item].ID)
        SomeItem.SetSelectionState(To: SelectedIndex == indexPath.item ? true : false)
        return SomeItem
    }
    
    var SelectedIndex = -1
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        let Index = indexPaths.first!.item
        SelectedIndex = Index
        CurrentShapes.reloadData()
    }
    
    //https://stackoverflow.com/questions/46439454/swift-osx-rearrange-nscollectionview-with-drag-and-drop-not-working
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool
    {
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting?
    {
        let Item = NSPasteboardItem()
        let DraggedShapeID = ShapeList[indexPath.item].ID
        Item.setString(DraggedShapeID.uuidString, forType: NSPasteboard.PasteboardType.string)
        return Item
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession,
                        willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>)
    {
        DraggedItems = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession,
                        endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation)
    {
        DraggedItems = []
    }
    
    var DraggedItems: Set<IndexPath>? = nil
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo,
                        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
                        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        if proposedDropOperation.pointee == NSCollectionView.DropOperation.on
        {
            proposedDropOperation.pointee = NSCollectionView.DropOperation.before
        }
        
        return NSDragOperation.move
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo,
                        indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool
    {
        if DraggedItems!.count == 1
        {
            for Item in DraggedItems!
            {
                let Destination = (indexPath.item <= Item.item) ? indexPath : (IndexPath(item: indexPath.item - 1, section: 0))
                collectionView.animator().moveItem(at: Item, to: Destination)
                print("Moving item from \(Item.item) to \(Destination.item)")
                ShapeList.swapAt(Item.item, Destination.item)
                CurrentShapes.reloadData()
                SaveShapeList()
            }
        }
        return true
    }
    
    @IBAction func HandleAddButtonPressed(_ sender: Any)
    {
        if let Raw = ShapeCombo.objectValueOfSelectedItem as? String
        {
            if let ActualShape = Shapes(rawValue: Raw)
            {
                ShapeList.append((ActualShape.rawValue, UUID()))
                CurrentShapes.reloadData()
                SaveShapeList()
            }
        }
    }
    
    @IBAction func HandleRemoveButtonPressed(_ sender: Any)
    {
        if SelectedIndex < 0
        {
            return
        }
        ShapeList.remove(at: SelectedIndex)
        SelectedIndex = -1
        CurrentShapes.reloadData()
        SaveShapeList()
    }
    
    func SaveShapeList()
    {
        var Final = ""
        for Shape in ShapeList
        {
            Final.append(Shape.Name)
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
                ShapeList.append((String(Part), UUID()))
            }
            CurrentShapes.reloadData()
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
    
    @IBOutlet weak var CurrentShapes: NSCollectionView!
    @IBOutlet weak var ComponentCombo: NSComboBox!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var Caption: NSTextField!
}
