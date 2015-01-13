//
//  DKPlayerTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/11.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let kCardScaleToScale:CGFloat = 0.5
private let kCardScaleToDuration = 0.6

private let kScaledCardVectorX:CGFloat = -32
private let kScaledCardVectorY:CGFloat = -36
private let kScaledCardMoveToDuration = 0.6

private let kScaledCardSlideVectorX:CGFloat = -64.0
private let kScaledCardSlideDuration = 0.6
private let kScaledCardResetMoveDuration = 0.5

private let kAnswerCardScale:CGFloat = 0.7
private let kAnswerCardMoveToY:CGFloat = 150.0
private let kAnswerCardMoveToDuration = 0.4
private let kAnswerCardResetMoveDuration = 0.5

private let kCardResetMoveDuration = 0.5

class DKPlayerTable: DKCardTable {
    var card: DKCard?

    func addCard(cardInfo:Card, withBlock block: dispatch_block_t?, duration:NSTimeInterval) -> DKCard {
        let card = super.addCard(cardInfo, withDirection: false, block:block, duration:duration)

        if let prevCard = self.card {
            prevCard.name = "behindCard"
            let scaleAction = SKAction.scaleTo(kCardScaleToScale, duration: kCardScaleToDuration)
            let moveAction = SKAction.moveBy(
                CGVectorMake(kScaledCardVectorX, kScaledCardVectorY), duration: kScaledCardMoveToDuration)
            prevCard.runAction(SKAction.group([scaleAction, moveAction]))

            self.enumerateChildNodesWithName("behindCard", usingBlock: { (node, stop) -> Void in
                if !self.parent!.frame.contains(node.frame) {
                    node.removeFromParent()
                } else {
                    let slideAction = SKAction.moveBy(CGVectorMake(kScaledCardSlideVectorX, 0), duration: kScaledCardSlideDuration)
                    node.runAction(slideAction)
                }
            })
        }

        self.card = card
        return card
    }

    func addAnswerCard(cardInfo:Card) -> DKCard {
        let card = DKCard(cardInfo: cardInfo)
        card.name = "answer"
        card.xScale = kAnswerCardScale
        card.yScale = kAnswerCardScale
        card.position = CGPointMake(CGRectGetMidX(self.parent!.frame), self.parent!.frame.height)

        let moveAction = SKAction.moveTo(CGPointMake(CGRectGetMidX(self.parent!.frame), CGRectGetMidY(self.parent!.frame) + kAnswerCardMoveToY), duration: kAnswerCardMoveToDuration)

        card.runAction(moveAction)
        self.addChild(card)
        return card
    }

    func runResetAction() {
        if let card = self.card {
            let moveAction = SKAction.moveBy(CGVectorMake(0, -self.parent!.frame.height), duration: kCardResetMoveDuration)
            card.runAction(moveAction)
        }

        self.enumerateChildNodesWithName("behindCard", usingBlock: { (node, stop) -> Void in
            let moveAction = SKAction.moveBy(CGVectorMake(0, -self.parent!.frame.height), duration: kScaledCardResetMoveDuration)
            node.runAction(moveAction)
        })

        self.enumerateChildNodesWithName("answer", usingBlock: { (node, stop) -> Void in
            let moveAction = SKAction.moveBy(CGVectorMake(0, self.parent!.frame.height), duration: kAnswerCardResetMoveDuration)
            node.runAction(moveAction)
        })
    }

    func reset() {
        self.card = nil
        self.removeAllChildren()
    }
}
