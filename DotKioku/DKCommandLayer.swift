//
//  DKCommandLayer.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/07.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let ButtonHeight:CGFloat = 60.0

let FontSize:CGFloat = 42

protocol DKCommandDelegate {
    func commandSelected(typeId:Int)
}

class DKCommandLayer:SKNode {
    var delegate: DKCommandDelegate?
    var _disabled: Bool = false

    var disabled: Bool {
        get {
            return _disabled
        }
        set (value) {
            if _disabled != value {
                _disabled = value
                self.enumerateChildNodesWithName("cmdButton", usingBlock: { (node, stop) -> Void in
                    let btn = node as DKButton
                    btn.disabled = value
                })
            }
        }
    }

    init(cardPool:CardPool, viewSize:CGSize) {
        super.init()

        let buttonSize = CGSizeMake(viewSize.width / 2, ButtonHeight)
        let leftX:CGFloat = buttonSize.width / 2
        let rightX:CGFloat = viewSize.width - buttonSize.width / 2
        let upperY:CGFloat = buttonSize.height * 1.5
        let lowerY:CGFloat = buttonSize.height / 2

        let posX = [leftX, rightX]
        let posY = [upperY, lowerY]
        let text = ["A", "B", "C", "D"]
        let color = [SKColor.orangeColor(), SKColor.grayColor(), SKColor.grayColor(), SKColor.brownColor()]

        let typeIds = cardPool.pool
        for var index = 0 ; index < typeIds.count; index++ {
            let id = typeIds[index]
            let btn = DKButton(fontNamed: LabelFontName, fontSize: FontSize, buttonSize: buttonSize)
            btn.text = text[id]
            btn.name = "cmdButton"
            btn.backgroundColor = color[id]
            btn.position = CGPointMake(posX[index % 2], posY[(index - index % 2) / 2])
            btn.buttonDidToucheBlock = { () -> Void in
                self.commandSelected(id)
            }

            self.addChild(btn)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commandSelected(typeId:Int) {
        if !self.disabled {
            if let delegateObj = self.delegate {
                delegateObj.commandSelected(typeId)
            }
        }
    }
}