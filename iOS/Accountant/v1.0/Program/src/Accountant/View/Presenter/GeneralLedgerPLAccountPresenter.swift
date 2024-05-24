//
//  GeneralLedgerPLAccountPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/23.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GeneralLedgerPLAccountPresenterInput {
    
    var fiscalYear: Int? { get }
    
    var numberOfDataBaseTransferEntries: Int { get }
    var numberOfDataBaseCapitalTransferJournalEntry: Int { get }
    
    func dataBaseTransferEntries(forRow row: Int) -> DataBaseTransferEntry
    func dataBaseCapitalTransferJournalEntries() -> DataBaseCapitalTransferJournalEntry?
    
    var filePath: URL? { get }

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()

    func getNumberOfAccount(accountName: String) -> Int
    
    func pdfBarButtonItemTapped()
    func csvBarButtonItemTapped()
}

protocol GeneralLedgerPLAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}

final class GeneralLedgerPLAccountPresenter: GeneralLedgerPLAccountPresenterInput {
    
    // MARK: - var let

    var fiscalYear: Int?
    // 損益振替仕訳
    private var dataBaseTransferEntries: Results<DataBaseTransferEntry>
    // 資本振替仕訳
    private var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    // PDF,CSVファイルのパス
    var filePath: URL?

    private weak var view: GeneralLedgerPLAccountPresenterOutput!
    private var model: GeneralLedgerPLAccountModelInput
    
    init(view: GeneralLedgerPLAccountPresenterOutput, model: GeneralLedgerPLAccountModelInput) {
        self.view = view
        self.model = model

        // 損益振替仕訳
        dataBaseTransferEntries = model.getTransferEntryInAccount()
        // 資本振替仕訳
        dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount()
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        model.initialize(
            dataBaseTransferEntries: dataBaseTransferEntries,
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
    
    var numberOfDataBaseTransferEntries: Int {
        dataBaseTransferEntries.count
    }
    
    func dataBaseTransferEntries(forRow row: Int) -> DataBaseTransferEntry {
        dataBaseTransferEntries[row]
    }
    
    var numberOfDataBaseCapitalTransferJournalEntry: Int {
        dataBaseCapitalTransferJournalEntry == nil ? 0 : 1
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
        model.initializePdfMaker(completion: { PDFpath in
            
            self.filePath = PDFpath
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
}
