//
//  DataBaseManagerJournalEntryBook.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerJournalEntryBook {
    // データベース
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(fiscalYear: Int) -> Bool {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseJournalEntryBook.self) // DataBaseJournalEntryBookモデル
        objects = objects.filter("fiscalYear == \(fiscalYear)") // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加　仕訳帳
    func addJournalEntryBook(number: Int) {
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトを作成
        let dataBaseJournalEntryBook = DataBaseJournalEntryBook() // 仕訳帳
        dataBaseJournalEntryBook.fiscalYear = object.fiscalYear // Todo
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let number = dataBaseJournalEntryBook.save() //ページ番号(一年で1ページ)　自動採番
            print(number)
            // 年度　の数だけ増える　ToDo
//            realm.add(dataBaseJournalEntryBook)
            object.dataBaseJournalEntryBook = dataBaseJournalEntryBook
        }
    }
    // モデルオブフェクトの取得　仕訳帳
    func getJournalEntryBook() -> DataBaseJournalEntryBook { //DataBaseJournalEntryBook {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryBookモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseJournalEntryBook.self, forPrimaryKey: 1)! //ToDo // DataBaseJournalEntryBookモデル
        return object // 仕訳帳を返す
    }
}
