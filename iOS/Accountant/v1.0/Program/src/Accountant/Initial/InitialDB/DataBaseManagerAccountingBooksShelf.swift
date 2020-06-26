//
//  DataBaseManagerAccountingBooksShelf.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerAccountingBooksShelf  {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool { // 共通化したい
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseAccountingBooksShelf.self) // モデル
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addAccountingBooksShelf(company: String) -> Int {
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // オブジェクトを作成
        let dataBaseAccountingBooksShelf = DataBaseAccountingBooksShelf() // 会計帳簿棚
        dataBaseAccountingBooksShelf.company = company // Todo
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        try! realm.write {
            number = dataBaseAccountingBooksShelf.save() //　自動採番
            print("addAccountingBooksShelf",number)
            // 会社　の数だけ増える　ToDo
            realm.add(dataBaseAccountingBooksShelf)
//            object.dataBaseAccountingBooks.append(dataBaseAccountingBooks)
        }
        return number
    }
}
