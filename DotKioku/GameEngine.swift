//
//  GameEngine.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class GameEngine {
    private var _currentGame: CardSet?
    private var _playTimeMax:CFTimeInterval
    private var _score:Int

    init() {
        _playTimeMax = 0
        _score = 0
    }

    var currentGame:CardSet? {
        get { return _currentGame }
    }

    var playTimeMax:CFTimeInterval {
        get { return _playTimeMax }
    }

    var score:Int {
        get { return _score }
    }

    func newGame(stageId:Int) {
        let setId = 1
        let size = 6

        let pool = createPool(setId)
        let game = CardSet(size: size, pool: pool)

        self._currentGame = game
        self._playTimeMax = 50.0
    }

    // ラウンド終了の場、true
    func checkRoundFinish(cards:[Card]) -> Bool {
        let result = self.currentGame?.check(cards)
        if result?.filter({ !$0 }).count > 0 {
            return false
        }
        return true
    }

    func finishGameRound() {
        // TODO スコアの更新
    }

    func nextRound() {
    }

    private func createPool(setId:Int) -> CardPool {
        let pool = CardPool(setId: 1, name: "どうくつ")
        return pool
    }
}