//
//  ValidatePasswords.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

// Datamuse API for words: http://www.datamuse.com/api/

import Foundation

/// Options for password validate
///
/// - notInDictionary: word present in dictionary not authorized
/// - levelPassword: strong, soft or weak password
public enum Options {
    case notInDictionary
    case levelPassword
}

/// Enum for password status level type
///
/// - strong: strong password
/// - soft: soft password
/// - weak: weak password
/// - notInDictionary: dictionary not contain password
public enum LevelPassword {
    case strong
    case soft
    case weak
    case notInDictionary
}

/// Result for password validate
///
/// - passwordOK: OK
/// - passwordKO: KO
public enum Result {
    case passwordOK
    case passwordKO
}

class ValidatePasswords: NSObject {
    // MARK: - Public functions
    
    static func passwordIsValidate(password: String,
                                   options: Options,
                                   callback:@escaping(Result) -> Void) {
        
        switch options {
            
        case .notInDictionary:
            
            ValidatePasswords.checkIfWordExistInDictionary(word: password) { (result) in
                
                if result {
                    
                    callback(.passwordOK)
                } else {
                    
                    callback(.passwordKO)
                }
            }
        case .levelPassword:
            
            callback(.passwordKO)
        }
    }
    
    // MARK: - Private functions
    
    private class func checkIfWordExistInDictionary(word: String,
                                                     callback:@escaping(Bool) -> Void) {
        APIManager.requestToWS(urlBase: Constants.urlBaseAPI,
                               urlRequest: String(format: Constants.urlPathAPI, word),
                               headers: [:],
                               parameters: nil) { (jsonArray, error) in
                                
                                if let e = error {
                                    
                                    debugPrint("checkIfWordExistInDictionary:error: \(e.localizedDescription)")
                                    
                                    callback(false)
                                } else {
                                    
                                    if let ja = jsonArray {
                                        
                                        debugPrint("JSON: \(ja)")
                                        
                                        for option in ja {
                                            
                                            debugPrint("Option: \(option)")
                                        }
                                    }
                                }
        }
    }
    
    /// Password validate
    ///
    /// - Parameter str: password in string
    /// - Returns: value
    private class func getLevelPasswordFullRegEx(_ str: String) -> LevelPassword {
        var rules: Int = 0
        var characterSet: CharacterSet!
        
        characterSet = CharacterSet(charactersIn: "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNM")
        
        if str.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "qweértyuúiíoópaásdfghjklñzxcvbnm")
        
        if str.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "0987654321")
        
        if str.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNMqweértyuúiíoópaásdfghjklñzxcvbnm0987654321")
        
        if str.rangeOfCharacter(from: characterSet.inverted) != nil {
            
            rules += 1
        }
        
        if (str.count >= 8 && rules == 4) {
            
            return LevelPassword.strong
        } else if (str.count >= 8 && rules >= 3) {
            
            return LevelPassword.soft
        } else {
            
            return LevelPassword.weak
        }
    }
}
