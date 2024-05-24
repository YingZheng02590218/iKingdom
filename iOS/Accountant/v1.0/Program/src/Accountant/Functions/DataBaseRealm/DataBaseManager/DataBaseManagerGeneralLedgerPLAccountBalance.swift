//
//  DataBaseManagerGeneralLedgerPLAccountBalance.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/06.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 差引残高クラス　損益勘定用
class DataBaseManagerGeneralLedgerPLAccountBalance {

    public static let shared = DataBaseManagerGeneralLedgerPLAccountBalance()

    private init() {
    }
    // 損益振替仕訳
    var dataBaseTransferEntries: Results<DataBaseTransferEntry>!
    // 資本振替仕訳
    var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?

    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    // MARK: Update

    // 計算　差引残高
    func calculateBalance(dataBaseTransferEntries: Results<DataBaseTransferEntry>, dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?) {
        // 勘定名
        let account: String = "損益"
        // 参照先を渡す
        self.dataBaseTransferEntries = dataBaseTransferEntries
        self.dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry
        var left: Int64 = 0 // 差引残高 累積　勘定内の仕訳データを全て表示するまで、覚えておく
        var right: Int64 = 0
        // 損益振替仕訳
        print("損益振替仕訳", dataBaseTransferEntries.count, dataBaseTransferEntries)
        for i in 0..<dataBaseTransferEntries.count { // 勘定内のすべての損益振替仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseTransferEntries[i].debit_category)" { // 借方
                left += dataBaseTransferEntries[i].debit_amount // 累計額に追加
            } else if account == "\(dataBaseTransferEntries[i].credit_category)" { // 貸方
                right += dataBaseTransferEntries[i].credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseTransferEntries[i].balance_left = left - right // 差額を格納
                        dataBaseTransferEntries[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseTransferEntries[i].balance_left = 0
                        dataBaseTransferEntries[i].balance_right = right - left
                    } else {
                        dataBaseTransferEntries[i].balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseTransferEntries[i].balance_right = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 資本振替仕訳
        print("資本振替仕訳", dataBaseCapitalTransferJournalEntry)
        if let dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry {
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseCapitalTransferJournalEntry.debit_category)" { // 借方
                left += dataBaseCapitalTransferJournalEntry.debit_amount // 累計額に追加
            } else if account == "\(dataBaseCapitalTransferJournalEntry.credit_category)" { // 貸方
                right += dataBaseCapitalTransferJournalEntry.credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseCapitalTransferJournalEntry.balance_left = left - right // 差額を格納
                        dataBaseCapitalTransferJournalEntry.balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseCapitalTransferJournalEntry.balance_left = 0
                        dataBaseCapitalTransferJournalEntry.balance_right = right - left
                    } else {
                        dataBaseCapitalTransferJournalEntry.balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseCapitalTransferJournalEntry.balance_right = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }

    // MARK: Delete

}
