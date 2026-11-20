//
//  SceneFlattener.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 11/20/26.
//  Copyright © 2026 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import simd

/// Merges the many shape nodes of a still image into a few large meshes.
///
/// Each cell of a still image is its own node with its own geometry and material (and shadow). Tens of thousands of
/// those make every frame cost tens of thousands of draw calls, so rotating or zooming the scene crawls. Here the
/// geometry of every node is baked (with the node's transform applied) into `SCNGeometry` objects, with each node's
/// diffuse color stored as a vertex color. The result looks the same but is drawn in a few hundred calls.
///
/// The shapes are merged in spatial tiles rather than into one mesh so SceneKit can still skip the tiles that are off
/// screen, in particular when it renders the light's shadow maps.
enum SceneFlattener
{
    /// Number of tiles along each side of the image.
    private static let TilesPerSide = 10

    /// One node's geometry waiting to be merged.
    private struct Item
    {
        let Geometry: SCNGeometry
        let World: simd_float4x4
    }

    /// Merge all geometry under a node.
    /// - Note: Nodes that cannot be merged (those with particle systems, lights or cameras) are kept as separate nodes.
    ///         Per-material properties other than the diffuse color (specular, roughness and so on) are taken from
    ///         `Material`, which is shared by all the merged meshes.
    /// - Parameter Root: The node whose descendants are merged. It is not modified.
    /// - Parameter Material: The material for the merged meshes. Its diffuse contents are replaced with white so the
    ///                       vertex colors show through unchanged.
    /// - Returns: A new node (named like `Root`) holding the merged meshes and any nodes that could not be merged.
    @_optimize(speed)
    static func Flatten(_ Root: SCNNode, Material: SCNMaterial) -> SCNNode
    {
        var Items: [Item] = []
        var Kept: [SCNNode] = []
        for Child in Root.childNodes
        {
            Collect(Child, matrix_identity_float4x4, &Items, &Kept)
        }
        LimitDetail(Items.map{$0.Geometry})
        let Result = SCNNode()
        Result.name = Root.name
        Result.simdTransform = Root.simdTransform
        Material.diffuse.contents = NSColor.white
        Material.isDoubleSided = true
        if !Items.isEmpty
        {
            // Bucket the items into a grid by where their node sits.
            var MinX = Float.greatestFiniteMagnitude
            var MaxX = -Float.greatestFiniteMagnitude
            var MinY = Float.greatestFiniteMagnitude
            var MaxY = -Float.greatestFiniteMagnitude
            for Entry in Items
            {
                let T = Entry.World.columns.3
                MinX = min(MinX, T.x)
                MaxX = max(MaxX, T.x)
                MinY = min(MinY, T.y)
                MaxY = max(MaxY, T.y)
            }
            let Sides = Float(TilesPerSide)
            let SpanX = max(MaxX - MinX, 1e-6)
            let SpanY = max(MaxY - MinY, 1e-6)
            var Tiles = [[Item]](repeating: [], count: TilesPerSide * TilesPerSide)
            for Entry in Items
            {
                let T = Entry.World.columns.3
                let TX = min(Int((T.x - MinX) / SpanX * Sides), TilesPerSide - 1)
                let TY = min(Int((T.y - MinY) / SpanY * Sides), TilesPerSide - 1)
                Tiles[TY * TilesPerSide + TX].append(Entry)
            }
            // The tiles are independent, so merge them on all cores at once.
            let Occupied = Tiles.indices.filter{!Tiles[$0].isEmpty}
            var Merged = [SCNGeometry?](repeating: nil, count: Occupied.count)
            Merged.withUnsafeMutableBufferPointer
            {
                (Output: inout UnsafeMutableBufferPointer<SCNGeometry?>) in
                let Slots = Output.baseAddress!
                DispatchQueue.concurrentPerform(iterations: Occupied.count)
                {
                    Position in
                    Slots[Position] = MergedGeometry(Tiles[Occupied[Position]])
                }
            }
            for (Position, Geometry) in Merged.enumerated()
            {
                if let Geometry = Geometry
                {
                    Geometry.materials = [Material]
                    let MeshNode = SCNNode(geometry: Geometry)
                    MeshNode.name = "Merged Shapes \(Occupied[Position])"
                    MeshNode.castsShadow = true
                    Result.addChildNode(MeshNode)
                }
            }
        }
        for Node in Kept
        {
            Result.addChildNode(Node)
        }
        return Result
    }

