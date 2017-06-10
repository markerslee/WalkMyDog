//
//  ProfileViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 7/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileNameLabel: UILabel!
    @IBOutlet var profileAddressLabel: UILabel!
    
    @IBOutlet var dogImageView: UIImageView!
    @IBOutlet var dogNameLabel: UILabel!
    @IBOutlet var dogButton: UIButton!
    @IBOutlet var editDogButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserInfo()
    }
    
    func fetchUserInfo(){
        Database.database().reference().child("users")
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        let storage = Storage.storage()
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            //print(snapshot)
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let address = value?["address"] as? String ?? ""
            let state = value?["state"] as? String ?? ""
            let postcode = value?["postcode"] as? String ?? ""
            let imageURL = value?["profileImageURL"] as? String ?? ""
            let storageRef = storage.reference(forURL: imageURL)
            storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                // Create a UIImage
                let pic = UIImage(data: data!)
                self.profileImageView.image = pic
                self.profileImageView.layer.cornerRadius = 16
                self.profileImageView.layer.masksToBounds = true
        })
            self.profileNameLabel.text = name
            self.profileAddressLabel.text = address + " " + state + " " + postcode
        })
        
        //check if a dog exists
        ref.child("users").child(userID!).child("dog").observeSingleEvent(of: .value, with: { (dogSnapshot) in
          let dogcount = dogSnapshot.childrenCount
            if  dogcount != 0{
                //get dog info
                ref.child("users").child(userID!).child("dog").observeSingleEvent(of: .value, with: { (dogSnapshot) in
                    let dogValue = dogSnapshot.value as? NSDictionary
                    let dogImage = dogValue?["dogImageURL"] as? String ?? ""
                    let dogName = dogValue?["dog_name"] as? String ?? ""
                    let storageRef = storage.reference(forURL: dogImage)
                    storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                        // Create a UIImage
                        let dogpic = UIImage(data: data!)
                        self.dogImageView.image = dogpic
                        self.dogImageView.layer.cornerRadius = 16
                        self.dogImageView.layer.masksToBounds = true
                    })
                    self.dogNameLabel.text = dogName
                    self.dogButton.isEnabled = false
                    self.dogButton.isHidden = true
                    self.dogButton.layer.cornerRadius = 16
                    self.dogButton.layer.masksToBounds = true
                })
            }
            else{
                self.dogNameLabel.text = "No dog saved"
                self.editDogButton.isHidden = true
                self.editDogButton.isEnabled = false
            }
        })
    }

        
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
