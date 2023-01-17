//
//  AfterClosingTrialBalancePresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol AfterClosingTrialBalancePresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    var numberOfobjects: Int { get }
    
    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func debit_balance_total() -> String
    func credit_balance_total() -> String
    
    func getTotalAmount(account: String, leftOrRight: Int) -> String
}

protocol AfterClosingTrialBalancePresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
}

final class AfterClosingTrialBalancePresenter: AfterClosingTrialBalancePresenterInput {
    
    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 設定勘定科目 貸借科目
    private var dataBaseSettingsTaxonomyAccounts: Results<DataBaseSettingsTaxonomyAccount>
    // 財務諸表
    private var object: DataBaseFinancialStatements
    
    private weak var view: AfterClosingTrialBalancePresenterOutput!
    private var model: AfterClosingTrialBalanceModelInput
    
    init(view: AfterClosingTrialBalancePresenterOutput, model: AfterClosingTrialBalanceModelInput) {
        self.view = view
        self.model = model
        // 設定勘定科目 貸借科目
        dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0) // 貸借対照表　資産 負債 純資産
        // 財務諸表
        object = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 繰越試算表　再計算 合計額を計算
        model.calculateAmountOfBSAccounts(dataBaseSettingsTaxonomyAccounts: dataBaseSettingsTaxonomyAccounts)
        
        view.setupViewForViewWillAppear()
    }
    
    func viewWillDisappear() {
        
        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfobjects: Int {
        dataBaseSettingsTaxonomyAccounts.count
    }
    
    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        dataBaseSettingsTaxonomyAccounts[row]
    }
    
    // 借方　残高　集計
    func debit_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.afterClosingTrialBalance!.debit_balance_total)
    }
    // 貸方　残高　集計
    func credit_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.afterClosingTrialBalance!.credit_balance_total)
    }
    
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String {
        
        StringUtility.shared.setCommaForTB(amount: model.getTotalAmountAfterAdjusting(account: account, leftOrRight: leftOrRight))
    }
}
