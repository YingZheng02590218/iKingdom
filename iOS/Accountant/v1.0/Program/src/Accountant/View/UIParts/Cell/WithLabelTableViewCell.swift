//
//  WithLabelTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/15.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class WithLabelTableViewCell: UITableViewCell {

    @IBOutlet var leftTextLabel: UILabel!
    @IBOutlet var rightdetailTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
