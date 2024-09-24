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

    func numberOfsections() -> Int
    func numberOfobjects(section: Int) -> Int
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount

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
    
    private var objects0: Results<DataBaseSettingsTaxonomyAccount>
    private var objects1: Results<DataBaseSettingsTaxonomyAccount>
    private var objects2: Results<DataBaseSettingsTaxonomyAccount>
    private var objects3: Results<DataBaseSettingsTaxonomyAccount>
    private var objects4: Results<DataBaseSettingsTaxonomyAccount>
    private var objects5: Results<DataBaseSettingsTaxonomyAccount>
    private var objects6: Results<DataBaseSettingsTaxonomyAccount>
    private var objects7: Results<DataBaseSettingsTaxonomyAccount>
    private var objects8: Results<DataBaseSettingsTaxonomyAccount>
    private var objects9: Results<DataBaseSettingsTaxonomyAccount>
    private var objects10: Results<DataBaseSettingsTaxonomyAccount>
    private var objects11: Results<DataBaseSettingsTaxonomyAccount>
    private var objects12: Results<DataBaseSettingsTaxonomyAccount>
    private var objects13: Results<DataBaseSettingsTaxonomyAccount>
    // 財務諸表
    private var object: DataBaseFinancialStatements
    
    private weak var view: AfterClosingTrialBalancePresenterOutput!
    private var model: AfterClosingTrialBalanceModelInput
    
    init(view: AfterClosingTrialBalancePresenterOutput, model: AfterClosingTrialBalanceModelInput) {
        self.view = view
        self.model = model
        // 設定勘定科目 貸借科目
        dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0) // 貸借対照表　資産 負債 純資産
        objects0 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 0)
        objects1 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 1)
        objects2 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 2)
        
        objects3 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 3)
        objects4 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 4)
        objects5 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 5)
        
        objects6 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 2, rank1: 6)
        
        objects7 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 7)
        objects8 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 8)
        
        objects9 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 4, rank1: 9)
        
        objects10 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 10)
        objects11 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 11)
        objects12 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 12)
        objects13 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 19)
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
        // 設定勘定科目 貸借科目
        dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0) // 貸借対照表　資産 負債 純資産
        objects0 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 0)
        objects1 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 1)
        objects2 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 2)
        
        objects3 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 3)
        objects4 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 4)
        objects5 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 5)
        
        objects6 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 2, rank1: 6)
        
        objects7 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 7)
        objects8 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 8)
        
        objects9 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 4, rank1: 9)
        
        objects10 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 10)
        objects11 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 11)
        objects12 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 12)
        objects13 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 19)
        // 財務諸表
        object = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
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
    
    func numberOfsections() -> Int {
        14
    }
    
    func numberOfobjects(section: Int) -> Int {
        switch section {
            //     "流動資産"
        case 0: return objects0.count
        case 1: return objects1.count
        case 2: return objects2.count
            //     "固定資産"
        case 3: return objects3.count
        case 4: return objects4.count
        case 5: return objects5.count
            //     "繰延資産"
        case 6: return objects6.count
            //     "流動負債"
        case 7: return objects7.count
        case 8: return objects8.count
            //     "固定負債"
        case 9: return objects9.count
            //     "資本"
        case 10: return objects10.count
        case 11: return objects11.count
        case 12: return objects12.count
        case 13: return objects13.count
        default: //    ""
            return objects13.count
        }
    }
    
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount {
        switch section {
            //     "流動資産"
        case 0: return objects0[row]
        case 1: return objects1[row]
        case 2: return objects2[row]
            //     "固定資産"
        case 3: return objects3[row]
        case 4: return objects4[row]
        case 5: return objects5[row]
            //     "繰延資産"
        case 6: return objects6[row]
            //     "流動負債"
        case 7: return objects7[row]
        case 8: return objects8[row]
            //     "固定負債"
        case 9: return objects9[row]
            //     "資本"
        case 10: return objects10[row]
        case 11: return objects11[row]
        case 12: return objects12[row]
        case 13: return objects13[row]
        default: //    ""
            return objects13[row]
        }
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
