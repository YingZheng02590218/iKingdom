//
//  DataBaseManagerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 勘定クラス
class DataBaseManagerAccount {

    // 総勘定元帳でモデルオブフェクトの追加を行うためコメントアウト
    // モデルオブフェクトの追加　勘定
//    func addAccount(name: String){
//        // オブジェクトを作成
//        let dataBaseAccount = DataBaseAccount() // 勘定
//        dataBaseAccount.accountName = name // Todo
//        // データベース　書き込み
//        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
//        // (2)書き込みトランザクション内でデータを追加する
//        try! realm.write {
//            let number = dataBaseAccount.save() //　自動採番
//            print(number)
//            // 勘定　の数だけ増える　ToDo
//            realm.add(dataBaseAccount)
//        }
//    }
    // 追加　勘定
    func addGeneralLedgerAccount(number: Int){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 設定画面の勘定科目一覧にある勘定を取得する
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objectt = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: number)
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let dataBaseAccount = DataBaseAccount() // 勘定
            dataBaseAccount.number = number //save() //　自動採番ではなく、設定勘定科目のプライマリーキーを使用する
            print("dataBaseAccount",number)
            dataBaseAccount.fiscalYear = object.fiscalYear
            dataBaseAccount.accountName = objectt!.category
            object.dataBaseGeneralLedger!.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
        }
    }
    // 取得 仕訳　すべて　今期
    func getJournalEntryAll() -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseJournalEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects.filter("fiscalYear == \(fiscalYear)")
            objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　すべて　今期
    func getAdjustingEntryAll() -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects.filter("fiscalYear == \(fiscalYear)")
            objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得　通常仕訳 勘定別に月別に取得
    func getJournalEntryInAccount(section: Int, account: String) -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseJournalEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        switch section {
        case 0: // April
            objects = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects = objects.filter("date LIKE '*/03/*'")
            break
        default:
            // ありえない
            break
        }
        return objects
    }
    // 取得 決算整理仕訳 勘定別に月別に取得
    func getAdjustingJournalEntryInAccount(section: Int, account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        switch section {
        case 0: // April
            objects = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects = objects.filter("date LIKE '*/03/*'")
            break
        default:
            // ありえない
            break
        }
        return objects
    }
    // 取得 決算整理仕訳 決算振替仕訳　損益振替　勘定別に月別に取得
    func getPLAccount(section: Int) -> DataBasePLAccount? {
        let realm = try! Realm()
        var objects = realm.objects(DataBasePLAccount.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        objects = objects.sorted(byKeyPath: "date", ascending: true)

        return object.dataBaseGeneralLedger?.dataBasePLAccount
    }
    // 取得 仕訳　勘定別
    func getAllJournalEntryFromAccount(account: String) -> List<DataBaseJournalEntry> { // ResultではなくListを使う　問題ない？
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        var objects = object.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'") // 条件を間違えないように注意する
//            .filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")')")
//        objects = objects?.sorted(byKeyPath: "date", ascending: true)
        print(objects![0].dataBaseJournalEntries)
        return objects![0].dataBaseJournalEntries
    }
    // 取得 仕訳　勘定別
    func getAllJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseJournalEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
            .filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")')")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別　損益勘定以外
    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")')")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益は除外
    func getAllAdjustingEntryInPLAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
            .filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')") // 消すと、損益勘定の差引残高の計算が狂う　2020/10/11
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益を含む
    func getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
//            .filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')") // 消すと、損益勘定の差引残高の計算が狂う　2020/10/11
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益のみ
    func getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
            .filter("debit_category LIKE '\("繰越利益")' || credit_category LIKE '\("繰越利益")'")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAccount.self)
        objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        // 勘定のプライマリーキーを取得する
        let numberOfAccount = objects[0].number
        return numberOfAccount
    }
    // 勘定のプライマリーキーを取得　※丁数ではない
    func getPrimaryNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAccount.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        let number: Int = objects[0].number
        
        return number
    }
    // 取得　勘定名から勘定を取得
    func getAccountByAccountName(accountName: String) -> DataBaseAccount? {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAccount.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        print(objects)
        return objects[0]
    }
    // 削除　勘定　設定勘定科目を削除するときに呼ばれる
    func deleteAccount(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccount.self, forPrimaryKey: number)!
        // 勘定クラス　勘定ないの仕訳を取得
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccount(account: object.accountName)
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: object.accountName)
        let objectssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccount(account: object.accountName)
        // 仕訳クラス　仕訳を削除
        let dataBaseManagerJournalEntry = DataBaseManagerJournalEntry()
        var isInvalidated = true // 初期値は真とする。仕訳データが0件の場合の対策
        var isInvalidatedd = true
        var isInvalidateddd = true
        for _ in 0..<objectss.count {
            isInvalidated = dataBaseManagerJournalEntry.deleteJournalEntry(number: objectss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 仕訳クラス　決算整理仕訳仕訳を削除
        for _ in 0..<objectsss.count {
            isInvalidatedd = dataBaseManagerJournalEntry.deleteAdjustingJournalEntry(number: objectsss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 損益振替仕訳を削除
        for _ in 0..<objectssss.count {
            isInvalidateddd = dataBaseManagerJournalEntry.deleteAdjustingJournalEntry(number: objectssss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        if isInvalidateddd {
            if isInvalidatedd {
                if isInvalidated {
                    try! realm.write {
                        // 仕訳が残ってないか
                        realm.delete(object)
                    }
                    return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
                }
            }
        }
        return false
    }
}
