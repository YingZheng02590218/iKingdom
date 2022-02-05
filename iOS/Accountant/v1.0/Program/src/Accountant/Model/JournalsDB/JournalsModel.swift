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
    
    func initializeJournals()
    func checkInitialising(DataBase: DataBaseJournals, fiscalYear: Int) -> Bool
    func addJournals(number: Int)
    func deleteJournals(number: Int) -> Bool
    
    func getJournalEntryAll() -> Results<DataBaseJournalEntry>
    func getAdjustingEntryAll() -> Results<DataBaseAdjustingEntry>
    func getSettingsOperating() -> DataBaseSettingsOperating?
    func getFinancialStatements() -> DataBaseFinancialStatements
    func getJournalAdjustingEntry(section: Int, EnglishFromOfClosingTheLedger0: Bool, EnglishFromOfClosingTheLedger1: Bool) -> Results<DataBaseAdjustingEntry>
}
// 仕訳帳クラス TODO:
class JournalsModel: DataBaseManager, JournalsModelInput {
    
    func initializeJournals() {
        // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
        let databaseManager = TBModel()
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
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
    // モデルオブフェクトの追加　仕訳帳
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
    // モデルオブフェクトの削除
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
    
    // 取得 仕訳　すべて　今期
    func getJournalEntryAll() -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseJournalEntry.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　すべて　今期
    func getAdjustingEntryAll() -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects.filter("fiscalYear == \(fiscalYear)")
            objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得
    func getSettingsOperating() -> DataBaseSettingsOperating? {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseSettingsOperating.self, forPrimaryKey: 1)
        return object
    }
    // 取得　財務諸表　現在開いている年度
    func getFinancialStatements() -> DataBaseFinancialStatements {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseFinancialStatements.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0]
    }
    // 取得　決算整理仕訳
    func getJournalAdjustingEntry(section: Int, EnglishFromOfClosingTheLedger0: Bool, EnglishFromOfClosingTheLedger1: Bool) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        // 設定操作
        if !EnglishFromOfClosingTheLedger0 { // 損益振替仕訳
            objects = objects.filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")') || (debit_category LIKE '\("繰越利益")') || (credit_category LIKE '\("繰越利益")')")
            print(objects)
        }
        if !EnglishFromOfClosingTheLedger1 { // 資本振替仕訳
            objects = objects.filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')")
        }
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
}
