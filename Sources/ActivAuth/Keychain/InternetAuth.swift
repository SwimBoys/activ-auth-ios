//
//  InternetAuth.swift
//  ActivSync
//
//  Created by Bruno Henrique on 10/10/19.
//

import Foundation

enum InternetAuthenticationType: RawRepresentable {
    case httpBasic, httpDigest, htmlForm, `default`

    init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrAuthenticationTypeHTTPBasic):
            self = .httpBasic
        case String(kSecAttrAuthenticationTypeHTTPDigest):
            self = .httpDigest
        case String(kSecAttrAuthenticationTypeHTMLForm):
            self = .htmlForm
        case String(kSecAttrAuthenticationTypeDefault):
            self = .default
        default:
            self = .default
        }
    }

    var rawValue: String {
        switch self {
        case .httpBasic:
            return String(kSecAttrAuthenticationTypeHTTPBasic)
        case .httpDigest:
            return String(kSecAttrAuthenticationTypeHTTPDigest)
        case .htmlForm:
            return String(kSecAttrAuthenticationTypeHTMLForm)
        case .default:
            return String(kSecAttrAuthenticationTypeDefault)
        }
    }
}
