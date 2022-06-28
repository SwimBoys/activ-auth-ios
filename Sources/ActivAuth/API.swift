//
//  API.swift
//  ActivAuth
//
//  Created by Martin Kuvandzhiev on 15.01.20.
//

import Foundation
import Alamofire

class API: URLConvertible {
    let stringCall: String
    var baseURL: String {
        return ActivAuth.config.apiUrl.urlValue
    }

       init(_ value: String) {
           self.stringCall = value
       }
    
       func asURL() throws -> URL {
           return URL(string: baseURL + self.stringCall)!
       }
}

extension API {
    class var register: API {
        return API(ActivAuth.config.registerUrl)
    }
    
    class var token: API {
        return API(ActivAuth.config.tokenUrl)
    }
    
    class var loginWithGoogleUrl:API {
        return API("api/v4/login/google")
    }
    
    class var loginWithFacebookUrl:API {
        return API("api/v4/login/facebook")
    }
    
    class var loginWithAppleUrl:API {
        return API("api/v4/login/apple")
    }
    
    class var profile: API {
        return API("api/v4/profile")
    }
    
    class var forgottenPassword: API {
        return API("authentication/v2/actions/request-password-change")
    }
    
    class var updateV4Fields: API {
        return API("api/v4/profile")
    }
    
    class var assignDevice: API {
        return API("authentication/v2/users/\(ActivAuth.currentUserID ?? "")/devices")
    }
}
