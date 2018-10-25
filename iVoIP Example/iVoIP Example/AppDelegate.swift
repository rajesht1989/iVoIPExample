//
//  AppDelegate.swift
//  iVoIP Example
//
//  Created by Rajesh Thangaraj on 04/10/18.
//  Copyright © 2018 Rajesh Thangaraj. All rights reserved.
//

import UIKit
import Sinch
import UserNotifications


enum ConnectionStatus {
    case connecting
    case connected
    case failed
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var client : SINClient?
    var myName = "Rajesh Mob"
    var otherName = "Rajesh Ext"
    var status = ConnectionStatus.connecting
    var currentCall : SINCall?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if UIDevice.current.name.contains("Rajesh") == false {
            myName = "Rajesh Ext"
            otherName = "Rajesh Mob"
        }
        
        client = Sinch.client(withApplicationKey: "b1991ea4-ad1a-4bb9-9bc5-8b72ee63ff57", applicationSecret: "3p8o0h4NbUqL7jR4qE0I7g==", environmentHost: "clientapi.sinch.com", userId:myName)

        if let client = client {
            client.setSupportCalling(true)
            client.setSupportMessaging(true)
            client.enableManagedPushNotifications()
            client.delegate = self
            client.start()
            client.startListeningOnActiveConnection()
            
            
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        client?.registerPushNotificationDeviceToken(deviceToken, type: "SINPushTypeVoIP", apsEnvironment: .production)
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

extension AppDelegate: SINClientDelegate {
    
    func clientDidStart(_ client: SINClient!) {
        status = .connected
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "ConnectionStatusChanged")))
        client.call()?.delegate = self
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        status = .failed
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "ConnectionStatusChanged")))
        print(error)
    }
    
    func callOtherUser() {
        currentCall = client?.call()?.callUser(withId: otherName)
    }
    
}

extension AppDelegate: SINCallClientDelegate {
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        call.delegate = self
        
        let alertController = UIAlertController.init(title: nil, message: "Incoming Call from " + otherName, preferredStyle: .alert)
        window?.rootViewController?.present(alertController, animated: true, completion:nil)
        alertController.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
            call.answer()
        }))
        alertController.addAction(UIAlertAction(title: "Deny", style: .cancel, handler: { (action) in
            call.hangup()
        }))
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming Call"
        return notification
    }
    
}


extension AppDelegate: SINCallDelegate {
    
    func callDidEnd(_ call: SINCall!) {
        currentCall = nil
    }
    
    func callDidProgress(_ call: SINCall!) {
        
    }
    
    func callDidEstablish(_ call: SINCall!) {
        currentCall = call
    }
    
    func abortCall() {
        currentCall?.hangup()
    }
    
}




