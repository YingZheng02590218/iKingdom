//
//  DataBaseManagerFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 決算書クラス
class DataBaseManagerFinancialStatements: DataBaseManager {
    
    public static let shared = DataBaseManagerFinancialStatements()
    
    override private init() {
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // モデルオブフェクトの追加
    func addFinancialStatements(number: Int) {
        // 会計帳簿棚　のオブジェクトを取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooks.self, key: number) else { return }
        // オブジェクトに格納するオブジェクトを作成
        let balanceSheet = DataBaseBalanceSheet(
            fiscalYear: object.fiscalYear,
            CurrentAssets_total: 0,
            FixedAssets_total: 0,
            DeferredAssets_total: 0,
            Asset_total: 0,
            CurrentLiabilities_total: 0,
            FixedLiabilities_total: 0,
            Liability_total: 0,
            CapitalStock_total: 0,
            OtherCapitalSurpluses_total: 0,
            Capital_total: 0,
            Equity_total: 0
        )
        let profitAndLossStatement = DataBaseProfitAndLossStatement(
            fiscalYear: object.fiscalYear,
            NetSales: 0,
            CostOfGoodsSold: 0,
            GrossProfitOrLoss: 0,
            SellingGeneralAndAdministrativeExpenses: 0,
            OtherCapitalSurpluses_total: 0,
            NonOperatingIncome: 0,
            NonOperatingExpenses: 0,
            OrdinaryIncomeOrLoss: 0,
            ExtraordinaryIncome: 0,
            ExtraordinaryLosses: 0,
            IncomeOrLossBeforeIncomeTaxes: 0,
            IncomeTaxes: 0,
            NetIncomeOrLoss: 0
        )
        let cashFlowStatement = DataBaseCashFlowStatement(
            fiscalYear: object.fiscalYear,
            CashFlowsFromOperatingActivities: 0,
            CashFlowsFromInvestingActivities: 0,
            CashFlowsFromfInancingActivities: 0,
            EffectOfExchangeRateChangesOnCashAndCashEquivalents: 0,
            NetIncreaseInCashAndCashEquivalents: 0,
            CashAndCashEquivalentsAtBeginningOfPeriod: 0,
            CashAndCashEquivalentsAtEndOfPeriod: 0
        )
        let workSheet = DataBaseWorkSheet(
            fiscalYear: object.fiscalYear,
            netIncomeOrNetLossIncome: 0,
            netIncomeOrNetLossLoss: 0,
            debit_adjustingEntries_total_total: 0,
            credit_adjustingEntries_total_total: 0,
            debit_adjustingEntries_balance_total: 0,
            credit_adjustingEntries_balance_total: 0,
            debit_PL_total_total: 0,
            credit_PL_total_total: 0,
            debit_PL_balance_total: 0,
            credit_PL_balance_total: 0,
            debit_BS_total_total: 0,
            credit_BS_total_total: 0,
            debit_BS_balance_total: 0,
            credit_BS_balance_total: 0
        )
        let compoundTrialBalance = DataBaseCompoundTrialBalance(
            fiscalYear: object.fiscalYear,
            debit_total_total: 0,
            credit_total_total: 0,
            debit_balance_total: 0,
            credit_balance_total: 0
        )
        let afterClosingTrialBalance = DataBaseAfterClosingTrialBalance(
            fiscalYear: object.fiscalYear,
            debit_total_total: 0,
            credit_total_total: 0,
            debit_balance_total: 0,
            credit_balance_total: 0
        )
        let dataBaseFinancialStatements = DataBaseFinancialStatements(
            fiscalYear: object.fiscalYear,
            balanceSheet: balanceSheet,
            profitAndLossStatement: profitAndLossStatement,
            cashFlowStatement: cashFlowStatement,
            workSheet: workSheet,
            compoundTrialBalance: compoundTrialBalance,
            afterClosingTrialBalance: afterClosingTrialBalance
        )
        do {
            // (2)書き込みトランザクション内でデータを追加する
            try DataBaseManager.realm.write {
                var number = balanceSheet.save()
                print(number)
                number = profitAndLossStatement.save()
                number = cashFlowStatement.save()
                number = workSheet.save()
                number = compoundTrialBalance.save()
                number = afterClosingTrialBalance.save()
                number = dataBaseFinancialStatements.save() //　自動採番
                // 年度　の数だけ増える
                object.dataBaseFinancialStatements = dataBaseFinancialStatements // 会計帳簿に財務諸表を追加する
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // モデルオブフェクトの追加
    func addAfterClosingTrialBalanceToFinancialStatements(number: Int) {
        // 会計帳簿棚　のオブジェクトを取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooks.self, key: number) else { return }
        let afterClosingTrialBalance = DataBaseAfterClosingTrialBalance(
            fiscalYear: object.fiscalYear,
            debit_total_total: 0,
            credit_total_total: 0,
            debit_balance_total: 0,
            credit_balance_total: 0
        )
        do {
            // (2)書き込みトランザクション内でデータを追加する
            try DataBaseManager.realm.write {
                let number = afterClosingTrialBalance.save()
                print(number)
                object.dataBaseFinancialStatements?.afterClosingTrialBalance = afterClosingTrialBalance // 財務諸表に繰越試算表を追加する
            }
        } catch {
            print("エラーが発生しました")
        }
        
    }
    
    // MARK: Read
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseFinancialStatements, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    
    // 取得　財務諸表　現在開いている年度
    func getFinancialStatements() -> DataBaseFinancialStatements {
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseFinancialStatements.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        return objects[0]
    }
    
    // MARK: Update
    
    // MARK: Delete
    
    // モデルオブフェクトの削除
    func deleteFinancialStatements(number: Int) -> Bool {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseFinancialStatements.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                // 貸借対照表、損益計算書、CF計算書、精算表、試算表を削除
                if let balanceSheet = object.balanceSheet {
                    DataBaseManager.realm.delete(balanceSheet)
                }
                if let profitAndLossStatement = object.profitAndLossStatement {
                    DataBaseManager.realm.delete(profitAndLossStatement)
                }
                if let cashFlowStatement = object.cashFlowStatement {
                    DataBaseManager.realm.delete(cashFlowStatement)
                }
                if let workSheet = object.workSheet {
                    DataBaseManager.realm.delete(workSheet)
                }
                if let compoundTrialBalance = object.compoundTrialBalance {
                    DataBaseManager.realm.delete(compoundTrialBalance)
                }
                // 会計帳簿を削除
                DataBaseManager.realm.delete(object)
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
}
