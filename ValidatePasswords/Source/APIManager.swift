//
//  APIManager.swift
//  ValidatePasswords
//
//  Created by Arturo Carretero Calvo on 15/02/2019.
//  Copyright © 2019 Arturo Carretero Calvo. All rights reserved.
//

import Foundation

/// Request type
///
/// - GETRequestType: GET
/// - POSTRequestType: POST
/// - DELETERequestType: DELETE
/// - PUTRequestType: PUT
enum RequestType {
    case GETRequestType
    case POSTRequestType
    case DELETERequestType
    case PUTRequestType
}

/// APIManager class: for request to web service
class APIManager: NSObject {
    // MARK: - Properties
    
    static let timeOutInterval = 20.0
    
    // MARK: - Public functions
    
    static func requestToWS(urlBase: String,
                            urlRequest: String,
                            requestType: RequestType,
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
            case .POSTRequestType:
                
                requestString = "POST"
            case .DELETERequestType:
                
                requestString = "DELETE"
            case .PUTRequestType:
                
                requestString = "PUT"
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
                
                guard let _: Data = data,
                    let _: URLResponse = response, error == nil else {
                        
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                        
                        return
                }
                
                if let e = error {
                    
                    DispatchQueue.main.async {
                        completion(nil, e)
                    }
                }
                
                
                if let s = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    
                    let string: String = s as String
                    
                    if let data = string.data(using: .utf8) {
                        
                        do {
                            
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] {
                                
                                DispatchQueue.main.async {
                                    completion(jsonArray, nil)
                                }
                            } else {
                                
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        } catch let error as NSError {
                            
                            DispatchQueue.main.async {
                                completion(nil, error)
                            }
                        }
                    } else {
                        
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
            task.resume()
        } else {
            
            DispatchQueue.main.async {
                completion(nil, nil)
            }
        }
    }
}
