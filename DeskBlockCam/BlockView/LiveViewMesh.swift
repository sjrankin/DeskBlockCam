//
//  LiveViewMesh.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 10/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Draws the whole live view grid of blocks as a single mesh. Thousands of separate nodes (each with its own
/// geometry and material) are far too slow to update and render every frame. Here the static vertex layout is
/// built once, and each frame only the block lengths (vertex Z) and colors are rewritten.
class LiveViewMesh
{
    /// Number of horizontal blocks.
    let HCount: Int
    /// Number of vertical blocks.
    let VCount: Int
    
    /// Vertices per block. The back face is never visible so it is omitted.
    private let VerticesPerBlock = 20
    /// Static X, Y, Z (Z is 0 or 1, scaled by the block's length each frame) positions.
    private var Positions: [Float]
    /// Z multipliers (0 or 1) per vertex.
    private var ZFlags: [Float]
    /// Static normals source.
    private let NormalSource: SCNGeometrySource
    /// Static triangle indices.
    private let Elements: SCNGeometryElement
    
    /// Template for one block: dx, dy, z flag, nx, ny, nz for each of the 20 vertices (five faces of four).
    private static let Template: [[Float]] =
    [
        //Front (+Z)
        [-1, -1, 1, 0, 0, 1], [1, -1, 1, 0, 0, 1], [1, 1, 1, 0, 0, 1], [-1, 1, 1, 0, 0, 1],
        //Right (+X)
        [1, -1, 0, 1, 0, 0], [1, 1, 0, 1, 0, 0], [1, 1, 1, 1, 0, 0], [1, -1, 1, 1, 0, 0],
        //Left (-X)
        [-1, -1, 0, -1, 0, 0], [-1, -1, 1, -1, 0, 0], [-1, 1, 1, -1, 0, 0], [-1, 1, 0, -1, 0, 0],
        //Top (+Y)
        [-1, 1, 0, 0, 1, 0], [-1, 1, 1, 0, 1, 0], [1, 1, 1, 0, 1, 0], [1, 1, 0, 0, 1, 0],
        //Bottom (-Y)
        [-1, -1, 0, 0, -1, 0], [1, -1, 0, 0, -1, 0], [1, -1, 1, 0, -1, 0], [-1, -1, 1, 0, -1, 0]
    ]
    
    /// Initializer.
    /// - Parameter HCount: Number of horizontal blocks.
    /// - Parameter VCount: Number of vertical blocks.
    /// - Parameter Side: Side length of each block.
    init(HCount: Int, VCount: Int, Side: CGFloat)
    {
        self.HCount = HCount
        self.VCount = VCount
        let Total = HCount * VCount
        let Half = Float(Side) / 2.0
        var Pos = [Float](repeating: 0.0, count: Total * VerticesPerBlock * 3)
        var Z = [Float](repeating: 0.0, count: Total * VerticesPerBlock)
        var Norm = [Float](repeating: 0.0, count: Total * VerticesPerBlock * 3)
        var Indices = [UInt32](repeating: 0, count: Total * 30)
        for Y in 0 ..< VCount
        {
            for X in 0 ..< HCount
            {
                let Block = Y * HCount + X
                let CenterX = Float(X - (HCount / 2)) * Float(Side)
                let CenterY = Float(Y - (VCount / 2)) * Float(Side)
                for V in 0 ..< VerticesPerBlock
                {
                    let T = LiveViewMesh.Template[V]
                    let Index = Block * VerticesPerBlock + V
                    Pos[Index * 3] = CenterX + T[0] * Half
                    Pos[Index * 3 + 1] = CenterY + T[1] * Half
                    Z[Index] = T[2]
                    Norm[Index * 3] = T[3]
                    Norm[Index * 3 + 1] = T[4]
                    Norm[Index * 3 + 2] = T[5]
                }
                for Face in 0 ..< 5
                {
                    let Base = UInt32(Block * VerticesPerBlock + Face * 4)
                    let Out = Block * 30 + Face * 6
                    Indices[Out] = Base
                    Indices[Out + 1] = Base + 1
                    Indices[Out + 2] = Base + 2
                    Indices[Out + 3] = Base
                    Indices[Out + 4] = Base + 2
                    Indices[Out + 5] = Base + 3
                }
            }
        }
        Positions = Pos
        ZFlags = Z
        NormalSource = SCNGeometrySource(data: Norm.withUnsafeBufferPointer{Data(buffer: $0)},
                                         semantic: .normal, vectorCount: Total * VerticesPerBlock,
                                         usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                         dataOffset: 0, dataStride: 12)
        Elements = SCNGeometryElement(data: Indices.withUnsafeBufferPointer{Data(buffer: $0)},
                                      primitiveType: .triangles, primitiveCount: Total * 10, bytesPerIndex: 4)
    }
    
