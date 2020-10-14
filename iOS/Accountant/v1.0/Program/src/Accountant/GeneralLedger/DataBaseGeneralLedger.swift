//
//  DataBaseGeneralLedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 総勘定元帳クラス
// 総勘定元帳 は 勘定 を 1 個以上持つことができます。
class DataBaseGeneralLedger: RObject {
    @objc dynamic var fiscalYear: Int = 0           // 年度
    let dataBaseAccounts = List<DataBaseAccount>() // 勘定
//    let dataBasePLAccounts = List<DataBasePLAccount>() // 損益勘定
    @objc dynamic var dataBasePLAccount: DataBasePLAccount? // 損益勘定
}
