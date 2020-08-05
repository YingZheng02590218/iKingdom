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
        dataBaseAccountingBooksShelf.companyName = company 
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
    // 事業者名の取得
    func getCompanyName() -> String {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)! // モデル
        // (2)データベース内に保存されているモデルを全て取得する
//        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
//        objects = objects.filter("openOrClose == \(true)")
        // (2)データベース内に保存されているモデルをひとつ取得する
//        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: objects[0].number)!
        return object.companyName // 事業者名を返す
    }
    // モデルオブフェクトの更新
    func updateCompanyName(companyName: String) {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)! // モデル
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": 1, "companyName": companyName]
            realm.create(DataBaseAccountingBooksShelf.self, value: value, update: .modified) // 一部上書き更新
        }
    }
}
