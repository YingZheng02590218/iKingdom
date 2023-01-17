//
//  GenearlLedgerAccountPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/14.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GenearlLedgerAccountPresenterInput {
    
//    var company: String? { get }
//    var fiscalYear: Int? { get }
//    var theDayOfReckoning: String? { get }
//
    var numberOfobjects: Int { get }
    var numberOfobjectss: Int { get }
    var numberOfobjectsss: Int { get }
    var numberOfobjectssss: Int { get }

    func objects(forRow row: Int) -> DataBaseJournalEntry
    func objectss(forRow row: Int) -> DataBaseAdjustingEntry
    func objectsss(forRow row: Int) -> DataBaseJournalEntry
    func objectssss(forRow row: Int) -> DataBaseAdjustingEntry
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
}

protocol GenearlLedgerAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewDidAppear()
}

final class GenearlLedgerAccountPresenter: GenearlLedgerAccountPresenterInput {

    // MARK: - var let
    
    let dataBaseManagerGeneralLedgerAccountBalance = DataBaseManagerGeneralLedgerAccountBalance()

//    var company: String?
//    var fiscalYear: Int?
//    var theDayOfReckoning: String?
    // 通常仕訳　勘定別
    private var objects: Results<DataBaseJournalEntry>
    // 決算整理仕訳　勘定別　損益勘定以外
    private var objectss: Results<DataBaseAdjustingEntry>
    // 通常仕訳　勘定別に月別に取得
    private var objectsss: Results<DataBaseJournalEntry>
    // 決算整理仕訳　勘定別に取得
    private var objectssss: Results<DataBaseAdjustingEntry>
    // 勘定別に損益の仕訳のみを取得
    private var objectsssss: Results<DataBaseAdjustingEntry>
    
    private weak var view: GenearlLedgerAccountPresenterOutput!
    private var model: GenearlLedgerAccountModelInput
    
    init(view: GenearlLedgerAccountPresenterOutput, model: GenearlLedgerAccountModelInput, account: String) {
        self.view = view
        self.model = model
                
        objects = model.getAllJournalEntryInAccount(account: account) // 通常仕訳　勘定別
        objectss = model.getAllAdjustingEntryInAccount(account: account) // 決算整理仕訳　勘定別　損益勘定以外
        objectsss = model.getJournalEntryInAccount(account: account) // 通常仕訳　勘定別に月別に取得
        objectssss = model.getAdjustingJournalEntryInAccount(account: account) // 決算整理仕訳　勘定別に取得
        objectsssss = model.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: account) // 勘定別に損益の仕訳のみを取得

//        object = model.getFinancialStatements()
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
        
//        model.initializeJournals()
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
//        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
//        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
//        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        
        view.setupViewForViewWillAppear()
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
    
    var numberOfobjectss: Int {
        objectss.count
    }

    func objectss(forRow row: Int) -> DataBaseAdjustingEntry {
        objectss[row]
    }
    
    var numberOfobjectsss: Int {
        objectsss.count
    }

    func objectsss(forRow row: Int) -> DataBaseJournalEntry {
        objectsss[row]
    }
    
    var numberOfobjectssss: Int {
        objectssss.count
    }

    func objectssss(forRow row: Int) -> DataBaseAdjustingEntry {
        objectssss[row]
    }
}
