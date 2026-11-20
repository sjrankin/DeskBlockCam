//
//  LiveViewShapeMesh.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 11/20/26.
//  Copyright © 2026 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Draws the whole live view grid for the non-block shapes (spheres, rings, cones, squares, pyramids, tubes and
/// particles) as a single mesh, the way `LiveViewMesh` does for blocks. One node per cell (each with its own geometry
/// and material) is far too slow to update every frame. Here a small template shape is repeated once per cell when
/// the mesh is made, and each frame only the vertex positions and colors are rewritten.
class LiveViewShapeMesh
{
    /// A unit-sized shape that is repeated for every cell. Z points toward the camera.
    private struct Template
    {
        var Positions: [SIMD3<Float>] = []
        var Normals: [SIMD3<Float>] = []
        var Indices: [UInt32] = []

        /// Adds a triangle fan-free quad from four vertex indices (two triangles).
        mutating func AddQuad(_ A: Int, _ B: Int, _ C: Int, _ D: Int)
        {
            Indices.append(contentsOf: [UInt32(A), UInt32(B), UInt32(C), UInt32(A), UInt32(C), UInt32(D)])
        }
    }

    /// Number of horizontal cells.
    let HCount: Int
    /// Number of vertical cells.
    let VCount: Int
    /// The shape drawn in each cell.
    let Shape: Shapes

    /// Template instances per cell (more than one only for particles).
    private let InstancesPerCell: Int
    private let Source: Template
    private let VerticesPerInstance: Int
    private var Positions: [Float]
    private let NormalSource: SCNGeometrySource
    private let Elements: SCNGeometryElement

    /// The shapes this class can draw.
    static func Supports(_ Shape: Shapes) -> Bool
    {
        switch Shape
        {
            case .Spheres, .Rings, .Cones, .Squares, .Pyramids, .Tubes, .Particles:
                return true

            default:
                return false
        }
    }

    /// Initializer.
    /// - Parameter Shape: The shape for every cell. Must be one for which `Supports` is true.
    /// - Parameter HCount: Number of horizontal cells.
    /// - Parameter VCount: Number of vertical cells.
    init(Shape: Shapes, HCount: Int, VCount: Int)
    {
        self.Shape = Shape
        self.HCount = HCount
        self.VCount = VCount
        let Cells = HCount * VCount
        // Fewer segments when there are many cells, to keep the vertex count down.
        let Detailed = Cells <= 3000
        var T = Template()
        var Instances = 1
        switch Shape
        {
            case .Spheres:
                T = LiveViewShapeMesh.MakeSphere(Latitudes: Detailed ? 6 : 4, Longitudes: Detailed ? 10 : 6)

            case .Rings:
                T = LiveViewShapeMesh.MakeTorus(RingSegments: Detailed ? 12 : 8, PipeSegments: Detailed ? 6 : 4)

            case .Cones:
                T = LiveViewShapeMesh.MakeCone(Segments: Detailed ? 14 : 8, Offset: 0.0)

            case .Pyramids:
                T = LiveViewShapeMesh.MakeCone(Segments: 4, Offset: Float.pi / 4.0)

            case .Squares:
                T = LiveViewShapeMesh.MakeSquare()

            case .Tubes:
                T = LiveViewShapeMesh.MakeTube(Segments: Detailed ? 14 : 8)

            default:
                T = LiveViewShapeMesh.MakeOctahedron()
                Instances = Detailed ? 3 : 2
        }
        Source = T
        InstancesPerCell = Instances
        VerticesPerInstance = T.Positions.count
        let PerCell = VerticesPerInstance * Instances
        let TotalVertices = Cells * PerCell
        var Norm = [Float]()
        Norm.reserveCapacity(TotalVertices * 3)
        var Indices = [UInt32]()
        Indices.reserveCapacity(Cells * Instances * T.Indices.count)
        for Cell in 0 ..< Cells
        {
            for Instance in 0 ..< Instances
            {
                let Base = UInt32(Cell * PerCell + Instance * VerticesPerInstance)
                for N in T.Normals
                {
                    Norm.append(N.x)
                    Norm.append(N.y)
                    Norm.append(N.z)
                }
                for Index in T.Indices
                {
                    Indices.append(Base + Index)
                }
            }
        }
        Positions = [Float](repeating: 0.0, count: TotalVertices * 3)
        NormalSource = SCNGeometrySource(data: Norm.withUnsafeBufferPointer{Data(buffer: $0)},
                                         semantic: .normal, vectorCount: TotalVertices,
                                         usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                         dataOffset: 0, dataStride: 12)
        Elements = SCNGeometryElement(data: Indices.withUnsafeBufferPointer{Data(buffer: $0)},
                                      primitiveType: .triangles, primitiveCount: Indices.count / 3, bytesPerIndex: 4)
    }

