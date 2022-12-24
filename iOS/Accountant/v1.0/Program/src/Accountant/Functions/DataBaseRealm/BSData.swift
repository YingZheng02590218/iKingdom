//
//  BSData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/18.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// ModelからPresenterへ受け渡す貸借対照表の型
struct BSData {

    var company: String
    var fiscalYear: Int
    var theDayOfReckoning: String
    // 大区分 // MARK: - 資産の部
    // 中区分 // MARK: - "  流動資産"
    var objects0100: Results<DataBaseSettingsTaxonomy> // 流動資産
             // MARK: - "    流動資産合計"
    var currentAssetsTotal: String
    var lastCurrentAssetsTotal: String
             // MARK: - "  固定資産"
    // 小区分 // MARK: - 有形固定資産3
    var objects010142: Results<DataBaseSettingsTaxonomy> // 有形固定資産3
    
             // MARK: - 無形固定資産
    var objects010143: Results<DataBaseSettingsTaxonomy> // 無形固定資産4
             // MARK: - 投資その他資産　投資その他の資産
    var objects010144: Results<DataBaseSettingsTaxonomy> // 投資その他の資産5
             // MARK: - "    固定資産合計"
    var fixedAssetsTotal: String
    var lastFixedAssetsTotal: String
    // 中区分 // MARK: - "  繰越資産"
    var objects0102: Results<DataBaseSettingsTaxonomy> // 繰延資産
             // MARK: - "    繰越資産合計"
    var deferredAssetsTotal: String
    var lastDeferredAssetsTotal: String
             // MARK: - "資産合計"
    var assetTotal: String
    var lastAssetTotal: String

    // 大区分 // MARK: - 負債の部
    // 中区分 // MARK: - "  流動負債"
    var objects0114: Results<DataBaseSettingsTaxonomy> // 流動負債
             // MARK: - "    流動負債合計"
    var currentLiabilitiesTotal: String
    var lastCurrentLiabilitiesTotal: String
             // MARK: - "  固定負債"
    var objects0115: Results<DataBaseSettingsTaxonomy> // 固定負債
             // MARK: - "    固定負債合計"
    var fixedLiabilitiesTotal: String
    var lastFixedLiabilitiesTotal: String
             // MARK: - "負債合計"
    var liabilityTotal: String
    var lastLiabilityTotal: String

    // 大区分 // MARK: - 純資産の部
    // 中区分 // MARK: - "  株主資本"
    var objects0129: Results<DataBaseSettingsTaxonomy> // 株主資本14
             // MARK: - "    株主資本合計"
    var capitalStockTotal: String
    var lastCapitalStockTotal: String
             // MARK: - "  その他の包括利益累計額"
    var objects01210: Results<DataBaseSettingsTaxonomy> // 評価・換算差額等15
             // MARK: - "    その他の包括利益累計額合計"
    var otherCapitalSurplusesTotal: String
    var lastOtherCapitalSurplusesTotal: String
    //            0    1    2    11                    新株予約権
    //            0    1    2    12                    自己新株予約権
    //            0    1    2    13                    非支配株主持分
    //            0    1    2    14                    少数株主持分
    var objects01211: Results<DataBaseSettingsTaxonomy> // 新株予約権16
    var objects01213: Results<DataBaseSettingsTaxonomy> // 非支配株主持分22
             // MARK: - "純資産合計"
    var equityTotal: String
    var lastEquityTotal: String
             // MARK: - "負債純資産合計"
    var liabilityAndEquityTotal: String
    var lastLiabilityAndEquityTotal: String
}
