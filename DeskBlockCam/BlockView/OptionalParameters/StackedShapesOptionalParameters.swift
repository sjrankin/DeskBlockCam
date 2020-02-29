//
//  StackedShapesOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StackedShapesOptionalParameters: OptionalParameters
{
    /*
    init()
    {
        super.init(WithShape: .StackedShapes)
        self.Read()
    }
    
    init(WithStack: [Shapes])
    {
        super.init(WithShape: .StackedShapes)
        _ShapeList = WithStack
    }
    
    private var _ShapeList: [Shapes] = [.Blocks]
    {
        didSet
        {
            if _ShapeList.contains(.StackedShapes)
            {
                _ShapeList = _ShapeList.filter({$0 != .StackedShapes})
            }
        }
    }
    
    public var ShapeList: [Shapes]
    {
        get
        {
            return _ShapeList
        }
        set
        {
            _ShapeList = newValue
        }
    }
    
    override public func Read()
    {
        let RawString = Settings.GetString(ForKey: .StackedShapeList, Shapes.Blocks.rawValue)
        _ShapeList = ProcessingAttributes.MakeShapeList(From: RawString)
    }
    
    override public func Write()
    {
        let AsString = ProcessingAttributes.MakeShapeString(From: ShapeList)
        Settings.SetString(AsString, ForKey: .StackedShapeList)
    }
 */
}
