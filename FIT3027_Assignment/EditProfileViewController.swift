//
//  EditProfileViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 7/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//




///////////////////////////////
//Adpated from tutorial: https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
///////////////////////////////


import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var stateField: UITextField!
    @IBOutlet var postcodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
        self.hideKeyboardWhenTappedAround()
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        userImage.isUserInteractionEnabled = true
        }
    
    func loadUserProfile(){
        Database.database().reference().child("users")
        
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        let storage = Storage.storage()
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user values
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let password = value?["password"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let phone = value?["phone"] as? String ?? ""
            let address = value?["address"] as? String ?? ""
            let state = value?["state"] as? String ?? ""
            let postcode = value?["postcode"] as? String ?? ""
            let imageURL = value?["profileImageURL"] as? String ?? ""
            let storageRef = storage.reference(forURL: imageURL)
            storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                // Create a UIImage
                let pic = UIImage(data: data!)
                self.userImage.image = pic
                self.userImage.layer.cornerRadius = 16
                self.userImage.layer.masksToBounds = true

            })
            //Fill form expect password
            self.nameField.text = name
            self.passwordField.text = password
            self.emailField.text = email
            self.addressField.text = address
            self.phoneField.text = phone
            self.stateField.text = state
            self.postcodeField.text = postcode
            

        })
    }
    
    @IBAction func saveProfileButton(_ sender: Any) {
        saveProfileChanges()
    }
    
    func saveProfileChanges(){
        //guard statements
        guard let email = emailField.text, let password = passwordField.text, let name = nameField.text, let phone = phoneField.text, let address = addressField.text, let state = stateField.text, let postcode = postcodeField.text
            else{
                //error alert for incomplete form
                let alertController = UIAlertController(title: "Incomplete!", message: "Please ensure all fields are filled correctly.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        //get user id
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        //reference for image storage
        //use UID as image name in Storage
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profileImages").child("\(imageName).jpg")
        if let uploadData = UIImageJPEGRepresentation(self.userImage.image!, 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    //dictionary for user values
                    let userValues = ["name": name, "password": password, "email": email,"phone": phone, "address": address, "state": state, "postcode": postcode, "profileImageURL": profileImageUrl]
                    print(userValues)
                    
                    self.updateUserInDatabase(uid: uid, userValues: userValues)
                }
            })
        }

        
    }
    
    private func updateUserInDatabase(uid: String, userValues: [String: Any]) {
        //successfully authenticated user
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        //create child node
        let usersReference = ref.child("users").child(uid)
        
        //update child values
        usersReference.updateChildValues(userValues) { (err, ref) in
            if err != nil {
                print("Err")
                return
            }
            
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
        if let editedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("size: ", editedImage.size)
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("size: ", originalImage.size)
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            userImage.image = selectedImage
            userImage.layer.cornerRadius = 16
            userImage.layer.masksToBounds = true

        }
        
        self.dismiss(animated: true, completion: nil)
    }


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
