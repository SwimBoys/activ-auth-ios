//
//  Profile.swift
//  ActivAuth
//
//  Created by Martin Kuvandzhiev on 15.01.20.
//

import Foundation

public enum TwoFAType: String {
    case none = "None"
    case authenticator = "Authenticator"
}

public protocol ActivUserProtocol {
    var id: String { get set }
    var facebookId: String? { get set }
    var googleId: String? { get set }
    var twoFAtype: String { get set }
    var fullName: String? { get set }
    var email: String { get set }
    var birthday: String? { get set }
    var height: Double { get set }
    var weight: Double { get set }
    var gender: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var notifications: Bool { get set }
    var fitnessLevel: Int? { get set }
    var personalGoals: String? { get set }
    var systemOfUnits: String? { get set }
    var termsAccepted: String? { get set }
    var optin: Bool { get set }
}

public extension ActivUserProtocol {
    var birthdateAsDate: Date? {
        guard let birthday = birthday else {
            return nil
        }
        return Date.formatter.date(from: birthday)
    }

    var termsAcceptedDate: Date? {
        guard let termsAccepted = termsAccepted else {
            return nil
        }
        return Date.formatter.date(from: termsAccepted)
    }
}

public class ActivUser: ActivUserProtocol {
    public var gender: String?
    public var fitnessLevel: Int?
    public var systemOfUnits: String?
    public var firstName: String?
    public var lastName: String?
    public var notifications: Bool
    public var personalGoals: String?
    public var id: String
    public var facebookId: String?
    public var googleId: String?
    public var twoFAtype: String
    public var fullName: String?
    public var email: String
    public var birthday: String?
    public var height: Double
    public var weight: Double
    public var termsAccepted: String?
    public var optin: Bool
    
    init(json: [String: Any]) throws {
        guard let id = json["id"] as? String,
            let email = json["email"] as? String,
            let optin = json["optin"] as? Bool
            else {
                throw ActivUserError.unableToParseActivUser
        }
        
        self.id = id
        self.firstName = json["firstName"] as? String
        self.lastName = json["lastName"] as? String
        self.gender = json["gender"] as? String
        self.notifications = json["notifications"] as? Bool ?? false
        self.systemOfUnits = json["systemOfUnits"] as? String
        self.fitnessLevel = json["fitnessLevel"] as? Int
        self.personalGoals = json["personalGoals"] as? String ?? ""
        self.facebookId = json["facebookId"] as? String
        self.googleId = json["googleId"] as? String
        self.twoFAtype = json["twoFAtype"] as? String ?? TwoFAType.none.rawValue
        self.fullName = json["fullName"] as? String
        self.email = email
        self.birthday = json["birthday"] as? String
        self.height = json["height"] as? Double ?? 0
        self.weight = json["weight"] as? Double ?? 0
        self.gender = json["gender"] as? String ?? ""
        self.termsAccepted = json["termsAccepted"] as? String ?? ""
        self.optin = optin

    }
    
    init() {
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.gender = ""
        self.notifications = false
        self.systemOfUnits = "imperial"
        self.fitnessLevel = 0
        self.personalGoals = ""
        self.facebookId = ""
        self.googleId = ""
        self.twoFAtype = TwoFAType.none.rawValue
        self.fullName = ""
        self.email = ""
        self.birthday = ""
        self.height = 0
        self.weight = 0
        self.gender = ""
        self.optin = false
        self.termsAccepted = ""

    }
}

public extension ActivUser {
    enum ActivUserError: Error {
        case unableToParseActivUser
    }
}
