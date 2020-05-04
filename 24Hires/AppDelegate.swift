//
//  AppDelegate.swift
//  JobIn24
//
//  Created by Henry Heng on 8/26/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{

    var window: UIWindow?
    var actIdc = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!
    var storyboard: UIStoryboard?
    var displayHomeVCSplashScreen: Bool!
    let gcmMessageIDKey = "gcm.message_id"
    var count = 1

    
    
    class func instance() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showActivityIndicator(){
        if let window = window{
            container = UIView()
            container.frame = window.frame
            container.center = window.center
            container.backgroundColor = UIColor(white: 0, alpha: 0.8)
            
            actIdc.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            actIdc.hidesWhenStopped = true
            actIdc.center = CGPoint(x: container.frame.size.width / 2, y: container.frame.size.height / 2)
            
            container.addSubview(actIdc)
            window.addSubview(container)
            
            actIdc.startAnimating()
        }
    }
    
    func dismissActivityIndicator(){
        if let _ = window{
            container.removeFromSuperview()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true

        GMSServices.provideAPIKey("AIzaSyAuHZRT30kj63bROo7mN0otYr_Kdp0L9fM ")
        GMSPlacesClient.provideAPIKey("AIzaSyAuHZRT30kj63bROo7mN0otYr_Kdp0L9fM ")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),NSAttributedStringKey.foregroundColor: UIColor.defaultLightGrey], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        
        IQKeyboardManager.shared.enable = true
        
        //Message Delegate
        Messaging.messaging().delegate = self

        //Register for Notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        

        //Obtain Token
//        let token = Messaging.messaging().fcmToken
//        print("========== FCM TOKEN ==========\n[FCM Token]: \(token!)\n==========")

        
        
//[MOVE TO LAUNCH SCREEN]
//------
        let userDefaults    = UserDefaults.standard
        let currentUser     = Auth.auth().currentUser
        self.storyboard     = UIStoryboard(name: "Start", bundle: Bundle.main)
        
        //Default flag for new user
        if (userDefaults.object(forKey: "newUser")) == nil{
            userDefaults.set(false, forKey: "newUser")
        }
        
        if !(userDefaults.bool(forKey: "hasRunBefore")){
            // Remove Keychain items here
            do {
                try Auth.auth().signOut()
            }catch {
                
            }
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // Forces the app to update UserDefaults
            print("\n=========== User First Login ==========\n")
            displayHomeVCSplashScreen = false
            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            
        }else{
            if(currentUser != nil){
                print("\n=========== User Logged In ===========\n")
                displayHomeVCSplashScreen = true
            }
            else{
                print("\n=========== User Not Logged In===========\n")
                displayHomeVCSplashScreen = false
                self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            }
        }
        
        
        
        
        return true
    }
    
    //background notification receive message
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
    }
    
    //Foreground Notification receive message
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("Failed to log into Google")
            return
        }
        
        print("insideGoogle")
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            self.showActivityIndicator()
            
            if (error) != nil {
                print("Failed create Firebase User with Google")
                self.dismissActivityIndicator()
                return
            }
            
            guard let uid = user?.uid else{
                self.dismissActivityIndicator()
                return
            }
            
            //Check New User
            if user?.uid != ""{
                
                let myRootRef = Database.database().reference()
                
                let userRef = myRootRef.child("UserAccount").child(uid)
                
                let userName = user?.displayName
                let userEmail = user?.email
                let userID = user?.uid
                let userProvider = user?.providerID
                let userImage = user?.photoURL
                
                var newUserAccountInfo = [:] as [String : Any]
                
                newUserAccountInfo["name"] = userName!
                newUserAccountInfo["id"] = userID!
                newUserAccountInfo["image"] = userImage!.absoluteString
                newUserAccountInfo["provider"] = "google"
                
                if userEmail != nil{
                    newUserAccountInfo["email"] = userEmail!
                }
                Database.database().reference().child("UserAccount").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists(){
                        print("[Check New User]: This Is New User.\n")
                        let preference = UserDefaults.standard
                        let newUserKey  = "newUser"
                        preference.setValue(true, forKey: newUserKey)
                      
                        userRef.updateChildValues(newUserAccountInfo, withCompletionBlock: { (error, ref) in
                            
                            self.dismissActivityIndicator()
                            
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Start", bundle: nil)
                            let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarId") as! MainTabBarController
                            self.window?.rootViewController = tabBarController
                            
                            print("Succesfuflly create Firebase User with Google")
                        })
                        
                    }else{
                        userRef.updateChildValues(["provider": "google"])
                        
                        print("[Check New User]: UID Exist in DB , Old User!\n")
                        
                        self.dismissActivityIndicator()
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Start", bundle: nil)
                        let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarId") as! MainTabBarController
                        self.window?.rootViewController = tabBarController
                    }
                })

            }
            
        }
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled =  FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL?,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation] as Any
        )
        
        GIDSignIn.sharedInstance().handle(url,
                                          sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation] as Any)
        
        return handled
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL?,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
        
        return handled
    }
    
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    

    
    
    
    
    /*func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
       // let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }*/

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        /*count = count - 1
        print("count = \(count)")
        if count == 0 {
            let when = DispatchTime.now() + 5 // change 5 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                //self.loadingData = false
                if self.count == 0 {
                    print("Now going offline...in 5")
                    Database.database().goOffline()
                }
                else {
                    print("Not going offline")
                }
                
            }
        }*/
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Now DidEnterBackground")
        
        count = count - 1
        print("count = \(count)")
        if count == 0 {
            
            print("Now going offline...in 5")
            Database.database().goOffline()

        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        count = count + 1
        if count > 0 {
            print("Now WillEnterForeground")
            Database.database().goOnline()
            
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Now going online")
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("Now terminate")
    }

}



@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
// [END ios_10_data_message]
}
