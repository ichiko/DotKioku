//
//  GameViewController.swift
//  DotKioku
//
//  Created by ichiko on 2015/01/06.
//  Copyright (c) 2015年 ichiko_revjune. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    var bannerView:GADBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = TitleScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill

        skView.presentScene(scene)

        let bannerView = GADBannerView(adSize:kGADAdSizeBanner)
        bannerView.adUnitID = Constants.Ads.BannerUnitID
        bannerView.rootViewController = self

        let rootSize = self.view.frame.size;
        let viewSize = bannerView.frame.size;

        let rect = CGRectMake((rootSize.width - viewSize.width) / 2, rootSize.height - viewSize.height, viewSize.width, viewSize.height);
        bannerView.frame = rect;

        self.view.addSubview(bannerView)

        let request = GADRequest()
        request.testDevices = NSArray(array: [GAD_SIMULATOR_ID])
        bannerView.loadRequest(request)

        self.bannerView = bannerView
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
