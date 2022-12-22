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
        if string != "" { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        } else {
            return ""
        }
    }
    // カンマ区切りを削除（計算用）
    func removeComma(string: String) -> String {
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
    
    // MARK: 日付
    
    // 先頭行は月を表示 日付の6文字目にある月を抽出
    func pickupMonth(date: String) -> String {
        // 月
        let month = date[
            date.index(
                date.startIndex,
                offsetBy: 5
            )..<date.index(
                date.startIndex,
                offsetBy: 7
            )
        ]
        // 月の十の位を抽出
        let tensPlace = month.prefix(1)
        
        if tensPlace == "0" { // 月の十の位が0の場合は表示しない
            return "\(date[date.index(date.startIndex, offsetBy: 6)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
            
        } else {
            return "\(month)" // 「月」
        }
    }
    // 日付の6文字目にある月を抽出
    func pickupMonth(date: String, upperCellMonth: String) -> String {
        // 月
        let month = date[
            date.index(
                date.startIndex,
                offsetBy: 5
            )..<date.index(
                date.startIndex,
                offsetBy: 7
            )
        ]
        // 月　上のセル
        let upperMonth = upperCellMonth[
            upperCellMonth.index(
                upperCellMonth.startIndex,
                offsetBy: 5
            )..<upperCellMonth.index(
                upperCellMonth.startIndex,
                offsetBy: 7
            )
        ]
        // 月の十の位を抽出
        let tensPlace = month.prefix(1)
        
        if month != upperMonth {
            if tensPlace == "0" { // 月の十の位が0の場合は表示しない
                return "\(date[date.index(date.startIndex, offsetBy: 6)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
                
            } else {
                return "\(month)" // 「月」
            }
        } else {
            return "" // 注意：空白を代入しないと、変な値が入る。
        }
    }
    // 日付の9文字目にある日を抽出
    func pickupDay(date: String) -> String {
        let tensPlace = date[
            date.index(
                date.startIndex,
                offsetBy: 8
            )..<date.index(
                date.startIndex,
                offsetBy: 9
            )
        ] // 日付の9文字目にある日の十の位を抽出
        if tensPlace == "0" { // 日の十の位が0の場合は表示しない
            return "\(date.suffix(1))" // 末尾1文字の「日」         //日付
        } else {
            return "\(date.suffix(2))" // 末尾2文字の「日」         //日付
        }
    }
}
