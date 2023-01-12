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
    
    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して損益勘定を取得する
     * @param  年度
     */
    func getPLAccountByFiscalYear(fiscalYear: Int) -> DataBasePLAccount? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
        return dataBaseAccount
    }
    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して資本金勘定を取得する
     * @param  年度
     */
    func getCapitalAccountByFiscalYear(fiscalYear: Int) -> DataBaseCapitalAccount? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
        return dataBaseAccount
    }
    
    // MARK: - 決算整理仕訳 ※旧損益振替仕訳（損益勘定）
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    // チェック 決算整理仕訳　存在するかを確認 ※旧損益振替仕訳（損益勘定）
    func checkAdjustingEntry(account: String) -> Results<DataBaseAdjustingEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
        return objects
    }
    // チェック 決算整理仕訳　損益勘定内の勘定が存在するかを確認 ※旧損益振替仕訳（損益勘定）
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
    
    // MARK: Delete
    // 削除　決算整理仕訳 損益振替仕訳 ※旧損益振替仕訳（損益勘定）
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
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: "損益", fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
    // 関連削除　決算整理仕訳 損益振替仕訳 ※旧損益振替仕訳（損益勘定）
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
    
    // MARK: - 損益振替仕訳
    
    // MARK: - CRUD
    
    // MARK: Create
    // 追加　決算振替仕訳　損益振替仕訳をする
    // 引数：借方勘定、勘定残高額借方、貸方勘定
    func addTransferEntry(debitCategory: String, amount: Int64, creditCategory: String) {
        var account: String = "" // 損益振替の相手勘定
        if debitCategory == "損益" {
            account = creditCategory
        } else if creditCategory == "損益" {
            account = debitCategory
        }
        // 損益計算書に関する勘定科目のみに絞る
        if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            var number = 0 // 仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            // 決算日
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var fiscalYearFixed = ""
            if theDayOfReckoning == "12/31" {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear)
            } else {
                fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear + 1)
            }
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseTransferEntry(
                fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
                date: fiscalYearFixed + "/" + theDayOfReckoning,
                debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
                debit_amount: amount, // 借方金額
                credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
                credit_amount: amount, // 貸方金額
                smallWritting: "損益振替仕訳", // 小書き
                balance_left: 0,
                balance_right: 0
            )
            // 損益振替仕訳　が1件超が存在する場合は　削除
            let objects = checkTransferEntry(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objects.count > 1 {
            for i in 0..<objects.count {
                let isInvalidated = deleteTransferEntry(primaryKey: objects[i].number)
                print("削除", isInvalidated, objects.count)
                continue outerLoop
            }
            break
        }
            let objectss = checkTransferEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objectss.count > 1 {
            for i in 0..<objectss.count {
                let isInvalidated = removeTransferEntry(primaryKey: objectss[i].number)
                print("関連削除", isInvalidated, objectss.count)
                continue outerLoop
            }
            break
        }
            if objects.count == 1 {
                // リレーションが正しくない場合、一旦、資本振替仕訳を削除する
                do {
                    // 金額
                    if amount != 0 {
                        // 更新する
                    } else {
                        // 損益振替仕訳　が1件以上が存在する場合は　削除
                        let objects = checkTransferEntry(account: account) // 損益勘定内に勘定が存在するか
                    outerLoop: while objects.count >= 1 {
                        for i in 0..<objects.count {
                            let isInvalidated = deleteTransferEntry(primaryKey: objects[i].number)
                            print("削除", isInvalidated, objects.count)
                            continue outerLoop
                        }
                        break
                    }
                        let objectss = checkTransferEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
                    outerLoop: while objectss.count >= 1 {
                        for i in 0..<objectss.count {
                            let isInvalidated = removeTransferEntry(primaryKey: objectss[i].number)
                            print("関連削除", isInvalidated, objectss.count)
                            continue outerLoop
                        }
                        break
                    }
                    }
                }
            }
            if objects.count >= 1 {
                // 損益振替仕訳　が存在する場合は　更新
                number = updateTransferEntry(
                    primaryKey: objects[0].number,
                    date: dataBaseJournalEntry.date,
                    debitCategory: dataBaseJournalEntry.debit_category,
                    debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                    creditCategory: dataBaseJournalEntry.credit_category,
                    creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                    smallWritting: dataBaseJournalEntry.smallWritting
                )
            } else {
                // 損益振替仕訳　が存在しない場合は　作成
                if amount != 0 {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    print(number)
                    do {
                        // MARK: 損益振替仕訳は、仕訳帳には追加しない。
                        // 相手方の勘定
                        if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
                            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                try DataBaseManager.realm.write {
                                    // 損益振替仕訳データを代入
                                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseTransferEntry = dataBaseJournalEntry
                                }
                                break
                            }
                        }
                        // 損益勘定
                        try DataBaseManager.realm.write {
                            // 損益振替仕訳データを代入
                            dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseTransferEntries.append(dataBaseJournalEntry)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    // 追加　決算振替仕訳　残高振替仕訳をする closingBalanceAccount
    func addTransferEntryForClosingBalanceAccount(debitCategory: String, amount: Int64, creditCategory: String) {
        var account: String = "" // 残高振替の相手勘定
        if debitCategory == "残高" {
            account = creditCategory
        } else if creditCategory == "残高" {
            account = debitCategory
        }
        var number = 0 // 仕訳番号 自動採番にした
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        var fiscalYearFixed = ""
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear)
        } else {
            fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear + 1)
        }
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseTransferEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: fiscalYearFixed + "/" + theDayOfReckoning,
            debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
            debit_amount: amount, // 借方金額
            credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
            credit_amount: amount, // 貸方金額
            smallWritting: "残高振替仕訳", // 小書き
            balance_left: 0,
            balance_right: 0
        )
        // 取得　残高振替仕訳 勘定別に取得
        if let dataBaseTransferEntry = DataBaseManagerAccount.shared.getTransferEntryInAccount(account: account) {
            // 残高振替仕訳　が存在する場合は　更新
            number = updateTransferEntry(
                primaryKey: dataBaseTransferEntry.number,
                date: dataBaseJournalEntry.date,
                debitCategory: dataBaseJournalEntry.debit_category,
                debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                creditCategory: dataBaseJournalEntry.credit_category,
                creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                smallWritting: dataBaseJournalEntry.smallWritting
            )
        } else {
            // 残高振替仕訳　が存在しない場合は　作成
            if amount != 0 {
                number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                print(number)
                do {
                    // MARK: 残高振替仕訳は、仕訳帳には追加しない。
                    // 相手方の勘定
                    if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
                        if account == "資本金勘定" {
                            try DataBaseManager.realm.write {
                                dataBaseGeneralLedger.dataBaseCapitalAccount?.dataBaseTransferEntry = dataBaseJournalEntry
                            }
                        } else {
                            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                try DataBaseManager.realm.write {
                                    // 損益振替仕訳データを代入
                                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseTransferEntry = dataBaseJournalEntry
                                }
                                break
                            }
                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }

    // MARK: Read
    // チェック 損益振替仕訳　存在するかを確認
    func checkTransferEntry(account: String) -> Results<DataBaseTransferEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseTransferEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益"))
        ])
        return objects
    }
    // チェック 損益振替仕訳　損益勘定内の勘定が存在するかを確認
    func checkTransferEntryInPLAccount(account: String) -> Results<DataBaseTransferEntry> {
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let objects = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseTransferEntries // 損益振替仕訳
            .sorted(byKeyPath: "date", ascending: true)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益")' || credit_category LIKE '\("損益")'")
        print(objects)
        return objects!
    }
    
    // MARK: Update
    // 更新 損益振替仕訳
    func updateTransferEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
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
                DataBaseManager.realm.create(DataBaseTransferEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    // 削除 損益振替仕訳
    func deleteTransferEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseTransferEntry.self, key: primaryKey) else { return false }
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "損益" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: "損益", fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 勘定から削除前損益振替仕訳データの関連を削除
        do {
            try DataBaseManager.realm.write {
                oldLeftObject.dataBaseTransferEntry = nil
            }
        } catch {
            print("エラーが発生しました")
        }
        
        // 損益勘定から削除前損益振替仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<dataBasePLAccount.dataBaseTransferEntries.count where dataBasePLAccount.dataBaseTransferEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseTransferEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    dataBasePLAccount.dataBaseTransferEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
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
                    // 損益振替仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    // 関連削除 損益振替仕訳
    func removeTransferEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseTransferEntry.self, key: primaryKey) else { return false }
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "損益" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: "損益", fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 勘定から削除前損益振替仕訳データの関連を削除
        do {
            try DataBaseManager.realm.write {
                oldLeftObject.dataBaseTransferEntry = nil
            }
        } catch {
            print("エラーが発生しました")
        }
        
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while dataBasePLAccount.dataBaseTransferEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益")' || credit_category LIKE '\("損益")'").count > 1 {
        for i in 0..<dataBasePLAccount.dataBaseTransferEntries.count where dataBasePLAccount.dataBaseTransferEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseTransferEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    dataBasePLAccount.dataBaseTransferEntries.remove(at: i) // 会計帳簿.総勘定元帳.損益勘定.損益振替仕訳リスト
                    print(dataBasePLAccount.dataBaseTransferEntries.count)
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
    
    // MARK: - 資本振替仕訳
    
    // MARK: - CRUD
    
    // MARK: Create
    // 追加　決算振替仕訳　資本振替仕訳をする
    // 引数：借方勘定、金額、貸方勘定
    func addTransferEntryToNetWorth(debitCategory: String, amount: Int64, creditCategory: String) {
        var number = 0 // 仕訳番号 自動採番にした
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        var fiscalYearFixed = ""
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear)
        } else {
            fiscalYearFixed = String(dataBaseAccountingBook.fiscalYear + 1)
        }
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseCapitalTransferJournalEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: fiscalYearFixed + "/" + theDayOfReckoning,
            debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
            debit_amount: amount, // 借方金額
            credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
            credit_amount: amount, // 貸方金額
            smallWritting: "資本振替仕訳", // 小書き
            balance_left: 0,
            balance_right: 0
        )
        
        // 資本振替仕訳　が1件超が存在する場合は　削除
        var objects = checkCapitalTransferJournalEntry()
    outerLoop: while objects.count > 1 {
        for i in 0..<objects.count {
            let isInvalidated = deleteCapitalTransferJournalEntry(primaryKey: objects[i].number)
            print("削除", isInvalidated, objects.count)
            continue outerLoop
        }
        break
    }
        if objects.count == 1 {
            // リレーションが正しくない場合、一旦、資本振替仕訳を削除する
            do {
                // 仕訳帳
                if dataBaseAccountingBook.dataBaseJournals?.dataBaseCapitalTransferJournalEntry != nil,
                   // 相手方の勘定
                   dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseCapitalAccount?.dataBaseCapitalTransferJournalEntry != nil,
                   // 損益勘定
                   dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseCapitalTransferJournalEntry != nil {
                    // 更新する
                } else {
                    // 資本振替仕訳　が1件以上が存在する場合は　削除
                    objects = checkCapitalTransferJournalEntry()
                outerLoop: while objects.count >= 1 {
                    for i in 0..<objects.count {
                        let isInvalidated = deleteCapitalTransferJournalEntry(primaryKey: objects[i].number)
                        print("削除", isInvalidated, objects.count)
                        continue outerLoop
                    }
                    break
                }
                }
            }
        }
        
        if objects.count == 1 {
            // 資本振替仕訳　が存在する場合は　更新
            number = updateCapitalTransferJournalEntry(
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
            number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
            print(number)
            //        ＜仕訳帳＞
            //        　　　――――――――――――――――――――――――――――――
            //        　　　（借）損　　　　　益　１２０　（貸）資　　本　　金　１２０
            //        　　　――――――――――――――――――――――――――――――
            //        ＜総勘定元帳の一部＞
            //        　　――――――――――――――――――――――――――――――――
            //        　　　　　　　　　　　　　　　　　　 　　　　資　本　金　　　　＋
            //        　　　　　　　　　　　　　　　　　　―――――――――――――――・
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜　　　　　××｜
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜　　　　　　　｜
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜―――――――・
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜　　　　１２０
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜
            //        　　　　　　　　　　　　　　　　　　 　　　　損　　　益　　　　＋
            //        　　　　　　　　　　　　　　　　　・―――――――――――――――・
            //        　　　　　　　　　　　　　　　　　｜合計　　６００｜合計　　７２０｜
            //        　　　　　　　　　　　　　　　　　・―――――――｜　　　　　　　｜
            //        　　　　　　　　　　　　　　　　　　　　　　１２０｜　　　　　　　｜
            //        　　　　　　　　　　　　　　　　　　　　　　　　　｜―――――――・
            //        　―――――――――――――――――――――――――――――――――
            do {
                // MARK: 仕訳帳 資本振替仕訳は、仕訳帳には追加する。
                try DataBaseManager.realm.write {
                    // 資本振替仕訳データを代入
                    dataBaseAccountingBook.dataBaseJournals?.dataBaseCapitalTransferJournalEntry = dataBaseJournalEntry
                }
                // 資本金勘定
                try DataBaseManager.realm.write {
                    // 資本振替仕訳データを代入
                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseCapitalAccount?.dataBaseCapitalTransferJournalEntry = dataBaseJournalEntry
                }
                // 損益勘定
                try DataBaseManager.realm.write {
                    // 資本振替仕訳データを代入
                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseCapitalTransferJournalEntry = dataBaseJournalEntry
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Read
    // チェック 資本振替仕訳　存在するかを確認
    func checkCapitalTransferJournalEntry() -> Results<DataBaseCapitalTransferJournalEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseCapitalTransferJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益"))
        ])
        print(objects)
        return objects
    }
    
    // MARK: Update
    // 更新 資本振替仕訳
    func updateCapitalTransferJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
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
                DataBaseManager.realm.create(DataBaseCapitalTransferJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    // 削除 資本振替仕訳
    func deleteCapitalTransferJournalEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseCapitalTransferJournalEntry.self, key: primaryKey) else { return false }
        // 資本金勘定
        guard let oldLeftObject: DataBaseCapitalAccount = DataBaseManagerPLAccount.shared.getCapitalAccountByFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        guard let dataBasePLAccount: DataBasePLAccount = DataBaseManagerPLAccount.shared.getPLAccountByFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 資本金勘定　から削除前資本振替仕訳データの関連を削除
        do {
            try DataBaseManager.realm.write {
                oldLeftObject.dataBaseCapitalTransferJournalEntry = nil
            }
        } catch {
            print("エラーが発生しました")
        }
        
        // 損益勘定から削除前資本振替仕訳データの関連を削除
        do {
            try DataBaseManager.realm.write {
                dataBasePLAccount.dataBaseCapitalTransferJournalEntry = nil
            }
        } catch {
            print("エラーが発生しました")
        }
        
        if !dataBaseJournalEntry.isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    // 資本振替仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    
}
