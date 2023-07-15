//
//  DataBaseManagerSettingsOperatingJournalEntryGroup.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// よく使う仕訳のグループクラス
class DataBaseManagerSettingsOperatingJournalEntryGroup {

    static let shared = DataBaseManagerSettingsOperatingJournalEntryGroup()

    private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　よく使う仕訳のグループ
    func addJournalEntryGroup(groupName: String) -> Int {
        // オブジェクトを作成 よく使う仕訳のグループ
        let dataBaseJournalEntry = DataBaseSettingsOperatingJournalEntryGroup(
            groupName: groupName // グループ名
        )
        var number = 0 // 仕訳番号 自動採番にした
        do {
            try DataBaseManager.realm.write {
                number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                // よく使う仕訳のグループを追加
                DataBaseManager.realm.add(dataBaseJournalEntry)
            }
        } catch {
            print("エラーが発生しました")
        }
        return number
    }
    
    // MARK: Read
    
    // 取得　よく使う仕訳のグループ
    func getJournalEntryGroup() -> Results<DataBaseSettingsOperatingJournalEntryGroup> {
        let objects = RealmManager.shared.read(type: DataBaseSettingsOperatingJournalEntryGroup.self)
        return objects
    }
    
    // 取得　よく使う仕訳のグループ
    func getJournalEntryGroup(groupName: String) -> Results<DataBaseSettingsOperatingJournalEntryGroup> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsOperatingJournalEntryGroup.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: groupName), NSString(string: groupName))
        ])
        return objects
    }

    // MARK: Update
    
    // 更新 よく使う仕訳のグループ
    func updateJournalEntryGroup(primaryKey: Int, groupName: String) -> Int {
        let value: [String: Any] = [
            "number": primaryKey,
            "nickname": groupName,
        ]
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.create(DataBaseSettingsOperatingJournalEntryGroup.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    
    // 削除　よく使う仕訳のグループ
    func deleteJournalEntryGroup(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperatingJournalEntryGroup.self, key: number) else { return false }
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
