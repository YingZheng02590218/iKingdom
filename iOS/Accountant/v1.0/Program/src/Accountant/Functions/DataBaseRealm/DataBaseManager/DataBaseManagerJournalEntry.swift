//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳クラス
class DataBaseManagerJournalEntry {
    // 追加　仕訳
    func addJournalEntry(date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {

        var number = 0
        // オブジェクトを作成
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let leftObject = dataBaseManagerAccount.getAccountByAccountName(accountName: debitCategory)
        let rightObject = dataBaseManagerAccount.getAccountByAccountName(accountName: creditCategory)

        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let fiscalYear = object.dataBaseJournals?.fiscalYear {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseJournalEntry(
                fiscalYear: fiscalYear,
                date: date,
                debit_category: debitCategory,
                debit_amount: debitAmount,
                credit_category: creditCategory,
                credit_amount: creditAmount,
                smallWritting: smallWritting,
                balance_left: 0,
                balance_right: 0
            )
            do {
                // (2)書き込みトランザクション内でデータを追加する
                try DataBaseManager.realm.write {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    // 仕訳帳に仕訳データを追加
                    object.dataBaseJournals?.dataBaseJournalEntries.append(dataBaseJournalEntry)
                    // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                    // 勘定に借方の仕訳データを追加
                    leftObject?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                    // 勘定に貸方の仕訳データを追加
                    rightObject?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(accountLeft: debitCategory, accountRight: creditCategory)
        return number
    }
    // 追加　決算整理仕訳
    func addAdjustingJournalEntry(date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {

        var number = 0
        // オブジェクトを作成
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let leftObject = dataBaseManagerAccount.getAccountByAccountName(accountName: debitCategory)
        let rightObject = dataBaseManagerAccount.getAccountByAccountName(accountName: creditCategory)

        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let fiscalYear = dataBaseAccountingBook.dataBaseJournals?.fiscalYear {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry(
                fiscalYear: fiscalYear,
                date: date,
                debit_category: debitCategory,
                debit_amount: debitAmount,
                credit_category: creditCategory,
                credit_amount: creditAmount,
                smallWritting: smallWritting,
                balance_left: 0,
                balance_right: 0
            )
            do {
                // (2)書き込みトランザクション内でデータを追加する
                try DataBaseManager.realm.write {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    // 仕訳帳に仕訳データを追加
                    dataBaseAccountingBook.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    // 勘定へ転記
                    // 勘定に借方の仕訳データを追加
                    leftObject?.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.決算整理仕訳リスト
                    // 勘定に貸方の仕訳データを追加
                    rightObject?.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.決算整理仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(accountLeft: debitCategory, accountRight: creditCategory)
        return number
    }
    // 取得　仕訳 編集する仕訳をプライマリーキーで取得
    func getJournalEntryWithNumber(number: Int) -> DataBaseJournalEntry? {

        guard let dataBaseJournalEntry = DataBaseManager.realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: number) else {
            return nil
        }
        return dataBaseJournalEntry
    }
    // 取得　決算整理仕訳 編集する仕訳をプライマリーキーで取得
    func getAdjustingEntryWithNumber(number: Int) -> DataBaseAdjustingEntry? {

        guard let dataBaseJournalEntry = DataBaseManager.realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: number) else {
            return nil
        }
        return dataBaseJournalEntry
    }
    // 仕訳　総数
    func getJournalEntryCount() -> Results<DataBaseJournalEntry> {

        let objects = DataBaseManager.realm.objects(DataBaseJournalEntry.self)
        return objects
    }
    // 決算整理仕訳　総数
    func getAdjustingEntryCount() -> Results<DataBaseAdjustingEntry> {

        let objects = DataBaseManager.realm.objects(DataBaseAdjustingEntry.self)
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        var objects = DataBaseManager.realm.objects(DataBaseSettingsTaxonomyAccount.self) // 2020/11/08
        objects = objects.filter("category LIKE '\(accountName)'")// 2020/11/08
        // 設定勘定科目のプライマリーキーを取得する
        if let numberOfAccount = objects.first {
            return numberOfAccount.number
        } else {
            return 0 // クラッシュ対応
        }
    }
    // 勘定のプライマリーキーを取得　※丁数ではない
    func getPrimaryNumberOfAccount(accountName: String) -> Int {
        var number: Int = 0
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let fiscalYear = dataBaseAccountingBooks.dataBaseJournals?.fiscalYear {
            let objects = DataBaseManager.realm.objects(DataBaseAccount.self)
                .filter("fiscalYear == \(fiscalYear)")
                .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
            number = objects[0].number
        }
        return number
    }

    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して勘定を取得する
     * @param  勘定名
     * @return  勘定
     */
    private func getAccountByAccountNameWithFiscalYear(accountName: String, fiscalYear: Int) -> DataBaseAccount? {
        let dataBaseAccountingBooks = DataBaseManager.realm.objects(DataBaseAccountingBooks.self)
            .filter("fiscalYear == \(fiscalYear)")
        guard let dataBaseAccountingBook = dataBaseAccountingBooks.first else {
            return nil
        }
        let dataBaseAccounts = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(accountName)'")
        guard let dataBaseAccount = dataBaseAccounts?.first else {
            return nil
        }
        return dataBaseAccount
    }
    // 更新 仕訳
    func updateJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String, completion: (Int) -> Void) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = DataBaseManager.realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: primaryKey) else {
            return
        }
        // 再計算用に、勘定をメモしておく
        let accountLeft = dataBaseJournalEntry.debit_category
        let accountRight = dataBaseJournalEntry.credit_category
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldLeftObject = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        guard let oldRightObject = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let leftObject = getAccountByAccountNameWithFiscalYear(accountName: debitCategory, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        guard let rightObject = getAccountByAccountNameWithFiscalYear(accountName: creditCategory, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        do {
            // 編集する仕訳
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
                DataBaseManager.realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeftObject.dataBaseJournalEntries.count where oldLeftObject.dataBaseJournalEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseJournalEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRightObject.dataBaseJournalEntries.count where oldRightObject.dataBaseJournalEntries[i].number == primaryKey ||
        oldRightObject.dataBaseJournalEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldRightObject.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        do {
            // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
            try DataBaseManager.realm.write {
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(accountLeft: accountLeft, accountRight: accountRight) // 編集前の借方勘定と貸方勘定
        dataBaseManager.setAccountTotal(accountLeft: debitCategory, accountRight: creditCategory) // 編集後の借方勘定と貸方勘定
        
        completion(primaryKey) //　ここでコールバックする（呼び出し元に処理を戻す）
    }
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String, completion: (Int) -> Void) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = DataBaseManager.realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey) else {
            return
        }
        // 再計算用に、勘定をメモしておく
        let accountLeft = dataBaseJournalEntry.debit_category
        let accountRight = dataBaseJournalEntry.credit_category
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldLeftObject = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        guard let oldRightObject = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let leftObject = getAccountByAccountNameWithFiscalYear(accountName: debitCategory, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        guard let rightObject = getAccountByAccountNameWithFiscalYear(accountName: creditCategory, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return
        }
        do {
            // 編集する仕訳
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
        // 編集前の勘定から借方の仕訳データを削除
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
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRightObject.dataBaseAdjustingEntries.count where oldRightObject.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldRightObject.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldRightObject.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        do {
            // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
            try DataBaseManager.realm.write {
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(accountLeft: accountLeft, accountRight: accountRight) // 編集前の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        dataBaseManager.setAccountTotalAdjusting(accountLeft: debitCategory, accountRight: creditCategory) // 編集後の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        
        completion(primaryKey) //　ここでコールバックする（呼び出し元に処理を戻す）
    }
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        let object = DataBaseManager.realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: number)!
        // 再計算用に、勘定をメモしておく
        let accountLeft = object.debit_category
        let accountRight = object.credit_category
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
                print("object.isInvalidated: \(object.isInvalidated)")
            }
        } catch {
            print("エラーが発生しました")
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(accountLeft: accountLeft, accountRight: accountRight)
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        let object = DataBaseManager.realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: number)!
        // 再計算用に、勘定をメモしておく
        let accountLeft = object.debit_category
        let accountRight = object.credit_category
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
            }
        } catch {
            print("エラーが発生しました")
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(accountLeft: accountLeft, accountRight: accountRight) // 決算整理仕訳用にしないといけない
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
