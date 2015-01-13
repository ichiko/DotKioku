//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let StartDurationOver = 0.5
let PreviewOverPerCard = 1.0
let PlayerTurnStartingDelay = 0.5
let PlayerTurnRunningOverPerCard = 1.0
let SucceedingWaitForNotice = 1.0
let SucceedingWaitForNextRound = 2.0

let CardSlideDuration = 0.4
let PreviewClearnDuration = 0.5
let PlayerStartedNoticeDuration = 1.0
let PlayerCompleteNoticeShowDelay = 0.3
let PlayerCompleteNoticeHideDuration = 1.5
let PlayerGoNextNoticeDuration = 1.0
let PlayerCleanWaitDuration = 0.8
let PlayerCleanDuration = 0.5
let PlayerFailedNoticeShowDelay = 0.8
let PlayerResultShowDelay = 0.5

let CardLayerBottom:CGFloat = 100
private let kPlayerTableBottom:CGFloat = 30

let CommandLayerBottom:CGFloat = 50
let ResultLayerBottomFromCenter:CGFloat = 40

let TimeBarHeight:CGFloat = 20
let TimeBarBottom:CGFloat = 170

enum GameStatus : String {
    case
    StartDuration = "StartDuration",
    WaitForReady = "WaitForReady", // wait player tap
    PreviewStarted = "PreviewStarted",
    Preview = "Preview",      // show card to remember
    PreviewEnded = "PreviewEnded", // end preview, wait animation end
    PlayerTurnStarted = "PlayerTurnStarted",   // timer start, enable command
    PlayerTunrStartingWait = "PlayerTurnStartingWait",
    PlayerTurnRunning = "PlayerTurnRunning",
    PlayerTurnEnded = "PlayerTurnEnded",
    PlayerCompleted = "PlayerCompleted", // wait a moment then goto Preview
    PlayerMissed = "PlayerMissed",  // wait a moment then show result
    PlayerTimeOver = "PlayerTimeOver", // wait a moment then show result
    GameOver = "GameOver"
}

class GameScene: SKScene, DKCommandDelegate {
    var previewTable:SKNode?
    var playerTable:DKPlayerTable?
    var commandLayer:DKCommandLayer?

    var readyLabel:SKLabelNode?
    var missLabel:SKLabelNode?
    var timeOverLabel:SKLabelNode?
    var successLabel:SKLabelNode?
    var startLabel:SKLabelNode?
    var nextLabel:SKLabelNode?

    var timerLabel:SKLabelNode?
    var timeBar:SKSpriteNode?
    var cardNumLabel:SKLabelNode?

    var _status:GameStatus = .StartDuration
    var timerSaved:CFTimeInterval = 0
    var playerTurnOver:CFTimeInterval = 0
    var endNoticeShown:Bool = false
    var cardCount:Int = 0

    var engine:GameEngine = GameEngine()

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
        timerSaved = CACurrentMediaTime()
        engine.newGame()

