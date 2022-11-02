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
        if amount < 0 { //0の場合は、空白を表示する
            let amauntFix = amount * -1
            return "△ \(addComma(string: amauntFix.description))"
        }
        else {
            return addComma(string: amount.description)
        }
    }
    // コンマを追加 0の場合は、空白を表示する
    func setCommaForTB(amount: Int64) -> String {
        if addComma(string: amount.description) == "0" { // 0の場合は、空白を表示する
            return ""
        }
        else {
            return addComma(string: amount.description)
        }
    }
    // コンマを追加
    func setCommaWith0(amount: Int64) -> String {

        return StringUtility.shared.addComma(string: amount.description)
    }
    
    // カンマ区切りに変換（表示用）
    func addComma(string :String) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        if (string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }
        else {
            return ""
        }
    }
    // カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String {
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
    
    // MARK: 日付

    // 日付の6文字目にある月の十の位を抽出
    func pickupMonth(d: String, upperCellMonth: String) -> String {

        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                return "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
            }
            else {
                return "" // 注意：空白を代入しないと、変な値が入る。
            }
        }
        else {
            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                return "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
            }
            else {
                return "" // 注意：空白を代入しないと、変な値が入る。
            }
        }
    }
    // 日付の9文字目にある日の十の位を抽出
    func pickupDay(d: String) -> String {
        let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
        if date == "0" { // 日の十の位が0の場合は表示しない
            return "\(d.suffix(1))" // 末尾1文字の「日」         //日付
        }
        else {
            return "\(d.suffix(2))" // 末尾2文字の「日」         //日付
        }
    }
}
