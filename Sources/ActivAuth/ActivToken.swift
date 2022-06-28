//
//  File.swift
//  
//
//  Created by Martin Kuvandzhiev on 13.10.20.
//

import Foundation
import JOSESwift

public class ActivToken: Codable {
    public static var current: ActivToken? {
        guard let token = ActivAuth.currentAuthToken else {
            return nil
        }
        
        guard let jws = try? JWS(compactSerialization: token) else {
            return nil
        }
        
        let payload = jws.payload
        
        guard let tokenInfo = try? JSONDecoder().decode(ActivToken.self, from: payload.data()) else {
            return nil
        }
        
        return tokenInfo
    }
    
    public var email: String = ""
    public var sub: String = ""
    public var roles: [String]?
    public var exp: Int = Int(Date().timeIntervalSince1970)
}

public extension ActivToken {
    var expDate: Date {
        return Date(timeIntervalSince1970: Double(exp))
    }
    
    var isExpired: Bool {
        return self.expDate.timeIntervalSinceNow < 0
    }
}
