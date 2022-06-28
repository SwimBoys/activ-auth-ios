//
//  RequestManager.swift
//  ActivAuth
//
//  Created by Martin Kuvandzhiev on 15.01.20.
//

import Foundation
import Alamofire



class RequestManager {
    
    static var additionalHeaders: HTTPHeaders {
        var headers = HTTPHeaders()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        return headers
    }
    
    static let sessionManager:SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "prod.activ5.com": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]

        let config = URLSessionConfiguration.default
        _ = RequestManager.additionalHeaders.map({ config.httpAdditionalHeaders?[$0.key] = $0.value})
        
        return Alamofire.SessionManager(
            configuration: config//,
//            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    class func register(email: String, password: String, firstName: String?, lastName: String?, completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        //setup headers
        var headers = [String:String]()
        headers["X-Request-ID"] = UUID().uuidString
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        //setup body
        var body: Parameters = ["email":email.lowercased(), "password":password]
        if let firstName = firstName, let lastName = lastName {
            body["firstName"] = firstName
            body["lastName"] = lastName
        }
        body["optin"] = false
        body["termsAccepted"] = "2018-01-01T02:32:03.000Z"
        body["notifications"] = false
        
        
        sessionManager.request(API.register, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            if let error = response.error {
                completion(nil, error)
                return
            }
            
            if response.response?.statusCode == 409 {
                completion(nil, AuthError.emailAlreadyUsed)
                return
            }
            
            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            KeychainService.userId = ActivToken.current?.sub
            
            completion(json, nil)
        }
    }
    
    class func updateV4Fields(dictionary: [String:Any], completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        headers["Authorization"] = ActivAuth.currentAuthToken
        
        let fields = ["profile": dictionary]
        
        sessionManager.request(API.updateV4Fields, method: .put, parameters: fields, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard response.response?.statusCode != 400 && response.response?.statusCode != 401 else {
                completion(nil,AuthError.incorrectCredentials)
                return
            }
            guard let json = response.result.value as? [String: Any], let user = json["profile"] as? [String:Any] else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            completion(user, nil)
        }
    }
    class func login(email: String, password: String, completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        let credentials = ["email":email.lowercased(), "password":password] as [String : Any]
        
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        
        sessionManager.request(API.token, method: .post, parameters: ["credentials": credentials, "grant": "password"], encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard response.response?.statusCode != 401 && response.response?.statusCode != 400 else {
                completion(nil, AuthError.incorrectCredentials)
                return
            }

            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            KeychainService.userId = ActivToken.current?.sub

            completion(json, nil)
        }
    }
    
    class func loginWithGoogle(email: String, token: String, googleId: String, completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        //setup headers
        var headers = [String:String]()
        headers["X-Request-ID"] = UUID().uuidString
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        //setup body
        let body: Parameters = ["email":email.lowercased(), "token":token, "googleId":googleId]
        
        sessionManager.request(API.loginWithGoogleUrl, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            if let error = response.error {
                completion(nil, error)
                return
            }
            
            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let id = json["id"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            KeychainService.userId = id
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            
            completion(json, nil)
        }
    }
    
    class func loginWithFacebok(email: String, token: String, facebookId: String, completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        //setup headers
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        
        //setup body
        let body: Parameters = ["email":email.lowercased(), "token":token, "facebookId":facebookId]
        
        sessionManager.request(API.loginWithFacebookUrl, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            if let error = response.error {
                completion(nil, error)
                return
            }
            
            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let id = json["id"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            KeychainService.userId = id
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            
            completion(json, nil)
        }
    }
    
    class func loginWithApple(appleId: String, appleToken: String, completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        //setup headers
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        
        //setup body
        let body: Parameters = ["appleId":appleId, "jwtToken":appleToken]
        
        sessionManager.request(API.loginWithAppleUrl, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            if let error = response.error {
                completion(nil, error)
                return
            }
            
            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let id = json["id"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            KeychainService.userId = id
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            
            completion(json, nil)
        }
    }
    
    class func refreshToken(completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        let credentials = ["refreshToken":KeychainService.refreshToken ?? ""] as [String : Any]
        
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        headers["Authorization"] = "JWT " + (ActivAuth.currentAuthToken ?? "")
        
        sessionManager.request(API.token, method: .post, parameters: ["credentials": credentials, "grant": "refresh_token"], encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard response.response?.statusCode != 401 && response.response?.statusCode != 400 else {
                completion(nil, AuthError.incorrectCredentials)
                return
            }

            guard let json = response.result.value as? [String: Any],
                let token = json["idToken"] as? String,
                let refreshToken = json["refreshToken"] as? String
                else {
                    completion(nil, AuthError.invalidResponse)
                    return
            }
            
            
            KeychainService.userToken = token
            KeychainService.refreshToken = refreshToken
            KeychainService.userId = ActivToken.current?.sub
            
            completion(json, nil)
        }
    }
    
    
    class func fetchProfile(completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {

        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        headers["Authorization"] = ActivAuth.currentAuthToken
        
        sessionManager.request(API.profile, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            guard response.response?.statusCode != 401 && response.response?.statusCode != 400 else {
                completion(nil, AuthError.accessDenied)
                return
            }

            guard let json = (response.result.value as? [String: Any])?["profile"] as? [String:Any] else {
                completion(nil, AuthError.invalidResponse)
                return
            }
            
            completion(json, nil)
        }
    }
    
    class func assignDevice(serialNumber: String, uuid: String, completion: @escaping(_ error: Error?) -> Void) {
        let dict = ["serialNumber": serialNumber, "uuid": uuid]
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        headers["Authorization"] = "JWT " + (ActivAuth.currentAuthToken ?? "")
        
        sessionManager.request(API.assignDevice, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            
            guard response.response?.statusCode != 401 else {
                completion(AuthError.accessDenied)
                return
            }
            
            guard response.response?.statusCode != 400 else {
                completion(AuthError.invalidRequest)
                return
            }
            
            guard response.response?.statusCode != 409 else {
                completion(AuthError.deviceAlreadyRegistered)
                return
            }
            
            guard response.error == nil else {
                completion(AuthError.invalidResponse)
                return
            }
            
            completion(nil)
        }
    }
    
    class func forgottenPass(email: String, completion: @escaping (_ error: Error?) -> Void) {
        let dict = ["email":email.lowercased()]
        var headers = [String:String]()
        for header in ActivAuth.config.extraHeaders {
            headers[header.key] = header.value
        }
        headers["X-Request-ID"] = UUID().uuidString
        sessionManager.request(API.forgottenPassword, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard let _ = response.result.value as? [String: Any] else {
                completion(AuthError.invalidResponse)
                return
            }
            guard let statusCode = response.response?.statusCode else {
                completion(AuthError.invalidResponse)
                return
            }
            
            if statusCode == 200 {
                completion(nil)
            } else {
                completion(AuthError.invalidEmail)
            }
            
        }
    }
}
