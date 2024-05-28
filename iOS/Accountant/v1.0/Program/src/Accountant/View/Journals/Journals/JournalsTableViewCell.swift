//
//  JournalsTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class JournalsTableViewCell: UITableViewCell {

    @IBOutlet var listSummaryDebitLabel: UILabel!
    @IBOutlet var listSummaryCreditLabel: UILabel!
    @IBOutlet var listSummaryLabel: UILabel!
    @IBOutlet var listDateMonthLabel: UILabel!
    @IBOutlet var listDateLabel: UILabel!
    @IBOutlet var listDateSecondLabel: UILabel!
    @IBOutlet var listNumberLeftLabel: UILabel!
    @IBOutlet var listNumberRightLabel: UILabel!
    @IBOutlet var listDebitLabel: UILabel!
    @IBOutlet var listCreditLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listDateMonthLabel.text = nil    // 「月」注意：空白を代入しないと、変な値が入る。
        listDateSecondLabel.text = nil    // 「月」注意：空白を代入しないと、変な値が入る。
        listDateLabel.text = nil     // 末尾2文字の「日」         //日付
        listSummaryDebitLabel.text = nil     // 借方勘定
        listSummaryCreditLabel.text = nil   // 貸方勘定
        listSummaryLabel.text = nil      // 小書き
        listNumberLeftLabel.text = nil       // 丁数
        listNumberRightLabel.text = nil
        listDebitLabel.text = nil        // 借方金額 注意：空白を代入しないと、変な値が入る。
        listCreditLabel.text = nil       // 貸方金額
    }
    
    func setTextColor(isInPeriod: Bool) {
        // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
        listDateMonthLabel.textColor = isInPeriod ? .paperTextColor : .red
        listDateSecondLabel.textColor = isInPeriod ? .paperTextColor : .red
        listDateLabel.textColor = isInPeriod ? .paperTextColor : .red
        listSummaryDebitLabel.textColor = isInPeriod ? .paperTextColor : .red
        listSummaryCreditLabel.textColor = isInPeriod ? .paperTextColor : .red
        listSummaryLabel.textColor = isInPeriod ? .paperTextColor : .red
        listNumberLeftLabel.textColor = isInPeriod ? .paperTextColor : .red
        listNumberRightLabel.textColor = isInPeriod ? .paperTextColor : .red
        listDebitLabel.textColor = isInPeriod ? .paperTextColor : .red
        listCreditLabel.textColor = isInPeriod ? .paperTextColor : .red
    }
}
