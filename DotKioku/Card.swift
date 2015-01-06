//
//  Card.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class Card {
    var typeId: Int
    
    init(typeId: Int) {
        self.typeId = typeId
    }
    
    func match(typeId: Int) -> Bool {
        return (self.typeId == typeId)
    }
}