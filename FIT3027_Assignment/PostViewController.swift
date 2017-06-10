//
//  PostViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 14/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import MapKit
import Firebase
//import GoogleMaps
//import GooglePlaces


class PostViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
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
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        

        loadPostInfo()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //Map
    func handleMap(){
        let initialLocation = CLLocation(latitude: passedInfo?.latitude as! CLLocationDegrees, longitude: passedInfo?.longitude as! CLLocationDegrees)
        centerMapOnLocation(location: initialLocation)
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //end map

    //taked passed info from prev page
    var passedUser: Users?
    var passedInfo: Posts?
    func loadPostInfo(){
        let IDfrompost = passedInfo?.userID
        userRef.child(IDfrompost!).child("name").observe(.value, with: { (snapshot) in
            self.nameLabel.text = snapshot.value as? String
        }, withCancel: nil)
        
        //set values on screen
        typeLabel.text = passedInfo?.type
        let date = passedInfo?.date
        let time = passedInfo?.time
        let dateTime = date! + " , " + time!
        dateTimeLabel.text = dateTime
        let latitude = passedInfo?.latitude as! Double
        let longitude = passedInfo?.longitude as! Double
        
        //location
        let location = CLLocation(latitude: latitude, longitude: longitude)
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
        centerMapOnLocation(location: location)
        
        let userID = passedInfo?.userID
        userRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let imageURL = value?["profileImageURL"] as? String ?? ""
            let storageRef = self.storage.reference(forURL: imageURL)
            storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                // Create a UIImage
                let pic = UIImage(data: data!)
                self.userImage?.image = pic
                self.userImage?.layer.cornerRadius = 16
                self.userImage?.layer.masksToBounds = true
            })
        })
        
    }
    
    //go to chat
    @IBAction func showChat(_ sender: Any) {
        performSegue(withIdentifier: "fromPostSegue", sender: self)
     
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fromPostSegue") {
            let controller: ChatLogController = segue.destination as! ChatLogController
            let idToPass = passedInfo!.userID!

            // Pass the selected object to the new view controller.
            controller.receivedID = idToPass
        }
    }

    

}
