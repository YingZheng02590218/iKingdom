//
//  BSTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/29.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit

class BSTableViewCell: UITableViewCell {

    @IBOutlet weak var labelForPrevious: UILabel!
    @IBOutlet weak var labelForThisYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelForPrevious.text = ""
        labelForThisYear.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
