//
//  WithIconTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/22.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class WithIconTableViewCell: UITableViewCell {

    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    
    @IBOutlet var centerLabelHeighCenterY: NSLayoutConstraint!
    @IBOutlet var centerLabelMiddleCenterY: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // アイコン画像の色を指定する
        leftImageView.tintColor = .textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
