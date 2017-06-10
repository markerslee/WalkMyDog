//
//  ChatLogController.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 20/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class ChatLogController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: Users?
    var receivedID: String?
    
    @IBOutlet var chatCollection: UICollectionView!
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up chat collectionview in page
        chatCollection.delegate = self
        chatCollection.dataSource = self
        chatCollection.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        chatCollection?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        chatCollection?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        chatCollection?.alwaysBounceVertical = true
        chatCollection.keyboardDismissMode = .interactive
        self.hideKeyboardWhenTappedAround()
        setupInputComponents()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUser()
        observeMessages()
    }
    
    //remove observers
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //bottom bar inputs and separator line
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    //setup collection view for chat bubbles
    let cellID = "cellID"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chatCollection.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        let message = messageArray[indexPath.item]
        cell.textView.text = message.text
        
        //bubbleView width
        cell.bubbleWidthAnchor?.constant = extimateFrameOfText(text: message.text!).width + 35
        
        setupCell(cell: cell, message: message)
        return cell
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    
    //setup input textfield and send button
    func setupInputComponents(){
        //put all into a container
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
       
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //remove toolbar from IQKeyboard
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        //bubbles for messages
        if message.fromID == Auth.auth().currentUser?.uid {
            
            //outgoing messages are orange
            
            cell.bubbleView.backgroundColor = ChatMessageCell.myOrange
            cell.textView.textColor = UIColor.white
            cell.bubbleViewLeftAchor?.isActive = false
            cell.bubbleViewRightAchor?.isActive = true

        } else{
            //incoming messages are grey
            cell.bubbleView.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAchor?.isActive = false
            cell.bubbleViewLeftAchor?.isActive = true
        }

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get height of text for bubble
        if let text = messageArray[indexPath.item].text {
            height = extimateFrameOfText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    //estimate the size of the bubble based on amount of text
    private func extimateFrameOfText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
   
    //get user values
    func getUser(){
        Database.database().reference().child("users")
        
        let ref = Database.database().reference(fromURL: "https://walkmydog-f5ea8.firebaseio.com/")
        
        ref.child("users").child(receivedID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            self.navigationItem.title = name
        })
        
    }
    
    var messageArray = [Message]()
    
    //Observing Message nodes
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(receivedID!)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else{
                    return
                }
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                self.messageArray.append(message)
                DispatchQueue.main.async {
                    self.chatCollection.reloadData()
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    func handleSend(){
        print(inputTextField.text!)
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = Auth.auth().currentUser!.uid
        let toID = receivedID!
        let time = NSDate().timeIntervalSince1970
        let timestamp = String(Int(time))
        let values = ["text": inputTextField.text!, "fromID": fromID, "toID": toID, "timestamp": timestamp]        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
        }
        
        self.inputTextField.text = nil
    
        let userMessagesRef = Database.database().reference().child("user-messages").child(fromID).child(toID)
        
        let messageID = childRef.key
        userMessagesRef.updateChildValues([messageID: 1])
        
        let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID).child(fromID)
        recipientUserMessagesRef.updateChildValues([messageID: 1])
    
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

}