    /// Lowers the segment counts of SceneKit's parametric shapes (cylinders, spheres, cones, tubes, capsules and tori)
    /// when there are many of them.
    ///
    /// SceneKit builds a parametric shape's mesh the first time its data is read, and that is slow: with the default of
    /// 48 segments a cylinder is hundreds of triangles, and thousands of them take seconds to build and then to draw.
    /// At the size these shapes appear in a grid of thousands the extra segments cannot be seen. This must run before any
    /// geometry data is read, so the unwanted detail is never built.
    /// - Parameter Geometries: The geometries that will be merged.
    private static func LimitDetail(_ Geometries: [SCNGeometry])
    {
        let Segments: Int
        switch Geometries.count
        {
            case 8000...:
                Segments = 12
            
            case 3000...:
                Segments = 16
            
            case 1000...:
                Segments = 24
            
            default:
                return
        }
        for Geometry in Geometries
        {
            switch Geometry
            {
                case let Shape as SCNCylinder:
                    Shape.radialSegmentCount = min(Shape.radialSegmentCount, Segments)
                
                case let Shape as SCNSphere:
                    Shape.segmentCount = min(Shape.segmentCount, Segments)
                
                case let Shape as SCNCone:
                    Shape.radialSegmentCount = min(Shape.radialSegmentCount, Segments)
                
                case let Shape as SCNTube:
                    Shape.radialSegmentCount = min(Shape.radialSegmentCount, Segments)
                
                case let Shape as SCNCapsule:
                    Shape.radialSegmentCount = min(Shape.radialSegmentCount, Segments)
                    Shape.capSegmentCount = min(Shape.capSegmentCount, max(2, Segments / 3))
                
                case let Shape as SCNTorus:
                    Shape.ringSegmentCount = min(Shape.ringSegmentCount, Segments)
                    Shape.pipeSegmentCount = min(Shape.pipeSegmentCount, max(6, Segments / 2))
                
                default:
                    break
            }
        }
    }
    
    /// Gathers the mergeable geometry under a node, with each node's transform relative to the root.
    @_optimize(speed)
    private static func Collect(_ Node: SCNNode, _ Parent: simd_float4x4, _ Items: inout [Item], _ Kept: inout [SCNNode])
    {
        if Node.isHidden
        {
            return
        }
        let World = Parent * Node.simdTransform
        if !(Node.particleSystems?.isEmpty ?? true) || Node.light != nil || Node.camera != nil
        {
            let Copy = Node.clone()
            Copy.simdTransform = World
            Kept.append(Copy)
            return
        }
        if let Geometry = Node.geometry
        {
            Items.append(Item(Geometry: Geometry, World: World))
        }
        for Child in Node.childNodes
        {
            Collect(Child, World, &Items, &Kept)
        }
    }

