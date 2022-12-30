//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/29.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// データベースマネジャー
class DataBaseManager {
    
    static var realm: Realm {
        do {
            return try Realm()
        } catch {
            print("エラーが発生しました")
        }
        return self.realm
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising<T>(dataBase: T, fiscalYear: Int) -> Bool {
        // (2)データベース内に保存されているモデルを全て取得する
        if dataBase is DataBaseAccountingBooksShelf {
            let objects = RealmManager.shared.read(type: DataBaseAccountingBooksShelf.self) // モデル
            return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
        } else if dataBase is DataBaseAccountingBooks {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
            ])
            return !objects.isEmpty
        } else if dataBase is DataBaseJournals {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseJournals.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
            ])
            return !objects.isEmpty
        } else if dataBase is DataBaseGeneralLedger {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseGeneralLedger.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
            ])
            return !objects.isEmpty
        } else if dataBase is DataBaseFinancialStatements {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseFinancialStatements.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
            ])
            return !objects.isEmpty
        } else {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseJournals.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
            ])
            return !objects.isEmpty
        }
    }
    
    // MARK: Update

    // MARK: Delete
    
}
