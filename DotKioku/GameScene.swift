//
//  GameScene.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let LabelFontName = "Chalkduster"

let StartDurationOver = 0.5
let PreviewOverPerCard = 1.0
let PlayerTurnRunningOverPerCard = 1.0
let SucceedingWaitForNotice = 1.0
let SucceedingWaitForNextRound = 2.0

let PreviewClearnDuration = 0.5

let CardLayerBottom:CGFloat = 100

enum GameStatus : String {
    case
    StartDuration = "StartDuration",
    WaitForReady = "WaitForReady", // wait player tap
    Preview = "Preview",      // show card to remember
    PreviewEnded = "PreviewEnded", // end preview, wait animation end
    PlayerTurnStarted = "PlayerTurnStarted",   // timer start, enable command
    PlayerTurnRunning = "PlayerTurnRunning",
    PlayerCompleted = "PlayerCompleted", // wait a moment then goto Preview
    PlayerMissed = "PlayerMissed",  // wait a moment then show result
    GameOver = "GameOver"
}

class GameScene: SKScene, DKCommandDelegate {
    var cardTableLayer:SKNode?
    var commandLayer:DKCommandLayer?

    var readyLabel:DKButton?
    var missLabel:SKLabelNode?
    var successLabel:SKLabelNode?
    var nextLabel:SKLabelNode?
    var timerLabel:SKLabelNode?

    var _status:GameStatus = .StartDuration
    var timerSaved:CFTimeInterval = 0
    var previewCount:Int = 0
    var playerTurnOver:CFTimeInterval = 0

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
        if self.status == .WaitForReady {
            self.status = .Preview
            self.readyLabel!.hidden = true
        } else if self.status == .PlayerMissed {
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
                self.previewCount = 0
            }
        case .Preview:
            if timeDiff >= PreviewOverPerCard {
                self.timerSaved = currentTime
                if self.previewCount < 4 {
                    self.previewCount++
                    var offset = self.previewCount * 4
                    self.addCard(CGFloat(offset))
                } else {
                    self.status = .PreviewEnded

                    let waitAction = SKAction.waitForDuration(PreviewOverPerCard)
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
            self.commandLayer!.disabled = false
        case .PlayerTurnRunning:
            // TODO 表示の更新
            if timeDiff >= self.playerTurnOver {
                self.status = .PlayerMissed
                self.timerSaved = currentTime
            }
        case .PlayerMissed:
            // TODO 結果表示
            self.missLabel!.hidden = false
            self.commandLayer!.disabled = true
        case .PlayerCompleted:
            self.successLabel!.hidden = false
            self.commandLayer!.disabled = true
            if timeDiff >= SucceedingWaitForNextRound {
                self.status = .Preview
                self.timerSaved = currentTime
            } else if timeDiff >= SucceedingWaitForNotice {
                if self.nextLabel!.hidden {
                    self.nextLabel!.hidden = false
                }
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

    func addLabels() {
        let posCenter = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

        let lbReady = DKButton(fontNamed:LabelFontName, fontSize:65)
        lbReady.text = ">> Ready ? <<";
        lbReady.backgroundColor = SKColor.whiteColor()
        lbReady.position = posCenter
        lbReady.buttonDidToucheBlock = buttonTouched

        let lbMiss = SKLabelNode(fontNamed: LabelFontName)
        lbMiss.text = "Miss !"
        lbMiss.position = posCenter
        lbMiss.hidden = true

        let lbSuccess = SKLabelNode(fontNamed: LabelFontName)
        lbSuccess.text = "Success !"
        lbSuccess.position = posCenter
        lbSuccess.hidden = true

        let lbNextRound = SKLabelNode(fontNamed: LabelFontName)
        lbNextRound.text = "Go Next Round"
        lbNextRound.position = CGPointMake(posCenter.x, posCenter.y - 40)
        lbNextRound.hidden = true

        let lbTimer = SKLabelNode(fontNamed: LabelFontName)
        lbTimer.text = "00"
        lbTimer.position = CGPointMake(30, self.view!.frame.height - 30.0)

        self.addChild(lbReady)
        self.addChild(lbMiss)
        self.addChild(lbSuccess)
        self.addChild(lbNextRound)
        self.addChild(lbTimer)

        self.readyLabel = lbReady
        self.missLabel = lbMiss
        self.successLabel = lbSuccess
        self.nextLabel = lbNextRound
        self.timerLabel = lbTimer
    }

    func addCard(offset:CGFloat) {
        let card = DKCard(cardInfo: Card(typeId: 0))
        let posTo = CGPoint(x:CGRectGetMidX(self.frame) + offset, y:CGRectGetMidY(self.frame));
        let posFrom = CGPointMake(CGRectGetMidX(self.frame), self.frame.height)
        card.position = posFrom

        let action = SKAction.moveTo(posTo, duration: 1)

        card.runAction(action)

        self.cardTableLayer!.addChild(card)
    }

    func buttonTouched() {
        NSLog("Button touched")
    }

    func commandSelected(typeId: Int) {
        NSLog("Command Selected %d", typeId)
    }
}
