//
//  StringUtility.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/02.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation

class StringUtility {
    
    public static let shared = StringUtility()
    
    private init() {
    }
    
    // MARK: NumberFormatter
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    
    // コンマを追加
    func setComma(amount: Int64) -> String {
        // 三角形はマイナスの意味
        if amount < 0 { // 0の場合は、空白を表示する
            let amauntFix = amount * -1
            return "△ \(addComma(string: amauntFix.description))"
        } else {
            return addComma(string: amount.description)
        }
    }
    // コンマを追加 0の場合は、空白を表示する
    func setCommaForTB(amount: Int64) -> String {
        if addComma(string: amount.description) == "0" { // 0の場合は、空白を表示する
            return ""
        } else {
            return addComma(string: amount.description)
        }
    }
    // コンマを追加
    func setCommaWith0(amount: Int64) -> String {
        
        StringUtility.shared.addComma(string: amount.description)
    }
    
    // カンマ区切りに変換（表示用）
    func addComma(string: String) -> String {
        // 3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        if string.isEmpty {
            return ""
        } else {
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            guard let value = Double(string) else { return "" }
            guard let formattedValue = formatter.string(from: NSNumber(value: value)) else { return "" }
            return formattedValue
        }
    }
    // カンマ区切りを削除（計算用）
    func removeComma(string: String) -> String {
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
}
