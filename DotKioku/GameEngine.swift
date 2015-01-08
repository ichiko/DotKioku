//
//  GameEngine.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

let InitialSize = 3

class GameEngine {
    var cardPool: CardPool?
    var currentGame: RemembranceArray?

    init() {
    }

    func newGame() {
        self.cardPool = CardPool(setId: 0)
        self.currentGame = RemembranceArray()

        for var i = 0; i < InitialSize; i++ {
            self.currentGame!.add(self.cardPool!.select())
        }
    }

    func startPreview() {
        self.currentGame!.reset()
    }

    func startInput() {
        self.currentGame!.reset()
    }

    func hasNext() -> Bool {
        return self.currentGame!.hasNext()
    }

    func next() -> Card {
        return self.currentGame!.next()
    }

    func checkInput(typeId:Int) -> Bool {
        let card = self.currentGame!.getCurrent()
        return card.match(typeId)
    }

    func getCardByTypeId(typeId:Int) -> Card? {
        return self.cardPool!.getById(typeId)
    }

    func nextRound() {
        self.currentGame!.add(self.cardPool!.select())
        self.currentGame!.reset()
    }

    func cardCount() -> Int {
        return self.currentGame!.count
    }
}