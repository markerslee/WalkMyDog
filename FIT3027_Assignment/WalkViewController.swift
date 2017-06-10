//
//  WalkViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 8/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class WalkViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var completeLabel: UILabel!
    @IBOutlet var completeButton: UIButton!
    
    let locationManager = CLLocationManager()
    let postsRef = Database.database().reference(withPath: "posts")
    let userRef = Database.database().reference(withPath: "users")
    let storage = Storage.storage()
    
    var posts = [Posts]()
    var users = [Users]()
    let annotation = MKPointAnnotation()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        checkIfComplete()

        loadPostInfo()
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkIfComplete() {
        //if walk is complete, hide button, else show text
        
        self.completeLabel.isHidden = true

        if passedWalkInfo?.isComplete == "no"{
            self.completeButton.isEnabled = true
            self.completeButton.isHidden = false
            
        } else {
            self.completeButton.isEnabled = false
            self.completeButton.isHidden = true
            self.completeLabel.isHidden = false
            self.completeLabel.text = "Status: Completed"
            self.completeLabel.textColor = UIColor.green
            
        }
        
    }
    
    
    @IBAction func markAsCompleteButton(_ sender: Any) {
        //get current post id
        let postID = passedWalkInfo?.key
        
        postsRef.child(postID!).updateChildValues(["isComplete" : "yes"]) { (error, ref) in
            if error != nil {
                print("Err")
                return
            }
        }
        //Completeion alert
        let alertController = UIAlertController(title: "Walk Complete!", message: "Done!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        checkIfComplete()
        
    }
    
    //store info passed from prev page
    var passedWalkInfo: Posts?
    func loadPostInfo(){
        timeLabel.text = passedWalkInfo?.time
        dateLabel.text = passedWalkInfo?.date
        let latitude = passedWalkInfo?.latitude as! Double
        let longitude = passedWalkInfo?.longitude as! Double
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
        
        centerMapOnLocation(location: location)
        
        
    }

    
}
