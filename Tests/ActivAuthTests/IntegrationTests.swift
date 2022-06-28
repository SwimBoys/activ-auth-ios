//
//  File.swift
//  
//
//  Created by Martin Kuvandzhiev on 13.10.20.
//

import Foundation
import XCTest
import ActivAuth

class IntegrationTests: XCTestCase {
    let email = UUID().uuidString + "@gmail.com"
    let password = "12345aA!"
    let firstName = "Boris"
    let lastName = "Kableshnikov"
    
    override func setUp() {
        super.setUp()
        ActivAuth.config.apiUrl = .custom(url: "https://228fac7d1634.ngrok.io/")
    }
    
    func testRegisterAndLogin() {
        let testExpectation1 = expectation(description: "")
        let testExpectation2 = expectation(description: "")
        let testExpectation3 = expectation(description: "")
        
        ActivAuth.register(email: email, password: password, firstName: firstName, lastName: lastName) { (user, error) in
            XCTAssertNil(error)
            
            XCTAssertNotNil(ActivAuth.currentAuthToken)
            XCTAssertNotNil(ActivAuth.currentRefreshToken)
            XCTAssertNotNil(ActivAuth.currentUserID)
            testExpectation1.fulfill()
            
            self.checkLogin(expectation: testExpectation2)
            self.getARefreshToken(expectation: testExpectation3)
        }

        wait(for: [testExpectation1, testExpectation2, testExpectation3], timeout: 15)
    }
    
    func checkLogin(expectation: XCTestExpectation) {
        
        ActivAuth.login(email: self.email, password: self.password) { (user, error) in
            XCTAssertNil(error)
            
            XCTAssertNotNil(ActivAuth.currentAuthToken)
            XCTAssertNotNil(ActivAuth.currentRefreshToken)
            XCTAssertNotNil(ActivAuth.currentUserID)
            expectation.fulfill()
        }
    }
    
    func getARefreshToken(expectation: XCTestExpectation) {
        ActivAuth.refreshToken { (json, error) in
            XCTAssertNil(error)
            
            XCTAssertNotNil(ActivAuth.currentAuthToken)
            XCTAssertNotNil(ActivAuth.currentRefreshToken)
            XCTAssertNotNil(ActivAuth.currentUserID)
            expectation.fulfill()
        }
    }

}
