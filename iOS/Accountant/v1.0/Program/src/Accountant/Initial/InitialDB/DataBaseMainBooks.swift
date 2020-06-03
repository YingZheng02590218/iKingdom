//
//  DataBaseMainBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 主要簿クラス
// 主要簿 は 仕訳帳　と　元帳 を 1 個ずつ持つことができます。
class DataBaseMainBooks: RObject {
    @objc dynamic var fiscalYear: Int = 0                                 // 年度
    @objc dynamic var dataBaseJournalEntryBook: DataBaseJournalEntryBook? // 仕訳帳
    // = DataBaseJournalEntryBook() と書くのは誤り
    @objc dynamic var dataBaseGeneralLedger: DataBaseGeneralLedger?       // 総勘定元帳

}
