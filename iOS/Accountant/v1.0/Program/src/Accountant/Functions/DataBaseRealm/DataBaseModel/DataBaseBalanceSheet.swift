//
//  DataBaseBalanceSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 貸借対照表クラス
class DataBaseBalanceSheet: RObject {
    convenience init(
        fiscalYear: Int,

        CurrentAssets_total: Int64,
        FixedAssets_total: Int64,
        DeferredAssets_total: Int64,
        Asset_total: Int64,

        CurrentLiabilities_total: Int64,
        FixedLiabilities_total: Int64,
        Liability_total: Int64,

        CapitalStock_total: Int64,
        OtherCapitalSurpluses_total: Int64,
        Equity_total: Int64
    ) {
        self.init()

        self.fiscalYear = fiscalYear

        self.CurrentAssets_total = CurrentAssets_total
        self.FixedAssets_total = FixedAssets_total
        self.DeferredAssets_total = DeferredAssets_total
        self.Asset_total = Asset_total

        self.CurrentLiabilities_total = CurrentLiabilities_total
        self.FixedLiabilities_total = FixedLiabilities_total
        self.Liability_total = Liability_total

        self.CapitalStock_total = CapitalStock_total
        self.OtherCapitalSurpluses_total = OtherCapitalSurpluses_total
        self.Equity_total = Equity_total
    }

    @objc dynamic var fiscalYear: Int = 0                      // 年度
    // 中分類　合計
    @objc dynamic var CurrentAssets_total: Int64 = 0          // 流動資産
    @objc dynamic var FixedAssets_total: Int64 = 0            // 固定資産
    @objc dynamic var DeferredAssets_total: Int64 = 0         // 繰延資産
    // 大分類　合計
    @objc dynamic var Asset_total: Int64 = 0                   // 資産
    
    // 中分類　合計
    @objc dynamic var CurrentLiabilities_total: Int64 = 0    // 流動負債
    @objc dynamic var FixedLiabilities_total: Int64 = 0      // 固定負債
    // 大分類　合計
    @objc dynamic var Liability_total: Int64 = 0              // 負債
    
    // 小分類　合計
    @objc dynamic var CapitalStock_total: Int64 = 0           // 株主資本
    @objc dynamic var OtherCapitalSurpluses_total: Int64 = 0 // その他の包括利益累計額 評価・換算差額等
    // 中分類　合計
    @objc dynamic var Capital_total: Int64 = 0           // 資本
    // 大分類　合計
    @objc dynamic var Equity_total: Int64 = 0                 // 純資産

    let dataBaseTaxonomy = List<DataBaseTaxonomy>()           // 表示科目　使用していない　2020/10/09 損益計算書には表示科目の属性がない 2020/11/12 使用する
}

// 月次貸借対照表クラス
class DataBaseMonthlyBalanceSheet: DataBaseBalanceSheet {
}
