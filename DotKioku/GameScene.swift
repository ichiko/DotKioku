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
private let SHOW_RESULT_DELAY_TIME = 0.8

private let CARD_TABLE_HEIGHT:CGFloat = 200

private let BUTTON_CHECK_WIDTH:CGFloat = 190
private let BUTTON_CHECK_HEIGHT:CGFloat = 40

private let INFO_AREA_HEIGHT:CGFloat = 40

enum GameStatus : String {
    case
    SceneStarted = "SceneStarted",              // initial State
    StartDelay = "StartDelay",                  // wait START_DELAY_TIME
    WaitToStart = "WaitToStart",                // wait until User Action
    StartRound = "StartRound",                  // next round
    StartRoundDelay = "StartRoundDelay",        // wait RESTART_DELAY_TIME
    ShowAnswer = "ShowAnswer",                  // action
    ShowAnswerDuration = "ShowAnswerDuration",  // wait ANSWER_DURATION_TIME
    StartPlayerTurnDelay = "StartPlayerTurnDelay", // wait START_PLAYER_TURN_DELAY_TIME
    StartPlayerTurn = "StartPlayerTurn",        // action
    PlayingTime = "PlayingTime",                // delay until TIME UP
    MatchAll = "MatchAll",                      // action with correct answer
    MatchAllDelay = "MatchAllDelay",            // wait MATCH_ALL_DELAY_TIME
    PrepareNextRound = "PrepareNextRound",      // action
    ShowResult = "ShowResult",                  // action
    ShowResultDelay = "ShowResultDelay",        // wait SHOW_RESULT_DELAY_TIME
    GameFinished = "GameFinished"               // wait to RETRY
}

class GameScene: SKScene {
    private var _status:GameStatus = .SceneStarted
    private var savedTime:CFTimeInterval = 0

    private var level:Int = 1

    private var engine:GameEngine = GameEngine()

    private var AreaCenterY:CGFloat = 0.0

    private var answerTable:DKCardTable?
    private var playerTable:DKCardTable?
    private var barNode:DKTimeBar?
    private var btnCheck:DKButton?

    private var labelScroe:SKLabelNode?
    private var labelLevel:SKLabelNode?

    private var labelReady:SKLabelNode?
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

        let tableSize = CGSizeMake(view.frame.width, CARD_TABLE_HEIGHT)
        let tableAreaSize = (view.frame.height - INFO_AREA_HEIGHT - BUTTON_CHECK_HEIGHT) / 2

        let tblAnswer = DKCardTable(size:tableSize)
        tblAnswer.position = CGPointMake(CGRectGetMidX(view.frame), tableAreaSize * 1.5 + BUTTON_CHECK_HEIGHT)
        let tblPlayer = DKCardTable(size:tableSize)
        tblPlayer.position = CGPointMake(CGRectGetMidX(view.frame), tableAreaSize / 2)
        self.addChild(tblAnswer)
        self.addChild(tblPlayer)

        self.answerTable = tblAnswer
        self.playerTable = tblPlayer

        self.AreaCenterY = (view.frame.height - INFO_AREA_HEIGHT) / 2
        let btn = DKButton(fontSize: DKFontSize.Middle, buttonSize: CGSizeMake(BUTTON_CHECK_WIDTH, BUTTON_CHECK_HEIGHT))
        btn.text = "Check it"
        btn.position = CGPointMake(CGRectGetMidX(view.frame), self.AreaCenterY)
        btn.buttonDidToucheBlock = checkAnswer
        btn.hidden = true
        self.addChild(btn)
        self.btnCheck = btn

        let bar = DKTimeBar(width: self.frame.width)
        bar.position = CGPointMake(0, self.frame.height - INFO_AREA_HEIGHT)
        self.addChild(bar)
        self.barNode = bar

        self.addLabel()

