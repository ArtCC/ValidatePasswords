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
        // Weak password
        ValidatePasswords.passwordIsValidate(password: "chicken",
                                             option: .checkStrengthPassword,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Weak password: PASSWORD TYPE: \(passwordType)")
        }
        
        // Soft password
        ValidatePasswords.passwordIsValidate(password: "Chicken1",
                                             option: .checkStrengthPassword,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Soft password: PASSWORD TYPE: \(passwordType)")
        }
        
        // Strong password
        ValidatePasswords.passwordIsValidate(password: "Chicken%1",
                                             option: .checkStrengthPassword,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Strong password: PASSWORD TYPE: \(passwordType)")
        }
        
        // Password error, dictionary contain this password
        ValidatePasswords.passwordIsValidate(password: "chicken",
                                             option: .notPresentInDictionary,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Password error: PASSWORD TYPE: \(passwordType)")
        }
        
        // Password ok, dictionary not contain this password
        ValidatePasswords.passwordIsValidate(password: "chickenandcow",
                                             option: .notPresentInDictionary,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Password ok: PASSWORD TYPE: \(passwordType)")
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
