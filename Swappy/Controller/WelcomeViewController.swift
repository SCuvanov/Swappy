//
//  ViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/6/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
            
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            //self.performSegue(withIdentifier: Constants.Segue.LOGIN_TO_MAIN, sender: self)
        }
    }
           
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    let alert = UIAlertController(title: "Login Error", message: "There has been an issue logging in, please check email and password.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in }
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: Constants.Segue.LOGIN_TO_MAIN, sender: self)
                }
            }
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Segue.LOGIN_TO_REGISTER, sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Forgot Password", message: "Keep an eye out for a password recovery email sent to the email provided below.", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Email"
            textField = alertTextField
        }
    
        let action = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let email = textField.text {
                Auth.auth().sendPasswordReset(withEmail: email) { error in }
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