        self.updateLevelInfo()
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if status == .WaitToStart {
            status = .StartRound
        } else if status == .GameFinished {
            let skView:SKView = self.view!
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
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

                self.labelReady?.hidden = false
            }
        } else if status == .StartRound {
            status = .StartRoundDelay
            savedTime = currentTime
            self.answerTable?.removeCards()
            self.playerTable?.removeCards()
            self.barNode?.reset()
        } else if status == .StartRoundDelay {
            if diffTime >= RESTART_DELAY_TIME {
                status = .ShowAnswer
            }
        } else if status == .ShowAnswer {
            status = .ShowAnswerDuration
            savedTime = currentTime

            self.labelReady?.hidden = true

            self.engine.nextRound()

            let cards = self.engine.currentRound!.answer
            self.answerTable?.displayCards(cards)
        } else if status == .ShowAnswerDuration {
            if diffTime >= ANSWER_DURATION_TIME {
                self.answerTable?.coverCards()
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
            self.playerTable?.displayCards(shuffled)
            self.playerTable?.enableInteraction()
            self.btnCheck?.hidden = false
            self.btnCheck?.disabled = false
        } else if status == .PlayingTime {
            let maxTime = self.engine.playTimeMax
            self.barNode?.update(maxTime - diffTime, maxTime: maxTime)
            if diffTime >= maxTime {
                checkAnswer()
            }
        } else if status == .MatchAll {
            status = .MatchAllDelay
            savedTime = currentTime
        } else if status == .MatchAllDelay {
            if !self.engine.hasNextRound() || diffTime >= MATCH_ALL_DELAY_TIME {
                status = .PrepareNextRound
            }
        } else if status == .PrepareNextRound {
            if self.engine.hasNextRound() {
                status = .StartRound
                self.level++
                self.updateLevelInfo()
                self.labelMatchAll?.hidden = true
                self.btnCheck?.hidden = true
            } else {
                status = .ShowResult
            }
        } else if status == .ShowResult {
            status = .ShowResultDelay
            savedTime = currentTime
        } else if status == .ShowResultDelay {
            if diffTime >= SHOW_RESULT_DELAY_TIME {
                let result = DKResultLayer(stageName: self.engine.currentStage!.name, score: self.engine.score)
                result.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                self.addChild(result)
                status = .GameFinished
            }
        }
    }

    func checkAnswer() {
        self.btnCheck?.disabled = true
        let cards = self.playerTable?.cardViews.map({ $0.cardInfo })
        self.answerTable?.openCards()
        self.playerTable?.disableInteraction()
        if self.engine.checkRoundFinish(cards!) {
            status = .MatchAll
            self.labelMatchAll?.hidden = false
        } else {
            status = .ShowResult
            self.addMatchNotAllLabel()
        }
    }

    private func addLabel() {
        let lbStart = DKUtils.createLabel()
        lbStart.text = "Ready?"
        lbStart.position = CGPointMake(CGRectGetMidX(self.frame), self.AreaCenterY)
        lbStart.hidden = true
        self.addChild(lbStart)
        self.labelReady = lbStart

        let lbMatchAll = DKUtils.createLabel(fontSize: DKFontSize.XXLarge)
        lbMatchAll.text = "◯"
        lbMatchAll.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        lbMatchAll.hidden = true
        self.addChild(lbMatchAll)
        self.labelMatchAll = lbMatchAll

        let viewTopTextY:CGFloat = 22
        let marginHorizontal:CGFloat = 10

        let lbScore = DKUtils.createLabel(fontSize: DKFontSize.Small)
        lbScore.text = "00"
        lbScore.position = CGPointMake(self.frame.width - marginHorizontal, self.frame.height - viewTopTextY)
        lbScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(lbScore)
        self.labelScroe = lbScore

        let lbLevel = DKUtils.createLabel(fontSize: DKFontSize.Small)
        lbLevel.text = "Lv 1"
        lbLevel.position = CGPointMake(marginHorizontal, self.frame.height - viewTopTextY)
        lbLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.addChild(lbLevel)
        self.labelLevel = lbLevel
    }

    private func addMatchNotAllLabel() {
        let lbMatchNot = DKUtils.createLabel(fontSize: DKFontSize.XXLarge)
        lbMatchNot.text = "x"
        lbMatchNot.fontColor = SKColor.redColor()
        lbMatchNot.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(lbMatchNot)
    }

    private func updateLevelInfo() {
        self.labelLevel?.text = NSString(format: "Lv%2d", self.level)
    }
}
