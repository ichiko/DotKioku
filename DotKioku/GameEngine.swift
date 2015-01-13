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
    private var cardPool: CardPool?
    private var currentGame: RemembranceArray?

    init() {
    }

    var info:CardPool {
        get {
            return self.cardPool!
        }
    }

    var score:Int {
        get {
            if self.hasNext() {
                return self.cardCount - 1
            } else {
                return self.cardCount
            }
        }
    }

    var cardCount:Int {
        get {
            return self.currentGame!.count
        }
    }

    var answer:Card {
        get {
            return self.currentGame!.getCurrent()
        }
    }

    func newGame() {
        self.cardPool = CardPool(setId: 0, name: "Sage Name")
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
}