//
//  DataBaseManagerGeneralLedgerAccountBalance.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 差引残高クラス
class DataBaseManagerGeneralLedgerAccountBalance {
    
    public static let shared = DataBaseManagerGeneralLedgerAccountBalance()
    
    private init() {
    }
    // 開始仕訳　OpeningJournalEntry
    var dataBaseOpeningJournalEntry: DataBaseOpeningJournalEntry?
    // 仕訳
    var dataBaseJournalEntries: Results<DataBaseJournalEntry>!
    // 決算整理仕訳　勘定別
    var dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>!
    // 資本振替仕訳
    var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // MARK: Update
    
    // 計算　差引残高
    func calculateBalance(
        account: String,
        dataBaseOpeningJournalEntry: DataBaseOpeningJournalEntry?,
        databaseJournalEntries: Results<DataBaseJournalEntry>,
        dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>,
        dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    ) {
        // 参照先を渡す
        self.dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry
        self.dataBaseJournalEntries = databaseJournalEntries
        self.dataBaseAdjustingEntries = dataBaseAdjustingEntries
        self.dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry
        var left: Int64 = 0 // 差引残高 累積　勘定内の仕訳データを全て表示するまで、覚えておく
        var right: Int64 = 0
        
        // 開始仕訳
        print("開始仕訳", dataBaseOpeningJournalEntry)
        if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
            // 勘定が借方と貸方のどちらか
            if account == dataBaseOpeningJournalEntry.debit_category || dataBaseOpeningJournalEntry.debit_category == "資本金勘定" { // 借方
                left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
            } else if account == dataBaseOpeningJournalEntry.credit_category || dataBaseOpeningJournalEntry.credit_category == "資本金勘定" { // 貸方
                right += dataBaseOpeningJournalEntry.credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseOpeningJournalEntry.balance_left = left - right // 差額を格納
                        dataBaseOpeningJournalEntry.balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseOpeningJournalEntry.balance_left = 0
                        dataBaseOpeningJournalEntry.balance_right = right - left
                    } else {
                        dataBaseOpeningJournalEntry.balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseOpeningJournalEntry.balance_right = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 仕訳
        print("仕訳", dataBaseJournalEntries.count, dataBaseJournalEntries)
        for i in 0..<dataBaseJournalEntries.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseJournalEntries[i].debit_category)" { // 借方
                left += dataBaseJournalEntries[i].debit_amount // 累計額に追加
            } else if account == "\(dataBaseJournalEntries[i].credit_category)" { // 貸方
                right += dataBaseJournalEntries[i].credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseJournalEntries[i].balance_left = left - right // 差額を格納
                        dataBaseJournalEntries[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseJournalEntries[i].balance_left = 0
                        dataBaseJournalEntries[i].balance_right = right - left
                    } else {
                        dataBaseJournalEntries[i].balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseJournalEntries[i].balance_right = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 決算整理仕訳　勘定別　注意：損益勘定を含めないとエラーになる
        print("決算整理仕訳", dataBaseAdjustingEntries.count, dataBaseAdjustingEntries)
        for i in 0..<dataBaseAdjustingEntries.count { // 勘定内のすべての決算整理仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseAdjustingEntries[i].debit_category)" { // 借方
                left += dataBaseAdjustingEntries[i].debit_amount // 累計額に追加
            } else if account == "\(dataBaseAdjustingEntries[i].credit_category)" { // 貸方
                right += dataBaseAdjustingEntries[i].credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseAdjustingEntries[i].balance_left = left - right // 差額を格納
                        dataBaseAdjustingEntries[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseAdjustingEntries[i].balance_left = 0
                        dataBaseAdjustingEntries[i].balance_right = right - left
                    } else {
                        dataBaseAdjustingEntries[i].balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseAdjustingEntries[i].balance_right = 0
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
            if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.debit_category)" { // 借方
                left += dataBaseCapitalTransferJournalEntry.debit_amount // 累計額に追加
            } else if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.credit_category)" { // 貸方
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
