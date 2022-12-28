//
//  JournalsModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol JournalsModelInput {
    
    func initializeJournals(completion: (Bool) -> Void)
    func checkInitialising(dataBase: DataBaseJournals, fiscalYear: Int) -> Bool
    func addJournals(number: Int)
    func deleteJournals(number: Int) -> Bool
    
    func getJournalEntriesInJournals() -> Results<DataBaseJournalEntry>
    func getJournalAdjustingEntry() -> Results<DataBaseAdjustingEntry>
    func updateJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String, completion: (Int) -> Void)
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String, completion: (Int) -> Void)
    
    func initializePDFMaker(completion: ([URL]?) -> Void)
}

// 仕訳帳クラス
class JournalsModel: DataBaseManager, JournalsModelInput {
    
    // 印刷機能
    let pDFMaker = PDFMaker()
    
    // 会計処理　転記、合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))、表示科目
    func initializeJournals(completion: (Bool) -> Void) {
        // 転記　仕訳から勘定への関連を付け直す
        reconnectJournalEntryToAccounts()
        // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
        let databaseManager = TBModel()
        databaseManager.setAllAccountTotal()            // 集計　合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))
        databaseManager.calculateAmountOfAllAccount()   // 合計額を計算
        
        completion(true)
    }

    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseJournals, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    // 追加
    func addJournals(number: Int) {
        // 会計帳簿　のオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseAccountingBooks.self, key: number) else { return }
        // オブジェクトを作成 仕訳帳
        let dataBaseJournals = DataBaseJournals(
            fiscalYear: object.fiscalYear
        )
        do {
            try DataBaseManager.realm.write {
                let number = dataBaseJournals.save() // ページ番号(一年で1ページ)　自動採番
                print("addJournals", number)
                // 年度　の数だけ増える
                object.dataBaseJournals = dataBaseJournals
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 削除
    func deleteJournals(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseJournals.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object.dataBaseJournalEntries) // 仕訳
                DataBaseManager.realm.delete(object.dataBaseAdjustingEntries) // 決算整理仕訳
                DataBaseManager.realm.delete(object) // 仕訳帳
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
    
    /**
     * 会計帳簿.仕訳帳.仕訳[ ] オブジェクトを取得するメソッド
     * 開いている帳簿の仕訳帳から通常仕訳を取得する
     * 日付を降順にソートする
     * @param -
     * @return 仕訳[ ]
     */
    func getJournalEntriesInJournals() -> Results<DataBaseJournalEntry> {
        
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseJournalEntries = dataBaseAccountingBooks.dataBaseJournals!.dataBaseJournalEntries
            .sorted(byKeyPath: "date", ascending: true)
        return dataBaseJournalEntries
    }
    
    /**
     * 会計帳簿.仕訳帳.決算整理仕訳[ ] オブジェクトを取得するメソッド\
     * 決算整理仕訳
     * 日付を降順にソートする
     * @param EnglishFromOfClosingTheLedger0 損益振替仕訳を含めるかフラグ
     * @param EnglishFromOfClosingTheLedger1 資本振替仕訳を含めるかフラグ
     * @return 決算整理仕訳[ ]
     */
    func getJournalAdjustingEntry() -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        var dataBaseAdjustingEntries = dataBaseAccountingBook.dataBaseJournals!.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
        let dataBaseSettingsOperating = RealmManager.shared.findFirst(type: DataBaseSettingsOperating.self, key: 1)

        if let englishFromOfClosingTheLedger0 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger0,
           let englishFromOfClosingTheLedger1 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger1 {
            if !englishFromOfClosingTheLedger0 { // 損益振替仕訳
                dataBaseAdjustingEntries = dataBaseAdjustingEntries.filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")') || (debit_category LIKE '\("繰越利益")') || (credit_category LIKE '\("繰越利益")')")
            }
            if !englishFromOfClosingTheLedger1 { // 資本振替仕訳
                dataBaseAdjustingEntries = dataBaseAdjustingEntries.filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')")
            }
        }
        return dataBaseAdjustingEntries
    }
    // 更新　仕訳　年度
    func updateJournalEntry(primaryKey: Int, fiscalYear: Int) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.findFirst(type: DataBaseJournalEntry.self, key: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        guard let oldRightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let leftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: fiscalYear) else { return }
        guard let rightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: fiscalYear) else { return }
        // 編集する仕訳
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": primaryKey, "fiscalYear": fiscalYear]
                DataBaseManager.realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        // 編集前の仕訳帳から仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseJournalEntries.count where oldJournals.dataBaseJournalEntries[i].number == primaryKey ||
        oldJournals.dataBaseJournalEntries[i].isInvalidated {
            // TODO: removeしきれてない
            do {
                try DataBaseManager.realm.write {
                    oldJournals.dataBaseJournalEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
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
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        do {
            try DataBaseManager.realm.write {
                journals.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }

    }
    // 更新　決算整理仕訳　年度 損益振替仕訳、資本振替仕訳以外の決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.findFirst(type: DataBaseAdjustingEntry.self, key: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        guard let oldRightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let leftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: fiscalYear) else { return }
        guard let rightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: fiscalYear) else { return }
        // 編集する仕訳
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": primaryKey, "fiscalYear": fiscalYear]
                DataBaseManager.realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        // 編集前の仕訳帳から仕訳データを削除
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
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        do {
            try DataBaseManager.realm.write {
                journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 更新 仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
    func updateJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String, completion: (Int) -> Void) {
        let dataBaseManager = DataBaseManagerJournalEntry()
        dataBaseManager.updateJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debitCategory: debitCategory,
            debitAmount: debitAmount,
            creditCategory: creditCategory,
            creditAmount: creditAmount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
    // 更新 決算整理仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
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
        let dataBaseManager = DataBaseManagerJournalEntry()
        dataBaseManager.updateAdjustingJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debitCategory: debitCategory,
            debitAmount: debitAmount,
            creditCategory: creditCategory,
            creditAmount: creditAmount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
    // 初期化 PDFメーカー
    func initializePDFMaker(completion: ([URL]?) -> Void) {

        pDFMaker.initialize(completion: { PDFpath in
            completion(PDFpath)
        })
    }
}
