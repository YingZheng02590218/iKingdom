//
//  OpeningBalanceModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol OpeningBalanceModelInput {
    func createOpeningBalance()
    func calculateAccountTotalAccount()

    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit)

    func getTotalAmount(leftOrRight: Int) -> Int64
    func getDataBaseTransferEntries() -> Results<SettingDataBaseTransferEntry>
}

// 繰越試算表クラス
class OpeningBalanceModel: OpeningBalanceModelInput {

    // MARK: - CRUD

    // MARK: Create

    // 開始残高　残高振替仕訳をつくる
    func createOpeningBalance() {
        guard let dataBaseAccountingBooksShelf = RealmManager.shared.readWithPrimaryKey(
            type: DataBaseAccountingBooksShelf.self,
            key: 1
        ) else { return }

        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0) // 貸借対照表　資産 負債 純資産
        if let dataBaseOpeningBalanceAccount = DataBaseManagerAccountingBooksShelf.shared.getOpeningBalanceAccount() {
            // 開始残高勘定がある場合
        } else {
            // 開始残高勘定がない場合
            // オブジェクトを作成 開始残高勘定
            let dataBaseAccount = DataBaseOpeningBalanceAccount(
                fiscalYear: 0,
                accountName: "開始残高",
                debit_total: 0,
                credit_total: 0,
                debit_balance: 0,
                credit_balance: 0,
                debit_total_Adjusting: 0,
                credit_total_Adjusting: 0,
                debit_balance_Adjusting: 0,
                credit_balance_Adjusting: 0,
                debit_total_AfterAdjusting: 0,
                credit_total_AfterAdjusting: 0,
                debit_balance_AfterAdjusting: 0,
                credit_balance_AfterAdjusting: 0
            )
            let numberr = dataBaseAccount.save() //　自動採番
            print("dataBaseOpeningBalanceAccount", numberr)

            do {
                try DataBaseManager.realm.write {

                    dataBaseAccountingBooksShelf.dataBaseOpeningBalanceAccount = dataBaseAccount
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 開始残高勘定がある場合
        if let dataBaseOpeningBalanceAccount = DataBaseManagerAccountingBooksShelf.shared.getOpeningBalanceAccount() {
            // 設定勘定科目　貸借科目
            for dataBaseSettingsTaxonomyAccount in dataBaseSettingsTaxonomyAccounts {
                // 設定残高振替仕訳 が存在するか
                let dataBaseTransferEntries = dataBaseOpeningBalanceAccount.dataBaseTransferEntries
                    .filter("debit_category LIKE '\(dataBaseSettingsTaxonomyAccount.category)' || credit_category LIKE '\(dataBaseSettingsTaxonomyAccount.category)'")

                if dataBaseTransferEntries.count == 1 {
                    // 正常
                    print(dataBaseTransferEntries)
                } else if dataBaseTransferEntries.count > 1 {
                    // 設定開始仕訳　が1件超が存在する場合は　削除
                outerLoop: while dataBaseTransferEntries.count > 1 {
                    for i in 0..<dataBaseTransferEntries.count {
                        let isInvalidated = deleteSettingDataBaseTransferEntry(primaryKey: dataBaseTransferEntries[i].number)
                        print("関連削除", isInvalidated, dataBaseTransferEntries.count)
                        continue outerLoop
                    }
                    break
                }
                } else {
                    // 設定残高振替仕訳
                    let dataBaseJournalEntry = SettingDataBaseTransferEntry(
                        fiscalYear: 0,
                        date: "",
                        debit_category: dataBaseSettingsTaxonomyAccount.category,
                        debit_amount: 0,
                        credit_category: "残高",
                        credit_amount: 0,
                        smallWritting: "",
                        balance_left: 0,
                        balance_right: 0
                    )
                    let numberr = dataBaseJournalEntry.save() //　自動採番
                    print("SettingDataBaseTransferEntry", numberr)

                    do {
                        try DataBaseManager.realm.write {

                            dataBaseAccountingBooksShelf.dataBaseOpeningBalanceAccount?.dataBaseTransferEntries.append(dataBaseJournalEntry)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }

    // MARK: Read

    func getDataBaseTransferEntries() -> Results<SettingDataBaseTransferEntry> {
        DataBaseManagerAccountingBooksShelf.shared.getTransferEntriesInOpeningBalanceAccount()
    }

    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        if let dataBaseOpeningBalanceAccount = DataBaseManagerAccountingBooksShelf.shared.getOpeningBalanceAccount() {
            switch leftOrRight {
            case 0: // 合計　借方
                result = dataBaseOpeningBalanceAccount.debit_total
            case 1: // 合計　貸方
                result = dataBaseOpeningBalanceAccount.credit_total
            case 2: // 残高　借方
                result = dataBaseOpeningBalanceAccount.debit_balance
            case 3: // 残高　貸方
                result = dataBaseOpeningBalanceAccount.credit_balance
            default:
                print("getTotalAmount 資本金勘定")
            }
        }
        return result
    }

    // MARK: Update

    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit) {
        DataBaseManagerAccountingBooksShelf.shared.updateJournalEntry(
            primaryKey: primaryKey,
            debitCategory: debitOrCredit == .debit ? "残高" : category,
            debitAmount: numbersOnDisplay,
            creditCategory: debitOrCredit == .credit ? "残高" : category,
            creditAmount: numbersOnDisplay,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                //                completion(primaryKey)
            }
        )
    }
    // 開始残高勘定クラス　勘定別に仕訳データを集計
    internal func calculateAccountTotalAccount() {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0

        let objects = DataBaseManagerAccountingBooksShelf.shared.getTransferEntriesInOpeningBalanceAccount()
        for i in 0..<objects.count {
            // 勘定が借方と貸方のどちらか
            if objects[i].debit_category == "残高" {
                left += objects[i].debit_amount // 累計額に追加
            } else if objects[i].credit_category == "残高" {
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        if let dataBaseOpeningBalanceAccount = DataBaseManagerAccountingBooksShelf.shared.getOpeningBalanceAccount() {
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseOpeningBalanceAccount.debit_total = left
                        dataBaseOpeningBalanceAccount.credit_total = right
                        dataBaseOpeningBalanceAccount.debit_balance = left - right // 差額を格納
                        dataBaseOpeningBalanceAccount.credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseOpeningBalanceAccount.debit_total = left
                        dataBaseOpeningBalanceAccount.credit_total = right
                        dataBaseOpeningBalanceAccount.debit_balance = 0
                        dataBaseOpeningBalanceAccount.credit_balance = right - left
                    } else {
                        dataBaseOpeningBalanceAccount.debit_total = left
                        dataBaseOpeningBalanceAccount.credit_total = right
                        dataBaseOpeningBalanceAccount.debit_balance = 0 // ゼロを入れないと前回値が残る
                        dataBaseOpeningBalanceAccount.credit_balance = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }

    // MARK: Delete
    // 削除 設定残高振替仕訳
    func deleteSettingDataBaseTransferEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: SettingDataBaseTransferEntry.self, key: primaryKey) else { return false }
        var account: String = "" // 相手勘定
        if dataBaseJournalEntry.debit_category == "残高" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "残高" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseOpeningBalanceAccount = DataBaseManagerAccountingBooksShelf.shared.getOpeningBalanceAccount() else {
            return false
        }
        // 開始残高勘定から設定残高振替仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeftObject.dataBaseTransferEntries.count where oldLeftObject.dataBaseTransferEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseTransferEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseTransferEntries.remove(at: i)
                }
            } catch {
                print("エラーが発生しました")
            }

            continue outerLoop
        }
        break
    }

        if !dataBaseJournalEntry.isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    // 設定残高振替仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }

}
