//
//  AuthenticationManager.swift
//  ActivAuth
//
//  Created by Martin Kuvandzhiev on 15.01.20.
//

import Foundation


public enum AuthError:String, Error {
    case invalidRequest = "Invalid request data"
    case invalidResponse = "Invalid response from server"
    case incorrectCredentials = "An incorrect email or password has been entered"
    case accessDenied = "Access denied"
    case googleAuthError    = "Google ID not found"
    case facebookAuthError  = "Facebook ID not found"
    case invalidEmail = "Invalid email"
    case deviceAlreadyRegistered = "Device Already Registed"
    case emailAlreadyUsed = "Email is already used"
}

///Manages authentication for Activbody API.
public class ActivAuth {
    
    public static var config = AuthConfig()
    public static var apiUrl = AuthConfig.APIEnvironment.test
    /// Returns the status of the current logged user
    public class var isLoggedIn: Bool {
        return KeychainService.userId != nil && KeychainService.userToken != nil
    }

    ///Returns the authorization token for the current logged user or nil of none.
    public class var currentAuthToken: String? {
        return KeychainService.userToken
    }
    ///Returns the ID for the current logged user or nil of none.
    public class var currentUserID: String? {
        return KeychainService.userId
    }
    
    public class var currentRefreshToken: String? {
        return KeychainService.refreshToken
    }
    
    // MARK: - Registration
    // only for user registration without social login
    public class func register(email: String, password: String, firstName: String?, lastName: String?, completion: @escaping(_ user: ActivUser?, _ error: Error?)->Void) {
        RequestManager.register(email: email, password: password, firstName: firstName, lastName: lastName) { (json, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }

    // MARK: - Login
    //Once login it saves to keychain and register a new user on the backend if none

    /// Login a user with the api
    public class func login(email: String, password: String, completion: @escaping(_ user: ActivUser?, _ error: Error?)->Void) {
        RequestManager.login(email: email, password: password) { (json, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    
    public class func loginWithFacebook(email: String, token: String, facebookId: String, completion: @escaping(_ user: ActivUser?, _ error: Error?)->Void) {
        RequestManager.loginWithFacebok(email: email, token: token, facebookId: facebookId) { (json, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    
    public class func loginWithGoogle(email: String, token: String, googleId: String, completion: @escaping(_ user: ActivUser?, _ error: Error?)->Void) {
        RequestManager.loginWithGoogle(email: email, token: token, googleId: googleId) { (json, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    
    public class func loginWithApple(appleId: String, appleToken: String, completion: @escaping(_ user: ActivUser?, _ error: Error?)->Void) {
        RequestManager.loginWithApple(appleId: appleId, appleToken: appleToken) { (json, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    
    public class func refreshToken(completion: @escaping(_ result: [String:Any]?, _ error: Error?)->Void) {
        RequestManager.refreshToken { (result, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            NotificationCenter.default.post(name: .tokenHasBeenRefreshed, object: nil)
            completion(result, nil)
            return
        }
    }
    
    public class func getProfile(completion: @escaping(_ user: ActivUser?, _ error:Error?)->Void) {
        RequestManager.fetchProfile { (json, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    
    public class func updateFields(dictionary: [String:Any], completion: @escaping (_ result: ActivUser?, _ error: Error?)->Void){
        RequestManager.updateV4Fields(dictionary: dictionary) { (json, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
//            guard let user = try? ActivUser(json: json!) else {
//                completion(nil, AuthError.invalidResponse)
//                return
//            }
            completion(nil, nil)
        }
    }
    public class func forgottenPass(email: String, completion: @escaping(_ error: Error?)->Void) {
        RequestManager.forgottenPass(email: email) { (error) in
            completion(error)
        }
    }
    
    public class func assignDevice(serialNumber: String, uuid: String, completion: @escaping(_ error: Error?) -> Void) {
        RequestManager.assignDevice(serialNumber: serialNumber, uuid: uuid) { (error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            refreshToken { (_, error) in
                guard error == nil else {
                    completion(AuthError.invalidResponse)
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    public class func logout() {
        KeychainService.userToken = nil
        KeychainService.userId = nil
        KeychainService.refreshToken = nil
    }
}


public extension ActivAuth {
    struct AuthConfig {
        public enum APIEnvironment {
            case test
            case staging
            case production
            case custom(url: String)
            
            var urlValue: String {
                switch self {
                case .test:
                    return "https://test.activ5.com/"
                case .staging:
                    return "https://staging.activ5.com/"
                case .production:
                    return "https://prod.activ5.com/"
                case .custom(let url):
                    guard url.last == "/" else {
                        assertionFailure("API URL should end with \'/\'")
                        return ""
                    }
                    return url
                }
            }
        }
        public var apiUrl = ActivAuth.apiUrl
        public var registerUrl = "authentication/v2/users"
        public var tokenUrl = "authentication/v2/token"
        public var extraHeaders: [String: String] = [String:String]()
    }
}
