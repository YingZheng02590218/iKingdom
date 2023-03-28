//
//  TBPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/31.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol TBPresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    var numberOfobjects: Int { get }

    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()

    func debit_total_total() -> String
    func credit_total_total() -> String
    func debit_balance_total() -> String
    func credit_balance_total() -> String
        
    func getTotalAmount(account: String, leftOrRight: Int) -> String
}

protocol TBPresenterOutput: AnyObject {
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
}

final class TBPresenter: TBPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 設定勘定科目
    private var objects: Results<DataBaseSettingsTaxonomyAccount>
    // 財務諸表
    private var object: DataBaseFinancialStatements
    
    private weak var view: TBPresenterOutput!
    private var model: TBModelInput
    
    init(view: TBPresenterOutput, model: TBModelInput) {
        self.view = view
        self.model = model
        
        objects = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: false, switching: true)
        
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
        // 合計残高試算表　再計算 合計額を計算
        model.calculateAmountOfAllAccount()
        
        view.setupViewForViewWillAppear()
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

    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        objects[row]
    }
    
    // 借方　合計　集計
    func debit_total_total() -> String {
        
        StringUtility.shared.setComma(amount: object.compoundTrialBalance!.debit_total_total)
    }
    // 貸方　合計　集計
    func credit_total_total() -> String {
        
        StringUtility.shared.setComma(amount: object.compoundTrialBalance!.credit_total_total)
    }
    // 借方　残高　集計
    func debit_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.compoundTrialBalance!.debit_balance_total)
    }
    // 貸方　残高　集計
    func credit_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.compoundTrialBalance!.credit_balance_total)
    }
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String {

        StringUtility.shared.setCommaForTB(amount: model.getTotalAmount(account: account, leftOrRight: leftOrRight))
    }
}
