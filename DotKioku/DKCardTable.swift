//
//  DKCardTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/11.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKCardTable:SKNode {
    var slideHeight:CGFloat = 0

    init(frame:CGRect) {
        self.slideHeight = CGRectGetMidY(frame)

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addCard(cardInfo:Card, offset:CGFloat, slideDown:Bool = true) -> DKCard {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPointMake(0, 0)
        let posFrom = CGPointMake(0, slideDown ? self.slideHeight + self.position.y : -self.slideHeight - self.position.y)
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: CardSlideDuration)

        card.runAction(action)

        self.addChild(card)

        return card
    }
}
