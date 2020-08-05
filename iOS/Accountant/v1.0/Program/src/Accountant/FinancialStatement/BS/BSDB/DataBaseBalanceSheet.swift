//
//  DataBaseBalanceSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 貸借対照表クラス
class DataBaseBalanceSheet: RObject {
    @objc dynamic var fiscalYear: Int = 0                         //年度

    @objc dynamic var CurrentAssets_total: Int64 = 0            //中分類　合計
    @objc dynamic var FixedAssets_total: Int64 = 0              //中分類　合計
    @objc dynamic var DeferredAssets_total: Int64 = 0           //中分類　合計 繰延資産
    @objc dynamic var Asset_total: Int64 = 0                     //大分類　合計

    @objc dynamic var CurrentLiabilities_total: Int64 = 0      //中分類　合計
    @objc dynamic var FixedLiabilities_total: Int64 = 0        //中分類　合計
    @objc dynamic var Liability_total: Int64 = 0                 //大分類　合計

    @objc dynamic var CapitalStock_total: Int64 = 0             //中分類　合計
    @objc dynamic var OtherCapitalSurpluses_total: Int64 = 0   //中分類　合計
    @objc dynamic var Equity_total: Int64 = 0                    //大分類　合計
    
    let dataBaseBSAndPLAccounts = List<DataBaseBSAndPLAccount>() //表記名
}
