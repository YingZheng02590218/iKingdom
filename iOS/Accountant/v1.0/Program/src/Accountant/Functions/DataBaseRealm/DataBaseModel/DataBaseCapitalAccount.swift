//
//  DataBaseCapitalAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/08.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 資本金勘定クラス　当期純利益を資本振替仕訳する対象の特別な勘定（繰越利益、元入金　として使用する）
class DataBaseCapitalAccount: DataBaseAccount {
    // 資本振替仕訳
    @objc dynamic var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
    // 月次資本振替仕訳
     let dataBaseMonthlyCapitalTransferJournalEntries = List<DataBaseMonthlyCapitalTransferJournalEntry>()
    // 月次損益振替仕訳、月次残高振替仕訳 資本金勘定クラスとしても使用する
    // let dataBaseMonthlyTransferEntries = List<DataBaseMonthlyTransferEntry>()
}
