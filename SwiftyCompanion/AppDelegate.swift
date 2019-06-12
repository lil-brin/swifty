//
//  AppDelegate.swift
//  SwiftyCompanion
//
//  Created by Brin on 6/6/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import UIKit

var api : Api?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        api = Api()
        api?.getToken(success: { (_tokenData) in
            tokenData = _tokenData
            print(tokenData!.access_token)
//            return true
        }) { (error) in
            print("error: ", error)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("expires_in: ", tokenData?.expires_in ?? "nil")
        print("created_at: ", tokenData?.created_at ?? "nil")
        if tokenData?.expires_in != nil && tokenData?.created_at != nil && ((tokenData?.created_at)! + (tokenData?.expires_in)! < NSDate.timeIntervalSinceReferenceDate) {
            api = nil
            tokenData = nil
            api = Api()
            api?.getToken(success: { (_tokenData) in
                tokenData = _tokenData
                print(tokenData!.access_token)
            }) { (error) in
                print("error: ", error)
            }
            print("access token is: \(String(describing: tokenData?.access_token))")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