    /// Build geometry for the current frame.
    /// - Parameter Colors: Block colors in the same YX order used elsewhere in live view.
    /// - Parameter Length: Returns the extrusion length for a color.
    /// - Returns: Geometry with one vertex color per block and the length applied to each block.
    func MakeGeometry(Colors: [[NSColor]], Length: (NSColor) -> CGFloat) -> SCNGeometry
    {
        let Total = HCount * VCount
        let VertexCount = Total * VerticesPerBlock
        var ColorData = [Float](repeating: 1.0, count: VertexCount * 4)
        for Y in 0 ..< VCount
        {
            for X in 0 ..< HCount
            {
                let Color = Colors[Y][X]
                let BlockLength = Float(max(Length(Color), 0.001))
                var R: CGFloat = 0.0
                var G: CGFloat = 0.0
                var B: CGFloat = 0.0
                var A: CGFloat = 0.0
                Color.getRed(&R, green: &G, blue: &B, alpha: &A)
                let First = (Y * HCount + X) * VerticesPerBlock
                for V in 0 ..< VerticesPerBlock
                {
                    let Index = First + V
                    Positions[Index * 3 + 2] = ZFlags[Index] * BlockLength
                    ColorData[Index * 4] = Float(R)
                    ColorData[Index * 4 + 1] = Float(G)
                    ColorData[Index * 4 + 2] = Float(B)
                }
            }
        }
        let PositionSource = SCNGeometrySource(data: Positions.withUnsafeBufferPointer{Data(buffer: $0)},
                                               semantic: .vertex, vectorCount: VertexCount,
                                               usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                               dataOffset: 0, dataStride: 12)
        let ColorSource = SCNGeometrySource(data: ColorData.withUnsafeBufferPointer{Data(buffer: $0)},
                                            semantic: .color, vectorCount: VertexCount,
                                            usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: 4,
                                            dataOffset: 0, dataStride: 16)
        return SCNGeometry(sources: [PositionSource, NormalSource, ColorSource], elements: [Elements])
    }
}

extension BlockView
{
    /// Draw (or update) the live view as one block mesh.
    /// - Parameter Colors: Colors in YX order.
    /// - Parameter HShapeCount: Number of horizontal blocks.
    /// - Parameter VShapeCount: Number of vertical blocks.
    /// - Parameter Side: Side length of each block.
    func DrawLiveViewMesh(Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, Side: CGFloat)
    {
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Small)
        let Determination = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                             Default: HeightDeterminations.Brightness)
        let Invert = Settings.GetBoolean(ForKey: .InvertHeight)
        var Created = false
        if LiveViewPrimaryNode == nil || LiveMesh == nil || LiveMesh!.HCount != HShapeCount || LiveMesh!.VCount != VShapeCount
        {
            LiveViewPrimaryNode?.removeFromParentNode()
            LiveMesh = LiveViewMesh(HCount: HShapeCount, VCount: VShapeCount, Side: Side)
            LiveViewPrimaryNode = SCNNode()
            LiveViewPrimaryNode?.name = "Primary Node"
            LiveViewPrimaryNode?.position = SCNVector3(0.0, 0.0, 0.0)
            LiveViewPrimaryNode?.addChildNode(SCNNode())
            self.scene?.rootNode.addChildNode(LiveViewPrimaryNode!)
            Created = true
        }
        let MeshNode = LiveViewPrimaryNode!.childNodes[0]
        let Material = MeshNode.geometry?.firstMaterial ?? NewLiveViewMaterial()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        SCNTransaction.disableActions = true
        let Geo = LiveMesh!.MakeGeometry(Colors: Colors)
        {
            Color in
            return self.ColorProminence(Color, Exaggeration: Exaggeration, Determination: Determination,
                                        Invert: Invert) * self.PMul
        }
        Geo.materials = [Material]
        MeshNode.geometry = Geo
        SCNTransaction.commit()
        if Created
        {
            let NewHeight = MinimizeBezel()
            CameraNode?.position = SCNVector3(CameraNode!.position.x, CameraNode!.position.y, CGFloat(NewHeight))
        }
    }
    
    /// Create the material for the live view mesh using the current lighting settings. The vertex
    /// colors modulate the white diffuse color.
    /// - Returns: New material.
    func NewLiveViewMaterial() -> SCNMaterial
    {
        let Material = SCNMaterial()
        Material.diffuse.contents = NSColor.white
        Material.specular.contents = NSColor.white
        switch Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self, Default: .Lambert)
        {
            case .Blinn:
                Material.lightingModel = .blinn
            
            case .Constant:
                Material.lightingModel = .constant
            
            case .Lambert:
                Material.lightingModel = .lambert
            
            case .Phong:
                Material.lightingModel = .phong
            
            case .Physical:
                Material.lightingModel = .physicallyBased
        }
        if Settings.GetBoolean(ForKey: .EnableMetalness)
        {
            Material.roughness.contents = Settings.GetDouble(ForKey: .Roughness)
            Material.metalness.contents = Settings.GetDouble(ForKey: .Metalness)
        }
        return Material
    }
}
