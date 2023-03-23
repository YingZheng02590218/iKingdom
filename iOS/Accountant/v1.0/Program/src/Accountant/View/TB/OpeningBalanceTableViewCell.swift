//
//  OpeningBalanceTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

class OpeningBalanceTableViewCell: UITableViewCell {

    var delegate: InputTextTableCellDelegate! = nil

    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var debitLabel: UILabel!
    // テキストフィールド　金額
    @IBOutlet var textFieldAmountDebit: UITextField!
    @IBOutlet var textFieldAmountCredit: UITextField!

    typealias Handler = (UITextField, UITextField) -> Void

    private var handler: Handler?
    // 設定残高振替仕訳　連番
    var primaryKey: Int = 0

    func setup(primaryKey: Int, category: String, valueDebitText: String, valueCreditText: String, tapHandler: @escaping Handler) {

        self.primaryKey = primaryKey

        textFieldAmountDebit.delegate = self
        textFieldAmountCredit.delegate = self
        // 初期値
        accountLabel.text = category // 勘定科目名をセルに表示する
        textFieldAmountDebit.text = valueDebitText
        textFieldAmountCredit.text = valueCreditText

        accountLabel.textAlignment = NSTextAlignment.center
        textFieldAmountDebit.textAlignment = .right
        textFieldAmountCredit.textAlignment = .right

        handler = tapHandler
    }
}

extension OpeningBalanceTableViewCell: UITextFieldDelegate {

    // MARK: - UITextFieldDelegate
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 借方金額　貸方金額
        if textField == textFieldAmountDebit {
            self.delegate.textFieldDidBeginEditing(primaryKey: primaryKey, category: accountLabel.text ?? "", debitOrCredit: DebitOrCredit.debit)
        } else if textField == textFieldAmountCredit {
            self.delegate.textFieldDidBeginEditing(primaryKey: primaryKey, category: accountLabel.text ?? "", debitOrCredit: DebitOrCredit.credit)
        }
    }
}

protocol InputTextTableCellDelegate {
    func textFieldDidBeginEditing(primaryKey: Int, category: String, debitOrCredit: DebitOrCredit)
}

enum DebitOrCredit {
    case debit // 借方
    case credit // 貸方
}
