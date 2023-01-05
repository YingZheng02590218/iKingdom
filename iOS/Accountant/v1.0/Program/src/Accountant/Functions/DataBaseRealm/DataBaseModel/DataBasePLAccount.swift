//
//  DataBasePLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/04.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益勘定クラス
class DataBasePLAccount: DataBaseAccount {
    // 損益振替仕訳
    let dataBaseTransferEntries = List<DataBaseTransferEntry>()
    // 資本振替仕訳
    @objc dynamic var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
}
