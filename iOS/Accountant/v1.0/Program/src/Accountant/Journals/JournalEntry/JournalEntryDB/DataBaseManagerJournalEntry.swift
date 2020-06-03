//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerJournalEntry  {
    // データベース
    
    // モデルオブフェクトの追加　仕訳
    func addJournalEntry(date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseJournalEntry()       //仕訳
        var number = 0                                          //仕訳番号 自動採番にした
        dataBaseJournalEntry.date = date                        //日付
        dataBaseJournalEntry.debit_category = debit_category    //借方勘定
        dataBaseJournalEntry.debit_amount = debit_amount        //借方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.credit_category = credit_category  //貸方勘定
        dataBaseJournalEntry.credit_amount = credit_amount      //貸方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.smallWritting = smallWritting      //小書き
        // オブジェクトを作成
//        let accountLeft = Account()                             //仕訳
//        accountLeft.accountName = debit_category
//        dataBaseJournalEntry.account.append(accountLeft)
//        let accountRight = Account()                            //仕訳 Accountオブジェクトをひとつでプロパティを上書きはできなかった
//        accountRight.accountName = credit_category
//        dataBaseJournalEntry.account.append(accountRight)
        let dataBaseManagerAccount = DataBaseManagerAccount()       //仕訳
        let left_number = dataBaseManagerAccount.getPrimaryNumberOfAccount(category: debit_category)
        let right_number = dataBaseManagerAccount.getPrimaryNumberOfAccount(category: credit_category)
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番
//            realm.add(dataBaseJournalEntry)
            // 仕訳帳に仕訳データを追加
            let object = realm.object(ofType: DataBaseJournalEntryBook.self, forPrimaryKey: 1 ) // ToDo
            object?.dataBaseJournalEntries.append(dataBaseJournalEntry)
//勘定へ転記
            // 勘定に借方の仕訳データを追加
            let object_leftAccount = realm.object(ofType: DataBaseAccount.self, forPrimaryKey: left_number ) // ToDo
            object_leftAccount?.dataBaseJournalEntries.append(dataBaseJournalEntry)
            // 勘定に貸方の仕訳データを追加
            let object_rightAccount = realm.object(ofType: DataBaseAccount.self, forPrimaryKey: right_number ) // 勘定科目のプライマリーキーを指定する
            object_rightAccount?.dataBaseJournalEntries.append(dataBaseJournalEntry)
        }
//        print(dataBaseJournalEntry)
        return number
    }
    // モデルオブフェクトの取得　仕訳
    func getJournalEntry(section: Int) -> Results<DataBaseJournalEntry> { //DataBaseJournalEntry {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
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
        // オブジェクトを準備
//        let dataBaseJournalEntry = DataBaseJournalEntry() //仕訳
        // 自動採番にした
        //                        journalEntry.number = 2
//        dataBaseJournalEntry.date = objects[0].date                        //日付
//        dataBaseJournalEntry.debit_category = objects[0].debit_category    //借方勘定
//        dataBaseJournalEntry.debit_amount = objects[0].debit_amount        //借方金額 Int型(TextField.text アンラップ)
//        dataBaseJournalEntry.credit_category = objects[0].credit_category  //貸方勘定
//        dataBaseJournalEntry.credit_amount = objects[0].credit_amount      //貸方金額 Int型(TextField.text アンラップ)
//        dataBaseJournalEntry.smallWritting = objects[0].smallWritting      //小書き
//        print(dataBaseJournalEntry)
        
//        return dataBaseJournalEntry
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
    // モデルオブフェクトの数を取得　仕訳
    func getJournalEntryCounts(section: Int) -> Int {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        let objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
//            print("DataBaseJournalEntryモデル : \(objects.count)")
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
        return objectsCount // 仕訳データの数を返す
    }
}
