//
//  WalksTableViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 24/4/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase

class WalksTableViewController: UITableViewController {

    let postsRef = Database.database().reference(withPath: "posts")
    let userRef = Database.database().reference(withPath: "users")
    let storage = Storage.storage()
    var posts = [Posts]()
    var users = [Users]()
    
    let uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        retrieveThisUsersPosts()
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(self.handleRefresh(sender:)), for: .valueChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.posts.removeAll()
        //retrieveThisUsersPosts()
        self.tableView.reloadData()
    }
    
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            print("not logged in")
            handleLogout()
        }
    }
    
    func handleLogout(){
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func handleRefresh(sender: Any) {
        self.posts.removeAll()
        retrieveThisUsersPosts()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }



    
    func retrieveThisUsersPosts(){
        
        //retrieve this user's posts only, by matching the uid
        Database.database().reference().child("posts").queryOrdered(byChild: "userID").queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            if let postDict = snapshot.value as? [String : Any] {
                let post = Posts()
                post.setValuesForKeys(postDict)
                post.key = snapshot.key
                self.posts.append(post)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        })
    }
    
    func reloadTable(){
        //retrieve this user's posts only, by matching the uid
        Database.database().reference().child("posts").queryOrdered(byChild: "userID").queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            if let postDict = snapshot.value as? [String : Any] {
                let post = Posts()
                post.setValuesForKeys(postDict)
                post.key = snapshot.key
                self.posts.append(post)
                self.tableView.reloadData()
            }
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "walkCell", for: indexPath) as! WalksViewCell
        let post = posts[indexPath.row]
        cell.dateTimeLabel?.text = post.date! + ", " + post.time!
        cell.typeLabel?.text = post.type
        
        if post.isComplete == "no"{
        cell.completeLabel?.text = "Status: Incomplete"
        cell.completeLabel?.textColor = UIColor.red
        }else if post.isComplete == "yes"{
            cell.completeLabel?.text = "Status: Complete"
            cell.completeLabel?.textColor = UIColor.green
        }
        
        return cell
        
    }
    
    
    //Passing info to next page
    var myWalkInfo: Posts?
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPost = posts[indexPath.row]
        //print(selectedPost)
        myWalkInfo = selectedPost
        
        performSegue(withIdentifier: "walkSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "walkSegue") {
            let controller: WalkViewController = segue.destination as! WalkViewController
            
            // Pass the selected object to the new view controller.
            
            controller.passedWalkInfo = myWalkInfo!
        }
    }
    
    // this method handles row deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        
        let postKey = selectedPost.key
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            posts.remove(at: indexPath.row)
            
            //delete from firebase
            postsRef.child(postKey!).removeValue()
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }

    


    
}
