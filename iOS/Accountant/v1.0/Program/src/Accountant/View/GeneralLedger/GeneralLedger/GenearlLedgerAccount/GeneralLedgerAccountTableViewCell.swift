//
//  GeneralLedgerTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class GeneralLedgerAccountTableViewCell: UITableViewCell {

    @IBOutlet var listDateMonthLabel: UILabel!
    @IBOutlet var listDateDayLabel: UILabel!
    @IBOutlet var listSummaryLabel: UILabel!
    @IBOutlet var listNumberLabel: UILabel!
    @IBOutlet var listDebitLabel: UILabel!
    @IBOutlet var listCreditLabel: UILabel!
    @IBOutlet var listDebitOrCreditLabel: UILabel!
    @IBOutlet var listBalanceLabel: UILabel!
    
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
