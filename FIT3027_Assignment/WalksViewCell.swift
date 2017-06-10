//
//  WalksViewCell.swift
//  FIT3027_Assignment
//
//  Created by Marcus Lee on 2/5/17.
//  Copyright © 2017 Marcus Lee. All rights reserved.
//

import UIKit

class WalksViewCell: UITableViewCell {
    
    
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var completeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
