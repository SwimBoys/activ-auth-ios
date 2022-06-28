//
//  KeychainService.swift
//  ActivAuth
//
//  Created by Martin Kuvandzhiev on 15.01.20.
//

import Foundation

class KeychainKey {
    static let currentUserEmail = "CurrentUserEmail"
    static let currentUserToken = "CurrentUserToken"
    static let currentRefreshToken = "CurrentRefreshToken"
    static let tokenService     = "Token"
}

class KeychainService {
    static var keychainStore: KeychainStore! = {
        let pwdQuery = KeychainPasswordQuery(service: KeychainKey.tokenService)
        return KeychainStore(secureStoreQueryable: pwdQuery)
    }()
    
    class var userToken: String? {
        get {
            return try! keychainStore.getValue(for: KeychainKey.currentUserToken)
        }
        set {
            guard let newValue = newValue else {
                try! keychainStore.removeValue(for: KeychainKey.currentUserToken)
                return
            }
            try! keychainStore.setValue(newValue, for: KeychainKey.currentUserToken)
        }
    }
    
    class var userId: String? {
        get {
            return try! keychainStore.getValue(for: KeychainKey.currentUserEmail)
        }
        set {
            guard let newValue = newValue else {
                try! keychainStore.removeValue(for: KeychainKey.currentUserEmail)
                return
            }
            try! keychainStore.setValue(newValue, for: KeychainKey.currentUserEmail)
        }
    }
    
    class var refreshToken: String? {
        get {
            return try! keychainStore.getValue(for: KeychainKey.currentRefreshToken)
        }
        set {
            guard let newValue = newValue else {
                try! keychainStore.removeValue(for: KeychainKey.currentRefreshToken)
                return
            }
            try! keychainStore.setValue(newValue, for: KeychainKey.currentRefreshToken)
        }
    }
}
