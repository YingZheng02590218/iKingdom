//
//  WSPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/29.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol WSPresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    func numberOfsections() -> Int
    func numberOfobjects(section: Int) -> Int
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func refreshTable()
    func getTotalAmount(account: String, leftOrRight: Int) -> String
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String
    func debit_total_total() -> String
    func credit_total_total() -> String
    func debit_balance_total() -> String
    func credit_balance_total() -> String
    
    func netIncomeOrNetLossLoss() -> String
    func netIncomeOrNetLossIncome() -> String
    func debit_adjustingEntries_total_total() -> String
    func credit_adjustingEntries_total_total() -> String
    func debit_BS_balance_total() -> String
    func credit_BS_balance_total() -> String
    func debit_PL_balance_total() -> String
    func credit_PL_balance_total() -> String
}

protocol WSPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
}

final class WSPresenter: WSPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 設定勘定科目
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
    private var objects14: Results<DataBaseSettingsTaxonomyAccount>
    private var objects15: Results<DataBaseSettingsTaxonomyAccount>
    private var objects16: Results<DataBaseSettingsTaxonomyAccount>
    private var objects17: Results<DataBaseSettingsTaxonomyAccount>
    private var objects18: Results<DataBaseSettingsTaxonomyAccount>
    private var objects19: Results<DataBaseSettingsTaxonomyAccount>
    private var objects20: Results<DataBaseSettingsTaxonomyAccount>
    private var objects21: Results<DataBaseSettingsTaxonomyAccount>
    private var objects22: Results<DataBaseSettingsTaxonomyAccount>
    // 財務諸表
    private var object: DataBaseFinancialStatements

    private weak var view: WSPresenterOutput!
    private var model: WSModelInput
    
    init(view: WSPresenterOutput, model: WSModelInput) {
        self.view = view
        self.model = model

        // 精算表　貸借対照表 損益計算書　初期化　再計算
        model.initialize()
        
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
        
        objects14 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 6, rank1: nil)
        
        objects15 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 13)
        objects16 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 14)
        
        objects17 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 8, rank1: nil)
        
        objects18 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 15)
        objects19 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 16)
        
        objects20 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 17)
        objects21 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 18)
        
        objects22 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 11, rank1: nil)

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
        
        view.setupViewForViewWillAppear()
    }

    func viewWillDisappear() {

        view.setupViewForViewWillDisappear()
    }

    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
        
    func numberOfsections() -> Int {
        23
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
            //     "売上"
        case 14: return objects14.count
            //     "売上原価"
        case 15: return objects15.count
        case 16: return objects16.count
            //     "販売費及び一般管理費"
        case 17: return objects17.count
            //     "営業外損益"
        case 18: return objects18.count
        case 19: return objects19.count
            //    "特別損益"
        case 20: return objects20.count
        case 21: return objects21.count
            //    "税金"
        case 22: return objects22.count
        default: //    ""
            return objects22.count
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
            //     "売上"
        case 14: return objects14[row]
            //     "売上原価"
        case 15: return objects15[row]
        case 16: return objects16[row]
            //     "販売費及び一般管理費"
        case 17: return objects17[row]
            //     "営業外損益"
        case 18: return objects18[row]
        case 19: return objects19[row]
            //    "特別損益"
        case 20: return objects20[row]
        case 21: return objects21[row]
            //    "税金"
        case 22: return objects22[row]
        default: //    ""
            return objects22[row]
        }
    }

    func refreshTable() {
        // 精算表　貸借対照表 損益計算書　初期化　再計算
        model.initialize()
        // 更新処理
        view.reloadData()
    }
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String {
        // TODO: 戻り値をカンマ追加後のStringに変換してから返す
        model.getTotalAmount(account: account, leftOrRight: leftOrRight)
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String {

        model.getTotalAmountAdjusting(account: account, leftOrRight: leftOrRight)
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String {
        
        model.getTotalAmountAfterAdjusting(account: account, leftOrRight: leftOrRight)
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
    
    func netIncomeOrNetLossLoss() -> String {
        
        StringUtility.shared.setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossLoss) // 0でも空白にしない
    }
    
    func netIncomeOrNetLossIncome() -> String {
        
        StringUtility.shared.setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossIncome) // 0でも空白にしない
    }
    // 修正記入 借方
    func debit_adjustingEntries_total_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.debit_adjustingEntries_total_total) // 残高ではなく合計
    }
    // 修正記入　貸方
    func credit_adjustingEntries_total_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.credit_adjustingEntries_total_total) // 残高ではなく合計
    }
    // 貸借対照表 借方
    func debit_BS_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.debit_BS_balance_total+object.workSheet!.netIncomeOrNetLossIncome) // 損益計算書とは反対の方に記入する
    }
    // 貸借対照表　貸方
    func credit_BS_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.credit_BS_balance_total+object.workSheet!.netIncomeOrNetLossLoss) // 損益計算書とは反対の方に記入する
    }
    // 損益計算書 借方
    func debit_PL_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.debit_PL_balance_total+object.workSheet!.netIncomeOrNetLossLoss) // 当期純利益と合計借方とを足す
    }
    // 損益計算書　貸方
    func credit_PL_balance_total() -> String {
        
        StringUtility.shared.setComma(amount: object.workSheet!.credit_PL_balance_total+object.workSheet!.netIncomeOrNetLossIncome) // 当期純損失と合計貸方とを足す
    }
    
}
