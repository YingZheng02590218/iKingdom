//
//  JournalsPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/01.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol JournalsPresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    var numberOfobjects: Int { get }
    var numberOfobjectsss: Int { get }
    var numberOfDataBaseTransferEntries: Int { get }
    var numberOfDataBaseCapitalTransferJournalEntry: Int { get }
    
    func objects(forRow row: Int) -> DataBaseJournalEntry
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry
    func dataBaseTransferEntries(forRow row: Int) -> DataBaseTransferEntry
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry?
    
    var filePath: URL? { get }

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func refreshTable(isEditing: Bool)
    func cellLongPressed(indexPath: IndexPath)
    func pdfBarButtonItemTapped()
    func csvBarButtonItemTapped()
    func deleteJournalEntry(number: Int) -> Bool
    func deleteAdjustingJournalEntry(number: Int) -> Bool
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int)
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: JournalEntryData)
    func autoScroll(number: Int, tappedIndexPathSection: Int)
}

protocol JournalsPresenterOutput: AnyObject {
    func showActivityIndicatorView()
    func finishActivityIndicatorView()
    func reloadData(primaryKeys: [Int]?, primaryKeysAdjusting: [Int]?)
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func setupCellLongPressed(indexPath: IndexPath)
    func autoScroll(number: Int, tappedIndexPathSection: Int)
    func showPreview()
}

final class JournalsPresenter: JournalsPresenterInput {
    
    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 通常仕訳　全
    private var objects: Results<DataBaseJournalEntry>
    // 決算整理仕訳
    private var objectsss: Results<DataBaseAdjustingEntry>
    // 損益振替仕訳
    private var dataBaseTransferEntries: Results<DataBaseTransferEntry>
    // 資本振替仕訳
    private var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    
    // PDF,CSVファイルのパス
    var filePath: URL?
    
    private weak var view: JournalsPresenterOutput!
    private var model: JournalsModelInput
    
    init(view: JournalsPresenterOutput, model: JournalsModelInput) {
        self.view = view
        self.model = model
        
        // 通常仕訳　全
        objects = model.getJournalEntriesInJournals()
        // 決算整理仕訳
        objectsss = model.getJournalAdjustingEntry()
        // 損益振替仕訳
        dataBaseTransferEntries = model.getTransferEntryInAccount()
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount()
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        self.company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        self.fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        self.theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        DispatchQueue.main.async {
            // 会計年度を切り替えした場合、仕訳帳をリロードして選択された年度のデータを表示する
            // 通常仕訳　全
            self.objects = self.model.getJournalEntriesInJournals()
            // 決算整理仕訳
            self.objectsss = self.model.getJournalAdjustingEntry()
            // 損益振替仕訳
            self.dataBaseTransferEntries = self.model.getTransferEntryInAccount()
            // 資本振替仕訳
            self.dataBaseCapitalTransferJournalEntry = self.model.getCapitalTransferJournalEntryInAccount()
        }
        self.view.setupViewForViewWillAppear()
    }
    
