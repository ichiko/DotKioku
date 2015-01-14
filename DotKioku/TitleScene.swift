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
        let lbTitle = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbTitle.text = Constants.Text.AppName
        lbTitle.fontSize = Constants.FontSizeLarge
        lbTitle.position = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) + 30.0)

        let btnPlay = DKButton(fontNamed: Constants.LabelFontName, fontSize: Constants.FontSizeLarge,
            buttonSize: CGSizeMake(200, 60))
        btnPlay.text = "Play"
        btnPlay.position = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) - 60.0)
        btnPlay.buttonDidToucheBlock = { () -> Void in
            let skView:SKView = self.view!

            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)
        }

        self.addChild(lbTitle)
        self.addChild(btnPlay)
    }
}