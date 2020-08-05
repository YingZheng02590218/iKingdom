//
//  DatabaseSettings.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 設定勘定科目クラス
class DataBaseSettingsCategory: RObject {
    // モデル定義
    @objc dynamic var big_category: Int = 0       //大分類
    @objc dynamic var mid_category: Int = 0       //中分類
    @objc dynamic var small_category: Int = 0     //小分類
    @objc dynamic var BSAndPL_category: Int = 0   //貸借対照表と損益計算書上の表記名
    @objc dynamic var AdjustingAndClosingEntries: Bool = false     //決算整理仕訳
    @objc dynamic var category: String = ""       //勘定科目
    @objc dynamic var explaining: String = ""     //説明
    @objc dynamic var switching: Bool = false     //有効無効
}
