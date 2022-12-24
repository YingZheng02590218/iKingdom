//
//  DataBaseSettingsOperatingJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定仕訳画面 よく使う仕訳
class DataBaseSettingsOperatingJournalEntry: RObject {
    // モデル定義
    // 連番　プライマリーキー
    @objc dynamic var nickname: String = ""                 // ニックネーム
    @objc dynamic var debit_category: String = ""       // 借方勘定
    @objc dynamic var debit_amount: Int64 = 0           // 借方金額
    @objc dynamic var credit_category: String = ""      // 貸方勘定
    @objc dynamic var credit_amount: Int64 = 0          // 貸方金額
    @objc dynamic var smallWritting: String = ""        // 小書き
}
