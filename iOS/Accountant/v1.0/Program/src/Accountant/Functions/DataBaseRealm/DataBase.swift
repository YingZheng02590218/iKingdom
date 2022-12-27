//
//  DataBase.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/29.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// class DataBase: RObject {
//
// }

class RObject: Object {
    @objc dynamic var number: Int = 0                   // 非オプショナル型
    // データを保存。
    func save() -> Int {
        if DataBaseManager.realm.isInWriteTransaction {
            if self.number == 0 { self.number = self.createNewId() }
            DataBaseManager.realm.add(self, update: .error)
        } else {
            do {
                try DataBaseManager.realm.write {
                    if self.number == 0 { self.number = self.createNewId() }
                    DataBaseManager.realm.add(self, update: .error)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return number
    }
    // 新しいIDを採番します。
    private func createNewId() -> Int {
        (DataBaseManager.realm.objects(type(of: self).self).sorted(byKeyPath: "number", ascending: false).first?.number ?? 0) + 1
    }
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        "number"
    }
}
