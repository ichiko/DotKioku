//
//  DKTimeBar.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/30.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKTimeBar: SKNode {
    private var barNode:SKSpriteNode
    private var label:SKLabelNode

    init(width:CGFloat, height:CGFloat = 20) {
        let bar = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(width, height))
        bar.anchorPoint = CGPointMake(0, 0.5)
        self.barNode = bar

        let label = DKUtils.createLabel(fontSize: DKFontSize.Small)
        label.text = ""
        label.position = CGPointMake(width / 2, -height * 0.2)
        self.label = label

        super.init()

        self.addChild(bar)
        self.addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(restTime:CFTimeInterval, maxTime:CFTimeInterval) {
        let progress = (restTime < 0) ? 0.0 : restTime / maxTime

        self.barNode.xScale = CGFloat(progress)
        if progress >= 0.6 {
            self.barNode.color = SKColor.greenColor()
        } else if progress >= 0.3 {
            self.barNode.color = SKColor.yellowColor()
        } else {
            self.barNode.color = SKColor.redColor()
        }
        self.label.text = NSString(format: "%2.2f", restTime < 0 ? 0 : restTime)
    }

    func reset() {
        self.barNode.xScale = 1.0
        self.barNode.color = SKColor.greenColor()
        self.label.text = ""
    }
}