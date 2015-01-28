//
//  RemembranceArray.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class RemembranceArray {
    var cards: [Card]
    var index: Int

    init() {
        self.cards = [Card]()
        self.index = 0
    }

    func add(card: Card) -> Int {
        cards.append(card)
        return cards.count
    }

    func reset() {
        self.index = 0
    }
    
    func clear() {
        self.cards.removeAll(keepCapacity: true)
    }

    func hasNext() -> Bool {
        return (self.index < self.cards.count)
    }

    func getCurrent() -> Card {
        return self.cards[self.index]
    }

    func next() -> Card {
        let card = self.cards[self.index]
        self.index += 1
        return card
    }

    var count: Int {
        get {
            return self.cards.count
        }
    }
}