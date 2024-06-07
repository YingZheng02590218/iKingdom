//
//  CompanyNameTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CompanyNameTableViewCell: UITableViewCell, UITextViewDelegate { // プロトコルを追加

    @IBOutlet var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // デリゲートを設定
        textView.delegate = self
        // データベース
        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        textView.text = company // 事業者名
        textView.textContainer.lineBreakMode = .byTruncatingTail // 文字が入りきらない場合に行末を…にしてくれます
        textView.textContainer.maximumNumberOfLines = 2 // 最大行数を1行に制限
        textView.textAlignment = .center
        // テキストの入力位置を指すライン、これはカーソルではなくキャレット(caret)と呼ぶそうです。
        textView.tintColor = UIColor.accentColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        // 変換中はスルー 変換中は制限されない
        if textView.markedTextRange != nil { return }
        // 入力チェック　文字数最大数を設定
        let maxLength: Int = 20 // 文字数最大値を定義
        if text.count > maxLength {
            // 確定した時にオーバーしている分は除かれる
            textView.text = String(text.prefix(maxLength))
        }
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // データベース
        DataBaseManagerAccountingBooksShelf.shared.updateCompanyName(companyName: textView.text)
    }
    // 入力制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 改行が入力された場合、リターンキーが押下されたということなのでキーボードを閉じる
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        // 文字列が0文字の場合、backspaceキーが押下されたということなので一文字削除する
        guard !text.isEmpty else { // 入力された文字
            //　textField.deleteBackward()　2文字分を削除してしまう
            return true // true だと2文字分を削除してしまう false だと未確定の文字が消えない
        }
        // 入力チェック　カンマを除外
        // 除外したい文字　(半角空白、全角空白)
        let notAllowedCharacters = CharacterSet(charactersIn: ",") // Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: text)
        // 指定したスーパーセットの文字セットでないならfalseを返す
        guard !(notAllowedCharacters.isSuperset(of: characterSet)) else { // 入力された文字
            return false
        }
        // 判定
        return true
    }
}
