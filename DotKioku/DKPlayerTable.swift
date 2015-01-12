//
//  DKPlayerTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/11.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let kCardScaleToScale:CGFloat = 0.4
private let kCardScaleToDuration = 0.6

private let kScaledCardPadding:CGFloat = 10.0
private let kScaledCardVectorX:CGFloat = -30
private let kScaledCardVectorY:CGFloat = -40
private let kScaledCardMoveToDuration = 0.6

private let kScaledCardSlideVectorX:CGFloat = -60.0
private let kScaledCardSlideDuration = 0.6

class DKPlayerTable: DKCardTable {
    var card: DKCard?

    func addCard(cardInfo:Card, offset:CGFloat = 0) -> DKCard {
        let card = super.addCardWithDirection(cardInfo, offset: offset, slideDown: false)

        if let prevCard = self.card {
            prevCard.name = "behindCard"
            let scaleAction = SKAction.scaleTo(kCardScaleToScale, duration: kCardScaleToDuration)
            let moveAction = SKAction.moveBy(
                CGVectorMake(kScaledCardVectorX, kScaledCardVectorY), duration: kScaledCardMoveToDuration)
            prevCard.runAction(SKAction.group([scaleAction, moveAction]))

            self.enumerateChildNodesWithName("behindCard", usingBlock: { (node, stop) -> Void in
                let slideAction = SKAction.moveBy(CGVectorMake(kScaledCardSlideVectorX, 0), duration: kScaledCardSlideDuration)
                node.runAction(slideAction)
            })
        }

        self.card = card
        return card
    }

    func reset() {
        self.card = nil
        self.removeAllChildren()
    }
}
