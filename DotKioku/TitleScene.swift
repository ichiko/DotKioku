//
//  TitleScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/14.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
    override func didMoveToView(view: SKView) {
        GoogleAnalyticsManager.sendScreenName("TitleScene")

        let atlas = SKTextureAtlas(named: "assets")
        let background = SKSpriteNode(texture: atlas.textureNamed("background.png"))
        background.anchorPoint = CGPointMake(0, 0)

        let lbTitle = DKUtils.shared.createLabel(fontSize: DKFontSize.XLarge)
        lbTitle.text = Constants.Text.AppName
        lbTitle.position = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) + 30.0)

        let btnPlay = DKButton(fontSize: DKFontSize.XLarge,
            buttonSize: CGSizeMake(200, 60))
        btnPlay.text = "はじめる"
        btnPlay.position = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) - 60.0)
        btnPlay.buttonDidToucheBlock = { () -> Void in
            let skView:SKView = self.view!

            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)
        }

        self.addChild(background)
        self.addChild(lbTitle)
        self.addChild(btnPlay)
    }
}