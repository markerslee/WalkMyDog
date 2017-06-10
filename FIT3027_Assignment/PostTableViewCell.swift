//
//  PostTableViewCell.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 15/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var datetimeLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
