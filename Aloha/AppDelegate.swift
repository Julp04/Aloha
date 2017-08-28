//
//  AppDelegate.swift
//  QNect
//
//  Created by Julian Panucci on 10/21/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Fabric
import TwitterKit
import OAuthSwift
import RevealingSplashView
import Crashlytics



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Activate remoteconfig to get different values which we can update on firebase, such as urls that might need to change. See SettingsViewController
        FIRRemoteConfig.remoteConfig().fetch(completionHandler: { (status, error) in
            if error == nil {
                FIRRemoteConfig.remoteConfig().activateFetched()
            }
        })
        
        #if DEVELOPMENT
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-DEV", ofType: "plist")!
            let options = FIROptions(contentsOfFile: filePath)
            FIRApp.configure(with: options!)
        #else
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
            let options = FIROptions(contentsOfFile: filePath)
            FIRApp.configure(with: options!)
            Fabric.with([Crashlytics.self])
        #endif
        
        FIRDatabase.database().persistenceEnabled = true
        

        if ((Defaults["HasLaunchedOnce"].bool == false || Defaults["HasLaunchedOnce"].bool == nil)) {
            
            if let _ = FIRAuth.auth()?.currentUser {
                QnClient.sharedInstance.signOut()
            }
           
            Defaults["HasLaunchedOnce"] = true
            Defaults.synchronize()
            
            let onboardNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardNavController") as! UINavigationController
            
            self.window!.rootViewController? = onboardNav
        }
        else {
            checkForCurrentUser()
        }
        
        let flowerLogo = #imageLiteral(resourceName: "aloha_logo")
        let qSize = CGSize(width: 240.0, height: 128.0)
        
        let splashView = RevealingSplashView(iconImage: flowerLogo, iconInitialSize: qSize, backgroundColor: UIColor.main)
        splashView.iconColor = UIColor.white
        splashView.duration = 1.5
        splashView.animationType = .twitter
        
        self.window?.rootViewController?.view.addSubview(splashView)
        
        splashView.startAnimation {
        }
        
        return true
    }
    
    
    fileprivate func checkForCurrentUser()
    {   
        if FIRAuth.auth()?.currentUser != nil {
            
            let mainVCNav = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainController") as! MainController
            self.window?.rootViewController = mainVCNav
        }else {
            let tutorialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardNavController")
            
            self.window!.rootViewController = tutorialVC
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      
       
        OAuthSwift.handle(url: url)
        
        
       
        return true
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

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}


