//
//  DKResultLayer.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/08.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let PANEL_WIDTH:CGFloat = 320
private let PANEL_HEIGHT:CGFloat = 200

private let TITLE_LABEL_BOTTOM:CGFloat = 30
private let SCORE_LABEL_BOTTOM:CGFloat = -30

class DKResultLayer:SKNode {
    init(stageName:String, score:Int) {
        super.init()

        let frame = self.scene?.frame
        let panel = SKSpriteNode(color: SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8),
            size: CGSizeMake(PANEL_WIDTH, PANEL_HEIGHT))
        self.addChild(panel)

        self.addTitle(stageName)
        self.addScore(score)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTitle(name:String) {
        let lbTitle = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbTitle.text = name
        lbTitle.position = CGPointMake(0, TITLE_LABEL_BOTTOM)
        self.addChild(lbTitle)
    }

    func addScore(score:Int) {
        let lbScore = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbScore.text = NSString(format: "score %d", score)
        lbScore.position = CGPointMake(0, SCORE_LABEL_BOTTOM)
        self.addChild(lbScore)
    }
}