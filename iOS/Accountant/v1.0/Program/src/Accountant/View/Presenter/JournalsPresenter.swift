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
    func objects(forRow row: Int) -> DataBaseJournalEntry
    var numberOfobjectss: Int { get }
    func objectss(forRow row: Int) -> DataBaseAdjustingEntry
    var numberOfobjectsss: Int { get }
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    
    func refreshTable()
    func cellLongPressed(indexPath: IndexPath)
    func deleteJournalEntry(number: Int) -> Bool
}

protocol JournalsPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewDidAppear()
    func setupCellLongPressed(indexPath: IndexPath)
}

final class JournalsPresenter: JournalsPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 通常仕訳　全
    private var objects:Results<DataBaseJournalEntry>
    // 決算整理仕訳　全
    private var objectss:Results<DataBaseAdjustingEntry>
    // 決算整理仕訳 決算整理仕訳 損益振替仕訳 資本振替仕訳
    private var objectsss:Results<DataBaseAdjustingEntry>
    // 財務諸表
    private var object:DataBaseFinancialStatements
    
    private var objectettingsOperating:DataBaseSettingsOperating?
    
    private weak var view: JournalsPresenterOutput!
    private var model: JournalsModelInput
    
    init(view: JournalsPresenterOutput, model: JournalsModelInput) {
        self.view = view
        self.model = model
                
        objects = model.getJournalEntryAll() // 通常仕訳　全
        objectss = model.getAdjustingEntryAll() // 決算整理仕訳　全
        // 設定操作
        objectettingsOperating = model.getSettingsOperating()
        objectsss = model.getJournalAdjustingEntry(section: 0000,
                                                             EnglishFromOfClosingTheLedger0: objectettingsOperating!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: objectettingsOperating!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        
        object = model.getFinancialStatements()
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
        
        model.initializeJournals()
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        
        view.setupViewForViewWillAppear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfobjects: Int {
        return objects.count
    }
    func objects(forRow row: Int) -> DataBaseJournalEntry {
        return objects[row]
    }
    var numberOfobjectss: Int {
        return objectss.count
    }
    func objectss(forRow row: Int) -> DataBaseAdjustingEntry {
        return objectss[row]
    }
    var numberOfobjectsss: Int {
        return objectsss.count
    }
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry {
        return objectsss[row]
    }
    
    func refreshTable() {
        objects = model.getJournalEntryAll() // 通常仕訳　全
        objectss = model.getAdjustingEntryAll() // 決算整理仕訳　全
        // 設定操作
        objectettingsOperating = model.getSettingsOperating()
        objectsss = model.getJournalAdjustingEntry(section: 0000,
                                                             EnglishFromOfClosingTheLedger0: objectettingsOperating!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: objectettingsOperating!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        
        object = model.getFinancialStatements()
        // 全勘定の合計と残高を計算する
        model.initializeJournals()

        // 更新処理
        view.reloadData()
    }
    
    func cellLongPressed(indexPath: IndexPath) {
        
        view.setupCellLongPressed(indexPath: indexPath)
    }

    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        
        let dataBaseManager = DataBaseManagerJournalEntry()
        return dataBaseManager.deleteJournalEntry(number: number)
    }
}
