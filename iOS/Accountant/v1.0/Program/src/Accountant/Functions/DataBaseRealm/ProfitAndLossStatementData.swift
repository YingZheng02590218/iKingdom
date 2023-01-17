//
//  ProfitAndLossStatementData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/11.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// ModelからPresenterへ受け渡す損益計算書の型
struct ProfitAndLossStatementData {
    
    var company: String
    var fiscalYear: Int
    var theDayOfReckoning: String
    
    // MARK: - 収益4
    // MARK: - 費用3
    
    // MARK: - 営業収益9
    // MARK: - 売上高10
    var objects0: Results<DataBaseSettingsTaxonomyAccount> // 売上高
    var netSales: String                                    // 売上高 Net sales TODO: 計算式を見直す
    var lastNetSales: String                                    // 売上高 Net sales TODO: 計算式を見直す
    // MARK: - 営業費用5
    // MARK: - 売上原価8
    var objects1: Results<DataBaseSettingsTaxonomyAccount> // 売上原価
    var objects2: Results<DataBaseSettingsTaxonomyAccount> // 製造原価
    var costOfGoodsSold: String                            // 商品売上原価 Cost of goods sold
    var lastCostOfGoodsSold: String                            // 商品売上原価 Cost of goods sold
    // MARK: - 販売費及び一般管理費9
    var objects3: Results<DataBaseSettingsTaxonomyAccount> // 販売費及び一般管理費9
    var sellingGeneralAndAdministrativeExpenses: String // 販売費及び一般管理費 Selling, general and administrative expenses
    var lastSellingGeneralAndAdministrativeExpenses: String // 販売費及び一般管理費 Selling, general and administrative expenses
    
    // MARK: - 営業外収益10
    var objects4: Results<DataBaseSettingsTaxonomyAccount> // 営業外収益10
    var nonOperatingIncome: String                        // 営業外収益 ⇒ Non-operating income
    var lastNonOperatingIncome: String                        // 営業外収益 ⇒ Non-operating income
    // MARK: - 営業外費用6
    var objects5: Results<DataBaseSettingsTaxonomyAccount> // 営業外費用6
    var nonOperatingExpenses: String                      // 営業外費用 ⇒ Non-operating expenses
    var lastNonOperatingExpenses: String                      // 営業外費用 ⇒ Non-operating expenses
    // MARK: - 特別利益11
    var objects6: Results<DataBaseSettingsTaxonomyAccount> // 特別利益11
    var extraordinaryIncome: String                       // 特別利益 ⇒ Extraordinary income
    var lastExtraordinaryIncome: String                       // 特別利益 ⇒ Extraordinary income
    // MARK: - 特別損失7
    var objects7: Results<DataBaseSettingsTaxonomyAccount> // 特別損失7
    var extraordinaryLosses: String                       // 特別損失 ⇒ Extraordinary losses
    var lastExtraordinaryLosses: String                       // 特別損失 ⇒ Extraordinary losses
    // MARK: - 税等8
    var objects8: Results<DataBaseSettingsTaxonomyAccount>
    var incomeTaxes: String                                // 法人税等 ⇒ Income taxes
    var lastIncomeTaxes: String                                // 法人税等 ⇒ Income taxes
    
    
    // MARK: - 利益
    
    var grossProfitOrLoss: String                          // 売上総利益（損失）Gross profit (loss)
    var lastGrossProfitOrLoss: String                          // 売上総利益（損失）Gross profit (loss)
    var otherCapitalSurplusesTotal: String              // 営業利益（損失）⇒ Operating income (loss)
    var lastOtherCapitalSurplusesTotal: String              // 営業利益（損失）⇒ Operating income (loss)
    var ordinaryIncomeOrLoss: String                      // 経常利益（損失）⇒ Ordinary income (loss)
    var lastOrdinaryIncomeOrLoss: String                      // 経常利益（損失）⇒ Ordinary income (loss)
    var incomeOrLossBeforeIncomeTaxes: String           // 税引前当期純利益（損失）⇒ Income (loss) before income taxes
    var lastIncomeOrLossBeforeIncomeTaxes: String           // 税引前当期純利益（損失）⇒ Income (loss) before income taxes
    var netIncomeOrLoss: String                            // 当期純利益（損失）⇒ Net income (loss)
    var lastNetIncomeOrLoss: String                            // 当期純利益（損失）⇒ Net income (loss)
}
