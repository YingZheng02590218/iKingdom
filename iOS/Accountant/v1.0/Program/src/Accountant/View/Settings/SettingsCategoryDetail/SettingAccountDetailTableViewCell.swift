//
//  SettingAccountDetailTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func selectedRankAction(big: String, mid: String, bigNum: String, midNum: String)
    func selectedAccountAction(accountname: String?)
}
// 勘定科目詳細セル　大区分　中区分 勘定科目名 表示科目名
class SettingAccountDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var accountDetailBigTextField: AccountDetailPickerTextField!
    @IBOutlet var accountDetailAccountTextField: UITextField!
    @IBOutlet var label: UILabel!
    
    var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 大区分　中区分
        if let accountDetailBigTextField = accountDetailBigTextField {
            accountDetailBigTextField.delegate = self
            accountDetailBigTextField.inputAssistantItem.leadingBarButtonGroups.removeAll()
            // TextFieldに入力された値に反応
            accountDetailBigTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
            accountDetailBigTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
        }
        // 勘定科目名
        if let accountDetailAccountTextField = accountDetailAccountTextField {
            accountDetailAccountTextField.delegate = self
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
            //　toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3) // RGBで指定する alpha 0透明　1不透明
            toolbar.isTranslucent = true
            toolbar.barStyle = .default
            let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            toolbar.setItems([cancelItem, flexSpaceItem, doneItem], animated: true)
            // previous, next, paste ボタンを消す
            self.inputAssistantItem.leadingBarButtonGroups.removeAll()
            accountDetailAccountTextField.inputAccessoryView = toolbar
            // 入力開始
            accountDetailAccountTextField.addTarget(self, action: #selector(textFieldEditingDidBegin),for: UIControl.Event.editingDidBegin)
            // 入力終了
            accountDetailAccountTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 大区分　中区分
        if let accountDetailBigTextField = accountDetailBigTextField {
            accountDetailBigTextField.isHidden = true
        }
        // 勘定科目名
        if let accountDetailAccountTextField = accountDetailAccountTextField {
            accountDetailAccountTextField.isHidden = true
        }
        // 表示科目
        if let label = label {
            label.text = ""
            label.isHidden = true
        }
        accessoryType = .none
        // セルの選択
        selectionStyle = .none
        accessoryView = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc
    func done() {
        self.endEditing(true)
    }
    
    @objc
    func cancel() {
        // 勘定科目名
        if let accountDetailAccountTextField = accountDetailAccountTextField {
            accountDetailAccountTextField.text = ""
        }
        self.endEditing(true)
    }
}

extension SettingAccountDetailTableViewCell: UITextFieldDelegate {
    
    // textFieldに文字が入力される際に呼ばれる　入力チェック(文字列、文字数制限)
    // 戻り値にtrueを返すと入力した文字がTextFieldに反映され、falseを返すと入力した文字が反映されない。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 勘定科目名
        guard textField == accountDetailAccountTextField else {
            return false
        }
        // 文字列が0文字の場合、backspaceキーが押下されたということなので一文字削除する
        guard !string.isEmpty else { // 入力された文字
            //　textField.deleteBackward()　2文字分を削除してしまう
            return true // true だと2文字分を削除してしまう false だと未確定の文字が消えない
        }
        // 入力チェック　カンマを除外
        // 除外したい文字　(半角空白、全角空白)
        let notAllowedCharacters = CharacterSet(charactersIn: ", 　") // Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: string)
        // 指定したスーパーセットの文字セットでないならfalseを返す
        guard !(notAllowedCharacters.isSuperset(of: characterSet)) else { // 入力された文字
            return false
        }
        // 入力チェック　文字数最大数を設定
        let maxLength: Int = 20 // 文字数最大値を定義
        // textField内の文字数
        let textFieldTextCount = textField.text?.count ?? 0
        // 入力された文字数
        let stringCount = string.count
        // 最大文字数以上ならfalseを返す
        guard textFieldTextCount + stringCount <= maxLength else {
            return false
        }
        // 判定
        return true
    }
    // 入力開始 テキストフィールがタップされ、入力可能になったあと
    @objc
    func textFieldEditingDidBegin(_ textField: UITextField) {
        // フォーカス　効果　ドロップシャドウをかける
        textField.layer.shadowOpacity = 1.4
        textField.layer.shadowRadius = 4
        textField.layer.shadowColor = UIColor.calculatorDisplay.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    // 入力終了 テキストフィールへの入力が終了したとき
    @objc
    func textFieldEditingDidEnd(_ textField: UITextField) {
        // フォーカス　効果　フォーカスが外れたら色を消す
        textField.layer.shadowColor = UIColor.clear.cgColor
        // 取得　TextField 入力テキスト
        
        // 勘定科目区分選択　の場合
        if textField is AccountDetailPickerTextField {
            // 大区分
            // 中区分
            delegate?.selectedRankAction(
                big: accountDetailBigTextField.accountDetailBig,
                mid: accountDetailBigTextField.accountDetail,
                bigNum: accountDetailBigTextField.selectedRank0,
                midNum: accountDetailBigTextField.selectedRank1
            )
        }
        // 勘定科目名
        delegate?.selectedAccountAction(accountname: accountDetailAccountTextField?.text)
    }
    
    // リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        
        return false
    }
}
