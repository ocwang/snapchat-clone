//
//  AppDelegate.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        if FIRAuth.auth()?.currentUser == nil {
            FIRAuth.auth()?.createUser(withEmail: "chase@world.com", password: "testtest", completion: { (user, error) in
                print("User: \(user) \nError: \(error?.localizedDescription)")
                
            })
        }
        
        return true
    }

   
}

