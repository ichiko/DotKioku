//
//  GameEngine.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class GameEngine {
    private var _currentStage:StageInfo?
    private var _currentRound:CardSet?
    private var _playTimeMax:CFTimeInterval
    private var _score:Int
    private var _results:[Bool]?

    init() {
        _playTimeMax = 0
        _score = 0
    }

    var currentStage:StageInfo? {
        get { return _currentStage }
    }

    var currentRound:CardSet? {
        get { return _currentRound }
    }

    var playTimeMax:CFTimeInterval {
        get { return _playTimeMax }
    }

    var score:Int {
        get { return _score }
    }

    var results:[Bool]? {
        get { return _results }
    }

    func newGame(stageId:Int) {
        _currentStage = StageInfo.load()
    }

    func hasNextRound() -> Bool {
        return _currentStage!.hasNextRound()
    }

    func nextRound() {
        if hasNextRound() {
            let roundInfo = _currentStage!.nextRound()!
            _currentRound = CardSet(roundInfo: roundInfo)
            self._playTimeMax = roundInfo.maxTime
        }
    }

    // ラウンド終了の場合、true
    func checkRoundFinish(cards:[Card]) -> Bool {
        _results = self.currentRound?.check(cards)
        if _results?.filter({ !$0 }).count > 0 {
            return false
        }
        return true
    }

    func finishRound() {
        // TODO スコアの更新
    }

    func finishGame() {
    }
}