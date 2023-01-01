//
//  DataBaseManagerPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益勘定クラス
class DataBaseManagerPLAccount {

    public static let shared = DataBaseManagerPLAccount()

    private init() {
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　決算振替仕訳　損益振替仕訳をする
    // 引数：日付、借方勘定、勘定残高額借方、貸方勘定、勘定残高貸方、小書き
    func addTransferEntry(debitCategory: String, amount: Int64, creditCategory: String) {
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debitCategory == "損益勘定" {
            account = creditCategory
        } else if creditCategory == "損益勘定" {
            account = debitCategory
        }
        if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          // 仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            dataBaseJournalEntry.fiscalYear = dataBaseAccountingBook.fiscalYear                        // 年度
            // 決算日
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var fiscalYearFixed = ""
            if theDayOfReckoning == "12/31" {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear)
            } else {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear + 1)
            }
            
            dataBaseJournalEntry.date = fiscalYearFixed + "/" + theDayOfReckoning
            dataBaseJournalEntry.debit_category = creditCategory    // 借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        // 借方金額
            dataBaseJournalEntry.credit_category = debitCategory  // 貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      // 貸方金額
            dataBaseJournalEntry.smallWritting = "損益振替仕訳"      // 小書き
            // 損益振替仕訳　が1件超が存在する場合は　削除
            let objects = checkAdjustingEntry(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objects.count > 1 {
            for i in 0..<objects.count {
                let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[i].number)
                print("削除", isInvalidated, objects.count)
                continue outerLoop
            }
            break
        }
            let objectss = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objectss.count > 1 {
            for i in 0..<objectss.count {
                let isInvalidated = removeAdjustingJournalEntry(primaryKey: objectss[i].number)
                print("関連削除", isInvalidated, objectss.count)
                continue outerLoop
            }
            break
        }
            if objects.count >= 1 {
                // 損益振替仕訳　が存在する場合は　更新
                if amount != 0 {
                    number = updateAdjustingJournalEntry(
                        primaryKey: objects[0].number,
                        date: dataBaseJournalEntry.date,
                        debitCategory: dataBaseJournalEntry.debit_category,
                        debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                        creditCategory: dataBaseJournalEntry.credit_category,
                        creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                        smallWritting: dataBaseJournalEntry.smallWritting
                    )
                } else { // 貸借が0の場合　削除する
                    let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[0].number)
                    print(isInvalidated)
                }
            } else {
                // 損益振替仕訳　が存在しない場合は　作成
                if amount != 0 {
                    do {
                        number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                        print(number)
                        try DataBaseManager.realm.write {
                            // 仕訳帳に仕訳データを追加
                            dataBaseAccountingBook.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        }
                        // 勘定へ転記 // オブジェクトを作成
                        if let objectss = dataBaseAccountingBook.dataBaseGeneralLedger {
                            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                            for i in 0..<objectss.dataBaseAccounts.count {
                                print(objectss.dataBaseAccounts[i].accountName, account)
                                if objectss.dataBaseAccounts[i].accountName == account {
                                    try DataBaseManager.realm.write {
                                        // 勘定に借方の仕訳データを追加
                                        dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                                    }
                                    break
                                }
                            }
                        }
                        try DataBaseManager.realm.write {
                            // 勘定に貸方の仕訳データを追加
                            dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    
    // 追加　決算振替仕訳　資本振替
    // 引数：日付、借方勘定、金額、貸方勘定
    func addTransferEntryToNetWorth(debitCategory: String, amount: Int64, creditCategory: String) {
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debitCategory == "損益勘定" {
            account = creditCategory
        } else if creditCategory == "損益勘定" {
            account = debitCategory
        }
        if account == "繰越利益" {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          // 仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            dataBaseJournalEntry.fiscalYear = dataBaseAccountingBook.fiscalYear                       // 年度
            // 決算日
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var fiscalYearFixed = ""
            if theDayOfReckoning == "12/31" {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear)
            } else {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear + 1)
            }
            dataBaseJournalEntry.date = fiscalYearFixed + "/" + theDayOfReckoning
            dataBaseJournalEntry.debit_category = creditCategory    // 借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        // 借方金額
            dataBaseJournalEntry.credit_category = debitCategory  // 貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      // 貸方金額
            dataBaseJournalEntry.smallWritting = "資本振替仕訳"
            // 損益振替仕訳　が1件超が存在する場合は　削除
            let objects = checkAdjustingEntry(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objects.count > 1 {
            for i in 0..<objects.count {
                let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[i].number)
                print("削除", isInvalidated, objects.count)
                continue outerLoop
            }
            break
        }
            let objectss = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objectss.count > 1 {
            for i in 0..<objectss.count {
                let isInvalidated = removeAdjustingJournalEntry(primaryKey: objectss[i].number)
                print("関連削除", isInvalidated, objectss.count)
                continue outerLoop
            }
            break
        }
            if objects.count == 1 {
                // 資本振替仕訳　が存在する場合は　更新
                number = updateAdjustingJournalEntry(
                    primaryKey: objects[0].number,
                    date: dataBaseJournalEntry.date,
                    debitCategory: dataBaseJournalEntry.debit_category,
                    debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                    creditCategory: dataBaseJournalEntry.credit_category,
                    creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                    smallWritting: dataBaseJournalEntry.smallWritting
                )
            } else {
                // 資本振替仕訳　が存在しない場合は　作成
                if amount != 0 {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    print(number)
                    do {
                        try DataBaseManager.realm.write {
                            // 仕訳帳に仕訳データを追加
                            dataBaseAccountingBook.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        }
                        // 勘定へ転記 // オブジェクトを作成
                        // 勘定に借方の仕訳データを追加
                        if let objectss = dataBaseAccountingBook.dataBaseGeneralLedger {
                            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                            for i in 0..<objectss.dataBaseAccounts.count where
                            objectss.dataBaseAccounts[i].accountName == account {
                                print(objectss.dataBaseAccounts[i].accountName, account)
                                
                                try DataBaseManager.realm.write {
                                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                                }
                                break
                            }
                        }
                        try DataBaseManager.realm.write {
                            // 勘定に貸方の仕訳データを追加
                            dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    
    // MARK: Read
    
    // チェック 決算整理仕訳　存在するかを確認
    func checkAdjustingEntry(account: String) -> Results<DataBaseAdjustingEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
        return objects
    }
    // チェック 決算整理仕訳　損益勘定内の勘定が存在するかを確認
    func checkAdjustingEntryInPLAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let objects = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries
            .sorted(byKeyPath: "date", ascending: true)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
        return objects!
    }
    
    // MARK: Update
    
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        // 編集前の借方勘定と貸方勘定をメモする
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date,
                    "debit_category": debitCategory,
                    "debit_amount": debitAmount,
                    "credit_category": creditCategory,
                    "credit_amount": creditAmount,
                    "smallWritting": smallWritting
                ]
                DataBaseManager.realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    
    // 削除　決算整理仕訳 損益振替仕訳
    func deleteAdjustingJournalEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: primaryKey) else { return false }
        // 削除前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益勘定" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "損益勘定" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: "損益勘定", fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 仕訳帳から削除前仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<oldLeftObject.dataBaseAdjustingEntries.count where oldLeftObject.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<dataBasePLAccount.dataBaseAdjustingEntries.count where dataBasePLAccount.dataBaseAdjustingEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    dataBasePLAccount.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
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
                    // 仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    
    // 関連削除　決算整理仕訳 損益振替仕訳
    func removeAdjustingJournalEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: primaryKey) else { return false }
        // 削除前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益勘定" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "損益勘定" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: "損益勘定", fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 仕訳帳から削除前仕訳データの関連を削除
    outerLoop: while oldJournals.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                    print(oldJournals.dataBaseAdjustingEntries.count)
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while oldLeftObject.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<oldLeftObject.dataBaseAdjustingEntries.count where oldLeftObject.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                    print(oldLeftObject.dataBaseAdjustingEntries.count)
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while dataBasePLAccount.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<dataBasePLAccount.dataBaseAdjustingEntries.count where dataBasePLAccount.dataBaseAdjustingEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    dataBasePLAccount.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                    print(dataBasePLAccount.dataBaseAdjustingEntries.count)
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        if !dataBaseJournalEntry.isInvalidated {
            
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
