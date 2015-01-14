//
//  GoogleAnalyticsManager.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/14.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

class GoogleAnalyticsManager {
    class func configure() {
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.dispatchInterval = 20.0
        gai.trackerWithTrackingId(Constants.Track.TrackingID)

#if DEBUG
        gai.dryRun = true
        gai.logger.logLevel = GAILogLevel.Verbose
#endif
    }

    class func setAppVersion(version:String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIAppVersion, value: version)
    }

    class func sendScreenName(name:String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createAppView().set(name, forKey: kGAIScreenName).build())
    }

    class func sendEvent(category:String?, action:String?, label:String? = nil, value:Int? = nil) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build())
    }
}