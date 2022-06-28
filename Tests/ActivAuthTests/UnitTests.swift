//
//  File.swift
//  
//
//  Created by Martin Kuvandzhiev on 13.10.20.
//

import Foundation
import XCTest
@testable import ActivAuth

class UnitTests: XCTestCase {
    var testToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRldmVsb3BtZW50In0.eyJlbWFpbCI6ImFAYS5jb20iLCJyb2xlcyI6W10sImlhdCI6MTYwMjU5MzY3NywiZXhwIjoxNjAzODAzMjc3LCJpc3MiOiJhY3RpdmJvZHkuY29tIiwic3ViIjoiNWY2ODhhYzk0ZDg5NzgwZmMzMjgwOWM4In0.oVjCTmFKH7ciYFm0Uu8JTt0n8BKN4RJwC9J7BVzs-QJru5WgjZ6xkTFQlwswOR9Ak_F4WzRJWzbnl2QFnN7fFVINyJQOu9g3fa8P_MVvKyxPQOPCUrVualMN0AL17Z7JlyemipleKA_ZkkZ9J4WanoFGPnrUBex18h4AhUq8zJu1HnrWzxTK5eb0S8n9pe5MC35-m4TgqVGG7LpXjXd9pn9EdKDvj1c7HgdEy9-O_79Hcam5Ja2DdtgZH-Ff6WGhS-7h9QA9NQMXBVMVap6Y2iQv4ibnZL60FDQe5GAUg-HoodAVOLITwVSgb_Vu2CkJ37akVqeOQhRdUcYUonWg4g"
    
    var refreshToken = "MjliNjE1MzQtYjcxOC00M2E2LWFmYTEtNGI4OTU1OTZiNmRh"
    
    var userId = "5f843b5dedecf3120d70cc56"
    
    func testDataSaving() {
        KeychainService.userToken = testToken
        KeychainService.refreshToken = refreshToken
        KeychainService.userId = userId
        
        XCTAssertEqual(ActivAuth.currentAuthToken, testToken)
        XCTAssertEqual(ActivAuth.currentRefreshToken, refreshToken)
        XCTAssertEqual(ActivAuth.currentUserID, userId)
    }
    
    func testTokenParsing() {
        KeychainService.userToken = testToken
        
        let tokenObject = ActivToken.current
        
        XCTAssertNotNil(tokenObject)
        XCTAssertEqual(tokenObject?.email, "a@a.com")
        XCTAssertEqual(tokenObject?.sub, "5f688ac94d89780fc32809c8")
        XCTAssert(tokenObject?.roles?.isEmpty ?? false)
    }
}
