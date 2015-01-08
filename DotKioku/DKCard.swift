//
//  DKCard.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/07.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let CardWidth:CGFloat = 120
let CardHeight:CGFloat = 150

class DKCard: SKNode {
    var cardInfo: Card
    var icon: SKLabelNode?

    init(cardInfo:Card) {
        self.cardInfo = cardInfo

        super.init()

        let panel = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(CardWidth, CardHeight))
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(0, CardHeight))
        path.addLineToPoint(CGPointMake(CardWidth, CardHeight))
        path.addLineToPoint(CGPointMake(CardWidth, 0))
        path.addLineToPoint(CGPointMake(0, 0))
        let border = SKShapeNode(path: path.CGPath)
        border.strokeColor = SKColor.blackColor()
        border.lineWidth = 4
        border.position = CGPointMake(-CardWidth/2, -CardHeight/2)

        self.addChild(panel)
        self.addChild(border)

        self.updateIcon()
    }

    deinit {
        self.icon = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCardInfo(cardInfo:Card) {
        self.cardInfo = cardInfo
        self.updateIcon()
    }

    func updateIcon() {
        if let prev = self.icon {
            self.removeChildrenInArray(NSArray(array: [prev]))
            self.icon = nil
        }

        let icon = SKLabelNode(fontNamed: LabelFontName)
        icon.text = ["A", "B", "C", "D"][self.cardInfo.typeId]
        icon.fontColor = SKColor.blackColor()

        self.addChild(icon)
        self.icon = icon
    }
}