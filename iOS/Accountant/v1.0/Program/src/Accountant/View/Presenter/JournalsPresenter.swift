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
    var numberOfobjectsss: Int { get }
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    
    func refreshTable(isEditing: Bool)
    func cellLongPressed(indexPath: IndexPath)
    func deleteJournalEntry(number: Int) -> Bool
    func deleteAdjustingJournalEntry(number: Int) -> Bool
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int)
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: DBJournalEntry)
    func autoScroll(number: Int, tappedIndexPathSection: Int)
}

protocol JournalsPresenterOutput: AnyObject {
    func reloadData(primaryKeys: [Int]?, primaryKeysAdjusting: [Int]?)
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewDidAppear()
    func setupCellLongPressed(indexPath: IndexPath)
    func autoScroll(number: Int, tappedIndexPathSection: Int)
}

final class JournalsPresenter: JournalsPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 通常仕訳　全
    private var objects:Results<DataBaseJournalEntry>
    // 決算整理仕訳 (損益振替仕訳 資本振替仕訳)
    private var objectsss:Results<DataBaseAdjustingEntry>
        
    private weak var view: JournalsPresenterOutput!
    private var model: JournalsModelInput
    
    init(view: JournalsPresenterOutput, model: JournalsModelInput) {
        self.view = view
        self.model = model
                
        objects = model.getJournalEntryAll() // 通常仕訳　全
        objectsss = model.getJournalAdjustingEntry() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
                
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 会計年度を切り替えした場合、仕訳帳をリロードして選択された年度のデータを表示する
        objects = model.getJournalEntryAll() // 通常仕訳　全
        objectsss = model.getJournalAdjustingEntry() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        
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
    var numberOfobjectsss: Int {
        return objectsss.count
    }
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry {
        return objectsss[row]
    }
    
    func refreshTable(isEditing: Bool) {
        if !isEditing {
            // 全勘定の合計と残高を計算する
            model.initializeJournals(completion: { isFinished in
                print("Result is \(isFinished)")
                objects = model.getJournalEntryAll() // 通常仕訳　全
                objectsss = model.getJournalAdjustingEntry() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                // 更新処理
                view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
            })
        }
        else {
            // 更新処理
            view.reloadData()
        }
    }
    
    func cellLongPressed(indexPath: IndexPath) {
        
        view.setupCellLongPressed(indexPath: indexPath)
    }

    func autoScroll(number: Int, tappedIndexPathSection: Int) {
        
        view.autoScroll(number: number, tappedIndexPathSection: tappedIndexPathSection)
    }
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        
        let dataBaseManager = DataBaseManagerJournalEntry()
        return dataBaseManager.deleteJournalEntry(number: number)
    }
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        
        let dataBaseManager = DataBaseManagerJournalEntry()
        return dataBaseManager.deleteAdjustingJournalEntry(number: number)
    }
    // 年度を変更する
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int) {
        // 一括変更の処理
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                // 仕訳データを更新
                let _ = model.updateJournalEntry(
                    primaryKey: self.objects(forRow:indexPath.row).number,
                    fiscalYear: fiscalYear
                )
            }
            else if indexPath.section == 1 {
                // 決算整理仕訳データを更新
                let _ = model.updateAdjustingJournalEntry(
                    primaryKey: self.objectsss(forRow:indexPath.row).number,
                    fiscalYear: fiscalYear
                )
            }
            else {
                // 空白行
            }
        }
        // view にリロードさせる
        self.view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
    }
    // 仕訳データを編集した通りに更新する
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: DBJournalEntry) {
        var primaryKeys:[Int] = []
        var primaryKeysAdjusting:[Int] = []
        // 一括変更の処理
        for indexPath in indexPaths {
            if indexPath.section == 0 {
                // 仕訳データを更新
                model.updateJournalEntry(
                    primaryKey: self.objects(forRow:indexPath.row).number,
                    date: dBJournalEntry.date ?? self.objects(forRow:indexPath.row).date,
                    debit_category: dBJournalEntry.debit_category ?? self.objects(forRow:indexPath.row).debit_category,
                    debit_amount: dBJournalEntry.debit_amount ?? self.objects(forRow:indexPath.row).debit_amount,
                    credit_category: dBJournalEntry.credit_category ?? self.objects(forRow:indexPath.row).credit_category,
                    credit_amount: dBJournalEntry.credit_amount ?? self.objects(forRow:indexPath.row).credit_amount,
                    smallWritting: dBJournalEntry.smallWritting ?? self.objects(forRow:indexPath.row).smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeys.append(primaryKey)
                    })
            }
            else if indexPath.section == 1 {
                // 決算整理仕訳データを更新
                let _ = model.updateAdjustingJournalEntry(
                    primaryKey: self.objectsss(forRow:indexPath.row).number,
                    date: dBJournalEntry.date ?? self.objectsss(forRow:indexPath.row).date,
                    debit_category: dBJournalEntry.debit_category ?? self.objectsss(forRow:indexPath.row).debit_category,
                    debit_amount: dBJournalEntry.debit_amount ?? self.objectsss(forRow:indexPath.row).debit_amount,
                    credit_category: dBJournalEntry.credit_category ?? self.objectsss(forRow:indexPath.row).credit_category,
                    credit_amount: dBJournalEntry.credit_amount ?? self.objectsss(forRow:indexPath.row).credit_amount,
                    smallWritting: dBJournalEntry.smallWritting ?? self.objectsss(forRow:indexPath.row).smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeysAdjusting.append(primaryKey)
                    })
            }
            else {
                // 空白行
            }
        }
        objects = model.getJournalEntryAll() // 通常仕訳　全
        objectsss = model.getJournalAdjustingEntry() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        // view にリロードさせる
        self.view.reloadData(primaryKeys: primaryKeys, primaryKeysAdjusting: primaryKeysAdjusting)
    }
}
