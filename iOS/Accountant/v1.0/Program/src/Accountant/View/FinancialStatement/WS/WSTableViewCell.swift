//
//  WSTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class WSTableViewCell: UITableViewCell {

    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var debitLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var debit1Label: UILabel!
    @IBOutlet var credit1Label: UILabel!
    @IBOutlet var debit2Label: UILabel!
    @IBOutlet var credit2Label: UILabel!
    @IBOutlet var debit3Label: UILabel!
    @IBOutlet var credit3Label: UILabel!
    
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
