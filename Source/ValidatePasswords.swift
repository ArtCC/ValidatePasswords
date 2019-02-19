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
/// - notPresentInDictionary: word present in dictionary not authorized
/// - checkStrengthPassword: strong, soft or weak password
public enum Option {
    case notPresentInDictionary
    case checkStrengthPassword
}

/// Enum for password status level type
///
/// - strong: strong password: minimum characters, four rules
/// - soft: soft password: minimum characters, three rules
/// - weak: weak password: minimum characters
/// - notPresentInDictionary: dictionary (English, German, Spanish, Italian) not contain password
/// - presentInDictionary: dictionary (English, German, Spanish, Italian) contain password
/// - errorPassword: password error
public enum PasswordType {
    case strong
    case soft
    case weak
    case notPresentInDictionary
    case presentInDictionary
    case errorPassword
}

class ValidatePasswords: NSObject {
    // MARK: - Public functions
    
    /// Function for validate password
    ///
    /// - Parameters:
    ///   - password: string password
    ///   - option: dictionary or strength level
    ///   - minimumCharacters: minimum characters for password
    ///   - callback: return type or error
    static func passwordIsValidate(password: String,
                                   option: Option,
                                   minimumCharacters: Int,
                                   callback:@escaping(PasswordType) -> Void) {
        
        switch option {
            
        case .notPresentInDictionary:
            
            ValidatePasswords.checkIfWordExistInDictionary(password) { (result) in
                
                if result {
                    
                    callback(PasswordType.presentInDictionary)
                } else {
                    
                    callback(PasswordType.notPresentInDictionary)
                }
            }
        case .checkStrengthPassword:
            
            ValidatePasswords.getLevelPasswordFullRegEx(password,
                                                        minimumCharacters) { (passwordType) in
                                                            
                                                            callback(passwordType)
            }
        }
    }
    
    // MARK: - Private functions
    
    private class func checkIfWordExistInDictionary(_ word: String,
                                                    callback:@escaping(Bool) -> Void) {
        APIManager.requestToWS(urlBase: Constants.urlBaseAPI,
                               urlRequest: String(format: Constants.urlPathAPI, word)) { (jsonArray, error) in
                                
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
                                                 callback:@escaping(PasswordType) -> Void) {
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
            
            callback(PasswordType.strong)
        } else if (password.count >= minimumCharacters && rules >= 3) {
            
            callback(PasswordType.soft)
        } else if (password.count >= minimumCharacters) {
            
            callback(PasswordType.weak)
        } else {
            
            callback(PasswordType.errorPassword)
        }
    }
}

/// Constants properties
class Constants: NSObject {
    static let urlBaseAPI: String = "https://api.datamuse.com"
    static let urlPathAPI: String = "/words?sp=%@"
}

/// APIManager class: for request to web service
class APIManager: NSObject {
    // MARK: - Public functions
    
    static func requestToWS(urlBase: String,
                            urlRequest: String,
                            completion:@escaping([Dictionary<String, Any>]?, Error?) -> Void) {
        let timeOutInterval = 10.0
        
        var urlString: String = urlBase
        urlString.append(urlRequest)
        
        if let urlWithCoding = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlWithCoding) {
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = timeOutInterval
            config.timeoutIntervalForResource = timeOutInterval
            
            var session: URLSession = URLSession()
            
            session = URLSession(
                configuration: config,
                delegate: nil,
                delegateQueue: nil)
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            request.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
            request.timeoutInterval = timeOutInterval
            
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let _: Data = data, let _: URLResponse = response, error == nil else {
                    
                    return completion(nil, error)
                }
                
                if let e = error {
                    
                    return completion(nil, e)
                }
                
                if let s = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    
                    let string: String = s as String
                    
                    if let data = string.data(using: .utf8) {
                        
                        do {
                            
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String, Any>] {
                                
                                completion(jsonArray, nil)
                            } else {
                                
                                completion(nil, error)
                            }
                        } catch let error as NSError {
                            
                            completion(nil, error)
                        }
                    } else {
                        
                        completion(nil, error)
                    }
                } else {
                    
                    completion(nil, error)
                }
            }
            
            task.resume()
        } else {
            
            completion(nil, nil)
        }
    }
}
