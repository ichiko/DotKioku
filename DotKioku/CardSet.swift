//
//  CardSet.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/28.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class CardSet {
    var roundInfo:RoundInfo
    var answer:[Card]

    init(roundInfo:RoundInfo) {
        self.roundInfo = roundInfo
        self.answer = [Card]()

        self.loadCard(roundInfo)
    }

    private func loadCard(roundInfo:RoundInfo) {
        var array = [Card]()
        for (id, nums) in roundInfo.cardInfo {
            for i in 1...nums {
                array.append(Card(typeId: id))
            }
        }
        self.answer = shuffle(array)
    }

    func shuffle() -> [Card] {
        var shuffled = shuffle(self.answer)
        while (find(check(shuffled), false) == nil) {
            shuffled = shuffle(self.answer)
        }
        return shuffled
    }

    func check(array:[Card]) -> [Bool] {
        var result = [Bool]()
        for var i = 0; i < answer.count; i++ {
            result.append(answer[i].match(array[i].typeId))
        }
        return result
    }

    private func shuffle(array:[Card]) -> [Card] {
        var result = [Card](array)
        for var i:UInt32 = UInt32(result.count); i > 1; i-- {
            let a:Int = i - 1
            let b:Int = Int(arc4random() % i)
            let tmp = result[a]
            result[a] = result[b]
            result[b] = tmp
        }
        return result
    }
}
