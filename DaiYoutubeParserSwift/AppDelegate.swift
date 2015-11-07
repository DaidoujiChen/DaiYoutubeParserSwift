//
//  AppDelegate.swift
//  DaiYoutubeParserSwift
//
//  Created by 啟倫 陳 on 2015/11/7.
//  Copyright © 2015年 ChilunChen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = DemoViewController(nibName: "DemoViewController", bundle: nil)
        self.window?.makeKeyAndVisible()
        return true
    }
    
}

