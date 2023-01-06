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
    // 仕訳
    var dataBaseJournalEntries: Results<DataBaseJournalEntry>!
    // 決算整理仕訳　勘定別
    var dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>!
    // 差引残高額
    var balanceAmount: Int64 = 0
    // 借又貸
    var balanceDebitOrCredit: String = ""
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        if !dataBaseJournalEntries.isEmpty {
            let r = indexPath.row
            if dataBaseJournalEntries[r].balance_left > dataBaseJournalEntries[r].balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseJournalEntries[r].balance_left// - objects[r].balance_right
            } else if dataBaseJournalEntries[r].balance_right > dataBaseJournalEntries[r].balance_left {
                balanceAmount = dataBaseJournalEntries[r].balance_right// - objects[r].balance_left
            } else {
                balanceAmount = 0
            }
        } else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {
        if !dataBaseJournalEntries.isEmpty {
            let r = indexPath.row
            if dataBaseJournalEntries[r].balance_left > dataBaseJournalEntries[r].balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseJournalEntries[r].balance_left < dataBaseJournalEntries[r].balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
        } else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    
    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        if !dataBaseAdjustingEntries.isEmpty {
            let r = indexPath.row
            if dataBaseAdjustingEntries[r].balance_left > dataBaseAdjustingEntries[r].balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseAdjustingEntries[r].balance_left// - objects[r].balance_right
            } else if dataBaseAdjustingEntries[r].balance_right > dataBaseAdjustingEntries[r].balance_left {
                balanceAmount = dataBaseAdjustingEntries[r].balance_right// - objects[r].balance_left
            } else {
                balanceAmount = 0
            }
        } else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {
        if !dataBaseAdjustingEntries.isEmpty {
            let r = indexPath.row
            if dataBaseAdjustingEntries[r].balance_left > dataBaseAdjustingEntries[r].balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseAdjustingEntries[r].balance_left < dataBaseAdjustingEntries[r].balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
        } else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    
    // MARK: Update
    
    // 計算　差引残高
    func calculateBalance(account: String, databaseJournalEntries: Results<DataBaseJournalEntry>, dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>) {
        // 参照先を渡す
        self.dataBaseJournalEntries = databaseJournalEntries
        self.dataBaseAdjustingEntries = dataBaseAdjustingEntries
        var left: Int64 = 0 // 差引残高 累積　勘定内の仕訳データを全て表示するまで、覚えておく
        var right: Int64 = 0
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
    }
    
    // MARK: Delete
    
}
