//
//  DataBaseManagerJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳帳クラス
class DataBaseManagerJournals: DataBaseManager {
    
    public static let shared = DataBaseManagerJournals()

    override private init() {
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加
    func addJournals(number: Int) {
        // 会計帳簿　のオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseAccountingBooks.self, key: number) else { return }
        // オブジェクトを作成 仕訳帳
        let dataBaseJournals = DataBaseJournals(
            fiscalYear: object.fiscalYear
        )
        do {
            try DataBaseManager.realm.write {
                let number = dataBaseJournals.save() // ページ番号(一年で1ページ)　自動採番
                print("addJournals", number)
                // 年度　の数だけ増える
                object.dataBaseJournals = dataBaseJournals
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Read
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseJournals, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    
    /**
     * 会計帳簿.仕訳帳 オブジェクトを取得するメソッド
     * 年度を指定して仕訳帳を取得する
     * @param 年度
     * @return 仕訳帳
     */
    func getJournalsWithFiscalYear(fiscalYear: Int) -> DataBaseJournals? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        
        guard let dataBaseJournals = dataBaseAccountingBook?.dataBaseJournals else {
            return nil
        }
        
        return dataBaseJournals
    }
    
    // MARK: Update
    
    // 転記をやり直し　再度開いている帳簿の年度のすべての仕訳、決算整理仕訳を勘定へ転記する
    func reconnectJournalEntryToAccounts() {
        // 会計帳簿 年度を使用するため
        guard let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ]) else { return }
        // 仕訳帳　開いている帳簿のすべての仕訳帳
        guard let dataBaseJournals = dataBaseAccountingBook.dataBaseJournals else {
            return
        }
        // 勘定　開いている帳簿のすべての勘定
        guard let dataBaseAccounts = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts else {
            return
        }
        // 損益勘定
        guard let dataBasePLAccount = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount else {
            return
        }
        // 通常仕訳 開いている帳簿の年度と同じ仕訳に絞り込む
        let dataBaseJournalEntries = RealmManager.shared.readWithPredicate(type: DataBaseJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook.fiscalYear))
        ])
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 開いている帳簿の年度と同じ仕訳に絞り込む
        let dataBaseJournalAdjustingEntries = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook.fiscalYear)),
            NSPredicate(format: "!(debit_category LIKE %@) AND !(credit_category LIKE %@)", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 借方勘定が損益勘定の場合
        let dataBasePLAccountJournalAdjustingEntriesDebit = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook.fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ AND !(credit_category LIKE %@)", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 貸方勘定が損益勘定の場合
        let dataBasePLAccountJournalAdjustingEntriesCredit = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook.fiscalYear)),
            NSPredicate(format: "!(debit_category LIKE %@) AND credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
            .sorted(byKeyPath: "date", ascending: true)
        do {
            // 転記やり直し前の仕訳データを仕訳帳と勘定、損益勘定から削除
            try DataBaseManager.realm.write {
                dataBaseJournals.dataBaseJournalEntries.removeAll() // 会計帳簿.仕訳帳.仕訳リスト
                dataBaseJournals.dataBaseAdjustingEntries.removeAll() // 会計帳簿.仕訳帳.決算整理仕訳リスト
            }
            for dataBaseAccount in dataBaseAccounts {
                try DataBaseManager.realm.write {
                    dataBaseAccount.dataBaseJournalEntries.removeAll() // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                    dataBaseAccount.dataBaseAdjustingEntries.removeAll() // 会計帳簿.総勘定元帳.勘定.決算整理仕訳リスト
                }
            }
            try DataBaseManager.realm.write {
                dataBasePLAccount.dataBaseJournalEntries.removeAll() // 会計帳簿.総勘定元帳.損益勘定.仕訳リスト
                dataBasePLAccount.dataBaseAdjustingEntries.removeAll() // 会計帳簿.総勘定元帳.損益勘定.決算整理仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
        // 勘定へ転記
        for dataBaseJournalEntry in dataBaseJournalEntries {
            // 転記やり直し後の仕訳帳と借方勘定と貸方勘定
            guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.debit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.credit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            do {
                // 転記やり直し後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
                try DataBaseManager.realm.write {
                    journals.dataBaseJournalEntries.append(dataBaseJournalEntry)
                    leftObject.dataBaseJournalEntries.append(dataBaseJournalEntry)
                    rightObject.dataBaseJournalEntries.append(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 勘定へ転記 損益勘定以外
        for dataBaseJournalEntry in dataBaseJournalAdjustingEntries {
            guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            do {
                try DataBaseManager.realm.write {
                    journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 借方勘定が損益勘定の場合
        for dataBaseJournalEntry in dataBasePLAccountJournalAdjustingEntriesDebit {
            guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.debit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.credit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            do {
                try DataBaseManager.realm.write {
                    journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        // 貸方勘定が損益勘定の場合
        for dataBaseJournalEntry in dataBasePLAccountJournalAdjustingEntriesCredit {
            guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.debit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            guard let rightObject: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                accountName: dataBaseJournalEntry.credit_category,
                fiscalYear: dataBaseJournalEntry.fiscalYear
            ) else {
                return
            }
            do {
                try DataBaseManager.realm.write {
                    journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Delete
    
    // 削除
    func deleteJournals(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseJournals.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object.dataBaseJournalEntries) // 仕訳
                DataBaseManager.realm.delete(object.dataBaseAdjustingEntries) // 決算整理仕訳
                DataBaseManager.realm.delete(object) // 仕訳帳
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
}
