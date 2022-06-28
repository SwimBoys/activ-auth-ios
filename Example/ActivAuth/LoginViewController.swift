//
//  LoginViewController.swift
//  ActivAuth_Example
//
//  Created by Konstantin Kostadinov on 17.01.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ActivAuth
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, LoginButtonDelegate, GIDSignInDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var forgottenPasswordButton: UIBarButtonItem!
    @IBOutlet weak var loginWithFacebookButton: FBLoginButton!
    @IBOutlet weak var loginWIthGoogleButton: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var myAccessToken: AccessToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginWithFacebookButton.delegate = self
        loginWithFacebookButton.permissions = ["email"]
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        if let accessToken = AccessToken.current {
            self.myAccessToken = accessToken
            print("User is already logged in")
            DispatchQueue.main.async(){
                self.requestForParameters()
            }
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let manager = LoginManager()
        manager.logIn(permissions: [.email, .publicProfile], viewController: self) { (result) in
            print("LOGIN SUCCESS!")
        }
        DispatchQueue.main.async(){
            self.requestForParameters()
        }
        
    }
    func requestForParameters(){
        let myGraphRequest = GraphRequest(graphPath: "/me", parameters: ["fields": "email, id"], tokenString: AccessToken.current?.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)
        myGraphRequest.start(completionHandler: { (connection, result, error) in
            if let res = result {
                let responseDict = res as! [String:Any]
                guard let email = responseDict["email"] as? String else { return }
                guard let fbId = responseDict["id"] as? String else { return }
                guard let userToken: String = self.myAccessToken?.tokenString else {return}
                
                ActivAuth.loginWithFacebook(email: email, token: userToken, facebookId: fbId) { (user, err) in
                    
                    if let err = err{
                        print("we have error \(err.localizedDescription)")
                        self.presentAlert(title: "Error logging in", text: "Please check your internet connection and your credentials")
                    } else {
                        self.presentAlert(title: "Logged in successfully", text: "")
                        self.performSegue(withIdentifier: "toMainScreenSegue", sender: nil)
                    }
                    
                }
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("we have error \(error.localizedDescription)")
            return
        }
        if let gmailUser = user{
            guard let email = gmailUser.profile.email else { return }
            guard let googleId = gmailUser.userID else { return }
            guard let token = gmailUser.authentication.accessToken else { return }

            ActivAuth.loginWithGoogle(email: email, token: token, googleId: googleId) { (
                user, err) in
                if let err = err {
                    self.presentAlert(title: "Error logging in", text: "Please check your internet connection and your credentials")
                    return
                } else {
                    self.presentAlert(title: "Logged in successfully", text: "")
                    self.performSegue(withIdentifier: "toMainScreenSegue", sender: nil)
                }
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    @IBAction func loginWithGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    @IBAction func loginWithFacebookTapped(_ sender: Any) {
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        ActivAuth.login(email: email, password: password) { (user, error) in
            if let error = error {
                print("we have error \(error.localizedDescription)")
                self.presentAlert(title: "Error logging in", text: "Please check your internet connection and your credentials")
                return
            } else {
                print("User is:", user!)
                self.presentAlert(title: "Logged in successfully", text: "")
                self.performSegue(withIdentifier: "toMainScreenSegue", sender: nil)
            }
        }
    }
    
    @IBAction func forgottenPasswordButtonTapped(_ sender: Any) {
        addAlert(in: self) { (email) in
            ActivAuth.forgottenPass(email: email) { (error) in
                if let error = error{
                    self.presentAlert(title: "Error reseting password", text: "Please check your internet connection")
                    print("the error is \(error)")
                    return
                } else {
                    self.presentAlert(title: "Password resetted", text: "Check your email!")
                }
            }
        }
    }
    
    private func addAlert(in vc: UIViewController,
                     completion: @escaping (String) -> Void) {
    
        let alert = UIAlertController(title: "Enter email to reset password", message: nil, preferredStyle: .alert)
            alert.addTextField { (emailTF) in
                emailTF.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Reset password", style: .default) { (_) in
            guard let email = alert.textFields?.first?.text else { return }
            
                completion(email)
        }
        let closeAction = UIAlertAction(title: "Close", style: .destructive) { (_) in }
        alert.addAction(action)
        alert.addAction(closeAction)
        vc.present(alert, animated: true)
    }
    private func presentAlert(title: String, text: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
