//
//  File.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/24.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 構造体定義
struct JournalEntryData {
    // ストアドプロパティ定義（初期値なし）
    let date: String?
    let debit_category: String?
    let debit_amount: Int64?
    let credit_category: String?
    let credit_amount: Int64?
    let smallWritting: String?
    // initを使用することでイニシャライザ定義
    init(date: String?, debit_category: String?, debit_amount: Int64?, credit_category: String?, credit_amount: Int64?, smallWritting: String?) {
        self.date = date
        self.debit_category = debit_category
        self.debit_amount = debit_amount
        self.credit_category = credit_category
        self.credit_amount = credit_amount
        self.smallWritting = smallWritting
    }
    // 値が入っているプロパティがあるかどうかをチェックする
    func checkPropertyIsNil() -> Bool {
        guard date != nil else { return false }
        guard debit_category != nil else { return false }
        guard debit_amount != nil else { return false }
        guard credit_category != nil else { return false }
        guard credit_amount != nil else { return false }
        guard smallWritting != nil else { return false }

        return true
    }
}
