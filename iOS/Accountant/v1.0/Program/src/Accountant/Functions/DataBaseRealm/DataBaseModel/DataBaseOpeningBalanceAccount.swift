//
//  DataBaseOpeningBalanceAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 開始残高勘定クラス
class DataBaseOpeningBalanceAccount: DataBaseAccount {
    // 設定残高振替仕訳
    let dataBaseTransferEntries = List<DataBaseSettingTransferEntry>()
}
