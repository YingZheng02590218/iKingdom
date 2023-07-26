//
//  DataBaseManagerMonthlyTransferEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/25.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 月次損益振替仕訳、月次残高振替仕訳クラス
class DataBaseManagerMonthlyTransferEntry {

    public static let shared = DataBaseManagerMonthlyTransferEntry()

    private init() {
    }
    
    // MARK: - 月次損益振替仕訳
    
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
    // チェック 損益振替仕訳　損益勘定に存在するかを確認
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

    
    // MARK: - 月次残高振替仕訳

    // MARK: - CRUD

    // MARK: Create
    // 追加　決算振替仕訳　月次残高振替仕訳をする
    func addTransferEntryForClosingBalanceAccount(
        date: String,
        debitCategory: String,
        creditCategory: String,
        debitAmount: Int64,
        creditAmount: Int64,
        balanceLeft: Int64,
        balanceRight: Int64
    ) {
        var account: String = "" // 残高振替の相手勘定
        if debitCategory == "残高" {
            account = creditCategory
        } else if creditCategory == "残高" {
            account = debitCategory
        }
        var number = 0 // 仕訳番号 自動採番にした
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)

        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseMonthlyTransferEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: date,
            debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
            debit_amount: debitAmount, // 借方金額
            credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
            credit_amount: creditAmount, // 貸方金額
            smallWritting: "残高振替仕訳", // 小書き
            balance_left: balanceLeft,
            balance_right: balanceRight
        )
        // 取得　残高振替仕訳 勘定別に取得
        if let dataBaseTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getTransferEntryInAccount(account: account, date: date) {
            // 残高振替仕訳　が存在する場合は　更新
            number = updateTransferEntry(
                primaryKey: dataBaseTransferEntry.number,
                date: dataBaseJournalEntry.date,
                debitCategory: dataBaseJournalEntry.debit_category,
                creditCategory: dataBaseJournalEntry.credit_category,
                debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                smallWritting: dataBaseJournalEntry.smallWritting,
                balanceLeft: Int64(dataBaseJournalEntry.balance_left),
                balanceRight: Int64(dataBaseJournalEntry.balance_right)
            )
        } else {
            // 残高振替仕訳　が存在しない場合は　作成
//            if amount != 0 {
                number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                print(number)
                do {
                    // MARK: 残高振替仕訳は、仕訳帳には追加しない。
                    // 相手方の勘定
                    if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
//                        if account == "資本金勘定" {
//                            try DataBaseManager.realm.write {
//                                dataBaseGeneralLedger.dataBaseCapitalAccount?.dataBaseTransferEntry = dataBaseJournalEntry
//                            }
//                        } else {
                            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                try DataBaseManager.realm.write {
                                    // 月次損益振替仕訳、月次残高振替仕訳
                                    dataBaseGeneralLedger.dataBaseAccounts[i].dataBaseMonthlyTransferEntries.append(dataBaseJournalEntry)
                                }
                                break
                            }
//                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
//            }
        }
    }

    // MARK: Read
    // 取得　損益振替仕訳、残高振替仕訳 勘定別に取得
    func getTransferEntryInAccount(account: String, date: String) -> DataBaseMonthlyTransferEntry? {
//        if account == Constant.capitalAccountName || account == "資本金勘定" {
//            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
//                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
//            ])
//            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
//            let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
//            return dataBaseTransferEntry
//        } else {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
            .filter("date LIKE '\(date)'")

        return dataBaseMonthlyTransferEntries?.first
//        }
    }

    // MARK: Update
    // 更新 月次残高振替仕訳
    func updateTransferEntry(
        primaryKey: Int,
        date: String,
        debitCategory: String,
        creditCategory: String,
        debitAmount: Int64,
        creditAmount: Int64,
        smallWritting: String,
        balanceLeft: Int64,
        balanceRight: Int64
    ) -> Int {
        // 編集前の借方勘定と貸方勘定をメモする
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date,
                    "debit_category": debitCategory,
                    "credit_category": creditCategory,
                    "debit_amount": debitAmount,
                    "credit_amount": creditAmount,
                    "smallWritting": smallWritting,
                    "balance_left": balanceLeft,
                    "balance_right": balanceRight,
                ]
                DataBaseManager.realm.create(DataBaseMonthlyTransferEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }

    // MARK: Delete

}
