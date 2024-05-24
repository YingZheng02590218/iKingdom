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

    func getNumberOfAccount(accountName: String) -> Int
    
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry>
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry?
    
    func initializePdfMaker(completion: (URL?) -> Void)
    func initializeCsvMaker(completion: (URL?) -> Void)
}
// 損益勘定クラス
class GeneralLedgerPLAccountModel: GeneralLedgerPLAccountModelInput {
    
    // 印刷機能
    let pDFMaker = PDFMakerPLAccount()
    // 初期化 PDFメーカー
    func initializePdfMaker(completion: (URL?) -> Void) {
        
        pDFMaker.initialize(completion: { filePath in
            completion(filePath)
        })
    }
    
    // CSV機能
    let csvFileMaker = CsvFileMakerPLAccount()
    // 初期化
    func initializeCsvMaker(completion: (URL?) -> Void) {
        
        csvFileMaker.initialize(completion: { filePath in
            completion(filePath)
        })
    }
    
    // MARK: - CRUD
    
    // MARK: Create

    // MARK: Read

    // 取得　損益振替仕訳
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry> {
        DataBaseManagerPLAccount.shared.getTransferEntryInAccount()
    }
    // 取得 資本振替仕訳
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
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
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        ) // 毎回、計算は行わない
    }
    
    // MARK: Delete
    
}
