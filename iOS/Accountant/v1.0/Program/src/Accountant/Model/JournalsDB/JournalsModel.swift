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
    func checkInitialising(DataBase: DataBaseJournals, fiscalYear: Int) -> Bool
    func addJournals(number: Int)
    func deleteJournals(number: Int) -> Bool
    
    func getJournalEntriesInJournals() -> Results<DataBaseJournalEntry>
    func getJournalAdjustingEntry() -> Results<DataBaseAdjustingEntry>
    func updateJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void)
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void)
}

// 仕訳帳クラス
class JournalsModel: DataBaseManager, JournalsModelInput {
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
    func checkInitialising(DataBase: DataBaseJournals, fiscalYear: Int) -> Bool {
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // 追加
    func addJournals(number: Int) {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトを作成
        let dataBaseJournals = DataBaseJournals() // 仕訳帳
        dataBaseJournals.fiscalYear = object.fiscalYear
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let number = dataBaseJournals.save() //ページ番号(一年で1ページ)　自動採番
            print("addJournals",number)
            // 年度　の数だけ増える
            object.dataBaseJournals = dataBaseJournals
        }
    }
    // 削除
    func deleteJournals(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseJournals.self, forPrimaryKey: number)!
        try! realm.write {
            realm.delete(object.dataBaseJournalEntries) //仕訳
            realm.delete(object.dataBaseAdjustingEntries) //決算整理仕訳
            realm.delete(object) // 仕訳帳
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
        let realm = try! Realm()

        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        var dataBaseAdjustingEntries = dataBaseAccountingBook.dataBaseJournals!.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
        let dataBaseSettingsOperating = realm.object(ofType: DataBaseSettingsOperating.self, forPrimaryKey: 1)
        
        if let EnglishFromOfClosingTheLedger0 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger0,
           let EnglishFromOfClosingTheLedger1 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger1 {
            if !EnglishFromOfClosingTheLedger0 { // 損益振替仕訳
                dataBaseAdjustingEntries = dataBaseAdjustingEntries.filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")') || (debit_category LIKE '\("繰越利益")') || (credit_category LIKE '\("繰越利益")')")
            }
            if !EnglishFromOfClosingTheLedger1 { // 資本振替仕訳
                dataBaseAdjustingEntries = dataBaseAdjustingEntries.filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')")
            }
        }
        return dataBaseAdjustingEntries
    }
    // 更新　仕訳　年度
    func updateJournalEntry(primaryKey: Int, fiscalYear: Int) {
        let realm = try! Realm()
        // 編集する仕訳
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeft_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldRight_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let left_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: fiscalYear) else { return }
        guard let right_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: fiscalYear) else { return }
        // 編集する仕訳
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "fiscalYear": fiscalYear]
            realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 編集前の仕訳帳から仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseJournalEntries.count where oldJournals.dataBaseJournalEntries[i].number == primaryKey ||
        oldJournals.dataBaseJournalEntries[i].isInvalidated {
            // TODO: removeしきれてない
            try! realm.write {
                oldJournals.dataBaseJournalEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeft_object.dataBaseJournalEntries.count where oldLeft_object.dataBaseJournalEntries[i].number == primaryKey ||
        oldLeft_object.dataBaseJournalEntries[i].isInvalidated {
            try! realm.write {
                oldLeft_object.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRight_object.dataBaseJournalEntries.count where oldRight_object.dataBaseJournalEntries[i].number == primaryKey ||
        oldRight_object.dataBaseJournalEntries[i].isInvalidated {
            try! realm.write {
                oldRight_object.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        try! realm.write {
            journals.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
            // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            // 勘定に借方の仕訳データを追加
            left_object.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
        }

    }
    // 更新　決算整理仕訳　年度 損益振替仕訳、資本振替仕訳以外の決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int) {
        let realm = try! Realm()
        // 編集する仕訳
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeft_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldRight_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let left_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: fiscalYear) else { return }
        guard let right_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: fiscalYear) else { return }
        // 編集する仕訳
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "fiscalYear": fiscalYear]
            realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 編集前の仕訳帳から仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeft_object.dataBaseAdjustingEntries.count where oldLeft_object.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeft_object.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldLeft_object.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRight_object.dataBaseAdjustingEntries.count where oldRight_object.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldRight_object.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldRight_object.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        try! realm.write {
            journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
            // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            // 勘定に借方の仕訳データを追加
            left_object.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
        }
    }
    // 更新 仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
    func updateJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void) {
        let dataBaseManager = DataBaseManagerJournalEntry()
        dataBaseManager.updateJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debit_category: debit_category,
            debit_amount: debit_amount,
            credit_category: credit_category,
            credit_amount: credit_amount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            })
    }
    // 更新 決算整理仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void) {
        let dataBaseManager = DataBaseManagerJournalEntry()
        dataBaseManager.updateAdjustingJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debit_category: debit_category,
            debit_amount: debit_amount,
            credit_category: credit_category,
            credit_amount: credit_amount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            })
    }
}
