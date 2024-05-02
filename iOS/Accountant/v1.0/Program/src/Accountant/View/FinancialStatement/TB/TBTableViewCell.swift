//
//  TBTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TBTableViewCell: UITableViewCell {

    @IBOutlet var debitLabel: UILabel!
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
