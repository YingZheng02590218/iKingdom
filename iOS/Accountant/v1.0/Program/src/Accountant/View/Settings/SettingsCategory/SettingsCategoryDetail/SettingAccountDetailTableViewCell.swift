//
//  SettingAccountDetailTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目詳細セル　テキストフィールド入力　大区分　中区分　小区分
class SettingAccountDetailTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var textField_AccountDetail_big: AccountDetailPickerTextField!
//    @IBOutlet var textField_AccountDetail: AccountDetailPickerTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // テキストフィールド作成
        self.textField_AccountDetail_big.inputAssistantItem.leadingBarButtonGroups.removeAll()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
