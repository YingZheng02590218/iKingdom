//
//  DataBaseWorkSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 精算表クラス
// 精算表 は 合計残高試算表(残高試算表部分のみを使用) を 1 つ以上持っています。
class DataBaseWorkSheet: RObject {
    @objc dynamic var fiscalYear: Int = 0                                            // 年度
//    @objc dynamic var dataBaseCompoundTrialBalance: DataBaseCompoundTrialBalance? // 合計残高試算表
    let adjustingEntries = List<DataBaseAdjustingEntry>()                           // 決算整理仕訳　一対多の関連
    // 当期純利益は損益計算書に記入する
//    @objc dynamic var netIncomeOrNetLoss: Int64 = 0                                 // 当期純利益(損失)
}
