//
//  GenearlLedgerAccountPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/23.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GenearlLedgerAccountPresenterInput {
    
    var fiscalYear: Int? { get }

    var numberOfDatabaseJournalEntries: Int { get }
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry
    var numberOfDataBaseAdjustingEntries: Int { get }
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()

    func getBalanceAmountAdjusting(indexPath: IndexPath) ->Int64
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) ->String
    func getBalanceAmount(indexPath: IndexPath) ->Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) ->String
    func getNumberOfAccount(accountName: String) -> Int
}

protocol GenearlLedgerAccountPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewDidAppear()
}

final class GenearlLedgerAccountPresenter: GenearlLedgerAccountPresenterInput {

    // MARK: - var let
    
    // 勘定名
    var account :String = ""
    var fiscalYear: Int?
    // 通常仕訳　勘定別
    private var databaseJournalEntries: Results<DataBaseJournalEntry>
    // 決算整理仕訳　勘定別　損益勘定を含む　繰越利益を含む
    private var dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>
    
    private weak var view: GenearlLedgerAccountPresenterOutput!
    private var model: GenearlLedgerAccountModelInput

    init(view: GenearlLedgerAccountPresenterOutput, model: GenearlLedgerAccountModelInput, account: String) {
        self.view = view
        self.model = model
        self.account = account

        // 通常仕訳　勘定別
        databaseJournalEntries = model.getJournalEntryInAccount(account: account)
        // 決算整理仕訳　勘定別　損益勘定を含む　繰越利益を含む
        dataBaseAdjustingEntries = model.getAdjustingJournalEntryInAccount(account: account)
    }

    // MARK: - Life cycle

    func viewDidLoad() {
        
        model.initialize(account: account, databaseJournalEntries: databaseJournalEntries, dataBaseAdjustingEntries: dataBaseAdjustingEntries)

        view.setupViewForViewDidLoad()
    }

    func viewWillAppear() {

        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()

        view.setupViewForViewWillAppear()
    }

    func viewDidAppear() {

        view.setupViewForViewDidAppear()
    }

    var numberOfDatabaseJournalEntries: Int {
        return databaseJournalEntries.count
    }
    func databaseJournalEntries(forRow row: Int) -> DataBaseJournalEntry {
        return databaseJournalEntries[row]
    }
    
    var numberOfDataBaseAdjustingEntries: Int {
        return dataBaseAdjustingEntries.count
    }
    func dataBaseAdjustingEntries(forRow row: Int) -> DataBaseAdjustingEntry {
        return dataBaseAdjustingEntries[row]
    }

    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) ->Int64 {
        
        return model.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) ->String {
        
        return model.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) ->Int64 {
        
        return model.getBalanceAmount(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) ->String {
        
        return model.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        
        return model.getNumberOfAccount(accountName: accountName)
    }
}
