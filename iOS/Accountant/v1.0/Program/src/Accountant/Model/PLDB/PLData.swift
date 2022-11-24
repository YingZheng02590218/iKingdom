//
//  PLData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/22.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// ModelからPresenterへ受け渡す損益計算書の型
struct PLData {
    
    var company: String
    var fiscalYear: Int
    var theDayOfReckoning: String
    
    // 大区分 // MARK: - 費用3
    
    // 中区分 // MARK: -  営業費用5
    // 小区分 // MARK: -   売上原価8
    var CostOfGoodsSold: String                            //商品売上原価 Cost of goods sold
    var lastCostOfGoodsSold: String                            //商品売上原価 Cost of goods sold
             // MARK: -   販売費及び一般管理費9
    var objects9: Results<DataBaseSettingsTaxonomy> //販売費及び一般管理費9
    var SellingGeneralAndAdministrativeExpenses: String //販売費及び一般管理費 Selling, general and administrative expenses
    var lastSellingGeneralAndAdministrativeExpenses: String //販売費及び一般管理費 Selling, general and administrative expenses

    // 中区分 // MARK: -  営業外費用6
    var mid_category6: Results<DataBaseSettingsTaxonomy> //営業外費用6
    var NonOperatingExpenses: String                      //営業外費用 ⇒ Non-operating expenses
    var lastNonOperatingExpenses: String                      //営業外費用 ⇒ Non-operating expenses
    // 中区分 // MARK: -  特別損失7
    var mid_category7: Results<DataBaseSettingsTaxonomy> //特別損失7
    var ExtraordinaryLosses: String                       //特別損失 ⇒ Extraordinary losses
    var lastExtraordinaryLosses: String                       //特別損失 ⇒ Extraordinary losses
    // 中区分 // MARK: -  税等8
    var IncomeTaxes: String                                //法人税等 ⇒ Income taxes
    var lastIncomeTaxes: String                                //法人税等 ⇒ Income taxes

    
    // 大区分 // MARK: - 収益4
    
    // 中区分 // MARK: -  営業収益9
    // 小区分 // MARK: -   売上高10
    var NetSales: String                                    //売上高 Net sales
    var lastNetSales: String                                    //売上高 Net sales
             // MARK: -   営業外収益10
    var mid_category10: Results<DataBaseSettingsTaxonomy> //営業外収益10
    var NonOperatingIncome: String                        //営業外収益 ⇒ Non-operating income
    var lastNonOperatingIncome: String                        //営業外収益 ⇒ Non-operating income
    // 中区分 // MARK: -  特別利益11
    var mid_category11: Results<DataBaseSettingsTaxonomy> //特別利益11
    var ExtraordinaryIncome: String                       //特別利益 ⇒ Extraordinary income
    var lastExtraordinaryIncome: String                       //特別利益 ⇒ Extraordinary income

    // MARK: - 利益
    
    var GrossProfitOrLoss: String                          //売上総利益（損失）Gross profit (loss)
    var lastGrossProfitOrLoss: String                          //売上総利益（損失）Gross profit (loss)
    var OtherCapitalSurpluses_total: String              //営業利益（損失）⇒ Operating income (loss)
    var lastOtherCapitalSurpluses_total: String              //営業利益（損失）⇒ Operating income (loss)
    var OrdinaryIncomeOrLoss: String                      //経常利益（損失）⇒ Ordinary income (loss)
    var lastOrdinaryIncomeOrLoss: String                      //経常利益（損失）⇒ Ordinary income (loss)
    var IncomeOrLossBeforeIncomeTaxes: String           //税引前当期純利益（損失）⇒ Income (loss) before income taxes
    var lastIncomeOrLossBeforeIncomeTaxes: String           //税引前当期純利益（損失）⇒ Income (loss) before income taxes
    var NetIncomeOrLoss: String                            //当期純利益（損失）⇒ Net income (loss)
    var lastNetIncomeOrLoss: String                            //当期純利益（損失）⇒ Net income (loss)
}
