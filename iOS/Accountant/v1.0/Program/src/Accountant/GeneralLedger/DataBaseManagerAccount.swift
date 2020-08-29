//
//  DataBaseManagerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

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
    // モデルオブフェクトの取得 勘定別に月別に取得　通常仕訳
    func getJournalEntryInAccount(section: Int, account: String) -> Results<DataBaseJournalEntry> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self)
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする 注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
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
    // モデルオブフェクトの取得 勘定別に月別に取得 決算整理仕訳
    func getAdjustingJournalEntryInAccount(section: Int, account: String) -> Results<DataBaseAdjustingEntry> { //DataBaseJournalEntry {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする 注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
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
            objects = objects.filter("date LIKE '*/00/*'") // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの取得 勘定別に全て取得
    func getAllJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self)
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする 注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // モデルオブフェクトの取得 勘定別に全て取得
    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする 注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseAccountモデルを全て取得する
        var objects = realm.objects(DataBaseAccount.self) // モデル
        // 希望する勘定だけを抽出する
        objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        // 勘定のプライマリーキーを取得する
        let numberOfAccount = objects[0].number
        return numberOfAccount
    }
    // 勘定のプライマリーキーを取得　※丁数ではない
    func getPrimaryNumberOfAccount(accountName: String) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccount.self) // モデル
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        let number: Int = objects[0].number
        
        return number
    }
}
