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
            let objects = DataBaseManager.realm.objects(DataBaseAccountingBooksShelf.self) // モデル
            return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
        } else if dataBase is DataBaseAccountingBooks {
            var objects = DataBaseManager.realm.objects(DataBaseAccountingBooks.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return !objects.isEmpty
        } else if dataBase is DataBaseJournals {
            var objects = DataBaseManager.realm.objects(DataBaseJournals.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return !objects.isEmpty
            
        } else if dataBase is DataBaseGeneralLedger {
            var objects = DataBaseManager.realm.objects(DataBaseGeneralLedger.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return !objects.isEmpty
        } else if dataBase is DataBaseFinancialStatements {
            var objects = DataBaseManager.realm.objects(DataBaseFinancialStatements.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return !objects.isEmpty
        } else {
            var objects = DataBaseManager.realm.objects(DataBaseJournals.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return !objects.isEmpty
        }
    }
    
    // 転記をやり直し　再度開いている帳簿の年度のすべての仕訳、決算整理仕訳を勘定へ転記する
    func reconnectJournalEntryToAccounts() {
        // 会計帳簿 年度を使用するため
        guard let dataBaseAccountingBook = DataBaseManager.realm.objects(DataBaseAccountingBooks.self).filter("openOrClose == \(true)").first else {
            return
        }
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
        let dataBaseJournalEntries = DataBaseManager.realm.objects(DataBaseJournalEntry.self)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 開いている帳簿の年度と同じ仕訳に絞り込む
        let dataBaseJournalAdjustingEntries = DataBaseManager.realm.objects(DataBaseAdjustingEntry.self)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")')")
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 借方勘定が損益勘定の場合
        let dataBasePLAccountJournalAdjustingEntriesDebit = DataBaseManager.realm.objects(DataBaseAdjustingEntry.self)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .filter("debit_category LIKE '\("損益勘定")' && !(credit_category LIKE '\("損益勘定")')")
            .sorted(byKeyPath: "date", ascending: true)
        // 決算整理仕訳 貸方勘定が損益勘定の場合
        let dataBasePLAccountJournalAdjustingEntriesCredit = DataBaseManager.realm.objects(DataBaseAdjustingEntry.self)
            .filter("fiscalYear == \(dataBaseAccountingBook.fiscalYear)")
            .filter("!(debit_category LIKE '\("損益勘定")') && credit_category LIKE '\("損益勘定")'")
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
            guard let leftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
            guard let leftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
            guard let leftObject: DataBasePLAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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
            guard let leftObject: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
                return
            }
            guard let rightObject: DataBasePLAccount = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else {
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

    /**
     * 会計帳簿.仕訳帳 オブジェクトを取得するメソッド
     * 年度を指定して仕訳帳を取得する
     * @param 年度
     * @return 仕訳帳
     */
    func getJournalsWithFiscalYear(fiscalYear: Int) -> DataBaseJournals? {
        let dataBaseAccountingBooks = DataBaseManager.realm.objects(DataBaseAccountingBooks.self).filter("fiscalYear == \(fiscalYear)")
        guard let dataBaseAccountingBook = dataBaseAccountingBooks.first else {
            return nil
        }

        guard let dataBaseJournals = dataBaseAccountingBook.dataBaseJournals else {
            return nil
        }

        return dataBaseJournals
    }

    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 勘定名と年度を指定して勘定を取得する
     * @param accountName 勘定名、fiscalYear 年度
     * @return  DataBaseAccount? 勘定、DataBasePLAccount? 損益勘定
     * 特殊化方法: 戻り値からの型推論による特殊化　戻り値の代入先の型が決まっている必要がある
     */
    func getAccountByAccountNameWithFiscalYear<T>(accountName: String, fiscalYear: Int) -> T? {
        guard let dataBaseAccountingBook = DataBaseManager.realm.objects(DataBaseAccountingBooks.self).filter("fiscalYear == \(fiscalYear)").first else {
            return nil
        }
        if accountName == "損益勘定" {
            // 損益勘定の場合
            guard let dataBasePLAccount = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBasePLAccount else {
                return nil
            }
            return dataBasePLAccount as? T
        } else {
            // 損益勘定以外の勘定の場合
            guard let dataBaseAccount = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts
                    .filter("accountName LIKE '\(accountName)'").first else { return nil }
            return dataBaseAccount as? T
        }
    }
}
