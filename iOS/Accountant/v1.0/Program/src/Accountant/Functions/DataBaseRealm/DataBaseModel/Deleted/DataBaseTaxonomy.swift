//
//  DataBaseTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 表示科目クラス　廃止
class DataBaseTaxonomy: RObject {
    convenience init(
        fiscalYear: Int,
        accountName: String,
        total: Int64,
        numberOfTaxonomy: Int
    ) {
        self.init()
        
        self.fiscalYear = fiscalYear
        self.accountName = accountName
        self.total = total
        self.numberOfTaxonomy = numberOfTaxonomy
    }
    
    // モデル定義
    @objc dynamic var fiscalYear: Int = 0               // 年度
    @objc dynamic var accountName: String = ""         // 表示科目名
    //　let dataBaseAccounts = List<DataBaseAccount>() // 一対多の関連 勘定
    @objc dynamic var total: Int64 = 0                   // 合計額
    @objc dynamic var numberOfTaxonomy: Int = 0        // 設定表示科目の連番　マイグレーション
}
