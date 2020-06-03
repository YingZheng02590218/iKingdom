//
//  DataBaseManagerMainBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerMainBooks  {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(fiscalYear: Int) -> Bool { // 共通化したい
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseMainBooks.self) // モデル
//        objects = objects.filter("fiscalYear LIKE '\(fiscalYear.description)'")
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addMainBooks(fiscalYear: Int) -> Int {
        // オブジェクトを作成
        let dataBaseMainBooks = DataBaseMainBooks() // 総勘定元帳
        dataBaseMainBooks.fiscalYear = fiscalYear // Todo
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        try! realm.write {
            number = dataBaseMainBooks.save() //　自動採番
            print(number)
            // 年度　の数だけ増える　ToDo
            realm.add(dataBaseMainBooks)
        }
        return number
    }
}