        let background = SKSpriteNode(color: SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), size: view.frame.size)
        background.anchorPoint = CGPointMake(0, 0)
        self.addChild(background)

        self.addCardTables()
        self.addLabels()
        self.addBar()

        let command = DKCommandLayer(cardPool: engine.info, viewSize: CGSizeMake(self.frame.width, self.frame.height))
        command.position = CGPointMake(0, CommandLayerBottom)
        command.disabled = true
        command.delegate = self
        self.addChild(command)
        self.commandLayer = command
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.status == .WaitForReady {
            AudioUtils.shared.playEffect(Constants.Sound.SERankUp, type: Constants.Sound.Type)
            self.status = .PreviewStarted
            self.readyLabel!.hidden = true
        } else if self.status == .GameOver {
            let skView:SKView = self.view!

            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if self.status == .WaitForReady {
            return
        }

        let timeDiff = currentTime - timerSaved

        self.cardNumLabel!.text = NSString(format: "%2d / %2d", self.cardCount, self.engine.cardCount)

        switch self.status {
        case .StartDuration:
            if timeDiff >= StartDurationOver {
                self.status = .WaitForReady
                self.timerSaved = currentTime
                self.cardCount = 0
                self.engine.startPreview()
            }
        case .PreviewStarted:
            self.status = .Preview
            self.timerSaved = currentTime
        case .Preview:
            if timeDiff >= PreviewOverPerCard {
                self.timerSaved = currentTime
                if self.engine.hasNext() {
                    self.cardCount++
                    self.addPreviewCard(self.engine.next(), offset: 0)
                } else {
                    self.status = .PreviewEnded

                    let waitAction = SKAction.waitForDuration(PreviewOverPerCard - PreviewClearnDuration)
                    let cleanAction = SKAction.moveBy(CGVectorMake(0, self.frame.height), duration: PreviewClearnDuration)
                    let afterAction = SKAction.runBlock({ () -> Void in
                        self.status = .PlayerTurnStarted
                    })

                    let seq = SKAction.sequence([waitAction, cleanAction, afterAction])
                    self.previewTable!.runAction(seq)
                }
            }
        case .PlayerTurnStarted:
            self.status = .PlayerTunrStartingWait
            self.timerSaved = currentTime

            self.startLabel!.hidden = false
            self.setHideAction(self.startLabel!, duration: PlayerStartedNoticeDuration)

            self.playerTurnOver = PlayerTurnRunningOverPerCard * Double(self.engine.cardCount)
            println(self.playerTurnOver)

            self.updateTimer(0)
            self.timerLabel!.hidden = false
            self.timeBar!.hidden = false
        case .PlayerTunrStartingWait:
            if timeDiff >= PlayerTurnStartingDelay {
                self.status = .PlayerTurnRunning
                self.timerSaved = currentTime
                self.cardCount = 0

                self.commandLayer!.disabled = false
                self.resetPreviewTable()
                self.engine.startInput()
            }
        case .PlayerTurnRunning:
            self.updateTimer(timeDiff)
            if timeDiff >= self.playerTurnOver {
                self.status = .PlayerTimeOver
                self.timerSaved = currentTime
                self.timeBar!.hidden = true
            }
        case .PlayerTurnEnded:
            self.status = .PlayerCompleted
            self.timerSaved = currentTime
            self.setShowAndHideAction(self.successLabel!, showDelay:PlayerCompleteNoticeShowDelay, hideDuration: PlayerCompleteNoticeHideDuration)
            self.commandLayer!.disabled = true
            self.endNoticeShown = false

            self.playerTable!.runResetAction()
        case .PlayerMissed:
            self.commandLayer!.disabled = true
            self.setShowResultAction(self.missLabel!)
            self.status = .GameOver
            AudioUtils.shared.playEffect(Constants.Sound.SEFail, type: Constants.Sound.Type)
        case .PlayerTimeOver:
            self.commandLayer!.disabled = true
            self.setShowResultAction(self.timeOverLabel!)
            self.status = .GameOver
            AudioUtils.shared.playEffect(Constants.Sound.SEFail, type: Constants.Sound.Type)
        case .PlayerCompleted:
            if timeDiff >= SucceedingWaitForNextRound {
                self.status = .Preview
                self.timerLabel!.hidden = true
                self.timeBar!.hidden = true
                self.timerSaved = currentTime
                self.cardCount = 0
                self.resetPlayerTable()
                self.engine.nextRound()
                AudioUtils.shared.playEffect(Constants.Sound.SERankUp, type: Constants.Sound.Type)
            } else if !self.endNoticeShown && timeDiff >= SucceedingWaitForNotice {
                self.endNoticeShown = true
                self.nextLabel!.hidden = false
                self.setHideAction(self.nextLabel!, duration: PlayerGoNextNoticeDuration)
            }
        default:
            let a = "A"
        }
    }

    func addCardTables() {
        let previewTable = SKNode()
        previewTable.position = CGPointMake(0, CardLayerBottom)
        self.addChild(previewTable)
        self.previewTable = previewTable

        let playerTable = DKPlayerTable()
        playerTable.position = CGPointMake(0, kPlayerTableBottom)
        self.addChild(playerTable)
        self.playerTable = playerTable
    }

    func resetPreviewTable() {
        self.previewTable!.position = CGPointMake(0, CardLayerBottom)
        self.previewTable!.removeAllChildren()
    }

    func resetPlayerTable() {
        self.playerTable!.position = CGPointMake(0, kPlayerTableBottom)
        self.playerTable!.removeAllChildren()
    }

    func addLabels() {
        let posCenter = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) + 60)

        let lbReady = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbReady.text = "Ready ?";
        lbReady.position = posCenter

        let lbMiss = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbMiss.text = "Not Collect !"
        lbMiss.position = posCenter
        lbMiss.hidden = true
        lbMiss.fontColor = SKColor.redColor()

        let lbTimeOver = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbTimeOver.text = "Time Over !"
        lbTimeOver.position = posCenter
        lbTimeOver.hidden = true
        lbTimeOver.fontColor = SKColor.redColor()

        let lbSuccess = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbSuccess.text = "Success !"
        lbSuccess.position = posCenter
        lbSuccess.hidden = true
        lbSuccess.fontColor = SKColor.greenColor()

        let lbStart = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbStart.text = "Start !"
        lbStart.position = posCenter
        lbStart.hidden = true
        lbStart.fontColor = SKColor.orangeColor()

        let lbNextRound = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbNextRound.text = "Go Next Round"
        lbNextRound.position = CGPointMake(posCenter.x, posCenter.y - 40)
        lbNextRound.hidden = true

        let lbTimer = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbTimer.text = "0"
        lbTimer.position = CGPointMake(0, self.frame.height - 30.0)
        lbTimer.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lbTimer.hidden = true

        let lbCardNum = SKLabelNode(fontNamed: Constants.LabelFontName)
        lbCardNum.text = "00/00"
        lbCardNum.position = CGPointMake(self.frame.width, self.frame.height - 30.0)
        lbCardNum.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right

        self.addChild(lbReady)
        self.addChild(lbMiss)
        self.addChild(lbTimeOver)
        self.addChild(lbSuccess)
        self.addChild(lbStart)
        self.addChild(lbNextRound)
        self.addChild(lbTimer)
        self.addChild(lbCardNum)

        self.readyLabel = lbReady
        self.missLabel = lbMiss
        self.timeOverLabel = lbTimeOver
        self.successLabel = lbSuccess
        self.startLabel = lbStart
        self.nextLabel = lbNextRound
        self.timerLabel = lbTimer
        self.cardNumLabel = lbCardNum
    }

    func addBar() {
        let bar = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(self.frame.width, TimeBarHeight))
        bar.position = CGPointMake(0, TimeBarBottom)
        bar.anchorPoint = CGPointMake(0, 0)
        bar.hidden = true

        self.addChild(bar)
        self.timeBar = bar
    }

    func updateTimer(timeDiff:CFTimeInterval) {
        let rest = max(0, self.playerTurnOver - timeDiff)
        self.timerLabel!.text = NSString(format: "% 2.2f", Float(rest))

        let progress = rest / self.playerTurnOver
        self.timeBar?.xScale = CGFloat(progress)
        if progress >= 0.5 {
            self.timeBar?.color = SKColor.greenColor()
        } else if progress >= 0.25 {
            self.timeBar?.color = SKColor.yellowColor()
        } else {
            self.timeBar?.color = SKColor.redColor()
        }
    }

    func addPreviewCard(cardInfo:Card, offset:CGFloat) {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPoint(x:CGRectGetMidX(self.frame) + offset, y:CGRectGetMidY(self.frame));
        let posFrom = CGPointMake(CGRectGetMidX(self.frame), self.frame.height)
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: CardSlideDuration)

        card.runAction(action)

        self.previewTable!.addChild(card)
        AudioUtils.shared.playEffect(Constants.Sound.SECard, type: Constants.Sound.Type)
    }

    func addPlayerCard(cardInfo:Card, offset:CGFloat, block:dispatch_block_t? = nil, duration:NSTimeInterval = 0) {
        self.playerTable!.addCard(cardInfo, withBlock: block, duration:duration)
        AudioUtils.shared.playEffect(Constants.Sound.SECard, type: Constants.Sound.Type)
    }

    func addAnswerCard(cardInfo:Card) {
        self.playerTable!.addAnswerCard(cardInfo)
    }

    func setHideAction(node:SKNode!, duration:CFTimeInterval) {
        let waitAction = SKAction.waitForDuration(duration)
        let hideAction = SKAction.hide()
        let seq = SKAction.sequence([waitAction, hideAction])
        node.runAction(seq)
    }

    func setShowAndHideAction(node:SKNode!, showDelay:CFTimeInterval, hideDuration:CFTimeInterval) {
        let delayAction = SKAction.waitForDuration(showDelay)
        let showAction = SKAction.unhide()
        let waitAction = SKAction.waitForDuration(hideDuration)
        let hideAction = SKAction.hide()
        let seq = SKAction.sequence([delayAction, showAction, waitAction, hideAction])
        node.runAction(seq)
    }

    func setShowResultAction(node:SKNode!) {
        node.hidden = true

        let delayAction = SKAction.waitForDuration(PlayerFailedNoticeShowDelay)
        let showAction = SKAction.unhide()
        let waitAction = SKAction.waitForDuration(PlayerResultShowDelay)
        let resultAction = SKAction.runBlock({ () -> Void in
            self.showResult()
        })

        let seq = SKAction.sequence([delayAction, showAction, waitAction, resultAction])
        node.runAction(seq)
    }

    func showResult() {
        let result = DKResultLayer(setInfo: self.engine.info, score: self.engine.score)
        result.position = CGPointMake(CGRectGetMidX(self.view!.frame), CGRectGetMidY(self.view!.frame) - ResultLayerBottomFromCenter)
        self.addChild(result)
    }

    func commandSelected(typeId: Int) {
        if self.status == .PlayerTurnRunning {
            self.cardCount++
            self.addAnswerCard(self.engine.answer)
            if self.engine.checkInput(typeId) {
                self.engine.next()
                if !self.engine.hasNext() {
                    self.commandLayer!.disabled = true
                    self.addPlayerCard(self.engine.getCardByTypeId(typeId)!, offset: 0, block: { () -> Void in
                        self.status = .PlayerTurnEnded
                    }, duration: 0.2)
                } else {
                    self.addPlayerCard(self.engine.getCardByTypeId(typeId)!, offset: 0)
                }
            } else {
                self.addPlayerCard(self.engine.getCardByTypeId(typeId)!, offset: 0)
                self.status = .PlayerMissed
                self.commandLayer!.disabled = true
            }
        }
    }
}
