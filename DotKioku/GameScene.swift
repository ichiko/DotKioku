//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

private let START_SCENE_DELAY_TIME = 0.5
private let START_DELAY_TIME = 0.6
private let ANSWER_DURATION_TIME = 2.0
private let START_PLAYER_TURN_DELAY_TIME = 1.0
private let MATCH_ALL_DELAY_TIME = 0.8
private let PREPARE_NEXT_ROUND_DELAY_TIME = 1.0
private let SHOW_RESULT_DELAY_TIME = 1.2

private let START_LABEL_FADEIN_DURATION = 0.4
private let START_LABEL_SCALE_DURATION = 0.4
private let START_LABEL_FREEZE_DURATION = 0.8
private let START_LABEL_FADEOUT_DURATION = 0.9
private let START_LABEL_MOVEUP_DURATION = 0.9
private let START_LABEL_MOVEUP_DIFF:CGFloat = 30

private let CARD_TABLE_HEIGHT:CGFloat = 320

private let BUTTON_CHECK_WIDTH:CGFloat = 190
private let BUTTON_CHECK_HEIGHT:CGFloat = 40
private let BUTTON_CHECK_MARGIN_BOTTOM:CGFloat = 80

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
    PrepareNextRoundDelay = "PrepareNextRoundDelay", // wait PREPARE_NEXT_ROUND_DELAY_TIME
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

    private var cardTable:DKCardTable?
    private var barNode:DKTimeBar?
    private var btnCheck:DKButton?

    private var labelScroe:SKLabelNode?
    private var labelLevel:SKLabelNode?
    private var labelNotice:SKLabelNode?

    private var labelReady:SKLabelNode?
    private var labelMatchAll:SKLabelNode?

    private var labelCountDown:SKLabelNode?
    private var labelStart:SKLabelNode?
    private var labelNextRound:SKLabelNode?

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

        self.AreaCenterY = (view.frame.height - INFO_AREA_HEIGHT) / 2

        let tableSize = CGSizeMake(view.frame.width, CARD_TABLE_HEIGHT)
        let table = DKCardTable(size:tableSize)
        table.position = CGPointMake(CGRectGetMidX(view.frame), self.AreaCenterY)
        self.addChild(table)
        self.cardTable = table

        let btn = DKButton(fontSize: DKFontSize.Middle, buttonSize: CGSizeMake(BUTTON_CHECK_WIDTH, BUTTON_CHECK_HEIGHT))
        btn.text = "できた!"
        btn.position = CGPointMake(CGRectGetMidX(view.frame), BUTTON_CHECK_MARGIN_BOTTOM)
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
        let diffTime:CFTimeInterval = currentTime - savedTime

        if status == .SceneStarted {
            status = .StartDelay
            savedTime = currentTime
        } else if status == .StartDelay {
            if diffTime >= START_SCENE_DELAY_TIME {
                status = .WaitToStart

                self.labelReady?.hidden = false
                self.labelNotice?.hidden = false
                self.labelNotice?.text = "タップ で かいし"
                self.labelCountDown?.hidden = true
            }
        } else if status == .StartRound {
            status = .StartRoundDelay
            savedTime = currentTime
            self.cardTable?.removeAll()
            self.barNode?.reset()
            self.labelNotice?.hidden = true
        } else if status == .StartRoundDelay {
            if diffTime >= START_DELAY_TIME {
                status = .ShowAnswer
            }
        } else if status == .ShowAnswer {
            status = .ShowAnswerDuration
            savedTime = currentTime

            self.labelReady?.hidden = true
            self.labelNotice?.hidden = false
            self.labelNotice?.text = "はいちを おぼえて"
            self.labelCountDown?.hidden = false
            self.labelCountDown?.text = NSString(format: "%d", ANSWER_DURATION_TIME)

            self.engine.nextRound()

            let cards = self.engine.currentRound!.answer
            self.cardTable?.displayAnswerCards(cards)
        } else if status == .ShowAnswerDuration {
            self.labelCountDown?.text = NSString(format: "%d", Int(ANSWER_DURATION_TIME - diffTime) + 1)
            if diffTime >= ANSWER_DURATION_TIME {
                self.cardTable?.coverCards()
                status = .StartPlayerTurnDelay
                savedTime = currentTime
                self.labelNotice?.hidden = true
                self.labelCountDown?.hidden = true
            }
        } else if status == .StartPlayerTurnDelay {
            if diffTime >= START_PLAYER_TURN_DELAY_TIME {
                status = .StartPlayerTurn
                self.showAndHideAction(self.labelStart!)
                self.labelNotice?.hidden = false
                self.labelNotice?.text = "いれかえて もとに もどして"
            }
        } else if status == .StartPlayerTurn {
            status = .PlayingTime
            savedTime = currentTime

            let shuffled = self.engine.currentRound!.shuffle()
            self.cardTable?.hideAnswer()
            self.cardTable?.displayPlayerCards(shuffled)
            self.cardTable?.discoverCards()
            self.cardTable?.enableInteraction()
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
                status = .PrepareNextRoundDelay
                savedTime = currentTime
                self.level++
                self.updateLevelInfo()
                self.labelMatchAll?.hidden = true
                self.showAndHideAction(self.labelNextRound!)
                self.btnCheck?.hidden = true
                if let label = self.labelStart {
                    label.hidden = true
                    let position = label.position
                    label.position = CGPointMake(position.x, position.y - START_LABEL_MOVEUP_DIFF)
                }
            } else {
                status = .ShowResult
            }
        } else if status == .PrepareNextRoundDelay {
            if diffTime >= PREPARE_NEXT_ROUND_DELAY_TIME {
                status = .StartRound
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
        self.cardTable?.disableInteraction()
        let cards = self.cardTable?.playerViews.map({ $0.cardInfo })
        self.labelNotice?.hidden = true
        if self.engine.checkRoundFinish(cards!) {
            status = .MatchAll
            self.labelMatchAll?.hidden = false
        } else {
            status = .ShowResult
            self.cardTable?.showResult()
            self.cardTable?.markCards(self.engine.results!)
        }
    }

    private func showAndHideAction(node:SKNode) {
        node.hidden = false
        node.alpha = 0.0
        node.xScale = 4.0
        node.yScale = 4.0
        let fadeIn = SKAction.fadeInWithDuration(START_LABEL_FADEIN_DURATION)
        let scale = SKAction.scaleTo(1.0, duration: START_LABEL_SCALE_DURATION)
        let delay = SKAction.waitForDuration(START_LABEL_FREEZE_DURATION)
        let fadeOut = SKAction.fadeOutWithDuration(START_LABEL_FADEOUT_DURATION)
        let moveUp = SKAction.moveToY(node.position.y + START_LABEL_MOVEUP_DIFF, duration: START_LABEL_MOVEUP_DURATION)
        let action = SKAction.sequence([SKAction.group([fadeIn, scale]), delay,
            SKAction.group([fadeOut, moveUp])])
        node.runAction(action)
    }

    private func addLabel() {
        let lbReady = DKUtils.createLabel(fontSize: DKFontSize.Large)
        lbReady.text = "Ready?"
        lbReady.position = CGPointMake(CGRectGetMidX(self.frame), self.AreaCenterY)
        lbReady.hidden = true
        self.addChild(lbReady)
        self.labelReady = lbReady

        let tableTopTextY:CGFloat = self.AreaCenterY + CARD_TABLE_HEIGHT / 2 - 20

        let lbMatchAll = DKUtils.createLabel(fontSize: DKFontSize.Large)
        lbMatchAll.text = "CLEAR!"
        lbMatchAll.position = CGPointMake(CGRectGetMidX(self.frame), tableTopTextY)
        lbMatchAll.hidden = true
        self.addChild(lbMatchAll)
        self.labelMatchAll = lbMatchAll

        let lbCount = DKUtils.createLabel(fontSize: DKFontSize.Large)
        lbCount.position = CGPointMake(CGRectGetMidX(self.frame), tableTopTextY)
        lbCount.hidden = true
        self.addChild(lbCount)
        self.labelCountDown = lbCount

        let lbStart = DKUtils.createLabel(fontSize: DKFontSize.Large)
        lbStart.text = "START!"
        lbStart.position = CGPointMake(CGRectGetMidX(self.frame), tableTopTextY)
        lbStart.hidden = true
        self.addChild(lbStart)
        self.labelStart = lbStart

        let lbNextRound = DKUtils.createLabel(fontSize: DKFontSize.Large)
        lbNextRound.text = "Level Up!"
        lbNextRound.position = CGPointMake(CGRectGetMidX(self.frame), tableTopTextY)
        lbNextRound.hidden = true
        self.addChild(lbNextRound)
        self.labelNextRound = lbNextRound

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

        let noticeTextY:CGFloat = 80

        let lbNotice = DKUtils.createLabel(fontSize: DKFontSize.Small)
        lbNotice.fontColor = SKColor.grayColor()
        lbNotice.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height - noticeTextY)
        self.addChild(lbNotice)
        self.labelNotice = lbNotice
    }

    private func updateLevelInfo() {
        self.labelLevel?.text = NSString(format: "Lv%2d", self.level)
    }
}
