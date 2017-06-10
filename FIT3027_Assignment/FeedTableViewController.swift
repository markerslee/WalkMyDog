//
//  FeedTableViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 23/4/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase


class FeedTableViewController: UITableViewController {
    
    let postsRef = Database.database().reference(withPath: "posts")
    let userRef = Database.database().reference(withPath: "users")
    let storage = Storage.storage()
    var posts = [Posts]()
    var users = [Users]()
    private var selectedIndexPath: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserLoggedIn()
        retrieveTableData()
        tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(self.handleRefresh(sender:)), for: .valueChanged)

        }
    
     var items = [DataSnapshot]()
    func checkIfUserLoggedIn(){
        
        if Auth.auth().currentUser?.uid == nil{
            print("not logged in")
            handleLogout()
        }
        
    }
    
    func retrieveTableData(){
        //retrieve data for table view
        postsRef.observe(.childAdded, with: { (snapshot) in
           if let postDict = snapshot.value as? [String : Any] {
                let post = Posts()
                post.setValuesForKeys(postDict)
            
            //do not show this user's posts on feed
            //hide posts that are marked as complete
                if post.userID != Auth.auth().currentUser?.uid && post.isComplete == "no"{
                    self.posts.append(post)
                }
           // self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    func handleRefresh(sender: Any) {
        //refresh table
        self.posts.removeAll()
        retrieveTableData()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    @IBAction func logoutButton(_ sender: Any) {
        handleLogout()
    }
    
    //unwind to login page
    func handleLogout(){
          self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        let userID = post.userID
        //set name for user in post cell
        userRef.child(userID!).child("name").observe(.value, with: { (snapshot) in
            cell.nameLabel?.text = snapshot.value as? String

        }, withCancel: nil)
        //set the other info in cell
        cell.datetimeLabel?.text = post.date! + ", " + post.time!
        cell.typeLabel?.text = post.type
        
        //picture in cell
        //check: if LTW post, show user image, if LFW post, show dog image
        
        if post.type == "LTW"{
            userRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let imageURL = value?["profileImageURL"] as? String ?? ""
                let storageRef = self.storage.reference(forURL: imageURL)
                   storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                     // Create a UIImage
                        let pic = UIImage(data: data!)
                         cell.userImage?.image = pic
                            cell.userImage?.layer.cornerRadius = 16
                            cell.userImage?.layer.masksToBounds = true
                   })
            })
        } else if post.type == "LFW"{
            userRef.child(userID!).child("dog").observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                let value = snapshot.value as? NSDictionary
                let imageURL = value?["dogImageURL"] as? String ?? ""
                
                if imageURL == "" {
                    self.userRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let imageURL = value?["profileImageURL"] as? String ?? ""
                        let storageRef = self.storage.reference(forURL: imageURL)
                        storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                            // Create a UIImage
                            let pic = UIImage(data: data!)
                            cell.userImage?.image = pic
                            cell.userImage?.layer.cornerRadius = 16
                            cell.userImage?.layer.masksToBounds = true
                        })
                    })
                    
                } else{
                    let storageRef = self.storage.reference(forURL: imageURL)
                    storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                        // Create a UIImage
                        let pic = UIImage(data: data!)
                        cell.userImage?.image = pic
                        cell.userImage?.layer.cornerRadius = 16
                        cell.userImage?.layer.masksToBounds = true

                    })
                }
                
            })
            
        }
        return cell
        
    }
    
    //passing selected post info to next screen
    var infoToPass: Posts?
    var sUser = Users()
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPost = posts[indexPath.row]
        let thisUserID = selectedPost.userID
        userRef.child(thisUserID!).observe(.value, with: { (snapshot) in
            let thisUserDict = snapshot.value as? NSDictionary
            self.sUser.setValuesForKeys(thisUserDict as! [String : Any])
            self.sUser.id = snapshot.key
        })
        infoToPass = selectedPost
       
        performSegue(withIdentifier: "viewPostSegue", sender: self)
        
    }
    
    //segue control
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "viewPostSegue") {
            let controller: PostViewController = segue.destination as! PostViewController
           
            // Pass the selected object to the new view controller.
            
           controller.passedInfo = infoToPass!
            controller.passedUser = sUser
        }
    }

 
}



