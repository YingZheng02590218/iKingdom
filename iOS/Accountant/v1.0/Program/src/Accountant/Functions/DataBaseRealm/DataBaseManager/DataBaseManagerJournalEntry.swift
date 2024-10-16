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

    public static let shared = DataBaseManagerJournalEntry()
    
    private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　仕訳
    func addJournalEntry(date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        
        var number = 0
        // オブジェクトを作成
        let leftObject = DataBaseManagerAccount.shared.getAccountByAccountName(accountName: debitCategory)
        let rightObject = DataBaseManagerAccount.shared.getAccountByAccountName(accountName: creditCategory)
        
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseJournalEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear,
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
                dataBaseAccountingBook.dataBaseJournals?.dataBaseJournalEntries.append(dataBaseJournalEntry)
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(accountLeft: debitCategory, accountRight: creditCategory)
        
        // TODO: 月次残高振替
        
        // ウィジェット　貸借対照表と損益計算書の、五大区分の合計額と当期純利益の額を再計算する
        DataBaseManagerBalanceSheetProfitAndLossStatement.shared.setupAmountForBsAndPL()
        return number
    }

    // MARK: Read
    
    // 取得　仕訳 編集する仕訳をプライマリーキーで取得
    func getJournalEntryWithNumber(number: Int) -> DataBaseJournalEntry? {
        
        RealmManager.shared.readWithPrimaryKey(type: DataBaseJournalEntry.self, key: number)
    }
    
    // 仕訳　総数
    func getJournalEntryCount() -> Results<DataBaseJournalEntry> {
        
        let objects = RealmManager.shared.read(type: DataBaseJournalEntry.self)
        return objects
    }

    // 取得 仕訳　勘定別 全年度
    func getAllJournalEntryInAccountAll(account: String) -> Results<DataBaseJournalEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseJournalEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)) // 条件を間違えないように注意する
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    
    // 取得 仕訳　日付と借方勘定科目、貸方勘定科目、金額が同一の仕訳
    func getJournalEntryWith(date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64) -> Results<DataBaseJournalEntry> {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)

        var objects = RealmManager.shared.readWithPredicate(
            type: DataBaseJournalEntry.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook.fiscalYear)),
                NSPredicate(format: "date LIKE %@", NSString(string: date)),
                NSPredicate(format: "debit_category LIKE %@ AND credit_category LIKE %@", NSString(string: debitCategory), NSString(string: creditCategory)),
                NSPredicate(format: "debit_amount == %@ AND credit_amount == %@", NSNumber(value: debitAmount), NSNumber(value: creditAmount)),
                // 条件を間違えないように注意する
            ]
        )
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }

    // MARK: Update
    
    // 更新 仕訳
    func updateJournalEntry(
        primaryKey: Int,
        date: String?,
        debitCategory: String?,
        debitAmount: Int64?,
        creditCategory: String?,
        creditAmount: Int64?,
        smallWritting: String?,
        completion: (Int) -> Void
    ) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseJournalEntry.self, key: primaryKey) else { return }
        // 再計算用に、勘定をメモしておく
        let accountLeft = dataBaseJournalEntry.debit_category
        let accountRight = dataBaseJournalEntry.credit_category

        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let leftObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: debitCategory ?? accountLeft,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return
        }
        guard let rightObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: creditCategory ?? accountRight,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return
        }
        do {
            // 編集する仕訳
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date ?? dataBaseJournalEntry.date,
                    "debit_category": debitCategory ?? dataBaseJournalEntry.debit_category,
                    "debit_amount": debitAmount ?? dataBaseJournalEntry.debit_amount,
                    "credit_category": creditCategory ?? dataBaseJournalEntry.credit_category,
                    "credit_amount": creditAmount ?? dataBaseJournalEntry.credit_amount,
                    "smallWritting": smallWritting ?? dataBaseJournalEntry.smallWritting
                ]
                DataBaseManager.realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldLeftObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return
        }
        guard let oldRightObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return
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
        // 勘定科目が空だった場合の対策
        if !accountLeft.isEmpty && !accountRight.isEmpty {
            dataBaseManager.setAccountTotal(accountLeft: accountLeft, accountRight: accountRight) // 編集前の借方勘定と貸方勘定
        }
        dataBaseManager.setAccountTotal(
            accountLeft: debitCategory ?? dataBaseJournalEntry.debit_category,
            accountRight: creditCategory ?? dataBaseJournalEntry.credit_category
        ) // 編集後の借方勘定と貸方勘定
        // ウィジェット　貸借対照表と損益計算書の、五大区分の合計額と当期純利益の額を再計算する
        DataBaseManagerBalanceSheetProfitAndLossStatement.shared.setupAmountForBsAndPL()
        completion(primaryKey) //　ここでコールバックする（呼び出し元に処理を戻す）
    }

    // MARK: Delete
    
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseJournalEntry.self, key: number) else { return false }
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
        // 勘定科目が空だった場合の対策
        if !accountLeft.isEmpty && !accountRight.isEmpty {
            // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
            let dataBaseManager = TBModel()
            dataBaseManager.setAccountTotal(accountLeft: accountLeft, accountRight: accountRight)
        }
        // ウィジェット　貸借対照表と損益計算書の、五大区分の合計額と当期純利益の額を再計算する
        DataBaseManagerBalanceSheetProfitAndLossStatement.shared.setupAmountForBsAndPL()
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
