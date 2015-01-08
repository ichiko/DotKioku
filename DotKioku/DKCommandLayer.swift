//
//  DKCommandLayer.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/07.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

let ButtonHeight:CGFloat = 60.0

let FontName:NSString = "Chalkduster"
let FontSize:CGFloat = 42

protocol DKCommandDelegate {
    func commandSelected(typeId:Int)
}

class DKCommandLayer:SKNode {
    var delegate: DKCommandDelegate?
    var disabled: Bool

    init(cardPool:CardPool, viewSize:CGSize) {
        self.disabled = false

        super.init()

        let buttonSize = CGSizeMake(viewSize.width / 2, ButtonHeight)
        let leftX:CGFloat = buttonSize.width / 2
        let rightX:CGFloat = viewSize.width - buttonSize.width / 2
        let upperY:CGFloat = buttonSize.height * 1.5
        let lowerY:CGFloat = buttonSize.height / 2

        let btnA = DKButton(fontNamed: FontName, fontSize: FontSize, buttonSize: buttonSize)
        btnA.text = "A"
        btnA.backgroundColor = SKColor.orangeColor()
        btnA.position = CGPointMake(leftX, upperY)
        btnA.buttonDidToucheBlock = { () -> Void in
            self.commandSelected(cardPool.pool[0])
        }
        let btnB = DKButton(fontNamed: FontName, fontSize: FontSize, buttonSize: buttonSize)
        btnB.text = "B"
        btnB.position = CGPointMake(rightX, upperY)
        btnB.buttonDidToucheBlock = { () -> Void in
            self.commandSelected(cardPool.pool[1])
        }
        let btnC = DKButton(fontNamed: FontName, fontSize: FontSize, buttonSize: buttonSize)
        btnC.text = "C"
        btnC.position = CGPointMake(leftX, lowerY)
        btnC.buttonDidToucheBlock = { () -> Void in
            self.commandSelected(cardPool.pool[2])
        }
        let btnD = DKButton(fontNamed: FontName, fontSize: FontSize, buttonSize: buttonSize)
        btnD.text = "D"
        btnD.backgroundColor = SKColor.brownColor()
        btnD.position = CGPointMake(rightX, lowerY)
        btnD.buttonDidToucheBlock = { () -> Void in
            self.commandSelected(cardPool.pool[3])
        }

        self.addChild(btnA)
        self.addChild(btnB)
        self.addChild(btnC)
        self.addChild(btnD)
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