//
//  TableViewCellSettingAccountDetailAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目詳細セル　テキストフィールド入力　勘定科目名
class TableViewCellSettingAccountDetailAccount: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var textField_AccountDetail_Account: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField_AccountDetail_Account.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
