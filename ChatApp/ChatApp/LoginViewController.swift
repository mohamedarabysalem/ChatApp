//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 4/27/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let activityIndecator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        activityIndicator()
        if emailTextField.text == "" || passwordTextField.text == "" {
            alert(text: "Username or Password Empty.")
            activityIndecator.stopAnimating()
        }else{
        FirebaseApi.shared.login(email: emailTextField.text!, password: passwordTextField.text!) { (succ,error) in
            self.activityIndecator.stopAnimating()
            if succ{
                
                print("Successful!")
                self.performSegue(withIdentifier: "goToChats", sender: self)
            }else{
                
                print("error")
                if error == "Please Enter Correct Credentals"{
                    self.alert(text: error!)
                }else{
                    self.alert(text: error!)
                }
                
                
            }
            }
        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        performSegue(withIdentifier: "goToSingup", sender: self)
    }
    func alert (text : String){
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    func activityIndicator (){
        activityIndecator.style = UIActivityIndicatorView.Style.gray
        activityIndecator.center = self.view.center
        activityIndecator.hidesWhenStopped = true
        activityIndecator.startAnimating()
        self.view.addSubview(activityIndecator)
        activityIndecator.startAnimating()
    }
}
