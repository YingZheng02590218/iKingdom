//
//  JournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳クラス
class DataBaseJournalEntry: RObject {
    // モデル定義
//    @objc dynamic var number: Int = 0                 //仕訳番号
    @objc dynamic var fiscalYear: Int = 0               //年度
    @objc dynamic var date: String = ""                 //日付
    @objc dynamic var debit_category: String = ""       //借方勘定
    @objc dynamic var debit_amount: Int64 = 0           //借方金額
    @objc dynamic var credit_category: String = ""      //貸方勘定
    @objc dynamic var credit_amount: Int64 = 0          //貸方金額
    @objc dynamic var smallWritting: String = ""        //小書き
    @objc dynamic var balance_left: Int64 = 0           //差引残高
    @objc dynamic var balance_right: Int64 = 0          //差引残高
}
// 構造体定義
struct DBJournalEntry {
    // ストアドプロパティ定義（初期値なし）
    let date: String?
    let debit_category: String?
    let debit_amount: Int64?
    let credit_category: String?
    let credit_amount: Int64?
    let smallWritting: String?
    // initを使用することでイニシャライザ定義
    init(date: String?, debit_category: String?, debit_amount: Int64?, credit_category: String?, credit_amount: Int64?, smallWritting: String?) {
        self.date = date
        self.debit_category = debit_category
        self.debit_amount = debit_amount
        self.credit_category = credit_category
        self.credit_amount = credit_amount
        self.smallWritting = smallWritting
    }
    // 値が入っているプロパティがあるかどうかをチェックする
    func checkPropertyIsNil() -> Bool {
        if let _ = date {
            return false
        }
        if let _ = debit_category {
            return false
        }
        if let _ = debit_amount {
            return false
        }
        if let _ = credit_category {
            return false
        }
        if let _ = credit_amount {
            return false
        }
        if let _ = smallWritting {
            return false
        }
        
        return true
    }
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
