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
    func numberOfDatabaseJournalEntries(forSection: Int) -> Int
    var numberOfDataBaseAdjustingEntries: Int { get }
    var numberOfDataBaseTransferEntry: Int { get }
    var numberOfDataBaseCapitalTransferJournalEntry: Int { get }
    
    func dataBaseOpeningJournalEntries() -> DataBaseOpeningJournalEntry?
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry
    func databaseJournalEntries(forSection: Int, forRow row: Int) -> DataBaseJournalEntry?
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry
    func dataBaseTransferEntries() -> DataBaseTransferEntry?
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry?
    
    var filePath: URL? { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func getNumberOfAccount(accountName: String) -> Int
    
    func pdfBarButtonItemTapped()
    func csvBarButtonItemTapped()
    func cellLongPressed(indexPath: IndexPath)
}

protocol GeneralLedgerAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func setupCellLongPressed(indexPath: IndexPath)
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
    // 通常仕訳 勘定別に月別に取得
    private var databaseJournalEntriesSection0: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection1: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection2: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection3: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection4: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection5: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection6: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection7: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection8: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection9: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection10: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection11: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection12: Results<DataBaseJournalEntry>?
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
        
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for i in 0..<lastDays.count {
            // 通常仕訳 勘定別に月別に取得
            let dataBaseJournalEntries = model.getJournalEntryInAccountInMonth(
                account: account,
                yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
            )
            switch i {
            case 0:
                databaseJournalEntriesSection0 = dataBaseJournalEntries
            case 1:
                databaseJournalEntriesSection1 = dataBaseJournalEntries
            case 2:
                databaseJournalEntriesSection2 = dataBaseJournalEntries
            case 3:
                databaseJournalEntriesSection3 = dataBaseJournalEntries
            case 4:
                databaseJournalEntriesSection4 = dataBaseJournalEntries
            case 5:
                databaseJournalEntriesSection5 = dataBaseJournalEntries
            case 6:
                databaseJournalEntriesSection6 = dataBaseJournalEntries
            case 7:
                databaseJournalEntriesSection7 = dataBaseJournalEntries
            case 8:
                databaseJournalEntriesSection8 = dataBaseJournalEntries
            case 9:
                databaseJournalEntriesSection9 = dataBaseJournalEntries
            case 10:
                databaseJournalEntriesSection10 = dataBaseJournalEntries
            case 11:
                databaseJournalEntriesSection11 = dataBaseJournalEntries
            case 12:
                databaseJournalEntriesSection12 = dataBaseJournalEntries
            default:
                break
            }
        }
        // 決算整理仕訳　勘定別
        dataBaseAdjustingEntries = model.getAdjustingJournalEntryInAccount(account: account)
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount(account: account)
        // 損益振替仕訳、残高振替仕訳
        dataBaseTransferEntry = model.getTransferEntryInAccount(account: account)
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        // 開始仕訳
        dataBaseOpeningJournalEntry = model.getOpeningJournalEntryInAccount(account: account)
        // 通常仕訳　勘定別
        databaseJournalEntries = model.getJournalEntryInAccount(account: account)
        
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for i in 0..<lastDays.count {
            // 通常仕訳 勘定別に月別に取得
            let dataBaseJournalEntries = model.getJournalEntryInAccountInMonth(
                account: account,
                yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
            )
            switch i {
            case 0:
                databaseJournalEntriesSection0 = dataBaseJournalEntries
            case 1:
                databaseJournalEntriesSection1 = dataBaseJournalEntries
            case 2:
                databaseJournalEntriesSection2 = dataBaseJournalEntries
            case 3:
                databaseJournalEntriesSection3 = dataBaseJournalEntries
            case 4:
                databaseJournalEntriesSection4 = dataBaseJournalEntries
            case 5:
                databaseJournalEntriesSection5 = dataBaseJournalEntries
            case 6:
                databaseJournalEntriesSection6 = dataBaseJournalEntries
            case 7:
                databaseJournalEntriesSection7 = dataBaseJournalEntries
            case 8:
                databaseJournalEntriesSection8 = dataBaseJournalEntries
            case 9:
                databaseJournalEntriesSection9 = dataBaseJournalEntries
            case 10:
                databaseJournalEntriesSection10 = dataBaseJournalEntries
            case 11:
                databaseJournalEntriesSection11 = dataBaseJournalEntries
            case 12:
                databaseJournalEntriesSection12 = dataBaseJournalEntries
            default:
                break
            }
        }
        // 決算整理仕訳　勘定別
        dataBaseAdjustingEntries = model.getAdjustingJournalEntryInAccount(account: account)
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount(account: account)
        // 損益振替仕訳、残高振替仕訳
        dataBaseTransferEntry = model.getTransferEntryInAccount(account: account)

        model.initialize(
            account: account,
            dataBaseOpeningJournalEntry: dataBaseOpeningJournalEntry,
            databaseJournalEntries: databaseJournalEntries,
            dataBaseAdjustingEntries: dataBaseAdjustingEntries,
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        )
        
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
    
    // 通常仕訳
    var numberOfDatabaseJournalEntries: Int {
        databaseJournalEntries.count
    }
    // 通常仕訳
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry {
        databaseJournalEntries[row]
    }
    
    // 通常仕訳　月次残高
    func numberOfDatabaseJournalEntries(forSection: Int) -> Int {
        switch forSection {
        case 0:
            return databaseJournalEntriesSection0?.count ?? 0
        case 1:
            return databaseJournalEntriesSection1?.count ?? 0
        case 2:
            return databaseJournalEntriesSection2?.count ?? 0
        case 3:
            return databaseJournalEntriesSection3?.count ?? 0
        case 4:
            return databaseJournalEntriesSection4?.count ?? 0
        case 5:
            return databaseJournalEntriesSection5?.count ?? 0
        case 6:
            return databaseJournalEntriesSection6?.count ?? 0
        case 7:
            return databaseJournalEntriesSection7?.count ?? 0
        case 8:
            return databaseJournalEntriesSection8?.count ?? 0
        case 9:
            return databaseJournalEntriesSection9?.count ?? 0
        case 10:
            return databaseJournalEntriesSection10?.count ?? 0
        case 11:
            return databaseJournalEntriesSection11?.count ?? 0
        case 12:
            return databaseJournalEntriesSection12?.count ?? 0
        default:
            return 0
        }
    }
    // 通常仕訳　月次残高
    func databaseJournalEntries(forSection: Int, forRow row: Int) -> DataBaseJournalEntry? {
        switch forSection {
        case 0:
            return databaseJournalEntriesSection0?[row]
        case 1:
            return databaseJournalEntriesSection1?[row]
        case 2:
            return databaseJournalEntriesSection2?[row]
        case 3:
            return databaseJournalEntriesSection3?[row]
        case 4:
            return databaseJournalEntriesSection4?[row]
        case 5:
            return databaseJournalEntriesSection5?[row]
        case 6:
            return databaseJournalEntriesSection6?[row]
        case 7:
            return databaseJournalEntriesSection7?[row]
        case 8:
            return databaseJournalEntriesSection8?[row]
        case 9:
            return databaseJournalEntriesSection9?[row]
        case 10:
            return databaseJournalEntriesSection10?[row]
        case 11:
            return databaseJournalEntriesSection11?[row]
        case 12:
            return databaseJournalEntriesSection12?[row]
        default:
            return nil
        }
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
    
    func cellLongPressed(indexPath: IndexPath) {
        
        view.setupCellLongPressed(indexPath: indexPath)
    }
}
