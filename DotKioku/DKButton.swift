//
//  DKButton.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/07.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let PanelWidth:CGFloat = 150
let PanelHeight:CGFloat = 80

class DKButton: SKNode {
    var label: SKLabelNode
    var panel: SKSpriteNode?
    var disabled: Bool
    var highlighted: Bool
    var buttonDidToucheBlock: dispatch_block_t?

    init(fontNamed:NSString, fontSize:CGFloat, buttonSize:CGSize? = nil) {
        self.label = SKLabelNode(fontNamed: fontNamed)
        self.label.fontSize = fontSize
        self.highlighted = false
        self.disabled = false

        super.init()

        if buttonSize != nil {
            var panel = SKSpriteNode(color: SKColor.grayColor(), size: buttonSize!)
            panel.position = CGPointMake(0, buttonSize!.height * 0.3)
            self.addChild(panel)
            self.panel = panel
        }

        self.userInteractionEnabled = true

        self.addChild(self.label)
    }

    deinit {
        self.panel = nil
        self.buttonDidToucheBlock = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var text:NSString {
        get {
            return self.label.text
        }
        set (value) {
            self.label.text = value
        }
    }

    var backgroundColor:UIColor? {
        get {
            return self.panel?.color
        }
        set (value) {
            if let panel = self.panel {
                panel.color = value!
            }
        }
    }

    func setHighLighted(highlighted:Bool) {
        self.highlighted = highlighted
        self.label.colorBlendFactor = (self.highlighted ? 0.7 : 0)
        // 色とサイズのみのSpriteではブレンドが効かない
//        self.panel.colorBlendFactor = (self.highlighted ? 0.7 : 0)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !self.disabled {
            self.setHighLighted(true)
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !self.disabled {
            self.setHighLighted(false)
            if let block = self.buttonDidToucheBlock {
                block()
            }
        }
    }

    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if !self.disabled {
            self.setHighLighted(false)
        }
    }
}