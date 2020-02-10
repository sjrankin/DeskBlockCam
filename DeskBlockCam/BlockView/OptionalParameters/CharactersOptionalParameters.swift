//
//  CharactersOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CharactersOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Characters)
    }
    
    init(WithCharacters: String, FontName: String)
    {
        super.init(WithShape: .Characters)
        _CharacterList = WithCharacters
        self.FontName = FontName
    }
    
    init(WithSet: CharacterSets)
    {
        super.init(WithShape: .Characters)
        _CharSet = WithSet
    }
    
    private var _CharSet: CharacterSets = .Latin
    public var CharSet: CharacterSets
    {
        get
        {
            return _CharSet
        }
        set
        {
            _CharSet = newValue
        }
    }
    
    private var _CharacterList: String = "abcdefghijklmnopqrstuvwxyz"
    public var CharacterList: String
    {
        get
        {
            return _CharacterList
        }
        set
        {
            _CharacterList = newValue
        }
    }
    
    private var _FontName: String = "Avenir"
    public var FontName: String
    {
        get
        {
            return _FontName
        }
        set
        {
            _FontName = newValue
        }
    }
}
