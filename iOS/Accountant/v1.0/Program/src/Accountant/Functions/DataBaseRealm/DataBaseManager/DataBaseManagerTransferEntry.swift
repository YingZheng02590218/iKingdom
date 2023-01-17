//
//  DataBaseManagerTransferEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/08.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益振替仕訳クラス
class DataBaseManagerTransferEntry {

    public static let shared = DataBaseManagerTransferEntry()

    private init() {
    }

    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    // 取得 損益振替仕訳　勘定別  全年度 (※損益科目の勘定科目)
    func getAllTransferEntryInPLAccountAll(account: String) -> Results<DataBaseTransferEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseTransferEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益")),
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 残高振替仕訳　勘定別  全年度 (※貸借科目の勘定科目)
    func getAllTransferEntry(account: String) -> Results<DataBaseTransferEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseTransferEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "残高"), NSString(string: "残高")),
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }

    // MARK: Update

    // MARK: Delete

    // 削除　損益振替仕訳、残高振替仕訳
    func deleteTransferEntry(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseTransferEntry.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
