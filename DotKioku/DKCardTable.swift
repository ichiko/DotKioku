//
//  DKCardTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/11.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let kCardSlideDuration = 0.4

class DKCardTable:SKNode {
    func addCard(cardInfo:Card, withDirection slideDown:Bool, block:dispatch_block_t?, duration:NSTimeInterval = 0) -> DKCard {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPointMake(CGRectGetMidX(self.parent!.frame), CGRectGetMidY(self.parent!.frame))
        let posFrom = CGPointMake(posTo.x, posTo.y + (slideDown ? self.parent!.frame.height : -self.parent!.frame.height))
        card.position = posFrom

        let moveAction = SKAction.moveTo(posTo, duration: kCardSlideDuration)
        if block != nil {
            let afterAction = SKAction.runBlock(block!)
            let waitAction = SKAction.waitForDuration(duration)
            let seq = SKAction.sequence([moveAction, waitAction, afterAction])
            card.runAction(seq)
        } else {
            card.runAction(moveAction)
        }

        self.addChild(card)

        return card
    }
}
