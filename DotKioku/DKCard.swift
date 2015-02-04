//
//  DKCard.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/07.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let kDKCardWidth:CGFloat = 60
let kDKCardHeight:CGFloat = 60

class DKCard: SKNode {
    var cardInfo: Card
    var icon: SKSpriteNode?
    var fixed: Bool = true

    init(cardInfo:Card) {
        self.cardInfo = cardInfo

        super.init()

        let panel = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(kDKCardWidth, kDKCardHeight))
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(0, kDKCardHeight))
        path.addLineToPoint(CGPointMake(kDKCardWidth, kDKCardHeight))
        path.addLineToPoint(CGPointMake(kDKCardWidth, 0))
        path.addLineToPoint(CGPointMake(0, 0))
        let border = SKShapeNode(path: path.CGPath)
        border.strokeColor = SKColor.blackColor()
        border.lineWidth = 4
        border.position = CGPointMake(-kDKCardWidth / 2, -kDKCardHeight / 2)

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
            prev.removeFromParent()
            self.icon = nil
        }

        if self.cardInfo.typeId > 0 {
            let texture = DKUtils.texture(fromTypeId: self.cardInfo.typeId)
            let icon = SKSpriteNode(texture: texture)

            self.addChild(icon)
            self.icon = icon
        }
    }
}