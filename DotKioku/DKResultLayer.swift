//
//  DKResultLayer.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/08.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let TitleLabelBottom:CGFloat = 40

class DKResultLayer:SKNode {
    init(setInfo:CardPool, score:Int) {
        super.init()

        self.addTitle(setInfo.name)
        self.addScore(score)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTitle(name:String) {
        let lbTitle = SKLabelNode(fontNamed: LabelFontName)
        lbTitle.text = name
        lbTitle.position = CGPointMake(0, TitleLabelBottom)
        self.addChild(lbTitle)
    }

    func addScore(score:Int) {
        let lbScore = SKLabelNode(fontNamed: LabelFontName)
        lbScore.text = NSString(format: "score %d", score)
        self.addChild(lbScore)
    }
}