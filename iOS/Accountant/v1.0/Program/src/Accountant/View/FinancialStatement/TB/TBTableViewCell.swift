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
        
        // selectedBackgroundView を明示的に生成することで、nilになることを防ぐ
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.mainColor
        self.selectedBackgroundView = selectedBackgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
