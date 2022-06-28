//
//  InternetProtocol.swift
//  ActivSync
//
//  Created by Bruno Henrique on 10/10/19.
//

import Foundation

enum InternetProtocol: RawRepresentable {
    case http, ssh, https

    init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrProtocolHTTP):
            self = .http
        case String(kSecAttrProtocolSSH):
            self = .ssh
        case String(kSecAttrProtocolHTTPS):
            self = .https
        default:
            self = .http
        }
    }

    var rawValue: String {
        switch self {
        case .http:
            return String(kSecAttrProtocolHTTP)
        case .ssh:
            return String(kSecAttrProtocolSSH)
        case .https:
            return String(kSecAttrProtocolHTTPS)

        }
    }
}
