//
//  AppDelegate.swift
//  Seeker
//
//  Created by Jose Candilejo on 1/12/16.
//  Copyright © 2016 Jose Candilejo. All rights reserved.
//


//MARK: - LIBRERIAS
import UIKit
import Parse

//MARK: - INICIO DE LA CLASE
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Inicializacion de "Parse"
        let configuration = ParseClientConfiguration {
            $0.applicationId = "0JSEQFffZkMs2TWhXf7Z4YsGC4vrD7VSBWRKwJoM"
            $0.clientKey = "UO996t25i4WmpJQh5bC7yA9HJg9gVxsKUm0pxhl0"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        // Establecemos la configuración de los NavigationBar.
        configuracionNavigationBar()
        
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CONFIGURA LOS NAVIGATIONBAR
    func configuracionNavigationBar(){
        
        let naviBar = UINavigationBar.appearance()
        let colorNB = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        let shadow = NSShadow()
        
        naviBar.tintColor = UIColor.white
        naviBar.barTintColor = colorNB
        
        shadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        naviBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSShadowAttributeName : shadow]
    }


}

