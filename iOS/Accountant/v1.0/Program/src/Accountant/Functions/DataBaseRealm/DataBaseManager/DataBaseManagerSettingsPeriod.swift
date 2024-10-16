//
//  DataBaseManagerSettingsPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/04.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計期間クラス
class DataBaseManagerSettingsPeriod {
    
    public static let shared = DataBaseManagerSettingsPeriod()
    
    private init() {
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　会計期間
    func addSettingsPeriod() {
        // (2)書き込みトランザクション内でデータを追加する
        // オブジェクトを作成
        let dataBaseSettingsPeriod = DataBaseSettingsPeriod(theDayOfReckoning: TheDayOfReckoning.soloProprietor.rawValue)
        do {
            try DataBaseManager.realm.write {
                let number = dataBaseSettingsPeriod.save() // 自動採番
                DataBaseManager.realm.add(dataBaseSettingsPeriod)
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Read
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseSettingsPeriod.self)
        return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    
    // 取得　決算日
    func getTheDayOfReckoning() -> String {
        // (2)データベース内に保存されているモデルを全て取得する
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsPeriod.self, key: 1) else { return "" }
        return object.theDayOfReckoning
    }
    
    // すべてのモデルオブフェクトの取得
    func getMainBooksAllCount() -> Int {
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = RealmManager.shared.read(type: DataBaseAccountingBooks.self)
        // ソートする　注意：ascending: true とするとモデルオブフェクトのnumberの自動採番がおかしくなる？
        objects = objects.sorted(byKeyPath: "fiscalYear", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects.count
    }
    // すべてのモデルオブフェクトの取得
    func getMainBooksAll() -> Results<DataBaseAccountingBooks> {
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = RealmManager.shared.read(type: DataBaseAccountingBooks.self)
        // ソートする        注意：ascending: true とするとモデルオブフェクトのnumberの自動採番がおかしくなる？
        objects = objects.sorted(byKeyPath: "fiscalYear", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 仕訳　年度別
    func getJournalEntryCount(fiscalYear: Int) -> Results<DataBaseJournalEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        return objects
    }
    // 決算整理仕訳　年度別
    func getAdjustingEntryCount(fiscalYear: Int) -> Results<DataBaseAdjustingEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        return objects
    }
    // 特定のモデルオブフェクトの取得　会計帳簿
    func getSettingsPeriod(lastYear: Bool) -> DataBaseAccountingBooks { // メソッド名を変更する
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        // 前年度の会計帳簿をし取得する場合
        if lastYear {
            let objectss = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: objects[0].fiscalYear - 1)) // 前年度と同じ年の会計帳簿を判断
            ])
            return objectss[0] // 前年度の会計帳簿を返す
        }
        return objects[0] // 今年度の会計帳簿を返す
    }
    // チェック　会計帳簿　前年度の会計帳簿
    func checkSettingsPeriod() -> Bool { // メソッド名を変更する
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true)) // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        ])
        let objectss = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: objects[0].fiscalYear - 1)) // 前年度と同じ年の会計帳簿を判断
        ])
        if !objectss.isEmpty {
            return true // 前年度の会計帳簿はある
        } else {
            return false // 前年度の会計帳簿はない
        }
    }
    // 年度の取得　会計帳簿
    func getSettingsPeriodYear() -> Int {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true)) // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        ])
        // (2)データベース内に保存されているモデルをひとつ取得する
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooks.self, key: objects[0].number) else { return 0 }
        return object.fiscalYear // 年度を返す
    }
    // 最古の年度の取得　会計帳簿
    func getOldestPeriodYear() -> Int {
        let objects = RealmManager.shared.read(type: DataBaseAccountingBooks.self)
        // 最小値
        if let min = objects.value(forKeyPath: "@min.fiscalYear") {
        print(min)
            return min as! Int // 年度を返す
        } else {
            return 0
        }
    }
    
    // MARK: Update
    
    // 更新　決算日
    func setTheDayOfReckoning(month: Bool, date: String) {
        var dateChanged = ""
        if date.count < 2 {
            dateChanged = "0" + date
        } else {
            dateChanged = date
        }
        var theDayOfReckoning = ""
        let currentTheDayOfReckoning = getTheDayOfReckoning()
        if !month {
            theDayOfReckoning = String(currentTheDayOfReckoning.prefix(2) + "/\(dateChanged)") // 先頭2文字
        } else { // 月
            // 月別に日数を調整する
            var dayChanged = ""
            switch dateChanged {
            case "02":
                if currentTheDayOfReckoning.suffix(2) == "29" ||
                    currentTheDayOfReckoning.suffix(2) == "30" ||
                    currentTheDayOfReckoning.suffix(2) == "31" {
                    dayChanged = "28"
                    theDayOfReckoning = String("\(dateChanged)/" + dayChanged) // 末尾2文字
                } else {
                    theDayOfReckoning = String("\(dateChanged)/" + currentTheDayOfReckoning.suffix(2)) // 末尾2文字
                }
            case "04", "06", "09", "11":
                if currentTheDayOfReckoning.suffix(2) == "31" {
                    dayChanged = "30"
                    theDayOfReckoning = String("\(dateChanged)/" + dayChanged) // 末尾2文字
                } else {
                    theDayOfReckoning = String("\(dateChanged)/" + currentTheDayOfReckoning.suffix(2)) // 末尾2文字
                }
            default:
                theDayOfReckoning = String("\(dateChanged)/" + currentTheDayOfReckoning.suffix(2)) // 末尾2文字
            }
        }
        // 更新　決算日
        updateTheDayOfReckoning(theDayOfReckoning: theDayOfReckoning)
    }
    
    // 更新　決算日
    func updateTheDayOfReckoning(theDayOfReckoning: String) {
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                // 選択された月または日に更新する
                let value: [String: Any] = [
                    "number": 1,
                    "theDayOfReckoning": theDayOfReckoning
                ]
                DataBaseManager.realm.create(DataBaseSettingsPeriod.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // モデルオブフェクトの更新
    func setMainBooksOpenOrClose(tag: Int) {
        // (2)データベース内に保存されているDataBaseAccountingBooksShelfモデルをひとつ取得する
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooksShelf.self, key: 1) else { return } // 会計帳簿棚は会社に一つ
        do {
            try DataBaseManager.realm.write {
                // 一括更新　一旦、すべてのチェックマークを外す
                object.setValue(false, forKeyPath: "dataBaseAccountingBooks.openOrClose")
                // そして、選択された年度の会計帳簿にチェックマークをつける
                let value: [String: Any] = [
                    "number": tag,
                    "openOrClose": true
                ]
                DataBaseManager.realm.create(DataBaseAccountingBooks.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Delete
    
}
