//
//  DKCardTable.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/28.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let CARD_MARGIN_VERTICAL:CGFloat = 60
private let CARD_MARGIN_HORIZONTAL:CGFloat = 20

private let CARD_SELECTED_DIFF_X:CGFloat = -5
private let CARD_SELECTED_DIFF_Y:CGFloat = 5

protocol DKCardTableDelegate {
    func allCardsMatched()
}

class DKCardTable : SKNode {
    private var engine:GameEngine?
    private var cardViews:[DKCard]
    private var selectedIndex:Int?
    var delegate:DKCardTableDelegate?

    init(engine:GameEngine) {
        self.engine = engine
        self.cardViews = [DKCard]()

        super.init()
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
                self.cardViews[firstIndex] = second
                self.cardViews[secondIndex] = first
                self.selectedIndex = nil

                let cards = self.cardViews.map({ $0.cardInfo })
                if self.engine!.checkRoundFinish(cards) {
                    if let target = self.delegate {
                        target.allCardsMatched()
                    }
                }
            } else {
                let selected = touchedCard[0]
                self.selectedIndex = find(self.cardViews, selected)

                let location = selected.position
                selected.position = CGPointMake(location.x + CARD_SELECTED_DIFF_X, location.y + CARD_SELECTED_DIFF_Y)
            }
        }
    }

    func enableInteraction() {
        self.userInteractionEnabled = true
        self.selectedIndex = nil
    }

    func disableInteraction() {
        self.userInteractionEnabled = false
    }

    func displayCards(cards:[Card]) {
        displayCards(cards, cols: 3)
    }

    private func displayCards(cards:[Card], cols:Int) {
        self.cardViews.removeAll(keepCapacity: false)
        let frame = self.scene!.frame
        let len = cards.count
        let rows = len / cols

        let colWidth = (frame.width - CARD_MARGIN_HORIZONTAL * 2) / CGFloat(cols)
        let rowHeight = (frame.height - CARD_MARGIN_VERTICAL * 2) / CGFloat(rows)

        for var i = 0; i < len; i++ {
            let dat = cards[i]
            let card = DKCard(cardInfo: dat)
            let col = i % cols
            let row:Int = i / cols

            card.position = CGPointMake(
                CARD_MARGIN_HORIZONTAL + colWidth * (CGFloat(col) + 0.5),
                CARD_MARGIN_VERTICAL + rowHeight * (CGFloat(row) + 0.5))
            self.addChild(card)
            self.cardViews.append(card)
        }
    }
}