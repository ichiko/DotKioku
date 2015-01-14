//
//  Constants.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/08.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import SpriteKit

struct Constants {
    static let LabelFontName = "Chalkduster"

    static let FontSizeLarge:CGFloat = 42.0

    struct Text {
        static let AppName = "DotKioku"
    }

    struct Sound {
        static let SEFail = "SE001_Fail"
        static let SERankUp = "SE001_Rankup"
        static let SECard = "SE002_paper"
        static let Type = "wav"
    }

    struct Ads {
        static let BannerUnitID = "ca-app-pub-4449584771405934/6448256002"
    }

    struct Track {
        static let TrackingID = "UA-50629803-8"
        static let CategoryScore = "Score"
        static let CategoryRetireType = "RetireType"
        static let LabelPlayerMiss = "PlayerMiss"
        static let LabelTimeOver = "TimeOver"
    }
}