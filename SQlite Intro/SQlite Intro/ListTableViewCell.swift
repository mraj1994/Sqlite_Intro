//
//  ListTableViewCell.swift
//  SQlite Intro
//
//  Created by QuietGrowth pty ltd on 29/07/19.
//  Copyright © 2019 Mrajsingh. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