    /// Build the geometry for the current frame.
    /// - Parameter Colors: Cell colors in YX order (as for `LiveViewMesh`).
    /// - Parameter Side: Side length of each cell.
    /// - Parameter Time: Seconds, used to animate particles.
    /// - Parameter Prominence: Returns the height value (0 up to `MaxProminence`) for a color.
    /// - Parameter MaxProminence: Largest value `Prominence` returns, used to normalize sizes.
    /// - Parameter LengthScale: Multiplier from prominence to scene units.
    /// - Returns: Geometry with one vertex color per vertex.
    func MakeGeometry(Colors: [[NSColor]], Side: CGFloat, Time: Double, MaxProminence: CGFloat,
                      LengthScale: CGFloat, Prominence: (NSColor) -> CGFloat) -> SCNGeometry
    {
        let Cells = HCount * VCount
        let PerCell = VerticesPerInstance * InstancesPerCell
        let TotalVertices = Cells * PerCell
        var ColorData = [Float](repeating: 1.0, count: TotalVertices * 4)
        let S = Float(Side)
        let Half = S / 2.0
        let TimeF = Float(Time.truncatingRemainder(dividingBy: 10000.0))
        for Y in 0 ..< VCount
        {
            for X in 0 ..< HCount
            {
                let Color = Colors[Y][X]
                let Height = Float(Prominence(Color))
                let N = Float(min(max(Height / Float(max(MaxProminence, 0.001)), 0.0), 1.0))
                let L = Float(max(Height, 0.001)) * Float(LengthScale)
                let CX = Float(X - (HCount / 2)) * S
                let CY = Float(Y - (VCount / 2)) * S
                var R: CGFloat = 0.0
                var G: CGFloat = 0.0
                var B: CGFloat = 0.0
                var A: CGFloat = 0.0
                Color.getRed(&R, green: &G, blue: &B, alpha: &A)
                let Cell = Y * HCount + X
                for Instance in 0 ..< InstancesPerCell
                {
                    var Size = Half * 0.95
                    var Extent: Float = 1.0
                    var Z0: Float = 0.0
                    var OX: Float = 0.0
                    var OY: Float = 0.0
                    switch Shape
                    {
                        case .Spheres, .Rings:
                            if Shape == .Rings
                            {
                                Size = Half * 0.95 * max(N, 0.3) / 1.3
                            }
                            else
                            {
                                // Spheres nearly fill their cell, shrinking only a little for darker cells.
                                Size = Half * 0.98 * (0.8 + 0.2 * N)
                            }
                            Extent = Size
                            Z0 = L

                        case .Cones, .Tubes:
                            Extent = L

                        case .Pyramids:
                            // The unit pyramid's corners lie on a unit circle; scale so its sides are cell-sized.
                            Size = Half * 0.95 * 1.4142
                            Extent = L

                        case .Squares:
                            Z0 = L

                        default:
                            // A particle: drifts up through the cell's column and fades (shrinks) at both ends.
                            let Seed = LiveViewShapeMesh.Hash(UInt32(Cell &* 8 &+ Instance))
                            OX = (Float(Seed & 0xff) / 255.0 - 0.5) * 0.8 * S
                            OY = (Float((Seed >> 8) & 0xff) / 255.0 - 0.5) * 0.8 * S
                            let Phase = Float((Seed >> 16) & 0xff) / 255.0
                            let Speed = 0.25 + 0.35 * Float((Seed >> 24) & 0xff) / 255.0
                            var Progress = Phase + TimeF * Speed
                            Progress -= Progress.rounded(.down)
                            Size = max(S * 0.2 * (0.4 + 0.6 * N) * sin(Progress * Float.pi), 0.0005)
                            Extent = Size
                            Z0 = L * Progress * 1.2
                    }
                    let First = Cell * PerCell + Instance * VerticesPerInstance
                    for V in 0 ..< VerticesPerInstance
                    {
                        let P = Source.Positions[V]
                        let Index = First + V
                        Positions[Index * 3] = CX + OX + P.x * Size
                        Positions[Index * 3 + 1] = CY + OY + P.y * Size
                        Positions[Index * 3 + 2] = Z0 + P.z * Extent
                        ColorData[Index * 4] = Float(R)
                        ColorData[Index * 4 + 1] = Float(G)
                        ColorData[Index * 4 + 2] = Float(B)
                    }
                }
            }
        }
        let PositionSource = SCNGeometrySource(data: Positions.withUnsafeBufferPointer{Data(buffer: $0)},
                                               semantic: .vertex, vectorCount: TotalVertices,
                                               usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4,
                                               dataOffset: 0, dataStride: 12)
        let ColorSource = SCNGeometrySource(data: ColorData.withUnsafeBufferPointer{Data(buffer: $0)},
                                            semantic: .color, vectorCount: TotalVertices,
                                            usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: 4,
                                            dataOffset: 0, dataStride: 16)
        return SCNGeometry(sources: [PositionSource, NormalSource, ColorSource], elements: [Elements])
    }

