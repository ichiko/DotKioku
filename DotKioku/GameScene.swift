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
let PlayerTurnRunningOverPerCard = 1.0
let SucceedingWaitForNotice = 1.0
let SucceedingWaitForNextRound = 2.0

let CardSlideDuration = 0.4
let PreviewClearnDuration = 0.5
let PlayerStartNoticeDuration = 1.0
let PlayerCompleteNoticeShowDelay = 0.3
let PlayerCompleteNoticeHideDuration = 1.5
let PlayerGoNextNoticeDuration = 1.0
let PlayerCleanWaitDuration = 0.8
let PlayerCleanDuration = 0.5
let PlayerFailedNoticeShowDelay = 0.8
let PlayerResultShowDelay = 0.5

let CardLayerBottom:CGFloat = 100

enum GameStatus : String {
    case
    StartDuration = "StartDuration",
    WaitForReady = "WaitForReady", // wait player tap
    Preview = "Preview",      // show card to remember
    PreviewEnded = "PreviewEnded", // end preview, wait animation end
    PlayerTurnStarted = "PlayerTurnStarted",   // timer start, enable command
    PlayerTurnRunning = "PlayerTurnRunning",
    PlayerTurnEnded = "PlayerTurnEnded",
    PlayerCompleted = "PlayerCompleted", // wait a moment then goto Preview
    PlayerMissed = "PlayerMissed",  // wait a moment then show result
    PlayerTimeOver = "PlayerTimeOver", // wait a moment then show result
    GameOver = "GameOver"
}

class GameScene: SKScene, DKCommandDelegate {
    var cardTableLayer:SKNode?
    var commandLayer:DKCommandLayer?

    var readyLabel:DKButton?
    var missLabel:SKLabelNode?
    var timeOverLabel:SKLabelNode?
    var successLabel:SKLabelNode?
    var startLabel:SKLabelNode?
    var nextLabel:SKLabelNode?

    var timerLabel:SKLabelNode?

    var _status:GameStatus = .StartDuration
    var timerSaved:CFTimeInterval = 0
    var playerTurnOver:CFTimeInterval = 0
    var endNoticeShown:Bool = false

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
        view.backgroundColor = SKColor.grayColor()

        timerSaved = CACurrentMediaTime()
        engine.newGame()

        self.addCardTable()
        self.addLabels()

        let command = DKCommandLayer(cardPool: engine.cardPool!, viewSize: CGSizeMake(self.frame.width, self.frame.height))
        command.disabled = true
        command.delegate = self
        self.addChild(command)
        self.commandLayer = command
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.status == .PlayerMissed {
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

        self.timerLabel?.text = NSString(format: "% 2.2f", Float(timeDiff))

        switch self.status {
        case .StartDuration:
            if timeDiff >= StartDurationOver {
                self.status = .WaitForReady
                self.timerSaved = currentTime
                self.engine.startPreview()
            }
        case .Preview:
            if timeDiff >= PreviewOverPerCard {
                self.timerSaved = currentTime
                if self.engine.hasNext() {
                    self.addCard(self.engine.next(), offset: 0)
                } else {
                    self.status = .PreviewEnded

                    let waitAction = SKAction.waitForDuration(PreviewOverPerCard - PreviewClearnDuration)
                    let cleanAction = SKAction.moveTo(CGPointMake(0, self.view!.frame.height), duration: PreviewClearnDuration)
                    let afterAction = SKAction.runBlock({ () -> Void in
                        self.status = .PlayerTurnStarted
                    })

                    let seq = SKAction.sequence([waitAction, cleanAction, afterAction])
                    self.cardTableLayer!.runAction(seq)
                }
            }
        case .PlayerTurnStarted:
            self.status = .PlayerTurnRunning
            self.timerSaved = currentTime
            self.playerTurnOver = PlayerTurnRunningOverPerCard * Double(engine.currentGame!.count)
            println(self.playerTurnOver)

            self.startLabel!.hidden = false
            self.setHideAction(self.startLabel!, duration: PlayerStartNoticeDuration)

            self.commandLayer!.disabled = false
            self.resetCardTable()
            self.engine.startInput()
        case .PlayerTurnRunning:
            // TODO 表示の更新
            if timeDiff >= self.playerTurnOver {
                self.status = .PlayerTimeOver
                self.timerSaved = currentTime
            }
        case .PlayerTurnEnded:
            self.status = .PlayerCompleted
            self.timerSaved = currentTime
            self.setShowAndHideAction(self.successLabel!, showDelay:PlayerCompleteNoticeShowDelay, hideDuration: PlayerCompleteNoticeHideDuration)
            self.commandLayer!.disabled = true
            self.endNoticeShown = false

            let waitAction = SKAction.waitForDuration(PlayerCleanWaitDuration)
            let cleanAction = SKAction.moveTo(self.convertPointFromView(CGPointMake(0, 0)), duration: PlayerCleanDuration)

            let seq = SKAction.sequence([waitAction, cleanAction])
            self.cardTableLayer!.runAction(seq)
        case .PlayerMissed:
            self.commandLayer!.disabled = true
            self.setShowResultAction(self.missLabel!)
        case .PlayerTimeOver:
            self.commandLayer!.disabled = true
            self.setShowResultAction(self.timeOverLabel!)
        case .PlayerCompleted:
            if timeDiff >= SucceedingWaitForNextRound {
                self.status = .Preview
                self.timerSaved = currentTime
                self.resetCardTable()
                self.engine.nextRound()
            } else if !self.endNoticeShown && timeDiff >= SucceedingWaitForNotice {
                self.endNoticeShown = true
                self.nextLabel!.hidden = false
                self.setHideAction(self.nextLabel!, duration: PlayerGoNextNoticeDuration)
            }
        default:
            let a = "A"
        }
    }

