//
//  CardPool.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import Foundation

class CardPool {
    var pool: [Int]

    init(setId:Int) {
        self.pool = [Int]()
        self.initWithSet(setId)
    }

    func initWithSet(setId:Int) {
        self.pool.append(0)
        self.pool.append(1)
        self.pool.append(2)
        self.pool.append(3)
    }

    func select() -> Card {
        let index = arc4random() % UInt32(self.pool.count)
        let typeId = self.pool[Int(index)]
        return Card(typeId: typeId)
    }
}