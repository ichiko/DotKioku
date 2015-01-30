//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let START_DELAY_TIME = 0.5
private let RESTART_DELAY_TIME = 0.4
private let ANSWER_DURATION_TIME = 1.2
private let START_PLAYER_TURN_DELAY_TIME = 0.3
private let MATCH_ALL_DELAY_TIME = 0.8

enum GameStatus : String {
    case
    SceneStarted = "SceneStarted",              // initial State
    StartDelay = "StartDelay",                  // wait START_DELAY_TIME
    WaitToStart = "WaitToStart",                // wait until User Action
    ReStart = "ReStart",                        // next round
    ReStartDelay = "ReStartDelay",              // wait RESTART_DELAY_TIME
    ShowAnswer = "ShowAnswer",                  // action
    ShowAnswerDuration = "ShowAnswerDuration",  // wait ANSWER_DURATION_TIME
    StartPlayerTurnDelay = "StartPlayerTurnDelay", // wait START_PLAYER_TURN_DELAY_TIME
    StartPlayerTurn = "StartPlayerTurn",        // action
    PlayingTime = "PlayingTime",                // delay until TIME UP
    TimeIsUp = "TimeIsUp",                      // action with time over
    WaitToRetry = "WaitToRetry",                // wait until Retry | STATE END |
    MatchAll = "MatchAll",                      // action with correct answer
    MatchAllDelay = "MatchAllDelay",            // wait MATCH_ALL_DELAY_TIME
    PrepareNextRound = "PrepareNextRound",      // action
    ShowResult = "ShowResult",                  // action
    WaitToReplay = "WaitToReplay"
}

class GameScene: SKScene, DKCardTableDelegate {
    private var _status:GameStatus = .SceneStarted
    private var savedTime:CFTimeInterval = 0

    private var level:Int = 1

    private var engine:GameEngine = GameEngine()

    private var cardTable:DKCardTable?
    private var barNode:DKTimeBar?

    private var labelScroe:SKLabelNode?
    private var labelLevel:SKLabelNode?

    private var labelStart:SKLabelNode?
    private var labelMatchAll:SKLabelNode?

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

        self.engine.newGame(1)

        let background = SKSpriteNode(color: SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), size: view.frame.size)
        background.anchorPoint = CGPointMake(0, 0)
        self.addChild(background)

        let table = DKCardTable(engine: self.engine)
        table.delegate = self
        self.addChild(table)
        self.cardTable = table

        let bar = DKTimeBar(width: self.frame.width)
        bar.position = CGPointMake(0, self.frame.height - 60)
        self.addChild(bar)
        self.barNode = bar

        self.addLabel()

        self.updateLevelInfo()
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

        if status == .SceneStarted {
            status = .StartDelay
            savedTime = currentTime
        } else if status == .StartDelay {
            if diffTime >= START_DELAY_TIME {
                status = .WaitToStart

                self.labelStart?.hidden = false
            }
        } else if status == .ReStart {
            status = .ReStartDelay
            savedTime = currentTime
            self.cardTable?.removeAllChildren()
            self.barNode?.reset()
        } else if status == .ReStartDelay {
            if diffTime >= RESTART_DELAY_TIME {
                status = .ShowAnswer
            }
        } else if status == .ShowAnswer {
            status = .ShowAnswerDuration
            savedTime = currentTime

            self.labelStart?.hidden = true

            self.engine.nextRound()

            let cards = self.engine.currentRound!.answer
            self.cardTable?.removeAllChildren()
            self.cardTable?.displayCards(cards)
        } else if status == .ShowAnswerDuration {
            if diffTime >= ANSWER_DURATION_TIME {
                self.cardTable?.removeAllChildren()
                status = .StartPlayerTurnDelay
                savedTime = currentTime
            }
        } else if status == .StartPlayerTurnDelay {
            if diffTime >= START_PLAYER_TURN_DELAY_TIME {
                status = .StartPlayerTurn
            }
        } else if status == .StartPlayerTurn {
            status = .PlayingTime
            savedTime = currentTime

            let shuffled = self.engine.currentRound!.shuffle()
            self.cardTable?.displayCards(shuffled)
            self.cardTable?.enableInteraction()
        } else if status == .PlayingTime {
            let maxTime = self.engine.playTimeMax
            self.barNode?.update(maxTime - diffTime, maxTime: maxTime)
            if diffTime >= maxTime {
                // TODO Time Over
                status = .TimeIsUp
                self.cardTable?.disableInteraction()
            }
        } else if status == .TimeIsUp {
            status = .WaitToRetry
        } else if status == .MatchAll {
            status = .MatchAllDelay
            savedTime = currentTime
            self.labelMatchAll?.hidden = false
        } else if status == .MatchAllDelay {
            if diffTime >= MATCH_ALL_DELAY_TIME {
                status = .PrepareNextRound
            }
        } else if status == .PrepareNextRound {
            // -> ??
            status = .ReStart
            self.level++
            self.updateLevelInfo()
            self.labelMatchAll?.hidden = true
        } else if status == .ShowResult {
            status = .WaitToReplay
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

        let lbMatchAll = DKUtils.createLabel(fontSize: DKFontSize.XXLarge)
        lbMatchAll.text = "o"
        lbMatchAll.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        lbMatchAll.hidden = true
        self.addChild(lbMatchAll)
        self.labelMatchAll = lbMatchAll

        let viewTopTextY:CGFloat = 30
        let marginHorizontal:CGFloat = 10

        let lbScore = DKUtils.createLabel()
        lbScore.text = "00"
        lbScore.position = CGPointMake(self.frame.width - marginHorizontal, self.frame.height - viewTopTextY)
        lbScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(lbScore)
        self.labelScroe = lbScore

        let lbLevel = DKUtils.createLabel()
        lbLevel.text = "Lv 1"
        lbLevel.position = CGPointMake(marginHorizontal, self.frame.height - viewTopTextY)
        lbLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.addChild(lbLevel)
        self.labelLevel = lbLevel
    }

    private func updateLevelInfo() {
        self.labelLevel?.text = NSString(format: "Lv%2d", self.level)
    }
}
