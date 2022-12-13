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
    
    var numberOfobjects: Int { get }
    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount
    var numberOfobjectss: Int { get }
    func objectss(forRow row: Int) -> DataBaseSettingsTaxonomyAccount
    
    func viewDidLoad()
    func viewWillAppear()
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
    func setupViewForViewDidAppear()
}

final class WSPresenter: WSPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    
    // 期中の仕訳の勘定科目
    private var objects:Results<DataBaseSettingsTaxonomyAccount>
    // 修正記入の勘定科目
    private var objectss:Results<DataBaseSettingsTaxonomyAccount>
    // 財務諸表
    private var object:DataBaseFinancialStatements

    private weak var view: WSPresenterOutput!
    private var model: WSModelInput
    
    init(view: WSPresenterOutput, model: WSModelInput) {
        self.view = view
        self.model = model

        // 精算表　貸借対照表 損益計算書　初期化　再計算
        model.initialize()

        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        objects = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: false, switching: true) //期中の仕訳の勘定科目を取得
        objectss = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: true, switching: true) //修正記入の勘定科目を取得
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        object = dataBaseManagerFinancialStatements.getFinancialStatements()
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
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfobjects: Int {
        return objects.count
    }
    func objects(forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        return objects[row]
    }
    
    var numberOfobjectss: Int {
        return objectss.count
    }
    func objectss(forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        return objectss[row]
    }
    
    func refreshTable() {
        // 精算表　貸借対照表 損益計算書　初期化　再計算
        model.initialize()
        // 更新処理
        view.reloadData()
    }
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String { // TODO: 戻り値をカンマ追加後のStringに変換してから返す

        return model.getTotalAmount(account: account, leftOrRight: leftOrRight)
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String {

        return model.getTotalAmountAdjusting(account: account, leftOrRight: leftOrRight)
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String {
        
        return model.getTotalAmountAfterAdjusting(account: account, leftOrRight: leftOrRight)
    }
    //借方　合計　集計
    func debit_total_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.compoundTrialBalance!.debit_total_total)
    }
    //貸方　合計　集計
    func credit_total_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.compoundTrialBalance!.credit_total_total)
    }
    //借方　残高　集計
    func debit_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.compoundTrialBalance!.debit_balance_total)
    }
    //貸方　残高　集計
    func credit_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.compoundTrialBalance!.credit_balance_total)
    }
    
    func netIncomeOrNetLossLoss() -> String {
        
        return StringUtility.shared.setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossLoss)//0でも空白にしない
    }
    
    func netIncomeOrNetLossIncome() -> String {
        
        return StringUtility.shared.setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossIncome)//0でも空白にしない
    }
    // 修正記入 借方
    func debit_adjustingEntries_total_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.debit_adjustingEntries_total_total) // 残高ではなく合計
    }
    // 修正記入　貸方
    func credit_adjustingEntries_total_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.credit_adjustingEntries_total_total) // 残高ではなく合計
    }
    // 貸借対照表 借方
    func debit_BS_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.debit_BS_balance_total+object.workSheet!.netIncomeOrNetLossIncome) //損益計算書とは反対の方に記入する
    }
    // 貸借対照表　貸方
    func credit_BS_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.credit_BS_balance_total+object.workSheet!.netIncomeOrNetLossLoss) //損益計算書とは反対の方に記入する
    }
    // 損益計算書 借方
    func debit_PL_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.debit_PL_balance_total+object.workSheet!.netIncomeOrNetLossLoss)// 当期純利益と合計借方とを足す
    }
    // 損益計算書　貸方
    func credit_PL_balance_total() -> String {
        
        return StringUtility.shared.setComma(amount:object.workSheet!.credit_PL_balance_total+object.workSheet!.netIncomeOrNetLossIncome)// 当期純損失と合計貸方とを足す
    }
    
}
