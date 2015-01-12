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
    func addCardWithDirection(cardInfo:Card, offset:CGFloat, slideDown:Bool = true) -> DKCard {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPointMake(CGRectGetMidX(self.parent!.frame), CGRectGetMidY(self.parent!.frame))
        let posFrom = CGPointMake(posTo.x, posTo.y + (slideDown ? self.parent!.frame.height : -self.parent!.frame.height))
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: kCardSlideDuration)

        card.runAction(action)

        self.addChild(card)

        return card
    }
}
