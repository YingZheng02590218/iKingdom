//
//  JournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseJournalEntry: RObject {
    // モデル定義
//    @objc dynamic var number: Int = 0                 //仕訳番号
    @objc dynamic var date: String = ""                 //日付
    @objc dynamic var debit_category: String = ""       //借方勘定
    @objc dynamic var debit_amount: Int64 = 0             //借方金額
    @objc dynamic var credit_category: String = ""      //貸方勘定
    @objc dynamic var credit_amount: Int64 = 0            //貸方金額
    @objc dynamic var smallWritting: String = ""        //小書き
    @objc dynamic var balance_left: Int64 = 0
    @objc dynamic var balance_right: Int64 = 0
//    let account = List<Account>()               //多対多の関連 勘定

//    override static func ignoredProperties() -> [String] {
//        return ["balance_left","balance_right"]
//    }
}

class RObject: Object {
    @objc dynamic var number: Int = 0                   //非オプショナル型
    // データを保存。
    func save() -> Int {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            if self.number == 0 { self.number = self.createNewId() }
            realm.add(self, update: .error)
        } else {
            try! realm.write {
                if self.number == 0 { self.number = self.createNewId() }
                realm.add(self, update: .error)
            }
        }
        return number
    }
    // 新しいIDを採番します。
    private func createNewId() -> Int {
        let realm = try! Realm()
        return (realm.objects(type(of: self).self).sorted(byKeyPath: "number", ascending: false).first?.number ?? 0) + 1
    }
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "number"
    }
}
// 勘定クラス
// 仕訳データ は 勘定 を 1 つ以上持っています。同じ 勘定 を持っている 仕訳データ を取得したい時に逆方向の関連を使用すると 勘定 から 仕訳データ の一覧を取得することができます。
//class Account: Object {
//    @objc dynamic var accountName: String = ""          // 勘定名
//    let dataBaseJournalEntrys = LinkingObjects(fromType: DataBaseJournalEntry.self, property: "account") // 逆方向の関連　勘定→仕訳データ
//}
