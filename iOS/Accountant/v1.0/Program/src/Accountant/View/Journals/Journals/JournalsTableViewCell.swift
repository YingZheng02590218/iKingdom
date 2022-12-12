//
//  JournalsTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class JournalsTableViewCell: UITableViewCell {

    @IBOutlet weak var label_list_summary_debit: UILabel!
    @IBOutlet weak var label_list_summary_credit: UILabel!
    @IBOutlet weak var label_list_summary: UILabel!
    @IBOutlet weak var label_list_date_month: UILabel!
    @IBOutlet weak var label_list_date: UILabel!
    @IBOutlet weak var label_list_number_left: UILabel!
    @IBOutlet weak var label_list_number_right: UILabel!
    @IBOutlet weak var label_list_debit: UILabel!
    @IBOutlet weak var label_list_credit: UILabel!

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
        label_list_date_month.text = nil    // 「月」注意：空白を代入しないと、変な値が入る。
        label_list_date.text = nil     // 末尾2文字の「日」         //日付
        label_list_summary_debit.text = nil     //借方勘定
        label_list_summary_credit.text = nil   //貸方勘定
        label_list_summary.text = nil      //小書き
        label_list_number_left.text = nil       // 丁数
        label_list_number_right.text = nil
        label_list_debit.text = nil        //借方金額 注意：空白を代入しないと、変な値が入る。
        label_list_credit.text = nil       //貸方金額
    }
    
    func setTextColor(isInPeriod: Bool) {
        // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
        label_list_date_month.textColor = isInPeriod ? .textColor : .red
        label_list_date.textColor = isInPeriod ? .textColor : .red
        label_list_summary_debit.textColor = isInPeriod ? .textColor : .red
        label_list_summary_credit.textColor = isInPeriod ? .textColor : .red
        label_list_summary.textColor = isInPeriod ? .textColor : .red
        label_list_number_left.textColor = isInPeriod ? .textColor : .red
        label_list_number_right.textColor = isInPeriod ? .textColor : .red
        label_list_debit.textColor = isInPeriod ? .textColor : .red
        label_list_credit.textColor = isInPeriod ? .textColor : .red
    }
}
