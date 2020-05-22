//
//  DatabaseSettings.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseSettings: RObject2 {
    // モデル定義
    @objc dynamic var big_category: Int = 0       //大分類
    @objc dynamic var mid_category: Int = 0       //中分類
    @objc dynamic var small_category: Int = 0     //小分類
    @objc dynamic var category: String = ""       //勘定科目
    @objc dynamic var explaining: String = ""     //説明
    @objc dynamic var switching: Bool = false     //有効無効
}


class RObject2: Object {
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
