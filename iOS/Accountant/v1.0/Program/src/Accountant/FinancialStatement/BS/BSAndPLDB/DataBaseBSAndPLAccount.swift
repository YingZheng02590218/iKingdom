//
//  DataBaseBSAndPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 貸借対照表と損益計算書の表記名クラス
class DataBaseBSAndPLAccount: RObject {
    // モデル定義
    @objc dynamic var fiscalYear: Int = 0            //年度
    @objc dynamic var accountName: String = ""      // 表記名
//    let dataBaseAccounts = List<DataBaseAccount>() //一対多の関連 勘定
    @objc dynamic var total: Int64 = 0               //合計額
}
