//
//  RegisterViewController.swift
//  ActivAuth_Example
//
//  Created by Konstantin Kostadinov on 17.01.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ActivAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let name = nameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        ActivAuth.register(email: email, password: password, name: name) { (user, error) in
            guard error == nil else {return}
            print("User is: ", user!)
            self.presentAlert(title: "\(name) registered successfully", text: "")
        }
    }
    
    private func presentAlert(title: String, text: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
    

}
