//
//  DKCardTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/28.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let CARD_MARGIN_VERTICAL:CGFloat = 14
private let CARD_MARGIN_HORIZONTAL:CGFloat = 14

private let CARD_SELECTED_DIFF_X:CGFloat = -5
private let CARD_SELECTED_DIFF_Y:CGFloat = 5

private let COVER_POSITION_DIFF_X:CGFloat = 5
private let COVER_POSITION_DIFF_Y:CGFloat = 10

private let CARD_FADE_OUT_DURATION:CFTimeInterval = 0.5

private let COVER_FADE_DURATION:CFTimeInterval = 0.5
private let COVER_ROTATE_DURATION:CFTimeInterval = 0.7

class DKCardTable : SKNode {
    private var cardLayer:SKNode
    private var coverLayer:SKNode

    var cardViews:[DKCard]
    private var coverViews:[SKSpriteNode]

    private var selectedIndex:Int?

    init(size:CGSize) {
        self.cardLayer = SKNode()
        self.coverLayer = SKNode()
        self.cardViews = [DKCard]()
        self.coverViews = [SKSpriteNode]()

        super.init()

        let node = SKSpriteNode(color: SKColor(white: 1.0, alpha: 1.0), size: size)
        self.addChild(node)
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))

        self.addChild(self.cardLayer)
        self.addChild(self.coverLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touchedCard = self.cardViews.filter { (card) -> Bool in
            card.containsPoint(touches.allObjects[0].locationInNode(self))
        }
        if touchedCard.count > 0 {
            if let firstIndex = self.selectedIndex {
                let first = self.cardViews[firstIndex]
                let second = touchedCard[0]
                let secondIndex = find(self.cardViews, second)!

                let location = first.position
                first.position = second.position
                second.position = CGPointMake(location.x - CARD_SELECTED_DIFF_X, location.y - CARD_SELECTED_DIFF_Y)

                if firstIndex != secondIndex {
                    self.cardViews[firstIndex] = second
                    self.cardViews[secondIndex] = first
                }
                self.selectedIndex = nil
            } else {
                let selected = touchedCard[0]
                self.selectedIndex = find(self.cardViews, selected)

                let location = selected.position
                selected.position = CGPointMake(location.x + CARD_SELECTED_DIFF_X, location.y + CARD_SELECTED_DIFF_Y)
            }
        }
    }

    func enableInteraction() {
        NSLog("enableInteraction")
        self.userInteractionEnabled = true
        self.selectedIndex = nil
    }

    func disableInteraction() {
        NSLog("disableInteraction")
        self.userInteractionEnabled = false
    }

    func displayCards(cards:[Card]) {
        displayCards(cards, cols: 4)
    }

    func removeCards() {
        for card in self.cardViews {
            card.removeFromParent()
        }
        self.cardViews.removeAll()
    }

    func removeAll() {
        for card in self.cardViews {
            card.removeFromParent()
        }
        self.cardViews.removeAll()
        for cover in self.coverViews {
            cover.removeFromParent()
        }
        self.coverViews.removeAll()
    }

    func coverCards() {
        let len = self.cardViews.count
        for var i = 0; i < len; i++ {
            let card = self.cardViews[i]

            let cover = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(kDKCardWidth, kDKCardHeight))
            let location = card.position
            cover.position = CGPointMake(location.x - kDKCardHeight / 2, location.y + kDKCardHeight / 2)
            cover.anchorPoint = CGPointMake(0, 0)
            cover.alpha = 0.0
            self.coverLayer.addChild(cover)
            self.coverViews.append(cover)

            let fadeIn = SKAction.fadeInWithDuration(COVER_FADE_DURATION)
            let rotate = SKAction.rotateByAngle(CGFloat(-M_PI_2), duration: COVER_ROTATE_DURATION)
            let action = SKAction.group([fadeIn, rotate])
            cover.runAction(action)
        }
    }

    func discoverCards() {
        let len = self.coverViews.count
        for var i = 0; i < len; i++ {
            let cover = self.coverViews[i]
            let fadeOut = SKAction.fadeOutWithDuration(COVER_FADE_DURATION)
            let rotate = SKAction.rotateByAngle(CGFloat(-M_PI_2), duration: COVER_ROTATE_DURATION)
            let action = SKAction.group([fadeOut, rotate])
            cover.runAction(action)
        }
    }

    func markCards(results:[Bool]) {
        for var i = 0; i < self.cardViews.count; i++ {
            let card = self.cardViews[i]
            let match = results[i]
            if !match {
                let label = DKUtils.createLabel(fontSize: DKFontSize.Middle)
                label.text = "x"
                label.fontColor = SKColor.redColor()
                let location = card.position
                label.position = CGPointMake(location.x + kDKCardWidth / 2 - 5, location.y + kDKCardHeight / 2)
                self.cardLayer.addChild(label)
            }
        }
    }

    private func displayCards(cards:[Card], cols:Int) {
        self.cardViews.removeAll(keepCapacity: false)
        let frame = self.frame
        let len = cards.count
        let rows = len / cols

        let left = (frame.width - (kDKCardWidth * CGFloat(cols) + CGFloat(cols - 1) * CARD_MARGIN_HORIZONTAL)) / 2
        let bottom = (frame.height - (kDKCardHeight * CGFloat(rows) + CGFloat(rows - 1) * CARD_MARGIN_VERTICAL)) / 2

        for var i = 0; i < len; i++ {
            let dat = cards[i]
            let card = DKCard(cardInfo: dat)
            let col = i % cols
            let row:Int = i / cols

            card.position = CGPointMake(
                left + (CGFloat(col) + 0.5) * kDKCardWidth + CGFloat(col) * CARD_MARGIN_HORIZONTAL,
                bottom + (CGFloat(row) + 0.5) * kDKCardHeight + CGFloat(row) * CARD_MARGIN_VERTICAL)
            self.cardLayer.addChild(card)
            self.cardViews.append(card)
        }
    }
}