//
//  ChatMessageCell.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 30/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.text = "Sample"
        tv.textColor = .white
        
        return tv
        
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    static let myOrange = UIColor(red:1.00, green:0.51, blue:0.32, alpha:1.0)
    var bubbleViewRightAchor: NSLayoutConstraint?
    var bubbleViewLeftAchor: NSLayoutConstraint?
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = myOrange
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        
        //constriants
        bubbleViewRightAchor =  bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAchor?.isActive = true
        
        bubbleViewLeftAchor = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        //bubbleViewLeftAchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        

        //constriants
        //textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
