//
//  AppDelegate.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - Functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ValidatePasswords.passwordIsValidate(password: "chicken",
                                             options: .notInDictionary) { (result, _) in
                                                
                                                debugPrint("RESULT:notInDictionary: \(String(describing: result))")
        }
        
        ValidatePasswords.passwordIsValidate(password: "cow",
                                             options: .levelPassword) { (_, levelPassword) in
                                                
                                                debugPrint("RESULT:LEVEL PASSWORD: \(String(describing: levelPassword))")
        }
        
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
    }
}
