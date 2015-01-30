//
//  StageInfo.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/29.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

class RoundInfo {
    var no:Int
    var cardInfo:[Int:Int]
    var maxTime:CFTimeInterval = 10

    class func load() {
        // TODO
    }

    private init(no:Int) {
        self.no = no
        self.cardInfo = [Int:Int]()
    }

    private func addCardInfo(cardId:Int, num:Int) {
        self.cardInfo[cardId] = num
    }
}

class StageInfo {
    var id:String
    var name:String
    var roundInfo:[RoundInfo]
    var currentRoundIndex:Int

    class func load() -> StageInfo {
        // FIXME its test
        let info = StageInfo(id: "test01", name: "some")
        var round = RoundInfo(no: 1)
        round.addCardInfo(0, num: 2)
        round.addCardInfo(1, num: 2)
        info.addRound(round)
        round = RoundInfo(no: 2)
        round.addCardInfo(0, num: 1)
        round.addCardInfo(1, num: 2)
        round.addCardInfo(2, num: 1)
        info.addRound(round)

        return info
    }

    func hasNextRound() -> Bool {
        return (self.currentRoundIndex + 1 < self.roundInfo.count)
    }

    func nextRound() -> RoundInfo? {
        if hasNextRound() {
            currentRoundIndex++
            return self.roundInfo[currentRoundIndex]
        }
        return nil
    }

    private init(id:String, name:String) {
        self.id = id
        self.name = name
        self.roundInfo = [RoundInfo]()
        self.currentRoundIndex = -1
    }

    private func addRound(round:RoundInfo) {
        self.roundInfo.append(round)
    }
}
