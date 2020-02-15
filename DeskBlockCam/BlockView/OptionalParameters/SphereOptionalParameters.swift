//
//  SphereOptionalParameters.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SphereOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Spheres)
        self.Read()
    }
    
    init(Behavior: SphereBehaviors)
    {
        super.init(WithShape: .Spheres)
        _Behavior = Behavior
    }
    
    private var _Behavior: SphereBehaviors = .Size
    public var Behavior: SphereBehaviors
    {
        get
        {
            return _Behavior
        }
        set
        {
            _Behavior = newValue
        }
    }
    
    override public func Read()
    {
        _Behavior = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self, Default: SphereBehaviors.Size)
    }
    
    override public func Write()
    {
        Settings.SetEnum(Behavior, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
    }
}

