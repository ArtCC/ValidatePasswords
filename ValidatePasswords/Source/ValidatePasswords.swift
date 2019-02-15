//
//  ValidatePasswords.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

// Datamuse API for words: http://www.datamuse.com/api/

import Foundation

enum Result {
    case passwordOK
    case passwordKO
}

enum Options {
    case dictionary
}

class ValidatePasswords: NSObject {
    // MARK: - Public functions
    
    static func passwordIsValidate(password: String, options: Options,
                                   callback:@escaping(Result) -> Void) {
        
        switch options {
            
        case .dictionary:
            
            ValidatePasswords.checkIfWordExistInDictionary(word: password) { (result) in
                
                if result {
                    
                    callback(.passwordOK)
                } else {
                    
                    callback(.passwordKO)
                }
            }
        }
    }
    
    // MARK: - Private functions
    
    private static func checkIfWordExistInDictionary(word: String,
                                                     callback:@escaping(Bool) -> Void) {
        APIManager.requestToWS(urlBase: Constants.urlBaseAPI,
                               urlRequest: String(format: Constants.urlPathAPI, word),
                               requestType: .GETRequestType,
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
}
