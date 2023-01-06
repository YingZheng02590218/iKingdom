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
protocol GeneralLedgerPLAccountModelInput {
    func initialize(dataBaseTransferEntries: Results<DataBaseTransferEntry>, dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?)

    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceAmountCapitalTransferJournalEntry(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: IndexPath) -> String
    func getNumberOfAccount(accountName: String) -> Int
    
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry>
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry?
}
// 損益勘定クラス
class GeneralLedgerPLAccountModel: GeneralLedgerPLAccountModelInput {

    // MARK: - CRUD
    
    // MARK: Create

    // MARK: Read
    
    // 取得　差引残高額 損益振替仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        // 損益勘定用
        DataBaseManagerGeneralLedgerPLAccountBalance.shared.getBalanceAmount(indexPath: indexPath)
    }
    // 取得　差引残高額 資本振替仕訳
    func getBalanceAmountCapitalTransferJournalEntry(indexPath: IndexPath) -> Int64 {

        DataBaseManagerGeneralLedgerPLAccountBalance.shared.getBalanceAmountCapitalTransferJournalEntry(indexPath: indexPath)
    }
    // 借又貸を取得 損益振替仕訳
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {
        
        DataBaseManagerGeneralLedgerPLAccountBalance.shared.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 借又貸を取得 資本振替仕訳
    func getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: IndexPath) -> String {

        DataBaseManagerGeneralLedgerPLAccountBalance.shared.getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: indexPath)
    }

    // 取得　損益振替仕訳
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry> {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        // 損益勘定の場合
        let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
        let dataBaseJournalEntries = (dataBasePLAccount?.dataBaseTransferEntries.sorted(byKeyPath: "date", ascending: true))!
        print(dataBaseJournalEntries)
        return dataBaseJournalEntries
    }
    // 取得 資本振替仕訳
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        // 損益勘定の場合
        let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
        let dataBaseJournalEntries = dataBasePLAccount?.dataBaseCapitalTransferJournalEntry
        return dataBaseJournalEntries
    }
    
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfAccount(accountName: accountName)
    }
    
    // MARK: Update
    
    // 差引残高　計算
    func initialize(dataBaseTransferEntries: Results<DataBaseTransferEntry>, dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?) {
        
        DataBaseManagerGeneralLedgerPLAccountBalance.shared.calculateBalance(
            dataBaseTransferEntries: dataBaseTransferEntries,
            dataBaseAdjustingEntries: dataBaseCapitalTransferJournalEntry
        ) // 毎回、計算は行わない
    }
    
    // MARK: Delete
    
}
