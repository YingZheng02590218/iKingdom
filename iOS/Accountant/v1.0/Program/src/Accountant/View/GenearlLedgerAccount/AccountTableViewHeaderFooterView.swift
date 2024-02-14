//
//  AccountTableViewHeaderFooterView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/02/12.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import UIKit

class AccountTableViewHeaderFooterView: UITableViewHeaderFooterView {
    // 日付
    @IBOutlet var listDateMonthLabel: UILabel!
    @IBOutlet var listDateDayLabel: UILabel!
    // 摘要
    @IBOutlet var listSummaryLabel: UILabel!
    @IBOutlet var listSummarySecondLabel: UILabel!
    // 借方
    @IBOutlet var listDebitLabel: UILabel!
    @IBOutlet var listDebitSecondLabel: UILabel!
    @IBOutlet var listDebitThirdLabel: UILabel!
    // 貸方
    @IBOutlet var listCreditLabel: UILabel!
    @IBOutlet var listCreditSecondLabel: UILabel!
    @IBOutlet var listCreditThirdLabel: UILabel!
    // 借又貸
    @IBOutlet var listDebitOrCreditLabel: UILabel!
    // 差引残高
    @IBOutlet var listBalanceLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
