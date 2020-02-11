//
//  PSCNNode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Slight enhancement on `SCNNode` objects to record a logical X and Y coordinate.
class PSCNNode: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Note: Set to private access to stop external usage of this initializer because without
    ///         X and Y set, nodes do not show up in the processed view.
    /// - Parameter geometry: The geometry of the node.
    private init(geometry: SCNGeometry)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter Geometry: The geometry of the node.
    /// - Parameter X: Horizontal location in the processed view.
    /// - Parameter Y: Vertical location in the processed view.
    convenience init(geometry: SCNGeometry, X: Int, Y: Int)
    {
        self.init(geometry: geometry)
        _X = X
        _Y = Y
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Holds the horizontal location.
    private var _X: Int = 0
    /// Get or set the horizontal location of the node.
    public var X: Int
    {
        get
        {
            return _X
        }
        set
        {
            _X = newValue
        }
    }
    
    /// Holds the vertical location.
    private var _Y: Int = 0
    /// Get orset the vertical location of the node.
    public var Y: Int
    {
        get
        {
            return _Y
        }
        set
        {
            _Y = newValue
        }
    }
    
    private var _Prominence: CGFloat = 0.0
    public var Prominence: CGFloat
    {
        get
        {
            return _Prominence
        }
        set
        {
            _Prominence = newValue
        }
    }
    
    /// Holds an array of prominence values.
    var Prominences: [Double] = [Double]()
    
    /// Accumulate a new prominence value. If there are more than a certain number (see `MaxCount`)
    /// prominences, the first is removed before the new value is added.
    /// - Parameter PromVal: The prominence value to add.
    /// - Parameter MaxCount: The maximum number of prominences to accumulate. Defaults to 5.
    public func SetProminence(_ PromVal: Double, MaxCount: Int = 5)
    {
        if Prominences.count > MaxCount
        {
            Prominences.removeFirst()
        }
        Prominences.append(PromVal)
    }
    
    /// Return the number of prominence values.
    public var ProminenceCount: Int
    {
        get
        {
            return Prominences.count
        }
    }
    
    /// Return the current prominence variance.
    public func ProminenceVariance() -> Double
    {
        return Prominences.Variance()
    }
}

/// Extension for Double arrays to return the variance of the contents.
/// - Note: See [Sample variation for an Array in Swift](https://stackoverflow.com/questions/38228969/sample-variation-for-an-array-of-int-in-swift)
extension Array where Element == Double
{
    /// Returns the sum of the values of the array.
    func Sum() -> Element
    {
        return self.reduce(0, +)
    }
    
    /// Returns the mean of the values of the array.
    func Mean() -> Double
    {
        return Double(self.Sum()) / Double(self.count)
    }
    
    /// Returns the squared deviations of the values of the array.
    func SquaredDeviations() -> [Double]
    {
        let IMean = self.Mean()
        return self.map{ pow(Double($0) - IMean, 2)}
    }
    
    /// Returns the variance of the values of the array.
    func Variance() -> Double
    {
        return self.SquaredDeviations().Mean()
    }
}
