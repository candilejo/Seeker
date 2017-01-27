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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //PFUser.logOut()
    }
    
    
    
    //MARK -------------------------- UTILIDADES --------------------------
    
    // CONFIGURA EL COLOR DEL TEXTO Y DEL NAVIGATIONBAR Y LA SOMBRA.
    func configuracionNavigationBar(){
        
        let naviBar = UINavigationBar.appearance()
        let colorNB = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        let shadow = NSShadow()
        
        naviBar.tintColor = UIColor.white
        naviBar.barTintColor = colorNB
        
        shadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        naviBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSShadowAttributeName : shadow]
    }


}

