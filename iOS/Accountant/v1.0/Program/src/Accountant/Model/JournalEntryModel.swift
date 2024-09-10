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
    // 仕訳 複合仕訳
    func addJournalEntry(journalEntryDatas: [JournalEntryData], completion: () -> Void)
    // 仕訳
    func addJournalEntry(isForced: Bool, journalEntryData: JournalEntryData, completion: (Int) -> Void, errorHandler: ([Int]) -> Void)
    // 決算整理仕訳
    func addAdjustingJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void)
    // 仕訳 更新
    func updateJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void)
    // 決算整理仕訳 更新
    func updateAdjustingJournalEntry(journalEntryData: JournalEntryData, primaryKey: Int, completion: (Int) -> Void)
}

// 仕訳クラス
class JournalEntryModel: JournalEntryModelInput {

    // 仕訳 複合仕訳
    func addJournalEntry(journalEntryDatas: [JournalEntryData], completion: () -> Void) {
        for data in journalEntryDatas {
            // 取得 仕訳　日付と借方勘定科目、貸方勘定科目、金額が同一の仕訳
            let journalEntries = DataBaseManagerJournalEntry.shared.getJournalEntryWith(
                date: data.date!,
                debitCategory: data.debit_category!,
                debitAmount: data.debit_amount!,
                creditCategory: data.credit_category!,
                creditAmount: data.credit_amount!
            )
            let number = DataBaseManagerJournalEntry.shared.addJournalEntry(
                date: data.date!,
                debitCategory: data.debit_category!,
                debitAmount: data.debit_amount!,
                creditCategory: data.credit_category!,
                creditAmount: data.credit_amount!,
                smallWritting: data.smallWritting ?? ""
            )
            print(number)
        }
        completion()
    }
    // 仕訳
    func addJournalEntry(isForced: Bool, journalEntryData: JournalEntryData, completion: (Int) -> Void, errorHandler: ([Int]) -> Void) {
        // 取得 仕訳　日付と借方勘定科目、貸方勘定科目、金額が同一の仕訳
        let journalEntries = DataBaseManagerJournalEntry.shared.getJournalEntryWith(
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount! // カンマを削除してからデータベースに書き込む
        ) 
        if journalEntries.isEmpty || isForced {
            let number = DataBaseManagerJournalEntry.shared.addJournalEntry(
                date: journalEntryData.date!,
                debitCategory: journalEntryData.debit_category!,
                debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
                creditCategory: journalEntryData.credit_category!,
                creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
                smallWritting: journalEntryData.smallWritting ?? ""
            )
            completion(number)
        } else {
            errorHandler(journalEntries.map{ $0.number })
        }
    }
    // 決算整理仕訳
    func addAdjustingJournalEntry(journalEntryData: JournalEntryData, completion: (Int) -> Void) {
        let number = DataBaseManagerAdjustingEntry.shared.addAdjustingJournalEntry(
            date: journalEntryData.date!,
            debitCategory: journalEntryData.debit_category!,
            debitAmount: journalEntryData.debit_amount!, // カンマを削除してからデータベースに書き込む
            creditCategory: journalEntryData.credit_category!,
            creditAmount: journalEntryData.credit_amount!, // カンマを削除してからデータベースに書き込む
            smallWritting: journalEntryData.smallWritting ?? ""
        )
        completion(number)
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
            smallWritting: journalEntryData.smallWritting ?? "",
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
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
            smallWritting: journalEntryData.smallWritting ?? "",
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
}
