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

    var numberOfDataBaseOpeningJournalEntry: Int { get }
    var numberOfDatabaseJournalEntries: Int { get }
    var numberOfDataBaseAdjustingEntries: Int { get }
    var numberOfDataBaseTransferEntry: Int { get }
    var numberOfDataBaseCapitalTransferJournalEntry: Int { get }

    func dataBaseOpeningJournalEntries() -> DataBaseOpeningJournalEntry?
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry
    func dataBaseTransferEntries() -> DataBaseTransferEntry?
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry?

    var filePath: URL? { get }

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func getBalanceAmountOpeningJournalEntry() -> Int64
    func getBalanceDebitOrCreditOpeningJournalEntry() -> String
    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String
    func getBalanceAmountCapitalTransferJournalEntry() -> Int64
    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String
    func getNumberOfAccount(accountName: String) -> Int
    
    func pdfBarButtonItemTapped()
    func csvBarButtonItemTapped()
}

protocol GeneralLedgerAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}

final class GeneralLedgerAccountPresenter: GeneralLedgerAccountPresenterInput {
    
    // MARK: - var let
    
    // 勘定名
    var account: String = ""
    var fiscalYear: Int?
    // 開始仕訳　OpeningJournalEntry
    private var dataBaseOpeningJournalEntry: DataBaseOpeningJournalEntry?
    // 通常仕訳　勘定別
    private var databaseJournalEntries: Results<DataBaseJournalEntry>
    // 決算整理仕訳　勘定別　損益勘定を含む　繰越利益を含む
    private var dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>
    // 資本振替仕訳
    private var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    // 損益振替仕訳
    private var dataBaseTransferEntry: DataBaseTransferEntry?
    
    // PDF,CSVファイルのパス
    var filePath: URL?

    private weak var view: GeneralLedgerAccountPresenterOutput!
    private var model: GeneralLedgerAccountModelInput
    
    init(view: GeneralLedgerAccountPresenterOutput, model: GeneralLedgerAccountModelInput, account: String) {
        self.view = view
        self.model = model
        self.account = account
        // 開始仕訳
        dataBaseOpeningJournalEntry = model.getOpeningJournalEntryInAccount(account: account)
        // 通常仕訳　勘定別
        databaseJournalEntries = model.getJournalEntryInAccount(account: account)
        // 決算整理仕訳　勘定別
        dataBaseAdjustingEntries = model.getAdjustingJournalEntryInAccount(account: account)
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount(account: account)
        // 損益振替仕訳、残高振替仕訳
        dataBaseTransferEntry = model.getTransferEntryInAccount(account: account)
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        model.initialize(
            account: account,
            dataBaseOpeningJournalEntry: dataBaseOpeningJournalEntry,
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

    var numberOfDataBaseOpeningJournalEntry: Int {
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger2 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger2 {
            // 残高振替仕訳
            if englishFromOfClosingTheLedger2 {
                // 開始仕訳
                return dataBaseOpeningJournalEntry == nil ? 0 : 1
            }
        }
        return 0
    }

    func dataBaseOpeningJournalEntries() -> DataBaseOpeningJournalEntry? {
        dataBaseOpeningJournalEntry
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
        // 損益計算書に関する勘定科目のみに絞る
        if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            if let englishFromOfClosingTheLedger0 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger0 {
                // 損益振替仕訳
                if englishFromOfClosingTheLedger0 {
                    return dataBaseTransferEntry == nil ? 0 : 1
                }
            }
        } else {
            if let englishFromOfClosingTheLedger2 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger2 {
                // 残高振替仕訳
                if englishFromOfClosingTheLedger2 {
                    return dataBaseTransferEntry == nil ? 0 : 1
                }
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

    // MARK: - 差引残高額

    // 取得　差引残高額　 開始仕訳
    func getBalanceAmountOpeningJournalEntry() -> Int64 {

        model.getBalanceAmountOpeningJournalEntry()
    }
    // 借又貸を取得 開始仕訳
    func getBalanceDebitOrCreditOpeningJournalEntry() -> String {

        model.getBalanceDebitOrCreditOpeningJournalEntry()
    }
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {

        model.getBalanceAmount(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {

        model.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 取得　差引残高額　 決算整理仕訳
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        
        model.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {
        
        model.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    // 取得　差引残高額　 資本振替仕訳
    func getBalanceAmountCapitalTransferJournalEntry() -> Int64 {

        model.getBalanceAmountCapitalTransferJournalEntry()
    }
    // 借又貸を取得 資本振替仕訳
    func getBalanceDebitOrCreditCapitalTransferJournalEntry() -> String {

        model.getBalanceDebitOrCreditCapitalTransferJournalEntry()
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
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        
        model.getNumberOfAccount(accountName: accountName)
    }
    
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePdfMaker(account: account, completion: { filePath in
            
            self.filePath = filePath
            self.view.showPreview()
        })
    }
    
    // CSV機能
    func csvBarButtonItemTapped() {
        // 初期化
        model.initializeCsvMaker(account: account, completion: { csvPath in
                        
            self.filePath = csvPath
            self.view.showPreview()
        })
    }
}
