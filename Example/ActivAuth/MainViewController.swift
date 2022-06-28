//
//  MainViewController.swift
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

class MainViewController: UIViewController {
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var fetchProfileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    var user: ActivUser?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ActivAuth.getProfile { (user, error) in
            print("User is: ", user?.id)
            self.user = user
        }
    }
    @IBAction func updateProfileButtonTapped(_ sender: Any) {
        changeProfileProperties(in: self)
    }
    @IBAction func fetchProfileButtonTapped(_ sender: Any) {
        ActivAuth.getProfile { (user, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                guard let user = user else { return }
                self.addAlert(in: self, user: user)
            }
        }
    }
    
    private func changeProfileProperties(in vc: UIViewController) {
        let alert = UIAlertController(title: "Change profile properties", message: nil, preferredStyle: .alert)
        alert.addTextField { (emailTF) in
            emailTF.placeholder = "Email"
            emailTF.isSelected = true
            emailTF.isEnabled = true
        }
        alert.addTextField { (firstNameTF) in
            firstNameTF.placeholder = "First name"
            firstNameTF.isSelected = true
        }
        alert.addTextField { (lastNameTF) in
            lastNameTF.placeholder = "Last name"
            lastNameTF.isSelected = true
        }
        let updateAction = UIAlertAction(title: "Update profile", style: .default) { (_) in
            guard let emailString = alert.textFields?.first?.text, let firstNameString = alert.textFields?[1].text,
            let lastNameString = alert.textFields?.last?.text
            else { return }
            let dictionary = ["email": emailString, "firstName" : firstNameString, "lastName" : lastNameString]
            ActivAuth.updateFields(dictionary: dictionary) { (user, error) in
                if let error = error {
                    return
                } else {
                    guard let user = user else { return }
                    self.addAlert(in: self, user: user)
                }
                
            }
        }
        let closeAction = UIAlertAction(title: "Close", style: .destructive) { (_) in}
        alert.addAction(updateAction)
        alert.addAction(closeAction)
        vc.present(alert, animated: true)
    }
    
    private func addAlert(in vc: UIViewController,user: ActivUser) {
    
        let alert = UIAlertController(title: "user profile fetched", message: nil, preferredStyle: .alert)
        alert.addTextField { (emailTF) in
            emailTF.text = user.email
            emailTF.isSelected = false
        }
        alert.addTextField { (idTF) in
            idTF.text = user.id
            idTF.isSelected = false
        }
        alert.addTextField { (nameTF) in
            nameTF.text = user.fullName ?? ""
            nameTF.isSelected = false
        }
        let action = UIAlertAction(title: "Close", style: .destructive) { (_) in}
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        if let accessToken = AccessToken.current {
            let loginManager = LoginManager()
            loginManager.logOut()
        } else {
            ActivAuth.logout()
        }
        performSegue(withIdentifier: "toChooseScreenSegue", sender: nil)
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