    /// Cheap integer hash so each particle gets a stable pseudo-random position, phase and speed.
    private static func Hash(_ Value: UInt32) -> UInt32
    {
        var X = Value &* 0x9E3779B1
        X ^= X >> 15
        X = X &* 0x85EBCA6B
        X ^= X >> 13
        X = X &* 0xC2B2AE35
        X ^= X >> 16
        return X
    }

    // MARK: - Templates

    /// A unit sphere centered on the origin.
    private static func MakeSphere(Latitudes: Int, Longitudes: Int) -> Template
    {
        var T = Template()
        for I in 0 ... Latitudes
        {
            let Theta = Float.pi * Float(I) / Float(Latitudes)
            for J in 0 ... Longitudes
            {
                let Phi = 2.0 * Float.pi * Float(J) / Float(Longitudes)
                let P = SIMD3<Float>(sin(Theta) * cos(Phi), sin(Theta) * sin(Phi), cos(Theta))
                T.Positions.append(P)
                T.Normals.append(P)
            }
        }
        let Row = Longitudes + 1
        for I in 0 ..< Latitudes
        {
            for J in 0 ..< Longitudes
            {
                T.AddQuad(I * Row + J, (I + 1) * Row + J, (I + 1) * Row + J + 1, I * Row + J + 1)
            }
        }
        return T
    }

    /// A torus lying in the XY plane (ring radius 1, pipe radius 0.3).
    private static func MakeTorus(RingSegments: Int, PipeSegments: Int) -> Template
    {
        var T = Template()
        let Pipe: Float = 0.3
        for I in 0 ... RingSegments
        {
            let U = 2.0 * Float.pi * Float(I) / Float(RingSegments)
            for J in 0 ... PipeSegments
            {
                let V = 2.0 * Float.pi * Float(J) / Float(PipeSegments)
                let Radius = 1.0 + Pipe * cos(V)
                T.Positions.append(SIMD3<Float>(Radius * cos(U), Radius * sin(U), Pipe * sin(V)))
                T.Normals.append(SIMD3<Float>(cos(V) * cos(U), cos(V) * sin(U), sin(V)))
            }
        }
        let Row = PipeSegments + 1
        for I in 0 ..< RingSegments
        {
            for J in 0 ..< PipeSegments
            {
                T.AddQuad(I * Row + J, (I + 1) * Row + J, (I + 1) * Row + J + 1, I * Row + J + 1)
            }
        }
        return T
    }

