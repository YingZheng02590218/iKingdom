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

    // データベースにDataBaseAccountモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseAccountモデルを全て取得する
        let objects = realm.objects(DataBaseAccount.self) // DataBaseAccountモデル
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
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
    // モデルオブフェクトの取得 勘定別に取得
    func getAccount(section: Int, account: String) -> Results<DataBaseJournalEntry> { //DataBaseJournalEntry {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
                // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournalEntryBook!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする        注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
//        print("並び替え後　\(objects)")
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
    // モデルオブフェクトの取得 勘定別に取得
    func getAccountAll(account: String) -> Results<DataBaseJournalEntry> { //DataBaseJournalEntry {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
                // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournalEntryBook!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")// 条件を間違えないように注意する
        // ソートする        注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseAccountモデルを全て取得する
        var objects = realm.objects(DataBaseAccount.self) // モデル
        // 希望する勘定だけを抽出する　ToDo
        objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        // 勘定のプライマリーキーを取得する
        let numberOfAccount = objects[0].number
        return numberOfAccount
    }
    
    func getPrimaryNumberOfAccount(category: String) -> Int{
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccount.self) // モデル
        // 希望する勘定だけを抽出する
        objects = objects.filter("accountName LIKE '\(category)'")// 条件を間違えないように注意する
        let number: Int = objects[0].number
        
        return number
    }
//    func getAccountTest(section: Int, account: String) -> Results<Account> {
//        // データベース　読み込み
//        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
//        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
//        var objects = realm.objects(Account.self) // DataBaseJournalEntryモデル
//        print("全て取得：\(objects)")
//        // 希望する勘定だけを抽出する　ToDo
//        objects = objects.filter("accountName LIKE '\(account)'")// 条件を間違えないように注意する
//        print("特定の勘定だけ：\(objects)")
//        // ソートする        注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
////        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
////        print("並び替え：\(objects)")
//        var dataBaseJournalEntrysInAccount = objects[0].dataBaseJournalEntrys
//        print("勘定内の仕訳データ：\(dataBaseJournalEntrysInAccount)")
//
//        return objects
//    }
    // モデルオブフェクトの数を取得
    func getAccountCounts(section: Int, account: String) -> Int {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournalEntryBook!.fiscalYear
        // 希望する勘定だけを抽出する
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
        // ソートする        注意：ascending: true とするとDataBaseJournalEntryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "date", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        var objectsCount = 0
        switch section {
        case 0: // April
            objectsCount = objects.filter("date LIKE '*/04/*'").count
            break
        case 1: // May
            objectsCount = objects.filter("date LIKE '*/05/*'").count
            break
        case 2: // June
            objectsCount = objects.filter("date LIKE '*/06/*'").count
            break
        case 3: // July
            objectsCount = objects.filter("date LIKE '*/07/*'").count
            break
        case 4: // Ogust
            objectsCount = objects.filter("date LIKE '*/08/*'").count
            break
        case 5: // September
            objectsCount = objects.filter("date LIKE '*/09/*'").count
            break
        case 6: // October
            objectsCount = objects.filter("date LIKE '*/10/*'").count
            break
        case 7: // Nobember
            objectsCount = objects.filter("date LIKE '*/11/*'").count
            break
        case 8: // December
            objectsCount = objects.filter("date LIKE '*/12/*'").count
            break
        case 9: // January
            objectsCount = objects.filter("date LIKE '*/01/*'").count
            break
        case 10: // Feburary
            objectsCount = objects.filter("date LIKE '*/02/*'").count
            break
        case 11: // March
            objectsCount = objects.filter("date LIKE '*/03/*'").count
            break
        default:
            objectsCount = 0
            break
        }
//            print("DataBaseJournalEntry月別モデル数 :セクション \(section) :数 \(objectsCount)")
        return objectsCount // 希望の勘定内の仕訳データの数を返す
    }
}
