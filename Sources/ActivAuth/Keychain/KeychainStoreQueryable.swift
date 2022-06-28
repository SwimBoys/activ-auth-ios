//
//  SecureStoreQueryable.swift
//  ActivSync
//
//  Created by Bruno Henrique on 10/10/19.
//

import Foundation

protocol Queryable {
    var query: [String: Any] { get }
}

// MARK: - Keychain Generic Password

struct KeychainPasswordQuery {
    let service: String
    let accessGroup: String?

    public init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

extension KeychainPasswordQuery: Queryable {
    public var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        // Access group if target environment is not simulator
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
        return query
    }
}

// MARK: - Keychain Internet Password

struct KeychainInternetPasswordQuery {
    public let server: String
    public let port: Int
    public let path: String
    public let securityDomain: String
    public let internetProtocol: InternetProtocol
    public let internetAuthenticationType: InternetAuthenticationType

    init (server: String, port: Int, path: String, securityDomain: String, internetProtocol: InternetProtocol, internetAuthType: InternetAuthenticationType) {
        self.server = server
        self.port = port
        self.path = path
        self.securityDomain = securityDomain
        self.internetProtocol = internetProtocol
        self.internetAuthenticationType = internetAuthType
    }
}

extension KeychainInternetPasswordQuery: Queryable {
    public var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassInternetPassword
        query[String(kSecAttrPort)] = port
        query[String(kSecAttrServer)] = server
        query[String(kSecAttrSecurityDomain)] = securityDomain
        query[String(kSecAttrPath)] = path
        query[String(kSecAttrProtocol)] = internetProtocol.rawValue
        query[String(kSecAttrAuthenticationType)] = internetAuthenticationType.rawValue
        return query
    }
}
