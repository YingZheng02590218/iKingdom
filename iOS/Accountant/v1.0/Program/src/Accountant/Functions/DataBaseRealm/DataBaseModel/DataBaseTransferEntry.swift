//
//  DataBaseTransferEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/03.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// 損益振替仕訳クラス、残高振替仕訳クラス 決算振替仕訳
// 仕訳クラス　と　クラス名が違うだけでその他は同じ
class DataBaseTransferEntry: DataBaseJournalEntry {

}
// 月次残高振替仕訳
class DataBaseMonthlyTransferEntry: DataBaseJournalEntry {
    // 月次の借方合計金額として使用する
    // @objc dynamic var debit_category: String = ""       // 借方勘定
    // @objc dynamic var debit_amount: Int64 = 0           // 借方金額
    // 月次の貸方合計金額として使用する
    // @objc dynamic var credit_category: String = ""      // 貸方勘定
    // @objc dynamic var credit_amount: Int64 = 0          // 貸方金額
    // 月次の残高振替として使用する　次月繰越
    // @objc dynamic var balance_left: Int64 = 0           // 差引残高
    // @objc dynamic var balance_right: Int64 = 0          // 差引残高
}
// 設定残高振替仕訳クラス 開始残高で使用する
class DataBaseSettingTransferEntry: DataBaseJournalEntry {

}