    func addCardTable() {
        let cardLayer = SKNode()
        cardLayer.position = CGPointMake(0, CardLayerBottom)
        self.addChild(cardLayer)
        self.cardTableLayer = cardLayer
    }

    func resetCardTable() {
        self.cardTableLayer!.position = CGPointMake(0, CardLayerBottom)
        self.cardTableLayer!.removeAllChildren()
    }

    func addLabels() {
        let posCenter = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

        let lbReady = DKButton(fontNamed:LabelFontName, fontSize:65)
        lbReady.text = "Ready ?";
        lbReady.backgroundColor = SKColor.whiteColor()
        lbReady.position = posCenter
        lbReady.buttonDidToucheBlock = buttonTouched

        let lbMiss = SKLabelNode(fontNamed: LabelFontName)
        lbMiss.text = "Not Collect !"
        lbMiss.position = posCenter
        lbMiss.hidden = true
        lbMiss.fontColor = SKColor.redColor()

        let lbTimeOver = SKLabelNode(fontNamed: LabelFontName)
        lbTimeOver.text = "Time Over !"
        lbTimeOver.position = posCenter
        lbTimeOver.hidden = true
        lbTimeOver.fontColor = SKColor.redColor()

        let lbSuccess = SKLabelNode(fontNamed: LabelFontName)
        lbSuccess.text = "Success !"
        lbSuccess.position = posCenter
        lbSuccess.hidden = true
        lbSuccess.fontColor = SKColor.greenColor()

        let lbStart = SKLabelNode(fontNamed: LabelFontName)
        lbStart.text = "Start !"
        lbStart.position = posCenter
        lbStart.hidden = true
        lbStart.fontColor = SKColor.orangeColor()

        let lbNextRound = SKLabelNode(fontNamed: LabelFontName)
        lbNextRound.text = "Go Next Round"
        lbNextRound.position = CGPointMake(posCenter.x, posCenter.y - 40)
        lbNextRound.hidden = true

        let lbTimer = SKLabelNode(fontNamed: LabelFontName)
        lbTimer.text = "0"
        lbTimer.position = CGPointMake(0, self.view!.frame.height - 30.0)
        lbTimer.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

        self.addChild(lbReady)
        self.addChild(lbMiss)
        self.addChild(lbTimeOver)
        self.addChild(lbSuccess)
        self.addChild(lbStart)
        self.addChild(lbNextRound)
        self.addChild(lbTimer)

        self.readyLabel = lbReady
        self.missLabel = lbMiss
        self.timeOverLabel = lbTimeOver
        self.successLabel = lbSuccess
        self.startLabel = lbStart
        self.nextLabel = lbNextRound
        self.timerLabel = lbTimer
    }

    func addCard(cardInfo:Card, offset:CGFloat, slideDown:Bool = true) {
        let card = DKCard(cardInfo: cardInfo)
        let posTo = CGPoint(x:CGRectGetMidX(self.frame) + offset, y:CGRectGetMidY(self.frame));
        let posFrom = CGPointMake(CGRectGetMidX(self.frame), slideDown ? self.frame.height : 0)
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: CardSlideDuration)

        card.runAction(action)

        self.cardTableLayer!.addChild(card)
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
        // TODO 結果表示
    }

    func buttonTouched() {
        NSLog("Button touched")
        if self.status == .WaitForReady {
            self.status = .Preview
            self.readyLabel!.hidden = true
        }
    }

    func commandSelected(typeId: Int) {
        if self.status == .PlayerTurnRunning {
            NSLog("Command Selected %d", typeId)
            self.addCard(self.engine.getCardByTypeId(typeId)!, offset: 0, slideDown: false)
            if self.engine.checkInput(typeId) {
                self.engine.next()
                if !self.engine.hasNext() {
                    self.status = .PlayerTurnEnded
                    self.commandLayer!.disabled = true
                }
            } else {
                self.status = .PlayerMissed
                self.commandLayer!.disabled = true
            }
        }
    }
}
