//
//  ChatTableViewController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 24/4/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//





///////////////////////////////
//Adpated from tutorial: https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
///////////////////////////////

import UIKit
import Firebase

class ChatTableViewController: UITableViewController {

    
    let userRef = Database.database().reference(withPath: "users")
    let storage = Storage.storage()
    var users = [Users]()
    
    let chatCell = "chatCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        observeUserMessages()
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        messages.removeAll()
        messagesDict.removeAll()
        //observeUserMessages()
        //tableView.reloadData()
        observeUserMessages()
        tableView.reloadData()
    }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser == nil{
            print("not logged in")
            //handleLogout()
            let loginController = LoginViewController()
            present(loginController, animated: true, completion: nil)
        } else{
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
        
    }
    
    var messages = [Message]()
    var messagesDict = [String: Message]()
    
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
       //get all children from "users-messages"
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                
                let messageRef = Database.database().reference().child("messages").child(messageID)
                
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    //set messages dictionary
                    if let messageDict = snapshot.value as? [String: Any]{
                        let message = Message()
                        message.setValuesForKeys(messageDict)
                        //check for correct chat partner
                        if let chatPartnerID = message.chatPartnerID() {
                            self.messagesDict[chatPartnerID] = message
                            
                            self.messages = Array(self.messagesDict.values)
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }, withCancel: nil)
                
                

                
                
            }, withCancel: nil)
            
            
            
        }, withCancel: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //populate table with chat partners
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        let msg = messages[indexPath.row]
               
        if let toID = msg.chatPartnerID() {
            
            let ref = Database.database().reference().child("users").child(toID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String: Any]{
                    cell.userName.text = userDict["name"] as? String
                    let imageURL = userDict["profileImageURL"] as? String ?? ""
                    let storageRef = self.storage.reference(forURL: imageURL)
                    storageRef.getData(maxSize: (1 * 1024 * 1024), completion: { (data, error) in
                        // Create a UIImage
                        let pic = UIImage(data: data!)
                        cell.userImage?.image = pic
                        cell.userImage?.layer.cornerRadius = 16
                        cell.userImage?.layer.masksToBounds = true
                    })
                }
            }, withCancel: nil)
        }
        return cell
    }

    
    var passedUser: Users?
    var passID: String?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]

        guard let chatPartnerID = message.chatPartnerID() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else{
                return
            }
 
            let user = Users()
            user.setValuesForKeys(dictionary)
            user.id = chatPartnerID
            self.passID = user.id
            self.performSegue(withIdentifier: "fromChatsSegue", sender: self)
            
        }, withCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fromChatsSegue") {
            let controller: ChatLogController = segue.destination as! ChatLogController
            let idToPass = passID
            // Pass the selected object to the new view controller.
            controller.receivedID = idToPass
        }
    }

}
