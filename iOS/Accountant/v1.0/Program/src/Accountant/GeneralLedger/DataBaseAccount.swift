//
//  DataBaseAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 勘定クラス
// 勘定 は 仕訳データ を 1 つ以上持っています。
class DataBaseAccount: RObject {
    @objc dynamic var accountName: String = ""                // 勘定名
    let dataBaseJournalEntries = List<DataBaseJournalEntry>() //一対多の関連
    @objc dynamic var debit_total: Int64 = 0           //借方合計
    @objc dynamic var credit_total: Int64 = 0          //貸方合計
    @objc dynamic var debit_balance: Int64 = 0         //借方残高
    @objc dynamic var credit_balance: Int64 = 0        //貸方残高
}
