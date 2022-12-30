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
            guard let journals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
            guard let journals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
            guard let journals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
        // 貸方勘定が損益勘定の場合
        for dataBaseJournalEntry in dataBasePLAccountJournalAdjustingEntriesCredit {
            guard let journals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBasePLAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
    
}
