//
//  ShapeOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class ShapeOptionsCode: NSViewController, NSTabViewDelegate,
    NSOutlineViewDataSource, NSOutlineViewDelegate,
    NSCollectionViewDelegate, NSCollectionViewDataSource,
    ToOptionsParentProtocol
{
    private let ShapeTableTag = 100
    private let ShapesOutlineTag = 100
    private let SideBarTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeShapes()
        ShapeOutlineView.reloadData()
        InitializeColorSwatches()
        InitializeGradientSwatches()
        InitializeLighting()
        InitializeLiveView()
        InitializeSideBar()
        LastTouchedShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        if LastTouchedShape == .NoShape
        {
            CurrentShapeTitle.stringValue = ""
        }
        else
        {
            CurrentShapeTitle.stringValue = LastTouchedShape.rawValue
            //DisplayShapeOptions(For: LastTouchedShape)
        }
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
    
    @IBOutlet weak var CurrentSettings: NSOutlineView!
    
    /// Initialize the current settings side bar.
    func InitializeSideBar()
    {
        CurrentSettings.reloadData()
        CurrentSettings.expandItem(Current[1])
        CurrentSettings.expandItem(Current[2])
        let CurrentShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        UpdateShapeSettings(With: CurrentShape)
    }
    
    /// Update the current side bar shape settings.
    /// - Parameter With: The new shape.
    func UpdateShapeSettings(With NewShape: Shapes)
    {
        let ShapeName = NewShape.rawValue
        
        Current[1].ValueItems.removeAll()
        Current[1].ValueItems.append(ValueItem(Description: "Shape", Value: ShapeName, Color: NSColor.systemBlue))
        switch NewShape
        {
            case .Blocks:
                let Chamfer = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self, Default: BlockChamferSizes.None)
                Current[1].ValueItems.append(ValueItem(Description: "Chamfer", Value: Chamfer.rawValue))
            
            case .BrightnessVarying:
                let Shapes = Settings.GetString(ForKey: .BrightnessShapes)
                Current[1].ValueItems.append(ValueItem(Description: "Shapes", Value: Shapes!))
            
            case .HueVarying:
                let Shapes = Settings.GetString(ForKey: .HueShapes)
                Current[1].ValueItems.append(ValueItem(Description: "Shapes", Value: Shapes!))
            
            case .SaturationVarying:
                let Shapes = Settings.GetString(ForKey: .SaturationShapes)
                Current[1].ValueItems.append(ValueItem(Description: "Shapes", Value: Shapes!))
            
            case .CappedLines:
                let Location = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self, Default: CapLocations.Top)
                let CapShape = Settings.GetEnum(ForKey: .CapShape, EnumType: Shapes.self, Default: Shapes.Spheres)
                Current[1].ValueItems.append(ValueItem(Description: "Location", Value: Location.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Shape", Value: CapShape.rawValue))
            
            case .Characters:
                let CharSet = Settings.GetEnum(ForKey: .CharacterSet, EnumType: CharacterSets.self, Default: CharacterSets.Latin)
                Current[1].ValueItems.append(ValueItem(Description: "Character set", Value: CharSet.rawValue))
            
            case .Cones:
                let Top = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: ConeTopSizes.Zero)
                let Bottom = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: ConeBottomSizes.Side)
                let Invert = Settings.GetBoolean(ForKey: .ConeSwapTopBottom)
                Current[1].ValueItems.append(ValueItem(Description: "Top size", Value: Top.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Bottom size", Value: Bottom.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Invert top/bottom", Value: "\(Invert)"))
            
            case .Diamonds:
                let Orientation = Settings.GetEnum(ForKey: .DiamondOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
                let Distance = Settings.GetEnum(ForKey: .DiamondLength, EnumType: Distances.self, Default: Distances.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Length", Value: Distance.rawValue))
            
            case .Ovals:
                let Orientation = Settings.GetEnum(ForKey: .OvalOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
                let Distance = Settings.GetEnum(ForKey: .OvalLength, EnumType: Distances.self, Default: Distances.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Length", Value: Distance.rawValue))
            
            case .RadiatingLines:
                let LineCount = Settings.GetInteger(ForKey: .LineCount)
                let Thickness = Settings.GetEnum(ForKey: .LineThickness, EnumType: LineThickenesses.self, Default: LineThickenesses.Thin)
                Current[1].ValueItems.append(ValueItem(Description: "Line count", Value: "\(LineCount)"))
                Current[1].ValueItems.append(ValueItem(Description: "Thickness", Value: Thickness.rawValue))
            
            case .Rings:
                let Orientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self, Default: RingOrientations.Flat)
                let DonutHole = Settings.GetEnum(ForKey: .DonutHoleSize, EnumType: DonutHoleSizes.self, Default: DonutHoleSizes.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Hole size", Value: DonutHole.rawValue))
            
            case .Spheres:
                let SphereB = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self, Default: SphereBehaviors.Size)
                Current[1].ValueItems.append(ValueItem(Description: "Prominence", Value: SphereB.rawValue))
            
            case .StackedShapes:
                let Shapes = Settings.GetString(ForKey: .StackedShapeList)
                Current[1].ValueItems.append(ValueItem(Description: "Shapes", Value: Shapes!))
            
            case .Stars:
                let Apexes = Settings.GetInteger(ForKey: .StarApexCount)
                let Intensity = Settings.GetBoolean(ForKey: .ApexesIncrease)
                Current[1].ValueItems.append(ValueItem(Description: "Apex count", Value: "\(Apexes)"))
                Current[1].ValueItems.append(ValueItem(Description: "Variable apexes", Value: "\(Intensity)"))
            
            default:
                break
        }
        CurrentSettings.reloadData()
    }
    
    var Current =
        [
            CurrentCategory(Name: "Current Settings", Icon: nil, Values: []),
            CurrentCategory(Name: "Shape Settings", Icon: NSImage(named: "ShapeIcon"),
                            Values: [
                                ValueItem(Description: "Shape", Value: "Some Shape"),
                                ValueItem(Description: "option 1", Value: "option value"),
                                ValueItem(Description: "option 2", Value: "option value")
            ]),
            CurrentCategory(Name: "Height Settings", Icon: NSImage(named: "HeightIcon"),
                            Values: [
                                ValueItem(Description: "Height from", Value: "brightness"),
                                ValueItem(Description: "Exaggeration", Value: "Medium"),
                                ValueItem(Description: "Invert height", Value: "false")
            ]),
            CurrentCategory(Name: "Color Settings", Icon: NSImage(named: "PaintbrushIcon"),
                            Values: [
                                ValueItem(Description: "Conditional colors", Value: "none"),
                                ValueItem(Description: "Action", Value: "Decrease saturation"),
                                ValueItem(Description: "Threshold", Value: "0.50"),
                                ValueItem(Description: "Invert threshold", Value: "false"),
            ]),
            CurrentCategory(Name: "Lighting Settings", Icon: NSImage(named: "LightbulbIcon"),
                            Values: [
                                ValueItem(Description: "Type", Value: "Omni"),
                                ValueItem(Description: "Color", Value: "white"),
                                ValueItem(Description: "Intensity", Value: "normal"),
                                ValueItem(Description: "Model", Value: "Phong"),
            ]),
            CurrentCategory(Name: "Processing Settings", Icon: NSImage(named: "PerformanceIcon"),
                            Values: [
                                ValueItem(Description: "Shape size", Value: "16"),
                                ValueItem(Description: "Maximum size", Value: "1024")
            ]),
            CurrentCategory(Name: "Background Settings", Icon: NSImage(named: "PhotoIcon"),
                            Values: [
                                ValueItem(Description: "Type", Value: "Color"),
                                ValueItem(Description: "Color", Value: "some color"),
                                ValueItem(Description: "Gradient", Value: "some gradient")
            ]),
            CurrentCategory(Name: "Live View Settings", Icon: nil, Values: []),
            CurrentCategory(Name: "Live View Settings", Icon: NSImage(named: "TVIcon"),
                            Values: [
                                ValueItem(Description: "Shape", Value: "Block")
            ])
    ]
    
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
            
            case SideBarTag:
                if let SomeItem = item as? CurrentCategory
                {
                    return SomeItem.ValueItems[index]
                }
                else
                {
                    return Current[index]
            }
            
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
            
            case SideBarTag:
                if let SomeItem = item as? CurrentCategory
                {
                    return SomeItem.ValueItems.count > 0
                }
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
            
            case SideBarTag:
                if Current.count < 1
                {
                    return 0
                }
                if let SomeItem = item as? CurrentCategory
                {
                    return SomeItem.ValueItems.count
                }
                return Current.count
            
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
            
            case SideBarTag:
                var Text = ""
                var Image: NSImage? = nil
                var FontSize: CGFloat = 13.0
                var IsHeader = false
                var TextColor = NSColor.black
                if let SomeItem = item as? CurrentCategory
                {
                    Text = SomeItem.Name
                    Image = SomeItem.Icon
                    FontSize = 13.0
                    if Image == nil
                    {
                        IsHeader = true
                    }
                }
                else
                {
                    if let Item = item as? ValueItem
                    {
                        Text = Item.Description + ": " + Item.Value
                        FontSize = 11.0
                        TextColor = Item.TextColor
                    }
                }
                var tableCell: NSTableCellView!
                if IsHeader
                {
                    tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "IconlessHeader"), owner: self) as? NSTableCellView
                }
                else
                {
                    tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CurrentCell"), owner: self) as? NSTableCellView
                    tableCell.imageView!.image = Image
                    tableCell.textField!.font = NSFont.systemFont(ofSize: FontSize)
                    tableCell.textField!.textColor = TextColor
                }
                tableCell.textField!.stringValue = Text
                return tableCell
            
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
                        LastTouchedShape = SelectedShape
                        UpdateShapeSettings(With: SelectedShape)
                        DisplayShapeOptions(For: SelectedShape)
                    }
            }
            
            case SideBarTag:
                let SelectedIndex = outView.selectedRow
                if let Name = outView.item(atRow: SelectedIndex) as? String
                {
                    print("Selected \(Name)")
            }
            
            default:
                break
        }
    }
    
    var LastTouchedShape: Shapes = .NoShape
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
    {
        CurrentAttributes = Updated
    }
    
    var CurrentAttributes: ProcessingAttributes = ProcessingAttributes()
    
    // MARK: - Colors functions
    
    func InitializeColorSwatches()
    {
        ColorSwatchView.enclosingScrollView?.borderType = .noBorder
        ColorSwatchView.wantsLayer = true
        ColorSwatchView.backgroundColors = [NSColor.clear]
        ColorSwatchView.reloadData()
    }
    
    func InitializeGradientSwatches()
    {
        GradientList.append((NSColor.white, NSColor.black))
        GradientList.append((NSColor.black, NSColor.white))
        GradientList.append((NSColor.gray, NSColor.black))
        GradientList.append((NSColor.gray, NSColor.blue))
        GradientList.append((NSColor.red, NSColor.black))
        GradientList.append((NSColor.white, NSColor.red))
        GradientList.append((NSColor.blue, NSColor.black))
        GradientList.append((NSColor.yellow, NSColor.systemYellow))
        GradientList.append((NSColor.systemYellow, NSColor.red))
        GradientList.append((NSColor.systemYellow, NSColor.systemOrange))
        GradientList.append((NSColor.gray, NSColor.systemGray))
        GradientList.append((NSColor.cyan, NSColor.systemBlue))
        GradientSwatchView.enclosingScrollView?.borderType = .noBorder
        GradientSwatchView.wantsLayer = true
        GradientSwatchView.backgroundColors = [NSColor.clear]
        GradientSwatchView.reloadData()
    }
    
    var ColorList: [(Name: String, Color: NSColor)] =
        [
            (Name: "Black", Color: NSColor.black),
            (Name: "White", Color: NSColor.white),
            (Name: "Red", Color: NSColor.red),
            (Name: "Green", Color: NSColor.green),
            (Name: "Blue", Color: NSColor.blue),
            (Name: "Gray", Color: NSColor.gray),
            (Name: "Indigo", Color: NSColor.systemIndigo),
            (Name: "Purple", Color: NSColor.purple),
            (Name: "Orange", Color: NSColor.orange),
            (Name: "System Orange", Color: NSColor.systemOrange),
            (Name: "Teal", Color: NSColor.systemTeal),
            (Name: "Yellow", Color: NSColor.yellow),
            (Name: "System Yellow", Color: NSColor.systemYellow),
            (Name: "Brown", Color: NSColor.brown)
    ]
    
    var GradientList = [(NSColor, NSColor)]()
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        switch collectionView
        {
            case ColorSwatchView:
                return ColorList.count
            
            case GradientSwatchView:
                return GradientList.count
            
            default:
                return 0
        }
    }
    
    func collectionView(_ itemForRepresentedObjectAtCollectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        switch itemForRepresentedObjectAtCollectionView
        {
            case ColorSwatchView:
                let Item = ColorSwatchView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ColorSwatchItem"), for: indexPath)
                guard let SomeItem = Item as? ColorSwatchItem else
                {
                    return Item
                }
                SomeItem.SetColor(ColorList[indexPath.item].Color, WithName: ColorList[indexPath.item].Name)
                SomeItem.SetSelectionState(To: indexPath.item == SelectedColorIndex)
                return SomeItem
            
            case GradientSwatchView:
                let Item = GradientSwatchView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GradientSwatchItem"), for: indexPath)
                guard let SomeItem = Item as? GradientSwatchItem else
                {
                    return Item
                }
                SomeItem.SetGradient(GradientList[indexPath.item].0, GradientList[indexPath.item].1)
                SomeItem.SetSelectionState(To: indexPath.item == SelectedGradientIndex)
                return SomeItem
            
            default:
                fatalError("Encountered unknown collection view.")
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        switch collectionView
        {
            case ColorSwatchView:
                SelectedColorIndex = indexPaths.first!.item
                ColorSwatchView.reloadData()
            
            case GradientSwatchView:
                SelectedGradientIndex = indexPaths.first!.item
                GradientSwatchView.reloadData()
            
            default:
                break
        }
        
    }
    
    var SelectedColorIndex: Int = 0
    var SelectedGradientIndex = 0
    
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
    
    // MARK: - Shape options.
    
    @IBOutlet weak var CurrentShapeTitle: NSTextField!
    
    func WasSelected(_ Shape: Shapes)
    {
        Settings.SetEnum(LastTouchedShape, EnumType: Shapes.self, ForKey: .Shape)
        CurrentShapeTitle.stringValue = "\(LastTouchedShape.rawValue)"
        UpdateShapeSettings(With: LastTouchedShape)
    }
    
    // MARK: - Options interface builder outlets.
    
    // @IBOutlet weak var OptionBox: NSBox!
    @IBOutlet weak var OptionsContainer: NSView!
    @IBOutlet weak var ShapeOutlineView: NSOutlineView!
    
    // MARK: - Current settings outline
    
    //   @IBOutlet weak var CurrentSettingsTable: NSOutlineView!
    
    // MARK: - TabView interface builder outlets.
    
    @IBOutlet weak var TabView: NSTabView!
    
    // MARK: - General interface builder outlets.
    
    @IBOutlet weak var ApplyButton: NSButton!
    
    // MARK: - Colors interface builder outlets and variables.
    
    @IBOutlet weak var ColorSwatchView: NSCollectionView!
    @IBOutlet weak var GradientSwatchView: NSCollectionView!
    
    //MARK: - Lighting interface builder outlines and variables.
    
    @IBOutlet weak var LightModelSegment: NSSegmentedControl!
    @IBOutlet weak var LightIntensitySegment: NSSegmentedControl!
    @IBOutlet weak var LightTypeSegment: NSSegmentedControl!
    @IBOutlet weak var LightColorCombo: NSComboBox!
    @IBOutlet weak var LightingSample: SCNView!
    var LightingSampleInitialized = false
    
    func DoUpdateLightSample()
    {
        var Model = SCNMaterial.LightingModel.blinn
        switch LightModelSegment.selectedSegment
        {
            case 0:
                Model = .blinn
            
            case 1:
                Model = .constant
            
            case 2:
                Model = .lambert
            
            case 3:
                Model = .phong
            
            case 4:
                Model = .physicallyBased
            
            default:
                Model = .lambert
        }
        
        var Color = NSColor.white
        let RawColor = LightColorCombo.objectValueOfSelectedItem as? String
        switch RawColor
        {
            case "White":
                Color = NSColor.white
            
            case "Yellow":
                Color = NSColor.yellow
            
            case "Orange":
                Color = NSColor.orange
            
            case "Teal":
                Color = NSColor.systemTeal
            
            case "Blue":
                Color = NSColor.blue
            
            case "Black":
                Color = NSColor.black
            
            default:
                Color = NSColor.white
        }
        
        var Intensity: CGFloat = 1000.0
        switch LightIntensitySegment.selectedSegment
        {
            case 0:
                Intensity = 500.0
            
            case 1:
                Intensity = 800.0
            
            case 2:
                Intensity = 1000.0
            
            case 3:
                Intensity = 1500.0
            
            case 4:
                Intensity = 2000.0
            
            default:
                Intensity = 1000.0
        }
        
        var Type = SCNLight.LightType.omni
        switch LightTypeSegment.selectedSegment
        {
            case 0:
                Type = .omni
            
            case 1:
                Type = .spot
            
            case 2:
                Type = .directional
            
            case 3:
                Type = .ambient
            
            default:
                Type = .omni
        }
        
        DrawLightingSample(Model: Model, Type: Type, Color: Color, Intensity: Intensity)
    }
    
    @IBAction func HandleLightTypeChanged(_ sender: Any)
    {
        DoUpdateLightSample()
    }
    
    @IBAction func HandleLightColorChanged(_ sender: Any)
    {
        DoUpdateLightSample()
    }
    
    @IBAction func HandleLightIntensityChanged(_ sender: Any)
    {
        DoUpdateLightSample()
    }
    
    @IBAction func HandleLightModelChanged(_ sender: Any)
    {
        DoUpdateLightSample()
    }
    
    // MARK: - Processing variables and code.
    
    
    @IBAction func HandleShapeSizeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleMaximumImageSizeChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var ShapeSizeSelector: NSSegmentedControl!
    @IBOutlet weak var MaximumImageSizeSelector: NSSegmentedControl!
    
    // MARK: - Live view processing.
    
    func InitializeLiveView()
    {
        let LVShape = Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self, Default: Shapes.Blocks)
        switch LVShape
        {
            case .Blocks:
                LiveViewShapeSegment.selectedSegment = 0
            
            case .Spheres:
                LiveViewShapeSegment.selectedSegment = 1
            
            case .Rings:
                LiveViewShapeSegment.selectedSegment = 2
            
            case .Cones:
                LiveViewShapeSegment.selectedSegment = 3
            
            case .Squares:
                LiveViewShapeSegment.selectedSegment = 4
            
            case .Tubes:
                LiveViewShapeSegment.selectedSegment = 5
            
            default:
                LiveViewShapeSegment.selectedSegment = 0
        }
    }
    
    @IBOutlet weak var LiveViewShapeSegment: NSSegmentedControl!
    
    @IBAction func LiveViewShapeSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(Shapes.Blocks, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                case 1:
                    Settings.SetEnum(Shapes.Spheres, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                case 2:
                    Settings.SetEnum(Shapes.Rings, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                case 3:
                    Settings.SetEnum(Shapes.Cones, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                case 4:
                    Settings.SetEnum(Shapes.Squares, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                case 5:
                    Settings.SetEnum(Shapes.Tubes, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                default:
                    Settings.SetEnum(Shapes.Blocks, EnumType: Shapes.self, ForKey: .LiveViewShape)
            }
        }
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    // MARK: - Sidebar variables and functions.
    
    @IBOutlet weak var SideBar: NSScrollView!
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

/*
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
 */

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
