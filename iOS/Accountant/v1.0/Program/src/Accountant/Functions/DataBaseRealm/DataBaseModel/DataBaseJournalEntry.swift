//
//  JournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳クラス
class DataBaseJournalEntry: RObject {
//    // initを使用することでイニシャライザ定義
//    init(date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, balance_left: Int64, balance_right: Int64) {
//        self.date = date
//        self.debit_category = debit_category
//        self.debit_amount = debit_amount
//        self.credit_category = credit_category
//        self.credit_amount = credit_amount
//        self.smallWritting = smallWritting
//    }
    // モデル定義
    // @objc dynamic var number: Int = 0                 // 仕訳番号
    @objc dynamic var fiscalYear: Int = 0               // 年度
    @objc dynamic var date: String = ""                 // 日付
    @objc dynamic var debit_category: String = ""       // 借方勘定
    @objc dynamic var debit_amount: Int64 = 0           // 借方金額
    @objc dynamic var credit_category: String = ""      // 貸方勘定
    @objc dynamic var credit_amount: Int64 = 0          // 貸方金額
    @objc dynamic var smallWritting: String = ""        // 小書き
    @objc dynamic var balance_left: Int64 = 0           // 差引残高
    @objc dynamic var balance_right: Int64 = 0          // 差引残高
}