    func viewWillDisappear() {
        
        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfobjects: Int {
        objects.count
    }
    
    func objects(forRow row: Int) -> DataBaseJournalEntry {
        objects[row]
    }
    
    var numberOfobjectsss: Int {
        objectsss.count
    }
    
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry {
        objectsss[row]
    }
    
    var numberOfDataBaseTransferEntries: Int {
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger0 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger0 {
            // 損益振替仕訳
            if englishFromOfClosingTheLedger0 {
                return dataBaseTransferEntries.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func dataBaseTransferEntries(forRow row: Int) -> DataBaseTransferEntry {
        dataBaseTransferEntries[row]
    }
    
    var numberOfDataBaseCapitalTransferJournalEntry: Int {
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger1 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger1 {
            // 資本振替仕訳
            if englishFromOfClosingTheLedger1 {
                return dataBaseCapitalTransferJournalEntry == nil ? 0 : 1
            }
        }
        return 0
    }
    
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry? {
        dataBaseCapitalTransferJournalEntry
    }
    
    func refreshTable(isEditing: Bool) {
        if !isEditing {
            // インジゲーターを開始
            view.showActivityIndicatorView()
            DispatchQueue.global(qos: .default).async {
                // 全勘定の合計と残高を計算する
                self.model.initializeJournals(completion: { isFinished in
                    print("Result is \(isFinished)")
                    // 重要: 仕訳データを参照する際、メインスレッドで行う
                    DispatchQueue.main.async {
                        // 通常仕訳　全
                        self.objects = self.model.getJournalEntriesInJournals()
                        // 決算整理仕訳
                        self.objectsss = self.model.getJournalAdjustingEntry()
                        // 損益振替仕訳
                        self.dataBaseTransferEntries = self.model.getTransferEntryInAccount()
                        // 資本振替仕訳
                        self.dataBaseCapitalTransferJournalEntry = self.model.getCapitalTransferJournalEntryInAccount()
                        // 更新処理
                        self.view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
                        // インジケーターを終了
                        self.view.finishActivityIndicatorView()
                    }
                })
            }
        } else {
            // 更新処理
            view.reloadData()
        }
    }
    
    func cellLongPressed(indexPath: IndexPath) {
        
        view.setupCellLongPressed(indexPath: indexPath)
    }
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePdfMaker(completion: { filePath in
            
            self.filePath = filePath
            self.view.showPreview()
        })
    }
    
    // CSV機能
    func csvBarButtonItemTapped() {
        // 初期化
        model.initializeCsvMaker(completion: { csvPath in
                        
            self.filePath = csvPath
            self.view.showPreview()
        })
    }
    
    func autoScroll(number: Int, tappedIndexPathSection: Int) {
        DispatchQueue.main.async {
            // 通常仕訳　全
            self.objects = self.model.getJournalEntriesInJournals()
            // 決算整理仕訳
            self.objectsss = self.model.getJournalAdjustingEntry()
            // 損益振替仕訳
            self.dataBaseTransferEntries = self.model.getTransferEntryInAccount()
            // 資本振替仕訳
            self.dataBaseCapitalTransferJournalEntry = self.model.getCapitalTransferJournalEntryInAccount()
            
            // オートスクロール
            self.view.autoScroll(number: number, tappedIndexPathSection: tappedIndexPathSection)
        }
    }
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        
        DataBaseManagerJournalEntry.shared.deleteJournalEntry(number: number)
    }
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        
        DataBaseManagerAdjustingEntry.shared.deleteAdjustingJournalEntry(number: number)
    }
    // 年度を変更する
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int) {
        // 一括変更の処理
        var numbers: [Int] = []
        var numbersAdjusting: [Int] = []
        
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                // 仕訳の連番を保持
                numbers.append(self.objects(forRow: indexPath.row).number)
            } else if indexPath.section == 1 {
                // 決算整理仕訳の連番を保持
                numbersAdjusting.append(self.objectsss(forRow: indexPath.row).number)
            } else {
                // 空白行
            }
        }
        for number in numbers {
            // 仕訳データを更新
            _ = model.updateJournalEntry(
                primaryKey: number,
                fiscalYear: fiscalYear
            )
        }
        for number in numbersAdjusting {
            // 決算整理仕訳データを更新
            _ = model.updateAdjustingJournalEntry(
                primaryKey: number,
                fiscalYear: fiscalYear
            )
        }
        // view にリロードさせる
        self.view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
    }
    // 仕訳データを編集した通りに更新する
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: JournalEntryData) {
        // インジゲーターを開始
        view.showActivityIndicatorView()
        
        var numbers: [Int] = []
        var numbersAdjusting: [Int] = []
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                // 仕訳の連番を保持
                numbers.append(self.objects(forRow: indexPath.row).number)
            } else if indexPath.section == 1 {
                // 決算整理仕訳の連番を保持
                numbersAdjusting.append(self.objectsss(forRow: indexPath.row).number)
            } else {
                // 空白行
            }
        }
        DispatchQueue.global(qos: .default).async {
            var primaryKeys: [Int] = []
            var primaryKeysAdjusting: [Int] = []
            // 一括変更の処理
            for number in numbers {
                // 仕訳データを更新
                self.model.updateJournalEntry(
                    primaryKey: number,
                    date: dBJournalEntry.date,
                    debitCategory: dBJournalEntry.debit_category,
                    debitAmount: dBJournalEntry.debit_amount,
                    creditCategory: dBJournalEntry.credit_category,
                    creditAmount: dBJournalEntry.credit_amount,
                    smallWritting: dBJournalEntry.smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeys.append(primaryKey)
                    }
                )
            }
            for number in numbersAdjusting {
                // 決算整理仕訳データを更新
                _ = self.model.updateAdjustingJournalEntry(
                    primaryKey: number,
                    date: dBJournalEntry.date,
                    debitCategory: dBJournalEntry.debit_category,
                    debitAmount: dBJournalEntry.debit_amount,
                    creditCategory: dBJournalEntry.credit_category,
                    creditAmount: dBJournalEntry.credit_amount,
                    smallWritting: dBJournalEntry.smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeysAdjusting.append(primaryKey)
                    }
                )
            }
            // 重要: 仕訳データを参照する際、メインスレッドで行う
            DispatchQueue.main.async {
                // 通常仕訳　全
                self.objects = self.model.getJournalEntriesInJournals()
                // 決算整理仕訳
                self.objectsss = self.model.getJournalAdjustingEntry()
                // 損益振替仕訳
                self.dataBaseTransferEntries = self.model.getTransferEntryInAccount()
                // 資本振替仕訳
                self.dataBaseCapitalTransferJournalEntry = self.model.getCapitalTransferJournalEntryInAccount()
                
                // view にリロードさせる
                self.view.reloadData(primaryKeys: primaryKeys, primaryKeysAdjusting: primaryKeysAdjusting)
                // インジケーターを終了
                self.view.finishActivityIndicatorView()
            }
        }
    }
}
