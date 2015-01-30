//
//  DKUtils.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/09.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKUtils {
    private class var atlas:SKTextureAtlas {
        struct Singleton {
            static let atlas = SKTextureAtlas(named:"assets")
        }
        return Singleton.atlas
    }

    class func texture(fromTypeId typeId:Int) -> SKTexture {
        var textureName:String
        switch typeId {
        case 1:
            textureName = "flower.png"
        case 2:
            textureName = "bottle.png"
        case 3:
            textureName = "bat.png"
        default:
            textureName = "kinoko.png"
        }

        let texture = atlas.textureNamed(textureName)
        texture.filteringMode = SKTextureFilteringMode.Nearest
        return texture
    }

    class func createLabel(fontSize:DKFontSize = .Middle) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.LabelFontName)
        label.fontSize = fontSize.rawValue
        label.fontColor = SKColor.blackColor()
        return label
    }
}