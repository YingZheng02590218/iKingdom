//
//  GeneralLedgerAccountModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GeneralLedgerAccountModelInput {
    func initialize(account: String, databaseJournalEntries: Results<DataBaseJournalEntry>, dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>)

    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String
    func getNumberOfAccount(accountName: String) -> Int
    
    func getJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry>
    func getJournalEntryInCapitalAccount() -> Results<DataBaseJournalEntry>

    func getAdjustingJournalEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry?

    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
}
// 勘定クラス
class GeneralLedgerAccountModel: GeneralLedgerAccountModelInput {

    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　勘定
    func addGeneralLedgerAccount(number: Int) {
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
            // 設定画面の勘定科目一覧にある勘定を取得する
            if let dataBaseSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: number) {
                // オブジェクトを作成 勘定
                let dataBaseAccount = DataBaseAccount(
                    fiscalYear: dataBaseAccountingBook.fiscalYear,
                    accountName: dataBaseSettingsTaxonomyAccount.category,
                    debit_total: 0,
                    credit_total: 0,
                    debit_balance: 0,
                    credit_balance: 0,
                    debit_total_Adjusting: 0,
                    credit_total_Adjusting: 0,
                    debit_balance_Adjusting: 0,
                    credit_balance_Adjusting: 0,
                    debit_total_AfterAdjusting: 0,
                    credit_total_AfterAdjusting: 0,
                    debit_balance_AfterAdjusting: 0,
                    credit_balance_AfterAdjusting: 0
                )
                do {
                    try DataBaseManager.realm.write {
                        let num = dataBaseAccount.save() // dataBaseAccount.number = number
                        // 自動採番ではなく、設定勘定科目のプライマリーキーを使用する　2020/11/08 年度を追加すると勘定クラスの連番が既に使用されている
                        print("dataBaseAccount", number)
                        print("dataBaseAccount", num)
                        dataBaseGeneralLedger.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    // 追加　勘定　不足している勘定を追加する
    func addGeneralLedgerAccountLack() {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
            // 設定画面の勘定科目一覧にある勘定を取得する
            let objects = DataBaseManagerGeneralLedger.shared.getObjects()
            // 設定勘定科目と総勘定元帳ないの勘定を比較
            for i in 0..<objects.count {
                let dataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountName(accountName: objects[i].category)
                print("addGeneralLedgerAccountLack", objects[i].category)
                if dataBaseAccount != nil {
                    // print("勘定は存在する")
                } else {
                    // print("勘定が存在しない")
                    // オブジェクトを作成 勘定
                    let dataBaseAccount = DataBaseAccount(
                        fiscalYear: dataBaseAccountingBook.fiscalYear,
                        accountName: objects[i].category,
                        debit_total: 0,
                        credit_total: 0,
                        debit_balance: 0,
                        credit_balance: 0,
                        debit_total_Adjusting: 0,
                        credit_total_Adjusting: 0,
                        debit_balance_Adjusting: 0,
                        credit_balance_Adjusting: 0,
                        debit_total_AfterAdjusting: 0,
                        credit_total_AfterAdjusting: 0,
                        debit_balance_AfterAdjusting: 0,
                        credit_balance_AfterAdjusting: 0
                    )
                    do {
                        try DataBaseManager.realm.write {
                            let number = dataBaseAccount.save() //　自動採番
                            print("dataBaseAccount", number)
                            dataBaseGeneralLedger.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    
    // MARK: Read
    
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmount(indexPath: indexPath)
    }
    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    
    // 取得　通常仕訳 勘定別に取得
    func getJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry> {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseJournalEntries = (dataBaseAccount?.dataBaseJournalEntries.sorted(byKeyPath: "date", ascending: true))!
        return dataBaseJournalEntries
    }
    // 取得　通常仕訳 資本金勘定から取得
    func getJournalEntryInCapitalAccount() -> Results<DataBaseJournalEntry> {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
        let dataBaseJournalEntries = (dataBaseAccount?.dataBaseJournalEntries.sorted(byKeyPath: "date", ascending: true))!
        return dataBaseJournalEntries
    }
    // 取得 決算整理仕訳 勘定別に取得
    func getAdjustingJournalEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseJournalEntries = (dataBaseAccount?.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true))!
        return dataBaseJournalEntries
    }
    // 取得　損益振替仕訳 損益勘定から取得
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry> {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
        let dataBaseJournalEntries = (dataBasePLAccount?.dataBaseTransferEntries.sorted(byKeyPath: "date", ascending: true))!
        return dataBaseJournalEntries
    }
    // 取得　損益振替仕訳 勘定別に取得
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
        return dataBaseTransferEntry
    }
    // 取得 仕訳　勘定別 全年度
    func getAllJournalEntryInAccountAll(account: String) -> Results<DataBaseJournalEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseJournalEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)), // 条件を間違えないように注意する
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別　損益勘定以外 全年度
    func getAllAdjustingEntryInAccountAll(account: String) -> Results<DataBaseAdjustingEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)), // 条件を間違えないように注意する
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 損益振替仕訳　勘定別  全年度 (※損益科目の勘定科目)
    func getAllAdjustingEntryInPLAccountAll(account: String) -> Results<DataBaseTransferEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseTransferEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益")),
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別　損益勘定以外
    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAccount = dataBaseAccountingBooks.dataBaseGeneralLedger!.dataBaseAccounts
            .filter("accountName LIKE '\(account)'")
        var objects = dataBaseAccount[0].dataBaseAdjustingEntries
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }

    // 取得 資本振替仕訳　勘定別 損益勘定のみ　資本金勘定のみ
    func getAllCapitalTransferJournalEntry() -> Results<DataBaseCapitalTransferJournalEntry> {
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseCapitalTransferJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益")),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "資本金勘定"), NSString(string: "資本金勘定")) // FIXME: 資本金勘定
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }

    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfAccount(accountName: accountName)
    }
    
    // MARK: Update
    
    // 差引残高　計算
    func initialize(account: String, databaseJournalEntries: Results<DataBaseJournalEntry>, dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>) {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.calculateBalance(
            account: account,
            databaseJournalEntries: databaseJournalEntries,
            dataBaseAdjustingEntries: dataBaseAdjustingEntries
        ) // 毎回、計算は行わない
    }
    
    // MARK: Delete
    
    // 削除　勘定、よく使う仕訳　設定勘定科目を削除するときに呼ばれる
    func deleteAccount(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return false }
        // 勘定　全年度　取得
        let objectsssss = RealmManager.shared.readWithPredicate(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "accountName LIKE %@", NSString(string: object.category))
        ])
        // 勘定クラス　勘定ないの仕訳を取得
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: object.category) // 全年度の通常仕訳データを確認する
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: object.category) // 全年度の決算整理仕訳データを確認する
        let objectssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountAll(account: object.category) // 全年度の損益振替仕訳データを確認する
        let dataBaseSettingsOperatingJournalEntry = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(account: object.category) // よく使う仕訳

        // 仕訳クラス　仕訳を削除
        var isInvalidated = true // 初期値は真とする。仕訳データが0件の場合の対策
        var isInvalidatedd = true
        var isInvalidateddd = true
        var isInvalidatedddd = true
        // 仕訳を削除
        for _ in 0..<objectss.count {
            isInvalidated = DataBaseManagerJournalEntry.shared.deleteJournalEntry(number: objectss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 決算整理仕訳を削除
        for _ in 0..<objectsss.count {
            isInvalidatedd = DataBaseManagerAdjustingEntry.shared.deleteAdjustingJournalEntry(number: objectsss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 損益振替仕訳を削除
        for _ in 0..<objectssss.count {
            isInvalidateddd = DataBaseManagerTransferEntry.shared.deleteTransferEntry(number: objectssss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // よく使う仕訳を削除
        for _ in 0..<dataBaseSettingsOperatingJournalEntry.count {
            isInvalidatedddd = DataBaseManagerSettingsOperatingJournalEntry.shared.deleteJournalEntry(number: dataBaseSettingsOperatingJournalEntry[0].number)
        }

        if isInvalidatedddd {
            if isInvalidateddd {
                if isInvalidatedd {
                    if isInvalidated {
                        do {
                            try DataBaseManager.realm.write {
                                for _ in 0..<objectsssss.count {
                                    // 仕訳が残ってないか
                                    DataBaseManager.realm.delete(objectsssss[0])
                                }
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        return true // objectsssss.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
                    }
                }
            }
        }
        return false
    }
}
