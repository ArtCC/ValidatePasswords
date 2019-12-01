//
//  ValidatePasswords.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

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

/// Private properties
fileprivate let capitalLetters = "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNM"
fileprivate let lowercasedLetters = "qweértyuúiíoópaásdfghjklñzxcvbnm"
fileprivate let numbers = "0987654321"
fileprivate let allLetters = "QWEÉRTYUÚIÍOÓPAÁSDFGHJKLÑZXCVBNMqweértyuúiíoópaásdfghjklñzxcvbnm0987654321"
fileprivate let timeOutInterval = 10.0
fileprivate let wordString = "word"
fileprivate let typeRequest = "GET"
fileprivate let urlBaseAPI = "https://api.datamuse.com"
fileprivate let urlPathAPI = "/words?sp=%@"

class ValidatePasswords: NSObject {
    
    // MARK: - Public functions
    /// Function for validate password
    ///
    /// - Parameters:
    ///   - password: string password
    ///   - option: dictionary or strength level
    ///   - minimumCharacters: minimum characters for password
    ///   - output: return type or error
    class func passwordIsValidate(password: String,
                                  option: Option,
                                  minimumCharacters: Int,
                                  output:@escaping(PasswordType) -> Void) {
        switch option {
        case .notPresentInDictionary:
            ValidatePasswords.checkIfWordExistInDictionary(password) { (result) in
                if result {
                    output(PasswordType.presentInDictionary)
                } else {
                    output(PasswordType.notPresentInDictionary)
                }
            }
        case .checkStrengthPassword:
            ValidatePasswords.getLevelPasswordFullRegEx(password,
                                                        minimumCharacters) { (passwordType) in
                                                            
                                                            output(passwordType)
            }
        }
    }
}

// MARK: - Private util functions
private extension ValidatePasswords {
    
    /// Check if word exist in dictionary
    /// - Parameters:
    ///   - word: word
    ///   - output: bool with result
    class func checkIfWordExistInDictionary(_ word: String,
                                            output:@escaping(Bool) -> Void) {
        APIManager.requestToWS(urlBase: urlBaseAPI,
                               urlRequest: String(format: urlPathAPI, word)) { (jsonArray, error) in
                                if let e = error {
                                    debugPrint("checkIfWordExistInDictionary:error: \(e.localizedDescription)")
                                    output(false)
                                } else {
                                    if let ja = jsonArray {
                                        for option in ja {
                                            for (key, value) in option where key == wordString {
                                                guard let string: String = value as? String else { return output(false) }
                                                if word == string {
                                                    return output(true)
                                                }
                                            }
                                        }
                                    }
                                    output(false)
                                }
        }
    }
    
    /// Password validate
    ///
    /// - Parameter str: password in string
    /// - Returns: value
    class func getLevelPasswordFullRegEx(_ password: String,
                                         _ minimumCharacters: Int,
                                         output:@escaping(PasswordType) -> Void) {
        var rules: Int = 0
        var characterSet: CharacterSet!
        
        characterSet = CharacterSet(charactersIn: capitalLetters)
        if password.rangeOfCharacter(from: characterSet) != nil {
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: lowercasedLetters)
        if password.rangeOfCharacter(from: characterSet) != nil {
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: numbers)
        if password.rangeOfCharacter(from: characterSet) != nil {
            rules += 1
        }
        
        characterSet = CharacterSet(charactersIn: allLetters)
        if password.rangeOfCharacter(from: characterSet.inverted) != nil {
            rules += 1
        }
        
        if (password.count >= minimumCharacters && rules >= 4) {
            output(PasswordType.strong)
        } else if (password.count >= minimumCharacters && rules >= 3) {
            output(PasswordType.soft)
        } else if (password.count >= minimumCharacters) {
            output(PasswordType.weak)
        } else {
            output(PasswordType.errorPassword)
        }
    }
}

/// APIManager class: for request to web service
class APIManager: NSObject {
    
    // MARK: - Public functions
    class func requestToWS(urlBase: String,
                           urlRequest: String,
                           completion:@escaping([Dictionary<String, Any>]?, Error?) -> Void) {
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
            request.httpMethod = typeRequest
            request.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
            request.timeoutInterval = timeOutInterval
            
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let _: Data = data, let _: URLResponse = response, error == nil else { return completion(nil, error) }
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
