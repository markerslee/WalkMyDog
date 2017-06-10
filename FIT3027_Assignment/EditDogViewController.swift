//
//  EditDogViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 10/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase

class EditDogViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  
    @IBOutlet var dogImage: UIImageView!
    @IBOutlet var dogName: UITextField!
    @IBOutlet var dogAge: UITextField!
    @IBOutlet var dogDetails: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDogInfo()

        self.hideKeyboardWhenTappedAround()
        
        dogImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        dogImage.isUserInteractionEnabled = true

    }

    
    func loadDogInfo(){
        Database.database().reference().child("users").child("dog")
        
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        let storage = Storage.storage()
        let userID = Auth.auth().currentUser?.uid

        ref.child("users").child(userID!).child("dog").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get dog info values
            let value = snapshot.value as? NSDictionary
            let name = value?["dog_name"] as? String ?? ""
            let age = value?["dog_age"] as? String ?? ""
            let details = value?["dog_details"] as? String ?? ""
            let imageURL = value?["dogImageURL"] as? String ?? ""
            let storageRef = storage.reference(forURL: imageURL)
            storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                // Create a UIImage
                let pic = UIImage(data: data!)
                self.dogImage.image = pic
                self.dogImage.layer.cornerRadius = 16
                self.dogImage.layer.masksToBounds = true
            })
            
            self.dogName.text = name
            self.dogAge.text = age
            self.dogDetails.text = details
                    
        })

        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveDogInfoChanges()
    }
    
    func saveDogInfoChanges(){
        //guard statements
        guard let dogName = dogName.text, let dogAge = dogAge.text, let dogDetails = dogDetails.text
            else{
                print ("Form is not valid")
                return
        }

                //get user id
                let uid = Auth.auth().currentUser?.uid
                
                //reference for image storage
                //use UID as image name in Storage
                let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
                //create child node
                let dogReference = ref.child("users").child(uid!).child("dog")
                
                
                let imageName = dogReference.childByAutoId()
                
                let storageRef = Storage.storage().reference().child("dogImages").child("\(imageName).jpg")
                
                if let uploadData = UIImageJPEGRepresentation(self.dogImage.image!, 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            return
                        }
                        
                        if let dogImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            //dictionary for dog values
                            
                            let dogValues = ["dog_name": dogName, "dog_age": dogAge, "dog_details": dogDetails, "dogImageURL": dogImageUrl]
                            
                            self.saveNewDogInfo(uid: uid!, dogValues: dogValues)
                        }
                    })
                }
                
        
        
    }
        
        private func saveNewDogInfo(uid: String, dogValues: [String: Any]){
            //successfully authenticated user
            let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
            //create child node
            let dogReference = ref.child("users").child(uid).child("dog")
            
            
            //update child values
            dogReference.updateChildValues(dogValues) { (err, ref) in
                if err != nil {
                    print("Err")
                    return
                }
                
                //dismiss page
                self.dismiss(animated: true, completion: nil)
                
                print("dog saved into firebase db!")
            }
            
        }
        

    
    
    
    //for uploading image
    
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
            dogImage.image = selectedImage
            dogImage.layer.cornerRadius = 16
            dogImage.layer.masksToBounds = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
