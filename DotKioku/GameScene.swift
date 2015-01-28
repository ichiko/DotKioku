//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

enum GameStatus : String {
    case
    StartDuration = "StartDuration",
    ShowCorrects = "ShowCorrects"
}

class GameScene: SKScene {
    var _status:GameStatus = .StartDuration

    var engine:GameEngine = GameEngine()

    var status:GameStatus {
        get {
            return _status
        }
        set (value) {
            _status = value
            println(value.rawValue)
        }
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        GoogleAnalyticsManager.sendScreenName("GameScene")
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
