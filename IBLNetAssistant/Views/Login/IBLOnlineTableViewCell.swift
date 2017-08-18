//
//  IBLOnlineTableViewCell.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 17/08/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit

class IBLOnlineTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var offlineButton: UIButton!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
