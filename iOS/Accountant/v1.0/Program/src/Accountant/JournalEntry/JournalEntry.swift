//
//  JournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class JournalEntry: RObject {
    // モデル定義
//    @objc dynamic var number: Int = 0                   //非オプショナル型
    @objc dynamic var date: String = ""                 //非オプショナル型
    @objc dynamic var debit_category: String = ""       //非オプショナル型
    @objc dynamic var debit_amount: Int = 0                   //非オプショナル型
    @objc dynamic var credit_category: String = ""      //非オプショナル型
    @objc dynamic var credit_amount: Int = 0                  //非オプショナル型
    @objc dynamic var smallWritting: String = ""        //非オプショナル型
}


class RObject: Object {
    @objc dynamic var number: Int = 0                   //非オプショナル型

    // データを保存。
    func save() {
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
