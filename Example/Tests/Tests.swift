import XCTest
@testable import ActivAuth


class Tests: XCTestCase {
    
    var email: String = ""
    let password: String = "1234asDF"
    let fullName = "ActivAuth Test"
    let gmail = "stixxxxxxx7RANDOM2020@gmail.com"
    let googleId = "ya29.Il-6B7eC0jywAWs-6UvrQ_dPRn9GsTfsENGKMKzl-B8O_v3qHQGLXjjLPzeCaAey5GK8eCVPR8FQp5AWJd2U4Qo-OLSplO04z6XjItQleRFqYLanVxgkpcAfpgb5fGz9Lg"
    let googleToken = "101716983855034107124"
    let fbMail = "konstantinkostadinov.elsys@gmail.com"
    let fbId = "3332768470127241"
    let fbToken = "EAAOZB8y1n0FcBAG1bqBF4lZBDxGoQQMNkoiZCiSNaglFpC0s99zJGlTv3nqx4cYUQJlfEwR0WypzGTGPIJGi1MEzj4c7Xtmk982PfbTQhv3133ZCrf0iDiAoeHvjXORRIrxdTlsjdf96vJTUkcY2H7nf5Nldcs0utmMcIeEDZBHxie3hUMZCGjdisHNMdOU9TbpFgSO4bdbqLajSc7pMutcRZA1qiWPBj5pdWFNlh9uyzJ6UZCEXIObN"
    
    let appleId = "001397.032be1d13e99414da96957835eb7a928.2055"
    let appleToken = "eyJraWQiOiI4NkQ4OEtmIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmV4YW1wbGUuYXBwbGUtc2FtcGxlY29kZS5qdWljZVA2WTJXOVJRNTQiLCJleHAiOjE1ODc1NjAzMjAsImlhdCI6MTU4NzU1OTcyMCwic3ViIjoiMDAxMzk3LjAzMmJlMWQxM2U5OTQxNGRhOTY5NTc4MzVlYjdhOTI4LjIwNTUiLCJjX2hhc2giOiJrTi15MFJQcHNQemY3V0w4MnRRU0V3IiwiZW1haWwiOiIyOHA2ZWpkbWdiQHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjoidHJ1ZSIsImlzX3ByaXZhdGVfZW1haWwiOiJ0cnVlIiwiYXV0aF90aW1lIjoxNTg3NTU5NzIwLCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.ZJ6wOfwfIqAnC8BWkYO5dIAtsu8pK0sjJrQobOHmf04mGteYniJVu3cggfLLE0MieqCHn1r-i5e4vAp_qN-CSPqm2qrGR9lCriuDrhGmjzLy_Qp7j4pcsaa7UG94fdXR7dWwozpkFKeZS1BLLVjX5dYIWx6UTp8PD0Y-VAm9laYcJrZhZtozc_q5KwlWsHTvCP8VheZS7RHSoZuiAT6di_of0X2XAoM8tNc3t_uMvqgt2Gh4J2g2sCEPgQmGzMf1F8LK0Y1r8lr_2843zd7NRg9T7HJ4RjYFY4AjkkhwohfcFRenWznCrHJLi3LT3GKWbeueKaNXBgwHEPQ5oFofvw"
    
    override func setUp() {
        super.setUp()
        ActivAuth.config.apiUrl = .custom(url: "http://localhost:4000/")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterAndLogin() {
        self.email = UUID().uuidString + "@test.dev"
        let expectation = XCTestExpectation()
        ActivAuth.register(email: email, password: password, name: fullName) { (user, error) in
            XCTAssert(user?.email.lowercased() == self.email.lowercased())
            XCTAssert(user?.id != nil)
            XCTAssert(user?.fullName == self.fullName)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15)
        
        let expectation2 = XCTestExpectation()
        ActivAuth.login(email: email, password: password) { (user, error) in
            XCTAssert(user?.email.lowercased() == self.email.lowercased())
            XCTAssert(user?.id != nil)
            XCTAssert(user?.fullName == self.fullName)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 15)
        
        let expectation3 = XCTestExpectation()
        ActivAuth.getProfile { (user, error) in
            XCTAssert(user?.email.lowercased() == self.email.lowercased())
            XCTAssert(user?.id != nil)
            XCTAssert(user?.fullName == self.fullName)
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 15)
    }
    
   //TODO: Make tests for Facebook login and google login
    
    func testGoogleLogin(){
        let expectation = XCTestExpectation()
        ActivAuth.loginWithGoogle(email: gmail, token: googleToken, googleId: googleId) { (user, error) in
            XCTAssert(user?.googleId != nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 15)
    }
    
    func testFBLogin(){
        let expectation = XCTestExpectation()
        ActivAuth.loginWithFacebook(email: fbMail, token: fbToken, facebookId: fbId) { (user, error) in
            XCTAssert(user?.facebookId != nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 15)
    }
    
    func testLoginApple(){
        let expectation = XCTestExpectation()
        ActivAuth.loginWithApple(appleId: appleId, appleToken: appleToken) { (user, error) in
            XCTAssert(user != nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 15)
    }
}
