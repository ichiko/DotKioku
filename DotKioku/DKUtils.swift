//
//  DKUtils.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/09.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKUtils {
    private var atlas:SKTextureAtlas

    init() {
        self.atlas = SKTextureAtlas(named:"assets")
    }

    class var shared: DKUtils {
        struct Singleton {
            static let instance = DKUtils()
        }
        return Singleton.instance
    }

    func texture(fromTypeId typeId:Int) -> SKTexture {
        var textureName:String
        switch typeId {
        case 0:
            textureName = "flower.png"
        case 1:
            textureName = "bottle.png"
        case 2:
            textureName = "bat.png"
        default:
            textureName = "kinoko.png"
        }

        let texture = atlas.textureNamed(textureName)
        texture.filteringMode = SKTextureFilteringMode.Nearest
        return texture
    }
}