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

    // MARK: Update

    // MARK: Delete

    // 削除　損益振替仕訳
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
