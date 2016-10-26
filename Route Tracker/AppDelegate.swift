//
//  AppDelegate.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import UIKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        INPreferences.requestSiriAuthorization({ status in
            print(String(reflecting: status))
        })
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard let intent = userActivity.interaction?.intent else { return false }
        
        guard let navVC = application.keyWindow?.rootViewController as? UINavigationController else { return false }
        
        guard let trackerVC = navVC.topViewController as? RouteTrackingViewController else { return false }
        
        switch intent {
            
        case is INStartWorkoutIntent:
            
            trackerVC.start()
            trackerVC.updateButtonForStart()
            
        case is INPauseWorkoutIntent:
            
            trackerVC.pause()
            trackerVC.rightButton.configure(title: "End", color: UIColor(red: 0.851, green: 0.298, blue: 0.392, alpha: 0.8))
            trackerVC.leftButton.configure(title: "Resume")
            
        case is INResumeWorkoutIntent:
            
            trackerVC.resume()
            trackerVC.rightButton.configure(title: "New Lap")
            trackerVC.leftButton.configure(title: "Pause")
            
        case is INEndWorkoutIntent:
            trackerVC.end()
            trackerVC.rightButton.configure(title: "New Lap")
            trackerVC.leftButton.configure(title: "Start")
            
        default:
            break
        }
        
        
        
        return true
    }
}

