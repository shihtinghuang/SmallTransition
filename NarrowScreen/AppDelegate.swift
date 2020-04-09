//
//  AppDelegate.swift
//  NarrowScreen
//
//  Created by s-huang on 2020/01/31.
//  Copyright © 2020 U-Next. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true 
    }

    // MARK: UISceneSession Lifecycle



}

