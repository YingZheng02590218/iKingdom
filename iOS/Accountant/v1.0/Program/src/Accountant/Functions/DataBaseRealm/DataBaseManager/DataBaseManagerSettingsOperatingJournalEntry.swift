//
//  DataBaseManagerSettingsOperatingJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// よく使う仕訳クラス
class DataBaseManagerSettingsOperatingJournalEntry {

    static let shared = DataBaseManagerSettingsOperatingJournalEntry()

    private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　よく使う仕訳
    func addJournalEntry(nickname: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        // オブジェクトを作成 よく使う仕訳
        let dataBaseJournalEntry = DataBaseSettingsOperatingJournalEntry(
            nickname: nickname,                // ニックネーム
            debit_category: debitCategory,    // 借方勘定
            debit_amount: debitAmount,        // 借方金額 Int型(TextField.text アンラップ)
            credit_category: creditCategory,  // 貸方勘定
            credit_amount: creditAmount,      // 貸方金額
            smallWritting: smallWritting       // 小書き
        )
        var number = 0                                          // 仕訳番号 自動採番にした
        do {
            try DataBaseManager.realm.write {
                number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                // よく使う仕訳を追加
                DataBaseManager.realm.add(dataBaseJournalEntry)
            }
        } catch {
            print("エラーが発生しました")
        }
        return number
    }
    
    // MARK: Read
    
    // 取得　よく使う仕訳
    func getJournalEntry() -> Results<DataBaseSettingsOperatingJournalEntry> {
        let objects = RealmManager.shared.read(type: DataBaseSettingsOperatingJournalEntry.self)
        return objects
    }
    
    // 取得　よく使う仕訳
    func getJournalEntry(account: String) -> Results<DataBaseSettingsOperatingJournalEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsOperatingJournalEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account))
        ])
        return objects
    }
    // 取得　よく使う仕訳
    func getJournalEntry(number: Int) -> Results<DataBaseSettingsOperatingJournalEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsOperatingJournalEntry.self, predicates: [
            NSPredicate(format: "number == %@", NSNumber(value: number))
        ])
        return objects
    }
    // 取得　よく使う仕訳
    func getJournalEntry(group: Int) -> Results<DataBaseSettingsOperatingJournalEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsOperatingJournalEntry.self, predicates: [
            NSPredicate(format: "group == %@", NSNumber(value: group))
        ])
            .sorted(byKeyPath: "nickname", ascending: true) // タイトル順でソートする
        return objects
    }

    // MARK: Update
    
    // 更新 よく使う仕訳
    func updateJournalEntry(primaryKey: Int, nickname: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        let value: [String: Any] = [
            "number": primaryKey,
            "nickname": nickname,
            "debit_category": debitCategory,
            "debit_amount": debitAmount,
            "credit_category": creditCategory,
            "credit_amount": creditAmount,
            "smallWritting": smallWritting
        ]
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.create(DataBaseSettingsOperatingJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // 更新　よく使う仕訳　グループ
    func updateJournalEntry(primaryKey: Int, groupNumber: Int) {
        // 編集するよく使う仕訳
        let value: [String: Any] = [
            "number": primaryKey,
            "group": groupNumber
        ]
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.create(DataBaseSettingsOperatingJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }

    // MARK: Delete
    
    // 削除　よく使う仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperatingJournalEntry.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
                print("object.isInvalidated: \(object.isInvalidated)")
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
