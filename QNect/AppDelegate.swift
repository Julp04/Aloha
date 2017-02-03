//
//  AppDelegate.swift
//  QNect
//
//  Created by Julian Panucci on 10/21/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import CoreData
import Parse
import ParseTwitterUtils



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        let currentCountStr = UIApplication.shared.applicationIconBadgeNumber
        let currentCount = currentCountStr
        if(currentCount > 0) {
            UIApplication.shared.applicationIconBadgeNumber = currentCount - 1
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("etGyLfRDG9FFI4ptmAm4ou5Lyn4Yg5igxD06xIyM", clientKey: "saWCW2A7X40muruqcYWGG7cPmRO1GW2sCNbldBmH")

        PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions, block: nil)
        
        PFTwitterUtils.initialize(withConsumerKey: "m9VCFFsoERuNegQQygfBRXIuB",  consumerSecret:"e3j6KgdXJIdudqcfa3K53rxmfuimQodmquTOdKNR0AHCyFL9kq")
        
        
        if ((Defaults["HasLaunchedOnce"].bool == false || Defaults["HasLaunchedOnce"].bool == nil)) {
            Defaults["HasLaunchedOnce"] = true
            Defaults["QuickScan"] = false
            Defaults["AutomaticURLOpen"] = false
            Defaults.synchronize()
            
            
            let tutorialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialVC")
            
            self.window!.rootViewController = tutorialVC
            
        }
        else {
            checkForCurrentUser()
        }
        
        
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        
//
        
        let category = UIMutableUserNotificationCategory()
        
        let addAction = UIMutableUserNotificationAction()
        addAction.identifier = "ADD"
        addAction.isDestructive = false
        addAction.title = "Add User Back"
        addAction.activationMode = .foreground
        addAction.isAuthenticationRequired = false
        
        let categoryIdentifier = "cat"
        category.identifier = categoryIdentifier
        category.setActions([addAction], for: .default)
        
        let categories = Set(arrayLiteral: category)
        let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: categories)

        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()!
        installation.setDeviceTokenFrom(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                    print(message)
                }
            } else if let name = userInfo["name"] as? String {
                
                if application.applicationState == .active {
                    
                        let username = userInfo["username"] as! String
                    
                        QnUtilitiy.retrieveSavedConnectionsOffline({ (users) in
                            for user in users {
                                if user.username! == username {
                                    let alertView = SCLAlertView()
                                    alertView.showCloseButton = true
                                    alertView.showSuccesss(name, subTitle: "has saved you as a connection")
                                    return
                                }
                            }
                            
                            let alertView = SCLAlertView()
                            alertView.showCloseButton = true
                            alertView.addButton("Add \(username) back", action: {
                                QnUtilitiy.retrieveUserByUsername(username, completion: { (user) in
                                    QnUtilitiy.saveConnection(user, completion: { (error) in
                                        if error == nil {
                                            self.sendPushNotification(username)
                                        }
                                    })
                                })
                                
                            })
                            
                            alertView.showSuccesss(name, subTitle: "has saved you as a connection")
                            
                        })
                    
                } else if application.applicationState == .background {
                    print("Coming from background")
                }else if application.applicationState == .inactive {
                    print("Inactive")
            
                }
            }
        }

    }
    
    func sendPushNotification(_ username:String)
    {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("username", equalTo: username)
        print(username)
        
        // Send push notification to query
        let push = PFPush()
        let data =   ["alert" : "\(User.current()!.firstName) \(User.current()!.lastName) has saved you as a connection!","name" : "\(User.current()!.firstName) \(User.current()!.lastName)", "username":User.current()!.username!]
        push.setData(data)
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?) // Set our Installation query
        push.sendInBackground(block: { ( success, error) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        if let username = userInfo["username"] as? String {
            if identifier == "ADD" {
                
                QnUtilitiy.retrieveSavedConnectionsOffline({ (users) in
                    for user in users {
                        if user.username! == username {
                           return
                        }
                    }
                    
                    QnUtilitiy.retrieveUserByUsername(username, completion: { (user) in
                        QnUtilitiy.saveConnection(user, completion: { (error) in
                            if error != nil {
                                print(error)
                            }
                        })
                    })

                })
            }
        }
      
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    fileprivate func checkForCurrentUser()
    {
        if ((User.current()) != nil){
            let containerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.Containter) as! ContainerViewController
            self.window!.rootViewController = containerVC;
        }
        else{
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavController") as! UINavigationController
            self.window!.rootViewController = loginViewController;
            
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.psu.cse.jrp5502.QNect" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "QNect", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

