//
//  DataBaseFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 財務諸表クラス
// 財務諸表 は 貸借対照表、損益計算書、キャッシュフロー計算書、精算表、試算表 を 持つことができます。
class DataBaseFinancialStatements: RObject {
    convenience init(
        fiscalYear: Int,
        balanceSheet: DataBaseBalanceSheet?,
        profitAndLossStatement: DataBaseProfitAndLossStatement?,
        cashFlowStatement: DataBaseCashFlowStatement?,
        workSheet: DataBaseWorkSheet?,
        compoundTrialBalance: DataBaseCompoundTrialBalance?
    ) {
        self.init()

        self.fiscalYear = fiscalYear
        self.balanceSheet = balanceSheet
        self.profitAndLossStatement = profitAndLossStatement
        self.cashFlowStatement = cashFlowStatement
        self.workSheet = workSheet
        self.compoundTrialBalance = compoundTrialBalance
    }

    @objc dynamic var fiscalYear: Int = 0                                         // 年度
    @objc dynamic var balanceSheet: DataBaseBalanceSheet?                       // 貸借対照表
    @objc dynamic var profitAndLossStatement: DataBaseProfitAndLossStatement? // 損益計算書
    @objc dynamic var cashFlowStatement: DataBaseCashFlowStatement?            // キャッシュフロー計算書
    @objc dynamic var workSheet: DataBaseWorkSheet?                              // 精算表　// 使用しない　2020/07/25 → 使用する　2020/08/02
    @objc dynamic var compoundTrialBalance: DataBaseCompoundTrialBalance?      // 合計残高試算表
}
