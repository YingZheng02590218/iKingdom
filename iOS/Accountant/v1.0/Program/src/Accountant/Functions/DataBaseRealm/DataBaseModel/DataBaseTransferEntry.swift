//
//  DataBaseTransferEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/03.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import RealmSwift

// 損益振替仕訳クラス、残高振替仕訳クラス 決算振替仕訳
// 仕訳クラス　と　クラス名が違うだけでその他は同じ
class DataBaseTransferEntry: DataBaseJournalEntry {

}
// 設定残高振替仕訳クラス 開始残高で使用する
class DataBaseSettingTransferEntry: DataBaseJournalEntry {

}
