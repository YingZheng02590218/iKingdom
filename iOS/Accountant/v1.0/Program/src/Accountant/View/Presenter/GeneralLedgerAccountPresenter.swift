//
//  GeneralLedgerAccountPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/23.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GeneralLedgerAccountPresenterInput {
    
    var fiscalYear: Int? { get }
    
    var numberOfDatabaseJournalEntries: Int { get }
    var numberOfDataBaseAdjustingEntries: Int { get }
    var numberOfDataBaseTransferEntry: Int { get }
    var numberOfDataBaseCapitalTransferJournalEntry: Int { get }

    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry
    func dataBaseTransferEntries() -> DataBaseTransferEntry?
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry?

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String
    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceAmountCapitalTransferJournalEntry(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: IndexPath) -> String
    func getNumberOfAccount(accountName: String) -> Int
}

protocol GeneralLedgerAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
}

final class GeneralLedgerAccountPresenter: GeneralLedgerAccountPresenterInput {
    
    // MARK: - var let
    
    // 勘定名
    var account: String = ""
    var fiscalYear: Int?
    // 通常仕訳　勘定別
    private var databaseJournalEntries: Results<DataBaseJournalEntry>
    // 決算整理仕訳　勘定別　損益勘定を含む　繰越利益を含む
    private var dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>
    // 損益振替仕訳
    private var dataBaseTransferEntry: DataBaseTransferEntry?
    // 資本振替仕訳
    private var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?

    private weak var view: GeneralLedgerAccountPresenterOutput!
    private var model: GeneralLedgerAccountModelInput
    
    init(view: GeneralLedgerAccountPresenterOutput, model: GeneralLedgerAccountModelInput, account: String) {
        self.view = view
        self.model = model
        self.account = account
        
        // 通常仕訳　勘定別
        databaseJournalEntries = model.getJournalEntryInAccount(account: account)
        // 決算整理仕訳　勘定別
        dataBaseAdjustingEntries = model.getAdjustingJournalEntryInAccount(account: account)
        // 損益振替仕訳
        dataBaseTransferEntry = model.getTransferEntryInAccount(account: account)
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount()
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        model.initialize(
            account: account,
            databaseJournalEntries: databaseJournalEntries,
            dataBaseAdjustingEntries: dataBaseAdjustingEntries,
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        )
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        
        view.setupViewForViewWillAppear()
    }

    func viewWillDisappear() {

        view.setupViewForViewWillDisappear()
    }

    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfDatabaseJournalEntries: Int {
        databaseJournalEntries.count
    }
    
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry {
        databaseJournalEntries[row]
    }
    
    var numberOfDataBaseAdjustingEntries: Int {
        dataBaseAdjustingEntries.count
    }
    
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry {
        dataBaseAdjustingEntries[row]
    }

    var numberOfDataBaseTransferEntry: Int {
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger0 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger0 {
            // 損益振替仕訳
            if englishFromOfClosingTheLedger0 {
                return dataBaseTransferEntry == nil ? 0 : 1
            }
        }
        return 0
    }

    func dataBaseTransferEntries() -> DataBaseTransferEntry? {
        dataBaseTransferEntry
    }

    var numberOfDataBaseCapitalTransferJournalEntry: Int {
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger1 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger1 {
            // 資本振替仕訳
            if englishFromOfClosingTheLedger1 {
                // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
                // 法人/個人フラグ
                if UserDefaults.standard.bool(forKey: "corporation_switch") {
                    if account == CapitalAccountType.retainedEarnings.rawValue {
                        return dataBaseCapitalTransferJournalEntry == nil ? 0 : 1
                    }
                } else {
                    if account == CapitalAccountType.capital.rawValue {
                        return dataBaseCapitalTransferJournalEntry == nil ? 0 : 1
                    }
                }
            }
        }
        return 0
    }

    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry? {
        dataBaseCapitalTransferJournalEntry
    }
    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        
        model.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {
        
        model.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        
        model.getBalanceAmount(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {
        
        model.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // FIXME: 省略
//    // 取得　差引残高額 損益振替仕訳
//    func getBalanceAmountCapitalTransferJournalEntry() -> Int64 {
//
//        model.getBalanceAmountCapitalTransferJournalEntry()
//    }
//    // 借又貸を取得 損益振替仕訳
//    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String {
//
//        model.getBalanceDebitOrCreditCapitalTransferJournalEntry()
//    }
    // 取得　差引残高額　 資本振替仕訳
    func getBalanceAmountCapitalTransferJournalEntry(indexPath: IndexPath) -> Int64 {

        model.getBalanceAmountCapitalTransferJournalEntry(indexPath: indexPath)
    }
    // 借又貸を取得 資本振替仕訳
    func getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: IndexPath) -> String {

        model.getBalanceDebitOrCreditCapitalTransferJournalEntry(indexPath: indexPath)
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        
        model.getNumberOfAccount(accountName: accountName)
    }
}
