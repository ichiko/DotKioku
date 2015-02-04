//
//  DKBox.swift
//  DotKioku
//
//  Created by ichiko on 2015/02/04.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

class DKBox: SKNode {
    var card:DKCard?

    override init() {
        super.init()

        let node = SKSpriteNode(color: SKColor(white: 0.8, alpha: 1.0), size: CGSizeMake(kDKCardWidth, kDKCardHeight))
        self.addChild(node)
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hasCard() -> Bool {
        return self.card != nil
    }

    func feedOut() {
        self.card = nil
    }

    func feedIn(card:DKCard) -> Bool {
        if self.hasCard() {
            return false
        }
        let position = card.convertPoint(card.position, toNode: self)
        let frame = CGRectMake(self.position.x - kDKCardWidth / 2, self.position.y - kDKCardHeight / 2, kDKCardWidth, kDKCardHeight)
        if frame.contains(card.position) {
            self.card = card
            return true
        }
        return false
    }
}