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
    NSTextFieldDelegate,
    ToOptionsParentProtocol
{
    private let ShapeTableTag = 100
    private let ShapesOutlineTag = 100
    private let SideBarTag = 200
    
    public weak var ApplyDelegate: RedrawProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeShapes()
        ShapeOutlineView.reloadData()
        InitializeColorSwatches()
        InitializeHeight()
        InitializeGradientSwatches()
        InitializeLighting()
        InitializeLiveView()
        InitializeProcessing()
        InitializeConditionalColors()
        InitializeSideBar()
        LastTouchedShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
    }
    
    override func viewDidDisappear()
    {
        ApplyDelegate?.SettingsWindowClosing()
        super.viewDidDisappear()
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
    
    func UpdateCurrent(With Shape: Shapes)
    {
        UpdateShapeSettings(With: Shape)
        UpdateHeightSettings()
        UpdateLiveViewSettings()
        UpdateLightSettings()
        UpdateColorSettings()
        UpdateProcessingSettings()
        UpdateBackgroundSettings()
    }
    
    // MARK: - Outline view functions.
    
    @IBOutlet weak var CurrentSettings: NSOutlineView!
    
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
                                ValueItem(Description: "Height", Value: "brightness"),
                                ValueItem(Description: "Exaggeration", Value: "Medium"),
                                ValueItem(Description: "Invert", Value: "false")
            ]),
            CurrentCategory(Name: "Color Settings", Icon: NSImage(named: "PaintbrushIcon"),
                            Values: [
                                ValueItem(Description: "Conditional colors", Value: "none"),
                                ValueItem(Description: "Action", Value: "Decrease saturation"),
                                ValueItem(Description: "Threshold", Value: "0.50"),
                                ValueItem(Description: "Invert", Value: "false"),
            ]),
            CurrentCategory(Name: "Lighting Settings", Icon: NSImage(named: "LightbulbIcon"),
                            Values: [
                                ValueItem(Description: "Type", Value: "Omni"),
                                ValueItem(Description: "Color", Value: "white"),
                                ValueItem(Description: "Intensity", Value: "normal"),
                                ValueItem(Description: "Model", Value: "Phong"),
                                ValueItem(Description: "Metal Surface", Value: "false"),
                                ValueItem(Description: "Metalness", Value: "1.0"),
                                ValueItem(Description: "Roughness", Value: "1.0")
            ]),
            CurrentCategory(Name: "Processing Settings", Icon: NSImage(named: "PerformanceIcon"),
                            Values: [
                                ValueItem(Description: "Shape size", Value: "16"),
                                ValueItem(Description: "Image size", Value: "1024"),
                                ValueItem(Description: "Antialiasing", Value: "4x")
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
    
    let Categories = ShapeManager.Categories
    
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
                var ToolTipText: String? = nil
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
                        if Item.Description == "Shape"
                        {
                            ToolTipText = Item.Value
                        }
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
                    if let TipText = ToolTipText
                    {
                        tableCell.toolTip = TipText
                    }
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
                        print("Selected shape \(SelectedShape.rawValue)")
                        LastTouchedShape = SelectedShape
                        UpdateShapeSettings(With: SelectedShape)
                        DisplayShapeOptions(For: SelectedShape)
                        Settings.SetEnum(SelectedShape, EnumType: Shapes.self, ForKey: .Shape)
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
    
    // MARK: - Background functions.
    
    func InitializeBackground()
    {
        let Type = Settings.GetEnum(ForKey: .BackgroundType, EnumType: Backgrounds.self, Default: Backgrounds.Color)
        switch Type
        {
            case .Color:
                BackgroundTypeSegment.selectedSegment = 0
            
            case .Gradient:
                BackgroundTypeSegment.selectedSegment = 1
            
            case .Image:
                BackgroundTypeSegment.selectedSegment = 2
        }
        
    }
    
    @IBAction func HandleBackgroundTypeChanged(_ sender: Any)
    {
        switch BackgroundTypeSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Color, EnumType: Backgrounds.self, ForKey: .BackgroundType)
            
            case 1:
                Settings.SetEnum(.Gradient, EnumType: Backgrounds.self, ForKey: .BackgroundType)
            
            case 2:
                Settings.SetEnum(.Image, EnumType: Backgrounds.self, ForKey: .BackgroundType)
            
            default:
                Settings.SetEnum(.Color, EnumType: Backgrounds.self, ForKey: .BackgroundType)
        }
        UpdateBackgroundSettings()
    }
    
    @IBOutlet weak var BackgroundTypeSegment: NSSegmentedControl!
    
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
            (Name: BasicColors.Black.rawValue, Color: NSColor.black),
            (Name: BasicColors.White.rawValue, Color: NSColor.white),
            (Name: BasicColors.Red.rawValue, Color: NSColor.red),
            (Name: BasicColors.Green.rawValue, Color: NSColor.green),
            (Name: BasicColors.Blue.rawValue, Color: NSColor.blue),
            (Name: BasicColors.Cyan.rawValue, Color: NSColor.cyan),
            (Name: BasicColors.Magenta.rawValue, Color: NSColor.magenta),
            (Name: BasicColors.Yellow.rawValue, Color: NSColor.yellow),
            (Name: BasicColors.Orange.rawValue, Color: NSColor.orange),
            (Name: BasicColors.Indigo.rawValue, Color: NSColor.systemIndigo),
            (Name: BasicColors.Purple.rawValue, Color: NSColor.purple),
            (Name: BasicColors.Brown.rawValue, Color: NSColor.brown),
            (Name: BasicColors.Yellow2.rawValue, Color: NSColor.systemYellow),
            (Name: BasicColors.Orange2.rawValue, Color: NSColor.systemOrange),
            (Name: BasicColors.Brown2.rawValue, Color: NSColor.systemBrown),
            (Name: BasicColors.Gray.rawValue, Color: NSColor.gray),
    ]
    
    var GradientList = [(NSColor, NSColor)]()
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        switch collectionView
        {
            case ColorSwatchView:
                return ColorList.count
            
            case LightColorView:
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
            
            case LightColorView:
                let Item = ColorSwatchView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ColorSwatchItem"), for: indexPath)
                guard let SomeItem = Item as? ColorSwatchItem else
                {
                    return Item
                }
                SomeItem.SetColor(ColorList[indexPath.item].Color, WithName: ColorList[indexPath.item].Name)
                SomeItem.SetSelectionState(To: indexPath.item == SelectedLightColorIndex)
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
                let Color = ColorList[SelectedColorIndex].Color
                Settings.SetInteger(NSColor.AsInt(Color), ForKey: .BackgroundColor)
                UpdateBackgroundSettings()
            
            case LightColorView:
                SelectedLightColorIndex = indexPaths.first!.item
                LightColorView.reloadData()
                let Color = ColorList[SelectedLightColorIndex].Color
                Settings.SetInteger(NSColor.AsInt(Color), ForKey: .LightColor)
                UpdateLightSettings()
            
            case GradientSwatchView:
                SelectedGradientIndex = indexPaths.first!.item
                GradientSwatchView.reloadData()
                let Gradient = GradientList[SelectedGradientIndex]
                let Color1Int = NSColor.AsInt(Gradient.0)
                let Color1Name = "0x" + String(Color1Int, radix: 16, uppercase: false)
                let Color2Int = NSColor.AsInt(Gradient.1)
                let Color2Name = "0x" + String(Color2Int, radix: 16, uppercase: false)
                let Final = "\(Color1Name),\(Color2Name)"
                Settings.SetString(Final, ForKey: .BackgroundGradientColors)
                UpdateBackgroundSettings()
            
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
        ApplyDelegate?.RedrawImage()
    }
    
    // MARK: - Handle tab view events.
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?)
    {
        
    }
    
    // MARK: - Conditional colors.
    
    func InitializeConditionalColors()
    {
        InvertThresholdCheck.state = Settings.GetBoolean(ForKey: .InvertConditionalColor) ? .on : .off
        SetThresholdLabels(ForInverted: Settings.GetBoolean(ForKey: .InvertConditionalColor))
        let CColor = Settings.GetEnum(ForKey: .ConditionalColor, EnumType: ConditionalColorTypes.self,
                                      Default: ConditionalColorTypes.None)
        switch CColor
        {
            case .None:
                ConditionalColorSegment.selectedSegment = 0
            
            case .Hue:
                ConditionalColorSegment.selectedSegment = 1
            
            case .Saturation:
                ConditionalColorSegment.selectedSegment = 2
            
            case .Brightness:
                ConditionalColorSegment.selectedSegment = 3
        }
        
        let CAction = Settings.GetEnum(ForKey: .ConditionalColorAction, EnumType: ConditionalColorActions.self,
                                       Default: ConditionalColorActions.Grayscale)
        switch CAction
        {
            case .Grayscale:
                ColorActionSegment.selectedSegment = 0
            
            case .IncreaseSaturation:
                ColorActionSegment.selectedSegment = 1
            
            case .DecreaseSaturation:
                ColorActionSegment.selectedSegment = 2
        }
        
        let CThresh = Settings.GetEnum(ForKey: .ConditionalColorThreshold, EnumType: ConditionalColorThresholds.self,
                                       Default: ConditionalColorThresholds.Less50)
        switch CThresh
        {
            case .Less10:
                ColorThresholdSegment.selectedSegment = 0
            
            case .Less25:
                ColorThresholdSegment.selectedSegment = 1
            
            case .Less50:
                ColorThresholdSegment.selectedSegment = 2
            
            case .Less75:
                ColorThresholdSegment.selectedSegment = 3
            
            case .Less90:
                ColorThresholdSegment.selectedSegment = 4
        }
    }
    
    @IBAction func HandleConditionalColorsChanged(_ sender: Any)
    {
        let SegmentIndex = ConditionalColorSegment.selectedSegment
        switch SegmentIndex
        {
            case 0:
                Settings.SetEnum(ConditionalColorTypes.None, EnumType: ConditionalColorTypes.self,
                                 ForKey: .ConditionalColor)
            
            case 1:
                Settings.SetEnum(ConditionalColorTypes.Hue, EnumType: ConditionalColorTypes.self,
                                 ForKey: .ConditionalColor)
            
            case 2:
                Settings.SetEnum(ConditionalColorTypes.Saturation, EnumType: ConditionalColorTypes.self,
                                 ForKey: .ConditionalColor)
            
            case 3:
                Settings.SetEnum(ConditionalColorTypes.Brightness, EnumType: ConditionalColorTypes.self,
                                 ForKey: .ConditionalColor)
            
            default:
                Settings.SetEnum(ConditionalColorTypes.None, EnumType: ConditionalColorTypes.self,
                                 ForKey: .ConditionalColor)
        }
    }
    
    @IBAction func HandleColorActionChanged(_ sender: Any)
    {
        let SegmentIndex = ColorActionSegment.selectedSegment
        switch SegmentIndex
        {
            case 0:
                Settings.SetEnum(ConditionalColorActions.Grayscale, EnumType: ConditionalColorActions.self,
                                 ForKey: .ConditionalColorAction)
            
            case 1:
                Settings.SetEnum(ConditionalColorActions.IncreaseSaturation, EnumType: ConditionalColorActions.self,
                                 ForKey: .ConditionalColorAction)
            
            case 2:
                Settings.SetEnum(ConditionalColorActions.DecreaseSaturation, EnumType: ConditionalColorActions.self,
                                 ForKey: .ConditionalColorAction)
            
            default:
                Settings.SetEnum(ConditionalColorActions.Grayscale, EnumType: ConditionalColorActions.self,
                                 ForKey: .ConditionalColorAction)
        }
    }
    
    @IBAction func HandleInvertColorThresholdChanged(_ sender: Any)
    {
        Settings.SetBoolean(InvertThresholdCheck.state == .on, ForKey: .InvertConditionalColor)
        SetThresholdLabels(ForInverted: InvertThresholdCheck.state == .on)
    }
    
    @IBAction func HandleColorThresholdChanged(_ sender: Any)
    {
        let SegmentIndex = ColorThresholdSegment.selectedSegment
        switch SegmentIndex
        {
            case 0:
                Settings.SetEnum(ConditionalColorThresholds.Less10, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
            
            case 1:
                Settings.SetEnum(ConditionalColorThresholds.Less25, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
            
            case 2:
                Settings.SetEnum(ConditionalColorThresholds.Less50, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
            
            case 3:
                Settings.SetEnum(ConditionalColorThresholds.Less75, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
            
            case 4:
                Settings.SetEnum(ConditionalColorThresholds.Less90, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
            
            default:
                Settings.SetEnum(ConditionalColorThresholds.Less50, EnumType: ConditionalColorThresholds.self,
                                 ForKey: .ConditionalColorThreshold)
        }
    }
    
    func SetThresholdLabels(ForInverted: Bool)
    {
        if ForInverted
        {
            ColorThresholdSegment.setLabel("> 0.10", forSegment: 0)
            ColorThresholdSegment.setLabel("> 0.25", forSegment: 1)
            ColorThresholdSegment.setLabel("> 0.75", forSegment: 3)
            ColorThresholdSegment.setLabel("> 0.90", forSegment: 4)
        }
        else
        {
            ColorThresholdSegment.setLabel("< 0.10", forSegment: 0)
            ColorThresholdSegment.setLabel("< 0.25", forSegment: 1)
            ColorThresholdSegment.setLabel("< 0.75", forSegment: 3)
            ColorThresholdSegment.setLabel("< 0.90", forSegment: 4)
        }
    }
    
    @IBOutlet weak var ConditionalColorSegment: NSSegmentedControl!
    @IBOutlet weak var ColorActionSegment: NSSegmentedControl!
    @IBOutlet weak var ColorThresholdSegment: NSSegmentedControl!
    @IBOutlet weak var InvertThresholdCheck: NSButton!
    
    // MARK: - Shape options.
    
    func WasSelected(_ Shape: Shapes)
    {
        Settings.SetEnum(LastTouchedShape, EnumType: Shapes.self, ForKey: .Shape)
        UpdateShapeSettings(With: LastTouchedShape)
    }
    
    // MARK: - Height settings and functions.
    
    func InitializeHeight()
    {
        let HeightDetermination = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                                   Default: HeightDeterminations.Brightness)
        let IsInverted = Settings.GetBoolean(ForKey: .InvertHeight)
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Medium)
        
        HeightDeterminationCombo.removeAllItems()
        var Index = 0
        var SelectedComboItem = 2
        for det in HeightDeterminations.allCases
        {
            HeightDeterminationCombo.addItem(withObjectValue: det.rawValue)
            if det == HeightDetermination
            {
                SelectedComboItem = Index
            }
            Index = Index + 1
        }
        HeightDeterminationCombo.selectItem(at: SelectedComboItem)
        switch Exaggeration
        {
            case .None:
                VerticalExaggerationSegment.selectedSegment = 0
            
            case .Small:
                VerticalExaggerationSegment.selectedSegment = 1
            
            case .Medium:
                VerticalExaggerationSegment.selectedSegment = 2
            
            case .Large:
                VerticalExaggerationSegment.selectedSegment = 3
        }
        InvertVerticalHeightCheck.state = IsInverted ? .on : .off
    }
    
    @IBAction func HandleHeightDeterminationChanged(_ sender: Any)
    {
        let Selected = HeightDeterminationCombo.indexOfSelectedItem
        if Selected == -1
        {
            return
        }
        let Item = HeightDeterminations.allCases[Selected]
        Settings.SetEnum(Item, EnumType: HeightDeterminations.self, ForKey: .HeightDetermination)
        UpdateHeightSettings()
    }
    
    @IBAction func HandleVerticalExaggerationChanged(_ sender: Any)
    {
        let Index = VerticalExaggerationSegment.selectedSegment
        var Ex = VerticalExaggerations.Medium
        switch Index
        {
            case 0:
                Ex = .None
            
            case 1:
                Ex = .Small
            
            case 2:
                Ex = .Medium
            
            case 3:
                Ex = .Large
            
            default:
                Ex = .Medium
        }
        Settings.SetEnum(Ex, EnumType: VerticalExaggerations.self, ForKey: .VerticalExaggeration)
        UpdateHeightSettings()
    }
    
    @IBAction func HandleInvertHeightChanged(_ sender: Any)
    {
        Settings.SetBoolean(InvertVerticalHeightCheck.state == .on, ForKey: .InvertHeight)
        UpdateHeightSettings()
    }
    
    @IBOutlet weak var VerticalExaggerationSegment: NSSegmentedControl!
    @IBOutlet weak var HeightDeterminationCombo: NSComboBox!
    @IBOutlet weak var InvertVerticalHeightCheck: NSButton!
    
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
    
    @IBOutlet weak var LightColorView: NSCollectionView!
    @IBOutlet weak var LightModelSegment: NSSegmentedControl!
    @IBOutlet weak var LightIntensitySegment: NSSegmentedControl!
    @IBOutlet weak var LightTypeSegment: NSSegmentedControl!
    @IBOutlet weak var LightingSample: SCNView!
    var LightingSampleInitialized = false
    var SelectedLightColorIndex = -1
    @IBOutlet weak var EnableMetalnessSwitch: NSSwitch!
    @IBOutlet weak var MetalnessField: NSTextField!
    @IBOutlet weak var RoughnessField: NSTextField!
    
    @IBAction func HandleMetalnessChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBoolean(Switch.state == .on ? true : false, ForKey: .EnableMetalness)
            UpdateLightSettings()
            DoUpdateLightSample()
        }
    }
    
    func ValidateNormal(_ Raw: String) -> (Double, Bool)
    {
        if let Normal = Double(Raw)
        {
            if Normal >= 0.0 && Normal <= 1.0
            {
                return (Normal, false)
            }
        }
        return (0.5, true)
    }
    
    func controlTextDidChange(_ obj: Notification)
    {
        guard let Field = obj.object as? NSTextField else
        {
            return
        }
        switch Field
        {
            case MetalnessField:
                let (Value, Failed) = ValidateNormal(Field.stringValue)
                if Failed
                {
                    MetalnessField.stringValue = "\(Value)"
                }
                Settings.SetDouble(Value, ForKey: .Metalness)
                UpdateLightSettings()
                DoUpdateLightSample()
                
            case RoughnessField:
                let (Value, Failed) = ValidateNormal(Field.stringValue)
                if Failed
                {
                    RoughnessField.stringValue = "\(Value)"
                }
                Settings.SetDouble(Value, ForKey: .Roughness)
                UpdateLightSettings()
                DoUpdateLightSample()
                
            default:
                return
        }
    }
    
    func DoUpdateLightSample()
    {
        let MetallicSurface = Settings.GetBoolean(ForKey: .EnableMetalness)
        EnableMetalnessSwitch.state = MetallicSurface ? .on : .off
        let RoughValue = Settings.GetDouble(ForKey: .Roughness)
        RoughnessField.stringValue = "\(RoughValue)"
        let MetalValue = Settings.GetDouble(ForKey: .Metalness)
        MetalnessField.stringValue = "\(MetalValue)"
        var Model = SCNMaterial.LightingModel.blinn
        #if true
        let LightModel = Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self, Default: .Lambert)
        switch LightModel
        {
            case .Blinn:
                Model = .blinn
                LightModelSegment.selectedSegment = 0
                
            case .Constant:
                Model = .constant
                LightModelSegment.selectedSegment = 1
                
            case .Lambert:
                Model = .lambert
                LightModelSegment.selectedSegment = 2
                
            case .Phong:
                Model = .phong
                LightModelSegment.selectedSegment = 3
                
            case .Physical:
                Model = .physicallyBased
                LightModelSegment.selectedSegment = 4
        }
        #else
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
        #endif
        
        var Color = NSColor.white
        let RawColorS = Settings.GetInteger(ForKey: .LightColor)
        Color = NSColor.MakeColor(With: RawColorS)
        
        var Intensity: CGFloat = 1000.0
        #if true
        let IntensityType = Settings.GetEnum(ForKey: .LightIntensity, EnumType: LightIntensities.self, Default: .Normal)
        switch IntensityType
        {
            case .Darkest:
                Intensity = 500.0
                LightIntensitySegment.selectedSegment = 0
                
            case .Dim:
                Intensity = 800.0
                LightIntensitySegment.selectedSegment = 1
                
            case .Normal:
                Intensity = 1000.0
                LightIntensitySegment.selectedSegment = 2
                
            case .Bright:
                Intensity = 1500.0
                LightIntensitySegment.selectedSegment = 3
                
            case .Brightest:
                Intensity = 2000.0
                LightIntensitySegment.selectedSegment = 4
        }
        #else
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
        #endif
        
        var Type = SCNLight.LightType.omni
        let LightType = Settings.GetEnum(ForKey: .LightType, EnumType: LightingTypes.self, Default: .Omni)
        #if true
        switch LightType
        {
            case .Omni:
                LightTypeSegment.selectedSegment = 0
                Type = .omni
                
            case .Spot:
                LightTypeSegment.selectedSegment = 1
                Type = .spot
                
            case .Directional:
                LightTypeSegment.selectedSegment = 2
                Type = .directional
                
            case .Ambient:
                LightTypeSegment.selectedSegment = 3
                Type = .ambient
        }
        #else
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
        #endif
        
        DrawLightingSample(Model: Model, Type: Type, Color: Color, Intensity: Intensity)
    }
    
    @IBAction func HandleLightTypeChanged(_ sender: Any)
    {
        switch LightTypeSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Omni, EnumType: LightingTypes.self, ForKey: .LightType)
            
            case 1:
                Settings.SetEnum(.Spot, EnumType: LightingTypes.self, ForKey: .LightType)
            
            case 2:
                Settings.SetEnum(.Directional, EnumType: LightingTypes.self, ForKey: .LightType)
            
            case 3:
                Settings.SetEnum(.Ambient, EnumType: LightingTypes.self, ForKey: .LightType)
            
            default:
                Settings.SetEnum(.Omni, EnumType: LightingTypes.self, ForKey: .LightType)
        }
        DoUpdateLightSample()
        UpdateLightSettings()
    }
    
    @IBAction func HandleLightColorChanged(_ sender: Any)
    {
        DoUpdateLightSample()
        UpdateLightSettings()
    }
    
    @IBAction func HandleLightIntensityChanged(_ sender: Any)
    {
        switch LightIntensitySegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Darkest, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 1:
                Settings.SetEnum(.Dim, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 2:
                Settings.SetEnum(.Normal, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 3:
                Settings.SetEnum(.Bright, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 4:
                Settings.SetEnum(.Brightest, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            default:
                Settings.SetEnum(.Normal, EnumType: LightIntensities.self, ForKey: .LightIntensity)
        }
        DoUpdateLightSample()
        UpdateLightSettings()
    }
    
    @IBAction func HandleLightModelChanged(_ sender: Any)
    {
        switch LightModelSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Blinn, EnumType: LightModels.self, ForKey: .LightModel)
            
            case 1:
                Settings.SetEnum(.Constant, EnumType: LightModels.self, ForKey: .LightModel)
            
            case 2:
                Settings.SetEnum(.Lambert, EnumType: LightModels.self, ForKey: .LightModel)
            
            case 3:
                Settings.SetEnum(.Phong, EnumType: LightModels.self, ForKey: .LightModel)
            
            case 4:
                Settings.SetEnum(.Physical, EnumType: LightModels.self, ForKey: .LightModel)
            
            default:
                Settings.SetEnum(.Lambert, EnumType: LightModels.self, ForKey: .LightModel)
        }
        DoUpdateLightSample()
        UpdateLightSettings()
    }
    
    // MARK: - Processing variables and code.
    
    func InitializeProcessing()
    {
        var Size = Settings.GetInteger(ForKey: .ShapeSize)
        if Size == 0
        {
            Size = 16
            Settings.SetInteger(Size, ForKey: .ShapeSize)
        }
        switch Size
        {
            case 8:
                ShapeSizeSelector.selectedSegment = 0
                
            case 16:
                ShapeSizeSelector.selectedSegment = 1
            
            case 32:
                ShapeSizeSelector.selectedSegment = 2
            
            case 48:
                ShapeSizeSelector.selectedSegment = 3
            
            case 64:
                ShapeSizeSelector.selectedSegment = 4
            
            case 96:
                ShapeSizeSelector.selectedSegment = 5
            
            default:
                ShapeSizeSelector.selectedSegment = 1
        }
        var Maximum = Settings.GetInteger(ForKey: .MaximumLength)
        if Maximum == 0
        {
            Maximum = 1024
        }
        switch Maximum
        {
            case 512:
                MaximumImageSizeSelector.selectedSegment = 0
            
            case 1024:
                MaximumImageSizeSelector.selectedSegment = 1
            
            case 1600:
                MaximumImageSizeSelector.selectedSegment = 2
            
            case 2400:
                MaximumImageSizeSelector.selectedSegment = 3
                
            case 4096:
                MaximumImageSizeSelector.selectedSegment = 4
                
            default:
                MaximumImageSizeSelector.selectedSegment = 5
        }
        switch Settings.GetEnum(ForKey: .Antialiasing, EnumType: AntialiasingModes.self, Default: AntialiasingModes.x4)
        {
            case .None:
                AntialiasingSegment.selectedSegment = 0
                
            case .x2:
                AntialiasingSegment.selectedSegment = 1
                
            case .x4:
                AntialiasingSegment.selectedSegment = 2
                
            case .x8:
                AntialiasingSegment.selectedSegment = 3
                
            case .x16:
                AntialiasingSegment.selectedSegment = 4
        }
    }
    
    @IBAction func HandleShapeSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            var NewSize = 16
            switch Index
            {
                case 0:
                    NewSize = 8
                    
                case 1:
                    NewSize = 16
                
                case 2:
                    NewSize = 32
                
                case 3:
                    NewSize = 48
                
                case 4:
                    NewSize = 64
                
                case 5:
                    NewSize = 96
                
                default:
                    NewSize = 16
            }
            ApplyDelegate?.ResetLiveView()
            Settings.SetInteger(NewSize, ForKey: .ShapeSize)
            UpdateProcessingSettings()
        }
    }
    
    @IBAction func HandleMaximumImageSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            var NewLength = 1024
            switch Index
            {
                case 0:
                    NewLength = 512
                
                case 1:
                    NewLength = 1024
                
                case 2:
                    NewLength = 1600
                
                case 3:
                    NewLength = 2400
                
                case 4:
                    NewLength = 4096
                
                case 5:
                    NewLength = 100000
                
                default:
                    NewLength = 1024
            }
            Settings.SetInteger(NewLength, ForKey: .MaximumLength)
            UpdateProcessingSettings()
        }
    }
    
    @IBAction func HandleAntialiasingChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var NewAA = AntialiasingModes.x4
            let Index = Segment.selectedSegment
            switch Index
            {
                case 0:
                    NewAA = .None
                
                case 1:
                    NewAA = .x2
                
                case 2:
                    NewAA = .x4
                
                case 3:
                    NewAA = .x8
                
                case 4:
                    NewAA = .x16
                
                default:
                    NewAA = .None
            }
            Settings.SetEnum(NewAA, EnumType: AntialiasingModes.self, ForKey: .Antialiasing)
        }
    }
    
    @IBOutlet weak var AntialiasingSegment: NSSegmentedControl!
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
            
            case .Pyramids:
                LiveViewShapeSegment.selectedSegment = 6
            
            default:
                LiveViewShapeSegment.selectedSegment = 0
        }
        switch Settings.GetEnum(ForKey: .LiveViewImageSize, EnumType: LiveViewImageSizes.self,
        Default: LiveViewImageSizes.Medium)
        {
            case .Native:
                LiveViewImageSizeSegment.selectedSegment = 3
            
            case .Small:
                            LiveViewImageSizeSegment.selectedSegment = 0
            
            case .Medium:
                LiveViewImageSizeSegment.selectedSegment = 1
            
            case .Large:
                LiveViewImageSizeSegment.selectedSegment = 2
        }
    }
    
    @IBAction func LiveViewImageSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(.Small, EnumType: LiveViewImageSizes.self,
                                     ForKey: .LiveViewImageSize)
                
                case 1:
                    Settings.SetEnum(.Medium, EnumType: LiveViewImageSizes.self,
                                     ForKey: .LiveViewImageSize)
                
                case 2:
                    Settings.SetEnum(.Large, EnumType: LiveViewImageSizes.self,
                                     ForKey: .LiveViewImageSize)
                
                case 3:
                    Settings.SetEnum(.Native, EnumType: LiveViewImageSizes.self,
                                     ForKey: .LiveViewImageSize)
                
                default:
                    Settings.SetEnum(.Medium, EnumType: LiveViewImageSizes.self,
                                     ForKey: .LiveViewImageSize)
            }
            UpdateLiveViewSettings()
            ApplyDelegate?.ResetLiveView()
        }
    }
    
    @IBOutlet weak var LiveViewShapeSegment: NSSegmentedControl!
    @IBOutlet weak var LiveViewImageSizeSegment: NSSegmentedControl!
    
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
                
                case 6:
                    Settings.SetEnum(Shapes.Pyramids, EnumType: Shapes.self, ForKey: .LiveViewShape)
                
                default:
                    Settings.SetEnum(Shapes.Blocks, EnumType: Shapes.self, ForKey: .LiveViewShape)
            }
            UpdateLiveViewSettings()
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
