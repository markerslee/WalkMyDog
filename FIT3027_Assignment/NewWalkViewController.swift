//
//  NewWalkViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 2/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class NewWalkViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var typeField: UISegmentedControl!
    var postType: String = "LFW"
    var latitude: Double = 0
    var longitude: Double = 0
    var locationManager = CLLocationManager()
    //var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        dateTextField.delegate = self
        timeTextField.delegate = self
        textLabel.text = "Create New Post"
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
    }
    
    //date picker start
    func datePickerChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        timeFormatter.timeStyle = .short
        dateTextField.text = dateFormatter.string(from: sender.date)
        timeTextField.text = timeFormatter.string(from: sender.date)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePicker = UIDatePicker()
        let date = Date()
        datePicker.minimumDate = date
        dateTextField.inputView = datePicker
       datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        
        let timePicker = UIDatePicker()
        timeTextField.inputView = timePicker
        timePicker.minimumDate = date
        timePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dateTextField.resignFirstResponder()
        timeTextField.resignFirstResponder()
        return true
    }
    //date time picker end
  
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    //segment controls
    @IBAction func segmentedControlAction(sender: Any) {
        if(typeField.selectedSegmentIndex == 0)
        {
            textLabel.text = "Looking For Walker";
            postType = "LFW"
            print(postType)
        }
        else if(typeField.selectedSegmentIndex == 1)
        {
            textLabel.text = "Looking To Walk";
            postType = "LTW"
            print(postType)
        }
    }
    
    @IBAction func createButton(_ sender: Any) {
        if dateTextField.text != "" && timeTextField.text != ""{
            createPost()
            self.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Post Created!", message: " ", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
    
        } else{
            let alertController = UIAlertController(title: "Incomplete!", message: "Please ensure all fields are filled", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    
    //save the post into firebase
    func createPost(){
        //guard statements
        guard let date = dateTextField.text, let time = timeTextField.text
            else{
                print("Form Invalid")
                return
        }
        //Get current location, lat and long
        let currentLocation = locationManager.location
        self.latitude = (currentLocation?.coordinate.latitude)!
        self.longitude = (currentLocation?.coordinate.longitude)!
        //if unable to get location, set to Melbourne CBD
        if latitude == 0 && longitude == 0
        {
                latitude = -37.81
                longitude = 144.96
                print("unable to get user location")
                return
        }

        let isComplete = "no"
        //get user id
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //get name
        let ref = Database.database().reference().child("users").child(uid)
        
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //dictionary for walk info
            let walkInfo = ["date": date, "time": time, "type": self.postType, "userID": uid, "latitude": self.latitude, "longitude": self.longitude, "isComplete": isComplete] as [String : Any]
            self.savePostWithUserID(uid: uid, walkInfo: walkInfo)

        })
        

    }
    
    //saves post with userID
    private func savePostWithUserID(uid: String, walkInfo: [String: Any]){
        //successfully authenticated user
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        //create child node
        let timestamp = NSDate().timeIntervalSince1970
        let timeInt = Int(timestamp)
        let postID = String(timeInt)
        let postReference = ref.child("posts").child(postID)
        //update child values
        postReference.updateChildValues(walkInfo) { (err, ref) in
            if err != nil {
                let alertController = UIAlertController(title: "Error!", message: "Cannot Save to Database", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                

                print("Err")
                return
            }
            print("new post saved into firebase db!")
        }
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
