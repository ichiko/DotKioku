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
    var label: SKLabelNode?
    var icon: SKSpriteNode?
    var panel: SKSpriteNode?
    var _disabled: Bool = false
    var highlighted: Bool = false
    var buttonDidToucheBlock: dispatch_block_t?

    override init() {
        super.init()
        self.userInteractionEnabled = true
    }

    convenience init(iconTexture:SKTexture, buttonSize:CGSize? = nil) {
        self.init()

        self.addPanel(buttonSize, withIcon: true)

        let icon = SKSpriteNode(texture: iconTexture)
        icon.xScale = 0.7
        icon.yScale = 0.7
        self.addChild(icon)
        self.icon = icon
    }

    convenience init(fontSize:DKFontSize, buttonSize:CGSize? = nil) {
        self.init()

        self.addPanel(buttonSize)

        let label = DKUtils.createLabel(fontSize:fontSize)
        self.addChild(label)
        self.label = label
    }

    deinit {
        self.label = nil
        self.icon = nil
        self.panel = nil
        self.buttonDidToucheBlock = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var text:String? {
        get {
            return self.label?.text
        }
        set (value) {
            self.label?.text = value!
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

    var disabled:Bool {
        get {
            return _disabled
        }
        set (value) {
            _disabled = value
            setHighLighted(_disabled)
        }
    }

    func addPanel(buttonSize:CGSize?, withIcon:Bool = false) {
        if buttonSize != nil {
            var panel = SKSpriteNode(color: SKColor.grayColor(), size: buttonSize!)
            panel.position = CGPointMake(0, withIcon ? 0 : buttonSize!.height * 0.3)
            self.addChild(panel)
            self.panel = panel
        }
    }

    func setHighLighted(highlighted:Bool) {
        self.highlighted = highlighted
        self.label?.colorBlendFactor = (highlighted ? 0.7 : 0)
        self.icon?.colorBlendFactor = (highlighted ? 0.7 : 0)
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