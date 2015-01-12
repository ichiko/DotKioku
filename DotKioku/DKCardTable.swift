//
//  DKCardTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/11.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKCardTable:SKNode {
    func addCard(cardInfo:Card, offset:CGFloat, slideDown:Bool = true) -> DKCard {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPointMake(CGRectGetMidX(self.parent!.frame), CGRectGetMidY(self.parent!.frame))
        let posFrom = CGPointMake(CGRectGetMidX(self.parent!.frame), slideDown ? self.parent!.frame.height + self.position.y : -self.position.y)
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: CardSlideDuration)

        card.runAction(action)

        self.addChild(card)

        return card
    }
}
