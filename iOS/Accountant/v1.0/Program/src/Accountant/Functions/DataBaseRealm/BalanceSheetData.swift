//
//  BalanceSheetData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/02.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// ModelからPresenterへ受け渡す貸借対照表の型
struct BalanceSheetData {

    var company: String
    var fiscalYear: Int
    var theDayOfReckoning: String

    // MARK: - 資産の部

    // MARK: 流動資産
    var objects0: Results<DataBaseSettingsTaxonomyAccount> // 当座資産
    var objects1: Results<DataBaseSettingsTaxonomyAccount> // 棚卸資産
    var objects2: Results<DataBaseSettingsTaxonomyAccount> // その他の流動資産
    // MARK: 流動資産合計
    var currentAssetsTotal: String
    var lastCurrentAssetsTotal: String
    // MARK: 固定資産
    var objects3: Results<DataBaseSettingsTaxonomyAccount> // 有形固定資産3
    var objects4: Results<DataBaseSettingsTaxonomyAccount> // 無形固定資産4
    var objects5: Results<DataBaseSettingsTaxonomyAccount> // 投資その他の資産5
    // MARK: 固定資産合計
    var fixedAssetsTotal: String
    var lastFixedAssetsTotal: String
    // MARK: 繰越資産
    var objects6: Results<DataBaseSettingsTaxonomyAccount> // 繰延資産
    // MARK: 繰越資産合計
    var deferredAssetsTotal: String
    var lastDeferredAssetsTotal: String
    // MARK: - 資産合計
    var assetTotal: String
    var lastAssetTotal: String

    // MARK: - 負債の部

    // MARK: 流動負債
    var objects7: Results<DataBaseSettingsTaxonomyAccount> // 仕入債務
    var objects8: Results<DataBaseSettingsTaxonomyAccount> // その他の流動負債
    // MARK: 流動負債合計
    var currentLiabilitiesTotal: String
    var lastCurrentLiabilitiesTotal: String
    // MARK: 固定負債
    var objects9: Results<DataBaseSettingsTaxonomyAccount> // 長期債務
    // MARK: 固定負債合計
    var fixedLiabilitiesTotal: String
    var lastFixedLiabilitiesTotal: String
    // MARK: - 負債合計
    var liabilityTotal: String
    var lastLiabilityTotal: String

    // MARK: - 純資産の部

    var objects10: Results<DataBaseSettingsTaxonomyAccount> // 資本
    var objects11: Results<DataBaseSettingsTaxonomyAccount>
    var objects12: Results<DataBaseSettingsTaxonomyAccount>
    var objects13: Results<DataBaseSettingsTaxonomyAccount>
    // MARK: 資本合計

    // MARK: - 純資産合計
    var equityTotal: String
    var lastEquityTotal: String

    // MARK: - 負債純資産合計
    var liabilityAndEquityTotal: String
    var lastLiabilityAndEquityTotal: String
}
