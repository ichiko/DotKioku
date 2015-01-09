//
//  AudioUtils.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/09.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import AVFoundation

class AudioUtils {
    private var audio:AVAudioPlayer?

    class var shared:AudioUtils {
        struct Singleton {
            static let instance = AudioUtils()
        }
        return Singleton.instance
    }

    func playEffect(name:String, type:String) {
        if let audio = self.audio {
            audio.stop()
            self.audio = nil
        }

        let data = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: type)!)
        self.audio = AVAudioPlayer(contentsOfURL: data, error: nil)
        self.audio!.prepareToPlay()
        self.audio!.play()
    }
    
    func preload(name:String, type:String) {
        if let audio = self.audio {
            audio.stop()
            self.audio = nil
        }

        let data = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: type)!)
        self.audio = AVAudioPlayer(contentsOfURL: data, error: nil)
        self.audio!.prepareToPlay()
    }
}