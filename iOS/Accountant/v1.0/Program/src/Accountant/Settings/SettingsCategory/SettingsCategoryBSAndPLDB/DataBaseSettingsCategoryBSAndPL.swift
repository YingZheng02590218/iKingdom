//
//  DataBaseSettingsCategoryBSAndPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 設定表記名クラス
class DataBaseSettingsCategoryBSAndPL: RObject {
    // モデル定義
    @objc dynamic var big_category: Int = 0        //大分類
    @objc dynamic var mid_category: Int = 0        //中分類
    @objc dynamic var small_category: Int = 0      //小分類
    @objc dynamic var BSAndPL_category: Int = 0   //表記名の番号
    @objc dynamic var category: String = ""        //決算書上の表記名
    @objc dynamic var switching: Bool = false      //有効無効
}
