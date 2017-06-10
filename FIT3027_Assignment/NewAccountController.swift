//
//  NewAccountController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 23/4/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//




///////////////////////////////
//Adpated from tutorial: https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
///////////////////////////////


import UIKit
import Firebase

class NewAccountController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var nameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var stateField: UITextField!
    @IBOutlet var postcodeField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //register tap gesture
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
    }

    @IBAction func cancelButton(_ sender: Any) {
        //dismiss register page and go back to login
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func registerButton(_ sender: Any) {
        handleRegister()
    }
   
    func handleRegister(){
        //guard statements
        guard let email = emailField.text, let password = passwordField.text, let name = nameField.text, let phone = phoneField.text, let address = addressField.text, let state = stateField.text, let postcode = postcodeField.text
            else{
                //error alert for incomplete form
                let alertController = UIAlertController(title: "Incomplete!", message: "Please ensure all fields are filled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                print ("Form is not valid")
                return
        }
        
        //add user to firebase auth
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user: User?, error) in
            if error != nil {
                print("Error")
//                let alertController = UIAlertController(title: "Error!", message: "Cannot Save to Database", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okAction)
//                self.present(alertController, animated: true, completion: nil)
                return
            }            
            //get user id
            guard let uid = user?.uid else{
                return
            }
            //reference for image storage
            //use UID as image name in Storage
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profileImages").child("\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        //dictionary for user values
                        let userValues = ["name": name, "email": email,"phone": phone, "address": address, "state": state, "postcode": postcode, "profileImageURL": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, userValues: userValues)
                    }
                })
            }
        })
    }
    
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, userValues: [String: Any]) {
        //successfully authenticated user
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        //create child node
        let usersReference = ref.child("users").child(uid)
        
        //update child values
        usersReference.updateChildValues(userValues) { (err, ref) in
            if err != nil {
                let alertController = UIAlertController(title: "Error!", message: "Cannot Save to Database", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //dismiss register page and go back to login
            self.dismiss(animated: true, completion: nil)
            print("User saved into firebase db!")
        }
    }

//for uploading profile image
    func handleProfileImageView(){
        //setup image picker
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        //allow user to edit chosen image
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("size: ", editedImage.size)
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("size: ", originalImage.size)
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
            profileImageView.layer.cornerRadius = 16
            profileImageView.layer.masksToBounds = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
//end image handling
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
    
