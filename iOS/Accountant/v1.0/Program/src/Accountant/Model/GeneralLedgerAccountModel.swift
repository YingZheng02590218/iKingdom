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
    func initialize(
        account: String,
        dataBaseOpeningJournalEntry: DataBaseOpeningJournalEntry?,
        databaseJournalEntries: Results<DataBaseJournalEntry>,
        dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>,
        dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    )

    func getBalanceAmountOpeningJournalEntry() -> Int64
    func getBalanceDebitOrCreditOpeningJournalEntry() -> String
    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String
    func getBalanceAmountCapitalTransferJournalEntry() -> Int64
    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String

    func getNumberOfAccount(accountName: String) -> Int
    func getOpeningJournalEntryInAccount(account: String) -> DataBaseOpeningJournalEntry?
    func getJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry>
    func getAdjustingJournalEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry?
    func getCapitalTransferJournalEntryInAccount(account: String) -> DataBaseCapitalTransferJournalEntry?

    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
    
    func initializePdfMaker(account: String, completion: (URL?) -> Void)
    func initializeCsvMaker(account: String, completion: (URL?) -> Void)
}
// 勘定クラス
class GeneralLedgerAccountModel: GeneralLedgerAccountModelInput {

    // 印刷機能
    let pDFMaker = PDFMakerAccount()
    // 初期化 PDFメーカー
    func initializePdfMaker(account: String, completion: (URL?) -> Void) {
        
        pDFMaker.initialize(account: account, completion: { filePath in
            completion(filePath)
        })
    }
    
    // CSV機能
    let csvFileMaker = CsvFileMakerAccount()
    // 初期化
    func initializeCsvMaker(account: String, completion: (URL?) -> Void) {
        
        csvFileMaker.initialize(account: account, completion: { filePath in
            completion(filePath)
        })
    }
    
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

    // 取得　差引残高額　 開始仕訳
    func getBalanceAmountOpeningJournalEntry() -> Int64 {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmountOpeningJournalEntry()
    }
    // 借又貸を取得 開始仕訳
    func getBalanceDebitOrCreditOpeningJournalEntry() -> String {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCreditOpeningJournalEntry()
    }
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmount(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 取得　差引残高額　 決算整理仕訳
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    // 取得　差引残高額　 資本振替仕訳
    func getBalanceAmountCapitalTransferJournalEntry() -> Int64 {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceAmountCapitalTransferJournalEntry()
    }
    // 借又貸を取得 資本振替仕訳
    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String {

        DataBaseManagerGeneralLedgerAccountBalance.shared.getBalanceDebitOrCreditCapitalTransferJournalEntry()
    }

    // MARK: - 勘定
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
    // 取得 決算整理仕訳　勘定別に取得
    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAccount = dataBaseAccountingBooks.dataBaseGeneralLedger!.dataBaseAccounts
            .filter("accountName LIKE '\(account)'")
        var objects = dataBaseAccount[0].dataBaseAdjustingEntries
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得　損益振替仕訳 勘定別に取得
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry? {

        DataBaseManagerAccount.shared.getTransferEntryInAccount(account: account)
    }

    // 取得　開始仕訳 勘定別に取得
    func getOpeningJournalEntryInAccount(account: String) -> DataBaseOpeningJournalEntry? {

        DataBaseManagerAccount.shared.getOpeningJournalEntryInAccount(account: account)
    }

    // MARK: - 資本金勘定
    // 取得 資本振替仕訳 資本金勘定から取得
    func getCapitalTransferJournalEntryInAccount(account: String) -> DataBaseCapitalTransferJournalEntry? {
        if account == Constant.capitalAccountName {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
            let dataBaseCapitalTransferJournalEntry = dataBaseAccount?.dataBaseCapitalTransferJournalEntry
            return dataBaseCapitalTransferJournalEntry
        } else {
            return nil
        }
    }
    // 取得 資本振替仕訳　勘定別 損益勘定のみ　資本金勘定のみ
    func getAllCapitalTransferJournalEntry() -> Results<DataBaseCapitalTransferJournalEntry> {
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseCapitalTransferJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益")),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "資本金勘定"), NSString(string: "資本金勘定"))
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
    func initialize(
        account: String,
        dataBaseOpeningJournalEntry: DataBaseOpeningJournalEntry?,
        databaseJournalEntries: Results<DataBaseJournalEntry>,
        dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>,
        dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    ) {
        
        DataBaseManagerGeneralLedgerAccountBalance.shared.calculateBalance(
            account: account,
            dataBaseOpeningJournalEntry: dataBaseOpeningJournalEntry,
            databaseJournalEntries: databaseJournalEntries,
            dataBaseAdjustingEntries: dataBaseAdjustingEntries,
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        ) // 毎回、計算は行わない
    }
    
    // MARK: Delete

}
