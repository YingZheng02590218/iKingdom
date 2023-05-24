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
    // 決算整理仕訳
    func addAdjustingJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void)
    // 決算整理仕訳 更新
    func updateAdjustingJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void)
    // 仕訳 更新
    func updateJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void)
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
    // 決算整理仕訳
    func addAdjustingJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void) {
        let number = DataBaseManagerAdjustingEntry.shared.addAdjustingJournalEntry(
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
            smallWritting: journalEntryData.smallWritting!
        )
        completion(number)
    }
    // 決算整理仕訳 更新
    func updateAdjustingJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void) {
        DataBaseManagerAdjustingEntry.shared.updateAdjustingJournalEntry(
            primaryKey: primaryKey,
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
            smallWritting: journalEntryData.smallWritting!,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
    // 仕訳 更新
    func updateJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void) {
        DataBaseManagerJournalEntry.shared.updateJournalEntry(
            primaryKey: primaryKey,
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
            smallWritting: journalEntryData.smallWritting!,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
}
