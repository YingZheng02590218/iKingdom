//
//  DataBaseCompoundTrialBalance.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 合計残高試算表クラス
// 合計残高試算表 は 勘定(合計と残高) を 1 つ以上持っています。
class DataBaseCompoundTrialBalance: RObject {
    convenience init(
        fiscalYear: Int,

        debit_total_total: Int64,
        credit_total_total: Int64,
        debit_balance_total: Int64,
        credit_balance_total: Int64
    ) {
        self.init()

        self.fiscalYear = fiscalYear

        self.debit_total_total = debit_total_total
        self.credit_total_total = credit_total_total
        self.debit_balance_total = debit_balance_total
        self.credit_balance_total = credit_balance_total
    }

    @objc dynamic var fiscalYear: Int = 0          // 年度
    // let dataBaseAccount = List<DataBaseAccount>() // 一対多の関連
    @objc dynamic var debit_total_total: Int64 = 0                     // 借方　合計　集計
    @objc dynamic var credit_total_total: Int64 = 0                     // 貸方　合計　集計
    @objc dynamic var debit_balance_total: Int64 = 0                     // 借方　残高　集計
    @objc dynamic var credit_balance_total: Int64 = 0                     // 貸方　残高　集計
}
// 月次合計残高試算表クラス
class DataBaseCompoundTrialBalanceMonth: DataBaseCompoundTrialBalance {

}
// 日次合計残高試算表クラス
class DataBaseCompoundTrialBalanceDay: DataBaseCompoundTrialBalance {

}
// 繰越試算表
class DataBaseAfterClosingTrialBalance: DataBaseCompoundTrialBalance {

}
