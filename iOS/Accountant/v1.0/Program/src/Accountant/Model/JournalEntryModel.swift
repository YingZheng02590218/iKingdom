//
//  JournalEntryModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/05/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
/// GUIアーキテクチャ　MVP
protocol JournalEntryModelInput {
    // 仕訳
    func addJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void)
}

// 仕訳クラス
class JournalEntryModel: JournalEntryModelInput {
    
    // 仕訳
    func addJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void) {
        
        let number = DataBaseManagerJournalEntry.shared.addJournalEntry(
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
            smallWritting: journalEntryData.smallWritting!
        )
        completion(number)
    }

}
