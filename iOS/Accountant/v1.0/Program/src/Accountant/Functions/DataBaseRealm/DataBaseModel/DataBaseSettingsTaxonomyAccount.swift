//
//  DataBaseSettingsTaxonomyAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定勘定科目クラス
// class DataBaseSettingsCategory: RObject {
//    // モデル定義
//    @objc dynamic var big_category: Int = 0       //大分類
//    @objc dynamic var mid_category: Int = 0       //中分類
//    @objc dynamic var small_category: Int = 0     //小分類
//    @objc dynamic var BSAndPL_category: Int = 0   //貸借対照表と損益計算書上の表記名
//    @objc dynamic var AdjustingAndClosingEntries: Bool = false     //決算整理仕訳
//    @objc dynamic var category: String = ""       //勘定科目
//    @objc dynamic var explaining: String = ""     //説明
//    @objc dynamic var switching: Bool = false     //有効無効
// }

// 設定勘定科目
class DataBaseSettingsTaxonomyAccount: RObject {
    convenience init(
        Rank0: String,
        Rank1: String,
        Rank2: String,
        category: String,
        AdjustingAndClosingEntries: Bool,
        switching: Bool
    ) {
        self.init()
        
        self.Rank0 = Rank0
        self.Rank1 = Rank1
        self.Rank2 = Rank2
        self.category = category
        self.AdjustingAndClosingEntries = AdjustingAndClosingEntries
        self.switching = switching
    }
    
    @objc dynamic var serialNumber: Int = 0                    // シリアルナンバー　並び替えのための順序
    @objc dynamic var Rank0: String = ""                         // 大区分
    @objc dynamic var Rank1: String = ""                         // 中区分
    @objc dynamic var Rank2: String = ""                         // 小区分
    @objc dynamic var category: String = ""                      // 勘定科目名
    @objc dynamic var AdjustingAndClosingEntries = false // TODO: 決算整理仕訳　使用していない2020/10/07
    @objc dynamic var switching = false                    // 有効無効
    // @objc dynamic var explaining: String = ""              // 説明
}
