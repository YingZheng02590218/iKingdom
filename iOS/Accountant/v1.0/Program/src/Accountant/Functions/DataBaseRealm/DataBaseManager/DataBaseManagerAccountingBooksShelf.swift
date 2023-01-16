//
//  DataBaseManagerAccountingBooksShelf.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計帳簿棚クラス
class DataBaseManagerAccountingBooksShelf: DataBaseManager {
    
    public static let shared = DataBaseManagerAccountingBooksShelf()

    override private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // モデルオブフェクトの追加
    func addAccountingBooksShelf(company: String) -> Int {
        // オブジェクトを作成 会計帳簿棚
        let dataBaseAccountingBooksShelf = DataBaseAccountingBooksShelf(
            companyName: company,
            dataBaseOpeningBalanceAccount: nil
        )
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        do {
            try DataBaseManager.realm.write {
                number = dataBaseAccountingBooksShelf.save() //　自動採番
                // 会社　の数だけ増える
                DataBaseManager.realm.add(dataBaseAccountingBooksShelf)
            }
        } catch {
            print("エラーが発生しました")
        }
        return number
    }
    
    // MARK: Read
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseAccountingBooksShelf, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    
    // 事業者名の取得
    func getCompanyName() -> String {
        // (2)データベース内に保存されているモデルをひとつ取得する
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooksShelf.self, key: 1) else { return "" }
        return object.companyName // 事業者名を返す
    }

    /**
     * 会計帳簿.開始残高 オブジェクトを取得するメソッド
     * 開始残高を取得する
     */
    func getOpeningBalanceAccount() -> DataBaseOpeningBalanceAccount? {
        guard let dataBaseAccountingBooksShelf = RealmManager.shared.readWithPrimaryKey(
            type: DataBaseAccountingBooksShelf.self,
            key: 1
        ) else { return nil }
        let dataBaseAccount = dataBaseAccountingBooksShelf.dataBaseOpeningBalanceAccount
        return dataBaseAccount
    }

    /**
     * 設定残高振替仕訳 オブジェクトを取得するメソッド
     * 設定残高振替仕訳を取得する
     */
    func getTransferEntriesInOpeningBalanceAccount() -> Results<DataBaseSettingTransferEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingTransferEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "残高"), NSString(string: "残高"))
        ])
        return objects.sorted(byKeyPath: "number", ascending: true)
    }
    // 取得 設定残高振替仕訳　勘定別  全年度 (※貸借科目の勘定科目)
    func getAllTransferEntry(account: String) -> Results<DataBaseSettingTransferEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingTransferEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "残高"), NSString(string: "残高")),
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }

    // MARK: Update
    
    // モデルオブフェクトの更新
    func updateCompanyName(companyName: String) {
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": 1,
                    "companyName": companyName
                ]
                DataBaseManager.realm.create(DataBaseAccountingBooksShelf.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 更新 設定残高振替仕訳
    func updateJournalEntry(
        primaryKey: Int,
        debitCategory: String,
        debitAmount: Int, // 電卓で入力する場合は、Int64でなくてよい
        creditCategory: String,
        creditAmount: Int, // 電卓で入力する場合は、Int64でなくてよい
        completion: (Int) -> Void
    ) {
        do {
            // 編集する仕訳
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": "",
                    "debit_category": debitCategory,
                    "debit_amount": debitAmount,
                    "credit_category": creditCategory,
                    "credit_amount": creditAmount,
                    "smallWritting": ""
                ]
                DataBaseManager.realm.create(DataBaseSettingTransferEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Delete

    // 削除　設定残高振替仕訳
    func deleteTransferEntry(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingTransferEntry.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
}
