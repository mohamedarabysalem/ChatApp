//
//  SignupViewController.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 4/27/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let imagePicker = UIImagePickerController()
    let activityIndecator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.handle))
        userImg.addGestureRecognizer(tap)
        userImg.isUserInteractionEnabled = true
        userImg.layer.cornerRadius = userImg.frame.size.width / 2
        userImg.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    @objc func handle (){
        let alert = UIAlertController(title: "Profile Picture", message: "Please select a picture from library or take a picture", preferredStyle: .alert)
        let albumAction = UIAlertAction(title: "Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
        }
        alert.addAction(albumAction)
        alert.addAction(cameraAction)
        
        present(alert,animated: true,completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
             fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            return
        }
        self.userImg.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    func presentImagePickerWith(sourceType: UIImagePickerController.SourceType){
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
    }
    @IBAction func signupButton(_ sender: Any) {
        activityIndicator()
        if (emailTextField.text == "" || passwordTextField.text == "" || usernameTextField.text == ""){
            alert(text: "Please Enter Your Credentals")
            activityIndecator.stopAnimating()
        }else{
        FirebaseApi.shared.signup(email: emailTextField.text!, password: passwordTextField.text!, profileImage: userImg.image!,userName: usernameTextField.text!) { (succ) in
            self.activityIndecator.stopAnimating()
            if succ{
                print("Successful!")
                self.performSegue(withIdentifier: "signupSucc", sender: self)
            }else {
                self.alert(text: "Please Enter Valid Credentals")
                print("error")
            }
            }
        }
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
