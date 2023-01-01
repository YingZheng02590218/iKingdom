//
//  DataBaseManagerAdjustingEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 決算整理仕訳クラス
class DataBaseManagerAdjustingEntry {
    
    public static let shared = DataBaseManagerAdjustingEntry()

    private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　決算整理仕訳
    func addAdjustingJournalEntry(date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        
        var number = 0
        // オブジェクトを作成
        let leftObject = DataBaseManagerAccount.shared.getAccountByAccountName(accountName: debitCategory)
        let rightObject = DataBaseManagerAccount.shared.getAccountByAccountName(accountName: creditCategory)
        
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseAdjustingEntry(
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
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(accountLeft: debitCategory, accountRight: creditCategory)
        return number
    }
    
    // MARK: Read
    
    // 取得　決算整理仕訳 編集する仕訳をプライマリーキーで取得
    func getAdjustingEntryWithNumber(number: Int) -> DataBaseAdjustingEntry? {
        
        RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: number)
    }
    
    // 決算整理仕訳　総数
    func getAdjustingEntryCount() -> Results<DataBaseAdjustingEntry> {
        
        let objects = RealmManager.shared.read(type: DataBaseAdjustingEntry.self)
        return objects
    }
    
    // MARK: Update
    
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(
        primaryKey: Int,
        date: String,
        debitCategory: String,
        debitAmount: Int64,
        creditCategory: String,
        creditAmount: Int64,
        smallWritting: String,
        completion: (Int) -> Void
    ) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: primaryKey) else { return }
        // 再計算用に、勘定をメモしておく
        let accountLeft = dataBaseJournalEntry.debit_category
        let accountRight = dataBaseJournalEntry.credit_category
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
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let leftObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: debitCategory,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return
        }
        guard let rightObject = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: creditCategory,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
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
    
    // MARK: Delete
    
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: number) else { return false }
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
