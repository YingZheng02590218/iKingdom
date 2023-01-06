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
    // 差引残高額
    var balanceAmount: Int64 = 0
    // 借又貸
    var balanceDebitOrCredit: String = ""

    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    // 取得　差引残高額　損益振替仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        if !dataBaseTransferEntries.isEmpty {
            let r = indexPath.row
            if dataBaseTransferEntries[r].balance_left > dataBaseTransferEntries[r].balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseTransferEntries[r].balance_left// - objects[r].balance_right
            } else if dataBaseTransferEntries[r].balance_right > dataBaseTransferEntries[r].balance_left {
                balanceAmount = dataBaseTransferEntries[r].balance_right// - objects[r].balance_left
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
        if !dataBaseTransferEntries.isEmpty {
            let r = indexPath.row
            if dataBaseTransferEntries[r].balance_left > dataBaseTransferEntries[r].balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseTransferEntries[r].balance_left < dataBaseTransferEntries[r].balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
        } else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }

    // 取得　差引残高額　 資本振替仕訳　損益勘定以外
    func getBalanceAmountCapitalTransferJournalEntry() -> Int64 {
        if let dataBaseAdjustingEntries = dataBaseCapitalTransferJournalEntry {
            if dataBaseAdjustingEntries.balance_left > dataBaseAdjustingEntries.balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseAdjustingEntries.balance_left// - objects.balance_right
            } else if dataBaseAdjustingEntries.balance_right > dataBaseAdjustingEntries.balance_left {
                balanceAmount = dataBaseAdjustingEntries.balance_right// - objects.balance_left
            } else {
                balanceAmount = 0
            }
        } else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得 資本振替仕訳
    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String {
        if let dataBaseAdjustingEntries = dataBaseCapitalTransferJournalEntry {
            if dataBaseAdjustingEntries.balance_left > dataBaseAdjustingEntries.balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseAdjustingEntries.balance_left < dataBaseAdjustingEntries.balance_right {
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
    func calculateBalance(dataBaseTransferEntries: Results<DataBaseTransferEntry>, dataBaseAdjustingEntries: DataBaseCapitalTransferJournalEntry?) {
        // 勘定名
        let account: String = "損益"
        // 参照先を渡す
        self.dataBaseTransferEntries = dataBaseTransferEntries
        self.dataBaseCapitalTransferJournalEntry = dataBaseAdjustingEntries
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
        print("資本振替仕訳", dataBaseAdjustingEntries)
        if let dataBaseAdjustingEntries = dataBaseAdjustingEntries {
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseAdjustingEntries.debit_category)" { // 借方
                left += dataBaseAdjustingEntries.debit_amount // 累計額に追加
            } else if account == "\(dataBaseAdjustingEntries.credit_category)" { // 貸方
                right += dataBaseAdjustingEntries.credit_amount // 累計額に追加
            }
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseAdjustingEntries.balance_left = left - right // 差額を格納
                        dataBaseAdjustingEntries.balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseAdjustingEntries.balance_left = 0
                        dataBaseAdjustingEntries.balance_right = right - left
                    } else {
                        dataBaseAdjustingEntries.balance_left = 0 // ゼロを入れないと前回値が残る
                        dataBaseAdjustingEntries.balance_right = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }

    // MARK: Delete

}
