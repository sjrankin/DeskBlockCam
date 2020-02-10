//
//  StarOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StarOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Stars)
        self.Read()
    }
    
    init(ApexCount: Int, UseIntensity: Bool)
    {
        super.init(WithShape: .Stars)
        _ApexCount = ApexCount
        _IntensityAffectsApexCount = UseIntensity
    }
    
    private var _ApexCount: Int = 5
    public var ApexCount: Int
    {
        get
        {
            return _ApexCount
        }
        set
        {
            _ApexCount = newValue
        }
    }
    
    private var _IntensityAffectsApexCount: Bool = false
    public var IntensityAffectsApexCount: Bool
    {
        get
        {
            return _IntensityAffectsApexCount
        }
        set
        {
            _IntensityAffectsApexCount = newValue
        }
    }
    
    override public func Read()
    {
        _ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
        _IntensityAffectsApexCount = Settings.GetBoolean(ForKey: .ApexesIncrease)
    }
    
    override public func Write()
    {
        Settings.SetInteger(ApexCount, ForKey: .StarApexCount)
        Settings.SetBoolean(IntensityAffectsApexCount, ForKey: .ApexesIncrease)
    }
}
