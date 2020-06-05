//
//  DataBaseManagerAccountingBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerAccountingBooks  {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(fiscalYear: Int) -> Bool { // 共通化したい
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        objects = objects.filter("fiscalYear == \(fiscalYear)") // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addAccountingBooks(fiscalYear: Int) -> Int {
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)! // 会社に会計帳簿棚はひとつ
        // オブジェクトを作成
        let dataBaseAccountingBooks = DataBaseAccountingBooks() // 会計帳簿
        dataBaseAccountingBooks.fiscalYear = fiscalYear
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        try! realm.write {
            number = dataBaseAccountingBooks.save() //　自動採番
            print(number)
            // 年度　の数だけ増える　ToDo
//            realm.add(dataBaseMainBooks)
            object.dataBaseAccountingBooks.append(dataBaseAccountingBooks) // 会計帳簿棚に会計帳簿を追加する
        }
        return number
    }
}