    /// A cone with its base (radius 1) at Z = 0 and its apex at Z = 1. The base is not drawn: it faces away
    /// from the camera. Four segments (offset 45 degrees) make a pyramid.
    private static func MakeCone(Segments: Int, Offset: Float) -> Template
    {
        var T = Template()
        let Slope: Float = 0.6
        func Rim(_ Angle: Float) -> SIMD3<Float>
        {
            return SIMD3<Float>(cos(Angle), sin(Angle), 0.0)
        }
        func Normal(_ Angle: Float) -> SIMD3<Float>
        {
            let N = SIMD3<Float>(cos(Angle), sin(Angle), Slope)
            return N / (N.x * N.x + N.y * N.y + N.z * N.z).squareRoot()
        }
        for I in 0 ..< Segments
        {
            let A0 = Offset + 2.0 * Float.pi * Float(I) / Float(Segments)
            let A1 = Offset + 2.0 * Float.pi * Float(I + 1) / Float(Segments)
            let Base = T.Positions.count
            T.Positions.append(Rim(A0))
            T.Normals.append(Normal(A0))
            T.Positions.append(Rim(A1))
            T.Normals.append(Normal(A1))
            T.Positions.append(SIMD3<Float>(0.0, 0.0, 1.0))
            T.Normals.append(Normal((A0 + A1) / 2.0))
            T.Indices.append(contentsOf: [UInt32(Base), UInt32(Base + 1), UInt32(Base + 2)])
        }
        return T
    }

    /// A flat square (side 2) in the XY plane facing the camera.
    private static func MakeSquare() -> Template
    {
        var T = Template()
        for P in [SIMD3<Float>(-1, -1, 0), SIMD3<Float>(1, -1, 0), SIMD3<Float>(1, 1, 0), SIMD3<Float>(-1, 1, 0)]
        {
            T.Positions.append(P)
            T.Normals.append(SIMD3<Float>(0, 0, 1))
        }
        T.AddQuad(0, 1, 2, 3)
        return T
    }

    /// A hollow tube along Z from 0 to 1 (outer radius 1, inner radius 0.5) with an annular cap at the top.
    private static func MakeTube(Segments: Int) -> Template
    {
        var T = Template()
        let Inner: Float = 0.5
        // Outer wall.
        for I in 0 ... Segments
        {
            let A = 2.0 * Float.pi * Float(I) / Float(Segments)
            let Out = SIMD3<Float>(cos(A), sin(A), 0.0)
            T.Positions.append(Out)
            T.Normals.append(Out)
            T.Positions.append(SIMD3<Float>(Out.x, Out.y, 1.0))
            T.Normals.append(Out)
        }
        for I in 0 ..< Segments
        {
            let B = I * 2
            T.AddQuad(B, B + 2, B + 3, B + 1)
        }
        // Inner wall (faces inward).
        let InnerStart = T.Positions.count
        for I in 0 ... Segments
        {
            let A = 2.0 * Float.pi * Float(I) / Float(Segments)
            let In = SIMD3<Float>(cos(A), sin(A), 0.0)
            T.Positions.append(In * Inner)
            T.Normals.append(-In)
            T.Positions.append(SIMD3<Float>(In.x * Inner, In.y * Inner, 1.0))
            T.Normals.append(-In)
        }
        for I in 0 ..< Segments
        {
            let B = InnerStart + I * 2
            T.AddQuad(B, B + 1, B + 3, B + 2)
        }
        // Top cap.
        let CapStart = T.Positions.count
        for I in 0 ... Segments
        {
            let A = 2.0 * Float.pi * Float(I) / Float(Segments)
            T.Positions.append(SIMD3<Float>(cos(A), sin(A), 1.0))
            T.Normals.append(SIMD3<Float>(0, 0, 1))
            T.Positions.append(SIMD3<Float>(cos(A) * Inner, sin(A) * Inner, 1.0))
            T.Normals.append(SIMD3<Float>(0, 0, 1))
        }
        for I in 0 ..< Segments
        {
            let B = CapStart + I * 2
            T.AddQuad(B, B + 2, B + 3, B + 1)
        }
        return T
    }

