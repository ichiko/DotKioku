//
//  CardSet.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/28.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class CardSet {
    var answer:[Card]
    var size:Int

    init(size:Int, pool:CardPool) {
        self.answer = [Card]()
        self.size = size

        self.randomCorrect(pool)
    }

    private func randomCorrect(pool:CardPool) {
        for i in 1...self.size {
            self.answer.append(pool.select())
        }
    }

    func shuffle() -> [Card] {
        var result = [Card](self.answer)
        for var i:UInt32 = UInt32(result.count); i > 1; i-- {
            let a:Int = i - 1
            let b:Int = Int(arc4random() % i)
            let tmp = result[a]
            result[a] = result[b]
            result[b] = tmp
        }
        return result
    }

    func check(array:[Card]) -> [Bool] {
        var result = [Bool]()
        for var i = 0; i < answer.count; i++ {
            result.append(answer[i].match(array[i].typeId))
        }
        return result
    }
}
