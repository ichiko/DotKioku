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

private let DRAG_MOVE_THRESHOLD_SQ:CGFloat = 10 * 10

enum DragState:String {
    case None = "None", Started = "Started", Moving = "Moving"
}

class DKCardTable : SKNode {
    private var boxLayer:SKNode
    private var cardLayer:SKNode
    private var coverLayer:SKNode

    private var cardBoxes:[SKNode]
    private var cardViews:[DKCard]
    private var coverViews:[SKSpriteNode]

    private var selectedIndex:Int?

    private var _dragState:DragState = .None
    private var touchedPosition:CGPoint?
    private var touchedCard:DKCard?

    private var dragState:DragState {
        get { return _dragState }
        set (value) {
            _dragState = value
            println(value.rawValue)
        }
    }

    init(size:CGSize) {
        self.boxLayer = SKNode()
        self.boxLayer.zPosition = 1
        self.cardLayer = SKNode()
        self.cardLayer.zPosition = 2
        self.coverLayer = SKNode()
        self.coverLayer.zPosition = 3
        self.cardBoxes = [DKCard]()
        self.cardViews = [DKCard]()
        self.coverViews = [SKSpriteNode]()

        super.init()

        let node = SKSpriteNode(color: SKColor(white: 1.0, alpha: 1.0), size: size)
        self.addChild(node)
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))

        self.addChild(self.boxLayer)
        self.addChild(self.cardLayer)
        self.addChild(self.coverLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var cardInfos:[Card] {
        get {
            return self.cardViews.map({ $0.cardInfo })
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let position = touches.anyObject()!.locationInNode(self)
        let touchedCard = self.cardViews.filter { (card) -> Bool in
            card.containsPoint(position)
        }
        if touchedCard.count > 0 && self.dragState == .None {
            println("touchesBegin")
            self.dragState = .Started
            self.touchedPosition = position
            self.touchedCard = touchedCard[0]
            for card in self.cardViews {
                if card != self.touchedCard! {
                    card.zPosition = 1
                }
            }
            self.touchedCard!.zPosition = 2
        }
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if let card = self.touchedCard {
            let position = touches.anyObject()!.locationInNode(self)
            if self.dragState == .Started {
                let distance = fabs(position.x - self.touchedPosition!.x) * fabs(position.y - self.touchedPosition!.y)
                if distance >= DRAG_MOVE_THRESHOLD_SQ {
                    self.dragState = .Moving
                }
            } else if self.dragState == .Moving {
                let cardPos = card.position
                card.position = CGPointMake(cardPos.x + (position.x - self.touchedPosition!.x),
                    cardPos.y + (position.y - self.touchedPosition!.y))
                self.touchedPosition = position
            }
        }
    }

    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        println("touchesCancelled")
        self.dragState = .None
        self.touchedPosition = nil
        self.touchedCard = nil
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touchesEnded")
        self.dragState = .None
        self.touchedPosition = nil
        self.touchedCard = nil
    }

    func enableInteraction() {
        NSLog("enableInteraction")
        self.userInteractionEnabled = true
        self.selectedIndex = nil
    }

    func disableInteraction() {
        NSLog("disableInteraction")
        self.userInteractionEnabled = false
        self.dragState = .None
    }

    func displayAnswerCards(cards:[Card]) {
        displayCards(cards, cols: 4, appendBox: true)
    }

    func displayPlayerCards(cards:[Card]) {
        displayCards(cards, cols: 4, appendBox: false)
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

    private func displayCards(cards:[Card], cols:Int, appendBox:Bool) {
        for card in self.cardViews {
            card.removeFromParent()
        }
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
            card.zPosition = 1
            self.cardLayer.addChild(card)
            self.cardViews.append(card)

            if appendBox {
                let box = DKCard(cardInfo: Card(typeId: 0), color: SKColor.grayColor())
                box.position = card.position
                self.boxLayer.addChild(box)
                self.cardBoxes.append(box)
            }
        }
    }
}