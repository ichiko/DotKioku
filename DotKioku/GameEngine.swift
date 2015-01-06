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
    
    func newGame() {
        self.cardPool = CardPool(setId: 0)
        self.currentGame = RemembranceArray()
        
        for var i = 0; i < InitialSize; i++ {
            self.currentGame!.add(self.cardPool!.select())
        }
    }
    
    func nextRound() {
        self.currentGame!.add(self.cardPool!.select())
        self.currentGame!.reset()
    }
}