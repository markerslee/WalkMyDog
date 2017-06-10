//
//  Message.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 22/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromID: String?
    var text: String?
    var toID: String?
    var timestamp: String?
    
    func chatPartnerID() -> String?{
               if fromID == Auth.auth().currentUser?.uid{
            return toID
        } else{
            return fromID
        }

    }

}