    /// Builds one geometry from a set of items. Only triangle lists and strips are merged.
    /// - Note: The loops here are written with plain scalar math and raw buffers (no SIMD types or closures) so that
    ///         they run quickly even in an unoptimized Debug build.
    /// - Returns: The merged geometry, or nil if the items had no triangles.
    @_optimize(speed)
    private static func MergedGeometry(_ Items: [Item]) -> SCNGeometry?
    {
        // First pass: how many vertices and triangle indices will there be?
        var VertexTotal = 0
        var IndexTotal = 0
        for Entry in Items
        {
            guard let Source = Entry.Geometry.sources(for: .vertex).first else
            {
                continue
            }
            VertexTotal += Source.vectorCount
            for Element in Entry.Geometry.elements
            {
                IndexTotal += TriangleIndexCount(Element)
            }
        }
        if VertexTotal == 0 || IndexTotal == 0
        {
            return nil
        }
        // The buffers are handed to SceneKit without copying (and freed by it).
        let Pos = UnsafeMutablePointer<Float>.allocate(capacity: VertexTotal * 3)
        let Norm = UnsafeMutablePointer<Float>.allocate(capacity: VertexTotal * 3)
        let Col = UnsafeMutablePointer<Float>.allocate(capacity: VertexTotal * 4)
        let Idx = UnsafeMutablePointer<UInt32>.allocate(capacity: IndexTotal)
        Pos.initialize(repeating: 0.0, count: VertexTotal * 3)
        Norm.initialize(repeating: 0.0, count: VertexTotal * 3)
        Col.initialize(repeating: 1.0, count: VertexTotal * 4)
        Idx.initialize(repeating: 0, count: IndexTotal)
        var VertexBase = 0
        var IndexBase = 0
        for Entry in Items
        {
            guard let VertexSource = Entry.Geometry.sources(for: .vertex).first else
            {
                continue
            }
            let Count = VertexSource.vectorCount
            let W = Entry.World
            // Column-major 4x4: world = M * (x, y, z, 1).
            let M00 = W.columns.0.x, M10 = W.columns.1.x, M20 = W.columns.2.x, M30 = W.columns.3.x
            let M01 = W.columns.0.y, M11 = W.columns.1.y, M21 = W.columns.2.y, M31 = W.columns.3.y
            let M02 = W.columns.0.z, M12 = W.columns.1.z, M22 = W.columns.2.z, M32 = W.columns.3.z
            // Normal matrix: inverse transpose of the upper 3x3 (computed once per node).
            let Linear = simd_float3x3(SIMD3<Float>(M00, M01, M02), SIMD3<Float>(M10, M11, M12), SIMD3<Float>(M20, M21, M22))
            let NM = Linear.inverse.transpose
            let N00 = NM.columns.0.x, N10 = NM.columns.1.x, N20 = NM.columns.2.x
            let N01 = NM.columns.0.y, N11 = NM.columns.1.y, N21 = NM.columns.2.y
            let N02 = NM.columns.0.z, N12 = NM.columns.1.z, N22 = NM.columns.2.z
            // Positions.
            if VertexSource.usesFloatComponents, VertexSource.componentsPerVector >= 3,
               VertexSource.bytesPerComponent == 4 || VertexSource.bytesPerComponent == 8
            {
                let Raw = (VertexSource.data as NSData).bytes
                let Stride = VertexSource.dataStride
                let Offset = VertexSource.dataOffset
                let Wide = VertexSource.bytesPerComponent == 8
                let Available = VertexSource.data.count
                var V = 0
                let VLimit = Count
                while V < VLimit
                {
                    defer { V += 1 }
                    let Start = Offset + V * Stride
                    if Start + (Wide ? 24 : 12) > Available
                    {
                        break
                    }
                    var X: Float
                    var Y: Float
                    var Z: Float
                    if Wide
                    {
                        X = Float(Raw.loadUnaligned(fromByteOffset: Start, as: Double.self))
                        Y = Float(Raw.loadUnaligned(fromByteOffset: Start + 8, as: Double.self))
                        Z = Float(Raw.loadUnaligned(fromByteOffset: Start + 16, as: Double.self))
                    }
                    else
                    {
                        X = Raw.loadUnaligned(fromByteOffset: Start, as: Float.self)
                        Y = Raw.loadUnaligned(fromByteOffset: Start + 4, as: Float.self)
                        Z = Raw.loadUnaligned(fromByteOffset: Start + 8, as: Float.self)
                    }
                    let Slot = (VertexBase + V) * 3
                    Pos[Slot] = M00 * X + M10 * Y + M20 * Z + M30
                    Pos[Slot + 1] = M01 * X + M11 * Y + M21 * Z + M31
                    Pos[Slot + 2] = M02 * X + M12 * Y + M22 * Z + M32
                }
            }
            // Normals (a smooth fallback is computed below if the geometry has none).
            var HasNormals = false
            if let NormalSource = Entry.Geometry.sources(for: .normal).first, NormalSource.vectorCount == Count,
               NormalSource.usesFloatComponents, NormalSource.componentsPerVector >= 3,
               NormalSource.bytesPerComponent == 4 || NormalSource.bytesPerComponent == 8
            {
                HasNormals = true
                let Raw = (NormalSource.data as NSData).bytes
                let Stride = NormalSource.dataStride
                let Offset = NormalSource.dataOffset
                let Wide = NormalSource.bytesPerComponent == 8
                let Available = NormalSource.data.count
                var V = 0
                let VLimit = Count
                while V < VLimit
                {
                    defer { V += 1 }
                    let Start = Offset + V * Stride
                    if Start + (Wide ? 24 : 12) > Available
                    {
                        break
                    }
                    var X: Float
                    var Y: Float
                    var Z: Float
                    if Wide
                    {
                        X = Float(Raw.loadUnaligned(fromByteOffset: Start, as: Double.self))
                        Y = Float(Raw.loadUnaligned(fromByteOffset: Start + 8, as: Double.self))
                        Z = Float(Raw.loadUnaligned(fromByteOffset: Start + 16, as: Double.self))
                    }
                    else
                    {
                        X = Raw.loadUnaligned(fromByteOffset: Start, as: Float.self)
                        Y = Raw.loadUnaligned(fromByteOffset: Start + 4, as: Float.self)
                        Z = Raw.loadUnaligned(fromByteOffset: Start + 8, as: Float.self)
                    }
                    var NX = N00 * X + N10 * Y + N20 * Z
                    var NY = N01 * X + N11 * Y + N21 * Z
                    var NZ = N02 * X + N12 * Y + N22 * Z
                    let Length = (NX * NX + NY * NY + NZ * NZ).squareRoot()
                    if Length > 1e-9
                    {
                        NX /= Length
                        NY /= Length
                        NZ /= Length
                    }
                    else
                    {
                        NX = 0.0
                        NY = 0.0
                        NZ = 1.0
                    }
                    let Slot = (VertexBase + V) * 3
                    Norm[Slot] = NX
                    Norm[Slot + 1] = NY
                    Norm[Slot + 2] = NZ
                }
            }
            // Triangles and colors, one element (and its material) at a time.
            let Materials = Entry.Geometry.materials
            for (ElementIndex, Element) in Entry.Geometry.elements.enumerated()
            {
                let Size = Element.bytesPerIndex
                let Wanted = TriangleIndexCount(Element)
                if Wanted == 0
                {
                    continue
                }
                var R: Float = 1.0
                var G: Float = 1.0
                var B: Float = 1.0
                if !Materials.isEmpty,
                   let Color = Materials[ElementIndex % Materials.count].diffuse.contents as? NSColor,
                   let RGB = Color.usingColorSpace(.sRGB)
                {
                    R = Float(RGB.redComponent)
                    G = Float(RGB.greenComponent)
                    B = Float(RGB.blueComponent)
                }
                let Bytes = (Element.data as NSData).bytes
                let Strip = Element.primitiveType == .triangleStrip
                let Needed = Strip ? Element.primitiveCount + 2 : Element.primitiveCount * 3
                if Needed * Size > Element.data.count
                {
                    continue
                }
                let Start = IndexBase
                var I = 0
                let ILimit = Element.primitiveCount * (Strip ? 1 : 3)
                while I < ILimit
                {
                    defer { I += 1 }
                    // For a strip, each primitive I emits corners (I, I+1, I+2), the first two swapped when I is odd.
                    var Corners = (0, 0, 0)
                    var Count1 = 1
                    if Strip
                    {
                        Corners = I % 2 == 0 ? (I, I + 1, I + 2) : (I + 1, I, I + 2)
                        Count1 = 3
                    }
                    else
                    {
                        Corners = (I, 0, 0)
                    }
                    var K = 0
                    let KLimit = Count1
                    while K < KLimit
                    {
                        defer { K += 1 }
                        let Position = K == 0 ? Corners.0 : (K == 1 ? Corners.1 : Corners.2)
                        var Value: Int
                        switch Size
                        {
                            case 1:
                                Value = Int(Bytes.loadUnaligned(fromByteOffset: Position, as: UInt8.self))
                            
                            case 2:
                                Value = Int(Bytes.loadUnaligned(fromByteOffset: Position * 2, as: UInt16.self))
                            
                            default:
                                Value = Int(Bytes.loadUnaligned(fromByteOffset: Position * 4, as: UInt32.self))
                        }
                        if Value >= Count
                        {
                            Value = Count - 1
                        }
                        Idx[IndexBase] = UInt32(VertexBase + Value)
                        IndexBase += 1
                        let Slot = (VertexBase + Value) * 4
                        Col[Slot] = R
                        Col[Slot + 1] = G
                        Col[Slot + 2] = B
                    }
                }
                if !HasNormals
                {
                    var T = Start
                    while T + 2 < IndexBase
                    {
                        let A = Int(Idx[T]) * 3
                        let B2 = Int(Idx[T + 1]) * 3
                        let C = Int(Idx[T + 2]) * 3
                        T += 3
                        let E1X = Pos[B2] - Pos[A], E1Y = Pos[B2 + 1] - Pos[A + 1], E1Z = Pos[B2 + 2] - Pos[A + 2]
                        let E2X = Pos[C] - Pos[A], E2Y = Pos[C + 1] - Pos[A + 1], E2Z = Pos[C + 2] - Pos[A + 2]
                        let NX = E1Y * E2Z - E1Z * E2Y
                        let NY = E1Z * E2X - E1X * E2Z
                        let NZ = E1X * E2Y - E1Y * E2X
                        Norm[A] += NX; Norm[A + 1] += NY; Norm[A + 2] += NZ
                        Norm[B2] += NX; Norm[B2 + 1] += NY; Norm[B2 + 2] += NZ
                        Norm[C] += NX; Norm[C + 1] += NY; Norm[C + 2] += NZ
                    }
                }
            }
            if !HasNormals
            {
                var V = 0
                let VLimit = Count
                while V < VLimit
                {
                    defer { V += 1 }
                    let Slot = (VertexBase + V) * 3
                    let Length = (Norm[Slot] * Norm[Slot] + Norm[Slot + 1] * Norm[Slot + 1] + Norm[Slot + 2] * Norm[Slot + 2]).squareRoot()
                    if Length > 1e-12
                    {
                        Norm[Slot] /= Length
                        Norm[Slot + 1] /= Length
                        Norm[Slot + 2] /= Length
                    }
                    else
                    {
                        Norm[Slot] = 0.0
                        Norm[Slot + 1] = 0.0
                        Norm[Slot + 2] = 1.0
                    }
                }
            }
            VertexBase += Count
        }
        let PositionSource = SCNGeometrySource(data: Data(bytesNoCopy: Pos, count: VertexTotal * 12, deallocator: .free),
                                               semantic: .vertex, vectorCount: VertexTotal,
                                               usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                               dataOffset: 0, dataStride: 12)
        let NormalSource = SCNGeometrySource(data: Data(bytesNoCopy: Norm, count: VertexTotal * 12, deallocator: .free),
                                             semantic: .normal, vectorCount: VertexTotal,
                                             usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                             dataOffset: 0, dataStride: 12)
        let ColorSource = SCNGeometrySource(data: Data(bytesNoCopy: Col, count: VertexTotal * 16, deallocator: .free),
                                            semantic: .color, vectorCount: VertexTotal,
                                            usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: 4,
                                            dataOffset: 0, dataStride: 16)
        let Element = SCNGeometryElement(data: Data(bytesNoCopy: Idx, count: IndexTotal * 4, deallocator: .free),
                                         primitiveType: .triangles, primitiveCount: IndexBase / 3, bytesPerIndex: 4)
        return SCNGeometry(sources: [PositionSource, NormalSource, ColorSource], elements: [Element])
    }
    
    /// How many triangle corner indices an element yields when converted to a triangle list.
    private static func TriangleIndexCount(_ Element: SCNGeometryElement) -> Int
    {
        guard Element.bytesPerIndex == 1 || Element.bytesPerIndex == 2 || Element.bytesPerIndex == 4 else
        {
            return 0
        }
        switch Element.primitiveType
        {
            case .triangles, .triangleStrip:
                return Element.primitiveCount * 3
            
            default:
                return 0
        }
    }
}
