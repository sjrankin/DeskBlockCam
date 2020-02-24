//
//  ShapeListUICode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class ShapeListUICode: NSViewController, NSOutlineViewDataSource,
    NSOutlineViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AllShapes = [ShapeTreeNode]()
        for Category in ShapeManager.Categories
        {
            let NewNode = ShapeTreeNode(Category: Category.Name, Shapes: Category.Shapes)
            AllShapes!.append(NewNode)
        }
        InitializeShapeView()
        ShapeTable.reloadData()
        ZoomSlider.doubleValue = 15.0
    }
    
    var AllShapes: [ShapeTreeNode]!
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        if let SomeShape = item as? ShapeTreeNode
        {
            return SomeShape.Shapes[index]
        }
        return AllShapes![index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if let SomeShape = item as? ShapeTreeNode
        {
            return SomeShape.Shapes.count > 0
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if AllShapes == nil
        {
            return 0
        }
        if let SomeShape = item as? ShapeTreeNode
        {
            return SomeShape.Shapes.count
        }
        return AllShapes!.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
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
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outView = notification.object as? NSOutlineView else
        {
            return
        }
        let SelectedIndex = outView.selectedRow
        if let ShapeName = outView.item(atRow: SelectedIndex) as? String
        {
            if let SelectedShape = Shapes(rawValue: ShapeName)
            {
                print("User selected \(SelectedShape.rawValue)")
                ShowShape(SelectedShape)
            }
        }
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    func ShowShape(_ NewShape: Shapes)
    {
        if CurrentShape != nil
        {
            CurrentShape?.removeFromParentNode()
            CurrentShape = nil
        }
        CurrentShape = Generator.SingleShape(NewShape, Color: NSColor.orange, Side: 5.0)
        if CurrentShape == nil
        {
            return
        }
        CurrentShape?.position = SCNVector3(0.0, 0.0, 0.0)
        ShapeViewer.scene?.rootNode.addChildNode(CurrentShape!)
    }
    
    var CurrentShape: PSCNNode? = nil
    
    func InitializeShapeView()
    {
        ShapeViewer.scene = SCNScene()
        ShapeViewer.scene?.background.contents = NSColor.black
        ShapeViewer.allowsCameraControl = false
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        let CameraNode = SCNNode()
        CameraNode.name = "Camera Node"
        CameraNode.camera = Camera
        CameraNode.position = InitialCameraLocation
        let Light = SCNLight()
        Light.type = .omni
        Light.color = NSColor.white
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(-2.0, 2.0, 15.0)
        ShapeViewer.scene?.rootNode.addChildNode(CameraNode)
        ShapeViewer.scene?.rootNode.addChildNode(LightNode)
    }
    
    let InitialCameraLocation = SCNVector3(0.0, 0.0, 15.0)
    let InitialCameraRotation = SCNVector4(0.0, 0.0, 0.0, 0.0)
    let InitialCameraOrientation = SCNVector4(0.0, 0.0, 0.0, 1.0)
    
    @IBAction func HandleCenterShape(_ sender: Any)
    {
        var OriginalZ: CGFloat = 15.0
        if let POV = ShapeViewer.pointOfView
        {
            if let SampleShape = CurrentShape
            {
                if let CameraNode = GetNode(FromNode: ShapeViewer.scene!.rootNode, WithName: "Camera Node")
                {
                    OriginalZ = CameraNode.position.z
                    for CameraHeight in stride(from: 1.0, to: 100.0, by: 0.1)
                    {
                        CameraNode.position = SCNVector3(CameraNode.position.x,
                                                         CameraNode.position.y,
                                                         CGFloat(CameraHeight))
                        if AllInView(View: ShapeViewer, Node: SampleShape, PointOfView: POV)
                        {
                            CameraNode.position = InitialCameraLocation
                            CameraNode.orientation = InitialCameraOrientation
                            CameraNode.rotation = InitialCameraRotation
                            ShapeViewer.pointOfView?.position = InitialCameraLocation
                            ShapeViewer.pointOfView?.orientation = InitialCameraOrientation
                            ShapeViewer.pointOfView?.rotation = InitialCameraRotation
                            ZoomSlider.doubleValue = CameraHeight
                            return
                        }
                    }
                }
            }
        }
    }
    
    func AllInView(View: SCNView, Node: SCNNode, PointOfView: SCNNode) -> Bool
    {
        if !View.isNode(Node, insideFrustumOf: PointOfView)
        {
            return false
        }
        for ChildNode in Node.childNodes
        {
            if !AllInView(View: View, Node: ChildNode, PointOfView: PointOfView)
            {
                return false
            }
        }
        return true
    }
    
    func GetNode(FromNode: SCNNode, WithName: String) -> SCNNode?
    {
        if let NodeName = FromNode.name
        {
            if NodeName == WithName
            {
            return FromNode
            }
        }
        for ChildNode in FromNode.childNodes
        {
            if let NamedNode = GetNode(FromNode: ChildNode, WithName: WithName)
            {
                return NamedNode
            }
        }
        return nil
    }
    
    @IBAction func HandleZoomSlider(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
            let NewValue = Slider.doubleValue
            if let CameraNode = GetNode(FromNode: ShapeViewer.scene!.rootNode, WithName: "Camera Node")
            {
                CameraNode.position = SCNVector3(CameraNode.position.x, CameraNode.position.y,
                                                 CGFloat(NewValue))
            }
        }
    }
    
    @IBOutlet weak var ZoomSlider: NSSlider!
    @IBOutlet weak var ShapeTable: NSOutlineView!
    @IBOutlet weak var ShapeViewer: SCNView!
}
