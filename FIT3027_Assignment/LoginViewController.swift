//
//  LoginViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 3/4/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//




///////////////////////////////
//Adpated from tutorial: https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
///////////////////////////////


import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var emailInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
    }
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(false)
        if Auth.auth().currentUser?.uid != nil{
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    @IBAction func loginButton(_ sender: UIButton) {
        handleLogin()
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    func handleLogin(){
        guard let email = emailInput.text, let password = passwordInput.text
        else{
            //alert
            let alertController = UIAlertController(title: "Incomplete!", message: "Please ensure all fields are filled.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
                print ("Form is not valid")
                return
        }
        //sign in
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, Error) in
        
            if Error != nil{
                let alertController = UIAlertController(title: "Login Error!", message: "Please ensure email and password are correct.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

                print("Login Error")
                return
            }else {
                print("Login Success")
                self.performSegue(withIdentifier: "loginSegue", sender: self)

            }
           
            
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//hide keyboard when tapped outside textfield
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
