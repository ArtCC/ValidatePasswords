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
                                   minimumCharacters: Int = 8,
                                   callback:@escaping(Result?, LevelPassword?) -> Void) {
        
        switch options {
            
        case .notInDictionary:
            
            ValidatePasswords.checkIfWordExistInDictionary(password) { (result) in
                
                if result {
                    
                    callback(.passwordOK, nil)
                } else {
                    
                    callback(.passwordKO, nil)
                }
            }
        case .levelPassword:
            
            ValidatePasswords.getLevelPasswordFullRegEx(password,
                                                        minimumCharacters) { (levelPassword) in
                                                            
                                                            callback(nil, levelPassword)
            }
        }
    }
    
    // MARK: - Private functions
    
    private class func checkIfWordExistInDictionary(_ word: String,
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
                                        
                                        for option in ja {
                                            
                                            for (key, value) in option {
                                             
                                                if key == "word" {
                                                    
                                                    guard let string: String = value as? String else {
                                                        
                                                        return callback(false)
                                                    }
                                                    
                                                    if word == string {
                                                        
                                                        return callback(true)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    callback(false)
                                }
        }
    }
    
    /// Password validate
    ///
    /// - Parameter str: password in string
    /// - Returns: value
    private class func getLevelPasswordFullRegEx(_ password: String,
                                                 _ minimumCharacters: Int,
                                                 callback:@escaping(LevelPassword) -> Void) {
        var rules: Int = 0
        var characterSet: CharacterSet!
        
        characterSet = CharacterSet(charactersIn: "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNM")
        
        if password.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "qweértyuúiíoópaásdfghjklñzxcvbnm")
        
        if password.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "0987654321")
        
        if password.rangeOfCharacter(from: characterSet) != nil {
            
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNMqweértyuúiíoópaásdfghjklñzxcvbnm0987654321")
        
        if password.rangeOfCharacter(from: characterSet.inverted) != nil {
            
            rules += 1
        }
        
        if (password.count >= minimumCharacters && rules >= 4) {
            
            callback(LevelPassword.strong)
        } else if (password.count >= minimumCharacters && rules >= 3) {
            
            callback(LevelPassword.soft)
        } else {
            
            callback(LevelPassword.weak)
        }
    }
}