    /// A small octahedron (a "particle") with flat-shaded faces.
    private static func MakeOctahedron() -> Template
    {
        var T = Template()
        let Top = SIMD3<Float>(0, 0, 1)
        let Bottom = SIMD3<Float>(0, 0, -1)
        let Ring = [SIMD3<Float>(1, 0, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(-1, 0, 0), SIMD3<Float>(0, -1, 0)]
        for I in 0 ..< 4
        {
            let A = Ring[I]
            let B = Ring[(I + 1) % 4]
            for (P0, P1, P2) in [(A, B, Top), (B, A, Bottom)]
            {
                let N = SIMD3<Float>(P0.x + P1.x + P2.x, P0.y + P1.y + P2.y, P0.z + P1.z + P2.z) / 3.0
                let Length = (N.x * N.x + N.y * N.y + N.z * N.z).squareRoot()
                let Base = T.Positions.count
                for P in [P0, P1, P2]
                {
                    T.Positions.append(P)
                    T.Normals.append(N / Length)
                }
                T.Indices.append(contentsOf: [UInt32(Base), UInt32(Base + 1), UInt32(Base + 2)])
            }
        }
        return T
    }
}

extension VerticalExaggerations
{
    /// The multiplier `BlockView.ColorProminence` applies for this exaggeration.
    var Factor: CGFloat
    {
        switch self
        {
            case .None:
                return 1.0

            case .Small:
                return 1.5

            case .Medium:
                return 2.2

            case .Large:
                return 3.5
        }
    }
}

extension BlockView
{
    /// Draw (or update) the live view as one mesh of the current non-block shape.
    /// - Parameter Shape: The shape to draw. Must be one for which `LiveViewShapeMesh.Supports` is true.
    /// - Parameter Colors: Colors in YX order.
    /// - Parameter HShapeCount: Number of horizontal cells.
    /// - Parameter VShapeCount: Number of vertical cells.
    /// - Parameter Side: Side length of each cell.
    func DrawLiveViewShapeMesh(Shape: Shapes, Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, Side: CGFloat)
    {
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Small)
        let Determination = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                             Default: HeightDeterminations.Brightness)
        let Invert = Settings.GetBoolean(ForKey: .InvertHeight)
        let LengthScale = Side / 0.5 * PMul
        // A grid needs at least one cell and colors for each of them.
        guard HShapeCount >= 1, VShapeCount >= 1, Colors.count >= VShapeCount,
              (Colors.first?.count ?? 0) >= HShapeCount else
        {
            return
        }
        var Created = false
        var Mesh = LiveShapeMesh
        var Primary = LiveViewPrimaryNode
        if Primary == nil || Mesh == nil || Mesh?.Shape != Shape || Mesh?.HCount != HShapeCount ||
            Mesh?.VCount != VShapeCount
        {
            Primary?.removeFromParentNode()
            Mesh = LiveViewShapeMesh(Shape: Shape, HCount: HShapeCount, VCount: VShapeCount)
            let NewPrimary = SCNNode()
            NewPrimary.name = "Primary Node"
            NewPrimary.position = SCNVector3(0.0, 0.0, 0.0)
            NewPrimary.addChildNode(SCNNode())
            self.scene?.rootNode.addChildNode(NewPrimary)
            Primary = NewPrimary
            LiveShapeMesh = Mesh
            LiveViewPrimaryNode = NewPrimary
            Created = true
        }
        guard let ShapeMeshNow = Mesh, let MeshNode = Primary?.childNodes.first else
        {
            return
        }
        let Material = MeshNode.geometry?.firstMaterial ?? NewLiveViewMaterial()
        Material.isDoubleSided = (Shape == .Squares)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        SCNTransaction.disableActions = true
        let Geo = ShapeMeshNow.MakeGeometry(Colors: Colors, Side: Side, Time: CACurrentMediaTime(),
                                              MaxProminence: Exaggeration.Factor, LengthScale: LengthScale)
        {
            Color in
            return self.ColorProminence(Color, Exaggeration: Exaggeration, Determination: Determination,
                                        Invert: Invert)
        }
        Geo.materials = [Material]
        MeshNode.geometry = Geo
        SCNTransaction.commit()
        if Created
        {
            LiveViewNeedsFit = true
        }
        if LiveViewNeedsFit && bounds.width > 1.0 && bounds.height > 1.0
        {
            FitCameraToLiveGrid(HShapeCount: HShapeCount, VShapeCount: VShapeCount, Side: Side)
            LiveViewNeedsFit = false
        }
    }
}
