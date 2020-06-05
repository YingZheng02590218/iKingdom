//
//  DataBaseAccountingBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 会計帳簿棚クラス
// 会計帳簿 は 主要簿　と　補助簿 を 持つことができます。
class DataBaseAccountingBooks: RObject {
    @objc dynamic var fiscalYear: Int = 0                                 // 年度
    @objc dynamic var dataBaseJournalEntryBook: DataBaseJournalEntryBook? // 仕訳帳
    // = DataBaseJournalEntryBook() と書くのは誤り
    @objc dynamic var dataBaseGeneralLedger: DataBaseGeneralLedger?       // 総勘定元帳
//    @objc dynamic var dataBaseSubsidiaryLedger: DataBaseSubsidiaryLedger? // 補助元簿
    @objc dynamic var openOrClose: Bool = false                           // 会計帳簿を開いているかどうか
}
