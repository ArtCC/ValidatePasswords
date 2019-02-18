//
//  APIManager.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

import Foundation

class Constants: NSObject {
    static let urlBaseAPI: String = "https://api.datamuse.com"
    static let urlPathAPI: String = "/words?sp=%@"
}

/// Request type
///
/// - GETRequestType: GET
public enum RequestType {
    case GETRequestType
}

/// APIManager class: for request to web service
class APIManager: NSObject {
    // MARK: - Properties
    
    static let timeOutInterval = 10.0
    
    // MARK: - Public functions
    
    static func requestToWS(urlBase: String,
                            urlRequest: String,
                            requestType: RequestType = .GETRequestType,
                            headers: [String : String],
                            parameters: Data?,
                            completion:@escaping([Dictionary<String,Any>]?, Error?) -> Void) {
        var urlString: String = urlBase
        urlString.append(urlRequest)
        
        if let urlWithCoding = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlWithCoding) {
            
            var requestString = ""
            
            switch requestType {
                
            case .GETRequestType:
                
                requestString = "GET"
            }
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = APIManager.timeOutInterval
            config.timeoutIntervalForResource = APIManager.timeOutInterval
            
            var session: URLSession = URLSession()
            
            session = URLSession(
                configuration: config,
                delegate: nil,
                delegateQueue: nil)
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = requestString
            request.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
            request.allHTTPHeaderFields = headers
            
            if let p = parameters {
                
                if let paramData = String(data: p, encoding: .utf8) {
                    
                    debugPrint(paramData)
                }
            }
            
            if let p = parameters {
                
                request.httpBody = p
            }
            
            request.timeoutInterval = APIManager.timeOutInterval
            
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let _: Data = data, let _: URLResponse = response, error == nil else {
                    
                    return completion(nil, error)
                }
                
                if let e = error {
                    
                    completion(nil, e)
                }
                
                
                if let s = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    
                    let string: String = s as String
                    
                    if let data = string.data(using: .utf8) {
                        
                        do {
                            
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] {
                                
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
