//
//  CardSet.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/28.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class CardSet {
    var correct:[Card]
    var size:Int

    init(size:Int, pool:CardPool) {
        self.correct = [Card]()
        self.size = size

        self.randomCorrect(pool)
    }

    private func randomCorrect(pool:CardPool) {
        for i in 1...self.size {
            self.correct.append(pool.select())
        }
    }

    func shuffle() -> [Card] {
        var result = [Card](self.correct)
        for var i:UInt32 = UInt32(result.count); i > 1; i-- {
            let a:Int = i - 1
            let b:Int = Int(arc4random() % i)
            let tmp = result[a]
            result[a] = result[b]
            result[b] = tmp
        }
        return result
    }

    func check(array:[Card]) -> Bool {
        for var i = 0; i < correct.count; i++ {
            if correct[i] !== array[i] {
                return false
            }
        }
        return true
    }
}
