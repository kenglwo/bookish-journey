//
//  AppDelegate.swift
//  Affirmation
//
//  Created by 執行健人 on 2017/06/13.
//  Copyright © 2017年 Kento. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            
            if granted {
                print("通知を許可")
            } else {
                print("通知を拒否")
            }
        })
        
        
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = UIColor.white
        //ナビバーの色を変える
        UINavigationBar.appearance().barTintColor = UIColor.blue
        //ナビゲーションのタイトル文字列の色を変更
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        return true
    }
    
    //位置情報の取得を許可
    
    
    
    //レスポンスを受けて画面をchantViewへ遷移したい。
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        // 通知の情報を取得
        let notification = response.notification.request.content.body
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "chantViewController") as! chantViewController
        
        nextView.received = notification
        
        self.window?.rootViewController = nextView
        
        completionHandler()
        
    }
    
    
    
    
    
    //フォアグラウンドで通知する
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 通知の情報を取得
        let notification = notification.request.content.body
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "chantViewController") as! chantViewController
        
        nextView.received = notification
        
        self.window?.rootViewController = nextView
        
        completionHandler([.alert, .sound])
        
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

