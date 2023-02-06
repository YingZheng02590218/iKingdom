//
//  DataBaseSettingsTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 設定表記名クラス
// class DataBaseSettingsCategoryBSAndPL: RObject {
//    // モデル定義
//    @objc dynamic var big_category: Int = 0        //大分類
//    @objc dynamic var mid_category: Int = 0        //中分類
//    @objc dynamic var small_category: Int = 0      //小分類
//    @objc dynamic var BSAndPL_category: Int = 0   //表記名の番号
//    @objc dynamic var category: String = ""        //決算書上の表記名
//    @objc dynamic var switching: Bool = false      //有効無効
// }

// 設定表示科目クラス
class DataBaseSettingsTaxonomy: RObject {
    convenience init(
        category0: String,
        category1: String,
        category2: String,
        category3: String,
        category4: String,
        category5: String,
        category6: String,
        category7: String,
        category: String,
        abstract: Bool,
        switching: Bool
    ) {
        self.init()

        self.category0 = category0
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.category4 = category4
        self.category5 = category5
        self.category6 = category6
        self.category7 = category7
        self.category = category
        self.abstract = abstract
        self.switching = switching
    }

    @objc dynamic var category0: String = "" // 階層0
    @objc dynamic var category1: String = "" // 階層1
    @objc dynamic var category2: String = "" // 階層2  大分類　資産の部　など
    @objc dynamic var category3: String = "" // 階層3
    @objc dynamic var category4: String = "" // 階層4
    @objc dynamic var category5: String = "" // 階層5
    @objc dynamic var category6: String = "" // 階層6
    @objc dynamic var category7: String = "" // 階層7
    @objc dynamic var category: String = ""  // 表示科目名
    @objc dynamic var abstract = false // 抽象区分
    @objc dynamic var switching = false // 有効無効
}
