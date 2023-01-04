//
//  DataBaseAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 勘定クラス
// 勘定 は 仕訳データ を 1 つ以上持っています。
class DataBaseAccount: RObject {
    convenience init(
        fiscalYear: Int,
        accountName: String,

        debit_total: Int64,
        credit_total: Int64,
        debit_balance: Int64,
        credit_balance: Int64,

        debit_total_Adjusting: Int64,
        credit_total_Adjusting: Int64,
        debit_balance_Adjusting: Int64,
        credit_balance_Adjusting: Int64,

        debit_total_AfterAdjusting: Int64,
        credit_total_AfterAdjusting: Int64,
        debit_balance_AfterAdjusting: Int64,
        credit_balance_AfterAdjusting: Int64
    ) {
        self.init()

        self.fiscalYear = fiscalYear
        self.accountName = accountName

        self.debit_total = debit_total
        self.credit_total = credit_total
        self.debit_balance = debit_balance
        self.credit_balance = credit_balance

        self.debit_total_Adjusting = debit_total_Adjusting
        self.credit_total_Adjusting = credit_total_Adjusting
        self.debit_balance_Adjusting = debit_balance_Adjusting
        self.credit_balance_Adjusting = credit_balance_Adjusting

        self.debit_total_AfterAdjusting = debit_total_AfterAdjusting
        self.credit_total_AfterAdjusting = credit_total_AfterAdjusting
        self.debit_balance_AfterAdjusting = debit_balance_AfterAdjusting
        self.credit_balance_AfterAdjusting = credit_balance_AfterAdjusting
    }

    @objc dynamic var fiscalYear: Int = 0                      // 年度
    @objc dynamic var accountName: String = ""                // 勘定名
    // 決算整理前
    let dataBaseJournalEntries = List<DataBaseJournalEntry>() // 仕訳
    @objc dynamic var debit_total: Int64 = 0           // 借方合計
    @objc dynamic var credit_total: Int64 = 0          // 貸方
    @objc dynamic var debit_balance: Int64 = 0         // 借方残高
    @objc dynamic var credit_balance: Int64 = 0        // 貸方
    // 決算整理仕訳
    let dataBaseAdjustingEntries = List<DataBaseAdjustingEntry>() // 決算整理仕訳
    @objc dynamic var debit_total_Adjusting: Int64 = 0           // 借方合計
    @objc dynamic var credit_total_Adjusting: Int64 = 0          // 貸方
    @objc dynamic var debit_balance_Adjusting: Int64 = 0         // 借方残高
    @objc dynamic var credit_balance_Adjusting: Int64 = 0        // 貸方
    // 決算整理後
    @objc dynamic var debit_total_AfterAdjusting: Int64 = 0           // 借方合計
    @objc dynamic var credit_total_AfterAdjusting: Int64 = 0          // 貸方
    @objc dynamic var debit_balance_AfterAdjusting: Int64 = 0         // 借方残高
    @objc dynamic var credit_balance_AfterAdjusting: Int64 = 0        // 貸方
}
