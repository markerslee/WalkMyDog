//
//  AddDogViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 7/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase

class AddDogViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var dogImageView: UIImageView!
    @IBOutlet var dogNameText: UITextField!
    @IBOutlet var dogAgeText: UITextField!
    @IBOutlet var dogDetailsText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
       dogImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDogImageView)))
        dogImageView.isUserInteractionEnabled = true
    }
    
    @IBAction func saveDogButton(_ sender: Any) {
        handleSaveDog()
    }
    
    //save dog info
    func handleSaveDog(){
        //guard statements
        guard let dogName = dogNameText.text, let dogAge = dogAgeText.text, let dogDetails = dogDetailsText.text
            else{
                let alertController = UIAlertController(title: "Incomplete!", message: "Please ensure all fields are filled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

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
        dogReference.observe(.value, with: { (snapshot: DataSnapshot!) in
            print("Got snapshot");
        })
        //create ID for dog image
        let imageName = dogReference.childByAutoId()
        let storageRef = Storage.storage().reference().child("dogImages").child("\(imageName).jpg")
        if let uploadData = UIImageJPEGRepresentation(self.dogImageView.image!, 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    return
                }
                
                if let dogImageUrl = metadata?.downloadURL()?.absoluteString {
                    //dictionary for dog values
                    let dogValues = ["dog_name": dogName, "dog_age": dogAge, "dog_details": dogDetails, "dogImageURL": dogImageUrl]
                    self.saveDogIntoDatabaseUnderUser(uid: uid!, dogValues: dogValues)
                }
            })
        }
    }
    
    private func saveDogIntoDatabaseUnderUser(uid: String, dogValues: [String: Any]){
        //successfully authenticated user
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        //create child node
        let dogReference = ref.child("users").child(uid).child("dog")
        //update child values
        dogReference.updateChildValues(dogValues) { (err, ref) in
            if err != nil {
                print("Err")
                let alertController = UIAlertController(title: "Error!", message: "Cannot Save to Database", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                return
            }
            
            //dismiss page
            self.dismiss(animated: true, completion: nil)
            
            print("dog saved into firebase db!")
        }

    }

    
    //for uploading dog image
    func handleDogImageView(){
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
            dogImageView.image = selectedImage
            dogImageView.layer.cornerRadius = 16
            dogImageView.layer.masksToBounds = true

        }
        
        self.dismiss(animated: true, completion: nil)
    }
    //end image handling

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
