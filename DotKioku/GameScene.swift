//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let START_DELAY_TIME = 0.5
private let ANSWER_DURATION_TIME = 1.2

enum GameStatus : String {
    case
    SceneStarted = "SceneStarted",              // initial State
    ReStart = "ReStart",                        // next round
    StartDelay = "StartDelay",                  // wait START_DELAY
    WaitToStart = "WaitToStart",                // wait until User Action
    ShowAnswer = "ShowAnswer",                  // action
    ShowAnswerDuration = "ShowAnswerDuration",  // wait ANSWER_DURATION
    StartPlayerTurn = "StartPlayerTurn",        // action
    PlayingTime = "PlayingTime",                // delay until TIME UP
    TimeIsUp = "TimeIsUp",                      // action with time over
    WaitToRetry = "WaitToRetry",                // wait until Retry | STATE END |
    MatchAll = "MatchAll",                      // action with correct answer
    PrepareNextRound = "PrepareNextRound"       // action
}

class GameScene: SKScene, DKCardTableDelegate {
    private var _status:GameStatus = .SceneStarted
    private var savedTime:CFTimeInterval = 0

    private var engine:GameEngine = GameEngine()

    private var cardTable:DKCardTable?

    private var labelStart:SKLabelNode?
    private var labelScroe:SKLabelNode?

    var status:GameStatus {
        get {
            return _status
        }
        set (value) {
            _status = value
            println(value.rawValue)
        }
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        GoogleAnalyticsManager.sendScreenName("GameScene")

        let background = SKSpriteNode(color: SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), size: view.frame.size)
        background.anchorPoint = CGPointMake(0, 0)
        self.addChild(background)

        self.addLabel()
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if status == .WaitToStart {
            status = .ShowAnswer
        } else if status == .WaitToRetry {
            // TODO hide all
            status = .ReStart
        }
    }

    override func update(currentTime: CFTimeInterval) {
        let diffTime = currentTime - savedTime

        if status == .SceneStarted || status == .ReStart {
            status = .StartDelay
            savedTime = currentTime
        } else if status == .StartDelay {
            if diffTime >= START_DELAY_TIME {
                status = .WaitToStart

                self.labelStart?.hidden = false
            }
        } else if status == .ShowAnswer {
            status = .ShowAnswerDuration
            savedTime = currentTime

            self.labelStart?.hidden = true

            self.engine.newGame(1)

            let table = DKCardTable(engine: self.engine)
            table.delegate = self
            self.addChild(table)

            let cards = self.engine.currentGame!.answer
            table.displayCards(cards)
            self.cardTable = table
        } else if status == .ShowAnswerDuration {
            if diffTime >= ANSWER_DURATION_TIME {
                status = .StartPlayerTurn
            }
        } else if status == .StartPlayerTurn {
            status = .PlayingTime
            savedTime = currentTime

            let shuffled = self.engine.currentGame!.shuffle()
            self.cardTable?.displayCards(shuffled)
            self.cardTable?.enableInteraction()
        } else if status == .PlayingTime {
            if diffTime >= self.engine.playTimeMax {
                // TODO Time Over
                status = .TimeIsUp
                self.cardTable?.disableInteraction()
            }
        } else if status == .TimeIsUp {
            status = .WaitToRetry
        } else if status == .MatchAll {
            status = .PrepareNextRound
        } else if status == .PrepareNextRound {
            // -> ??
        }
    }

    func allCardsMatched() {
        if status == .PlayingTime {
            status = .MatchAll
            self.cardTable?.disableInteraction()
        }
    }

    private func addLabel() {
        let lbStart = DKUtils.createLabel()
        lbStart.text = "Start"
        lbStart.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        lbStart.hidden = true
        self.addChild(lbStart)
        self.labelStart = lbStart

        let lbScore = DKUtils.createLabel()
        lbScore.text = "00"
        lbScore.position = CGPointMake(self.frame.width - 10, self.frame.height - 30)
        lbScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(lbScore)
        self.labelScroe = lbScore
    }
}
