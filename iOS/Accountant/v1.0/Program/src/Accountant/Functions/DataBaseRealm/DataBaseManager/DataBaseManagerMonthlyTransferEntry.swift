//
//  DataBaseManagerMonthlyTransferEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/25.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 月次損益振替仕訳、月次残高振替仕訳クラス
class DataBaseManagerMonthlyTransferEntry {

    public static let shared = DataBaseManagerMonthlyTransferEntry()

    private init() {
    }
    
    // MARK: - 月次損益振替仕訳
    
    // MARK: - CRUD
    
    // MARK: Create

    // MARK: Read
    
    // MARK: Update
    
    
    // MARK: Delete

    
    // MARK: - 月次残高振替仕訳

    // MARK: - CRUD

    // MARK: Create
    // 追加　決算振替仕訳　月次残高振替仕訳をする
    func addMonthlyTransferEntryForClosingBalanceAccount(
        date: String,
        debitCategory: String,
        creditCategory: String,
        debitAmount: Int64,
        creditAmount: Int64,
        balanceLeft: Int64,
        balanceRight: Int64
    ) {
        var account: String = "" // 残高振替の相手勘定
        if debitCategory == "残高" {
            account = creditCategory
        } else if creditCategory == "残高" {
            account = debitCategory
        }
        var number = 0 // 仕訳番号 自動採番にした
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)

        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseMonthlyTransferEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: date,
            debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
            debit_amount: debitAmount, // 借方金額
            credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
            credit_amount: creditAmount, // 貸方金額
            smallWritting: "月次残高振替仕訳", // 小書き
            balance_left: balanceLeft,
            balance_right: balanceRight
        )
        // 取得　月次残高振替仕訳 勘定別に取得　今年度の勘定別で日付が同一
        if let dataBaseTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccount(account: account, date: date) {
            // 残高振替仕訳　が存在する場合は　更新
            number = updateTransferEntry(
                primaryKey: dataBaseTransferEntry.number,
                date: dataBaseJournalEntry.date,
                debitCategory: dataBaseJournalEntry.debit_category,
                creditCategory: dataBaseJournalEntry.credit_category,
                debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                smallWritting: dataBaseJournalEntry.smallWritting,
                balanceLeft: Int64(dataBaseJournalEntry.balance_left),
                balanceRight: Int64(dataBaseJournalEntry.balance_right)
            )
        } else {
            // 残高振替仕訳　が存在しない場合は　作成
//            if amount != 0 {
                number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                print(number)
                do {
                    // MARK: 残高振替仕訳は、仕訳帳には追加しない。
                    // 相手方の勘定
                    if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
//                        if account == "資本金勘定" {
//                            try DataBaseManager.realm.write {
//                                dataBaseGeneralLedger.dataBaseCapitalAccount?.dataBaseTransferEntry = dataBaseJournalEntry
//                            }
//                        } else {
                            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                try DataBaseManager.realm.write {
                                    // 月次損益振替仕訳、月次残高振替仕訳
                                    dataBaseGeneralLedger.dataBaseAccounts[i].dataBaseMonthlyTransferEntries.append(dataBaseJournalEntry)
                                }
                                break
                            }
//                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
//            }
        }
    }

    // MARK: Read
    // 取得　月次残高振替仕訳 今年度の勘定別にすべて取得
    func getMonthlyTransferEntryInAccountInFiscalYear(account: String) -> List<DataBaseMonthlyTransferEntry>? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
        print("月次残高振替仕訳 12ヶ月分 \(account)　今年度の勘定別にすべて取得", dataBaseMonthlyTransferEntries)
        return dataBaseMonthlyTransferEntries
    }
    // 取得　月次残高振替仕訳 勘定別に取得　今年度の勘定別で日付が同一
    func getMonthlyTransferEntryInAccount(account: String, date: String) -> DataBaseMonthlyTransferEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
            .filter("date LIKE '\(date)'")
        print("月次残高振替仕訳 \(account)　今年度の勘定別で日付が同一", dataBaseMonthlyTransferEntries)
        return dataBaseMonthlyTransferEntries?.first
    }
    // 決算日が月末ではない場合、年が違う同じ月の月次残高振替仕訳が存在するため、CONTAINS 部分一致では区別がつかないため、使用しない
    //    // 取得 月次残高振替仕訳　勘定別
    //    func getMonthlyTransferEntryInAccount(account: String, yearMonth: String) -> DataBaseMonthlyTransferEntry? {
    //        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
    //            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
    //        ])
    //        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
    //            .filter("accountName LIKE '\(account)'").first
    //        // print("月次残高振替仕訳 12ヶ月分 \(account)", dataBaseAccount?.dataBaseMonthlyTransferEntries)
    //        let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
    //        // CONTAINS 部分一致
    //            .filter("date CONTAINS '\(yearMonth)'") // 決算日が変更され、年が変わった場合の対策
    //            .sorted(byKeyPath: "date", ascending: true)
    //        print(dataBaseMonthlyTransferEntries)
    //        return dataBaseMonthlyTransferEntries?.first
    //    }
    
    // 取得 月次残高振替仕訳　今年度の勘定別で日付の先方一致
    func getMonthlyTransferEntryInAccountBeginsWith(account: String, yearMonth: String) -> DataBaseMonthlyTransferEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
        // BEGINSWITH 先頭が指定した文字で始まるデータを検索
            .filter("date BEGINSWITH '\(yearMonth)'")
            .sorted(byKeyPath: "date", ascending: true)
        print("月次残高振替仕訳 \(account)　今年度の勘定別で日付の先方一致", dataBaseMonthlyTransferEntries)
        return dataBaseMonthlyTransferEntries?.first
    }
    // 取得 月次残高振替仕訳　今年度の勘定別で日付の先方一致 複数
    func getAllMonthlyTransferEntryInAccountBeginsWith(account: String, yearMonth: String) -> Results<DataBaseMonthlyTransferEntry>? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(account)'").first
        let dataBaseMonthlyTransferEntries = dataBaseAccount?.dataBaseMonthlyTransferEntries
        // BEGINSWITH 先頭が指定した文字で始まるデータを検索
            .filter("date BEGINSWITH '\(yearMonth)'")
            .sorted(byKeyPath: "date", ascending: true)
        print("月次残高振替仕訳 \(account)　今年度の勘定別で日付の先方一致 複数", dataBaseMonthlyTransferEntries)
        return dataBaseMonthlyTransferEntries
    }
    
    // MARK: Update
    // 更新 月次残高振替仕訳
    func updateTransferEntry(
        primaryKey: Int,
        date: String,
        debitCategory: String,
        creditCategory: String,
        debitAmount: Int64,
        creditAmount: Int64,
        smallWritting: String,
        balanceLeft: Int64,
        balanceRight: Int64
    ) -> Int {
        // 編集前の借方勘定と貸方勘定をメモする
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date,
                    "debit_category": debitCategory,
                    "credit_category": creditCategory,
                    "debit_amount": debitAmount,
                    "credit_amount": creditAmount,
                    "smallWritting": smallWritting,
                    "balance_left": balanceLeft,
                    "balance_right": balanceRight,
                ]
                DataBaseManager.realm.create(DataBaseMonthlyTransferEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    // 削除　月次残高振替仕訳 今年度の勘定別の月次残高振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
    func deleteMonthlyTransferEntryInAccountInFiscalYear(account: String) {
        // 今年度の勘定別の月次残高振替仕訳　今年度の勘定別にすべて取得
        if let dataBaseMonthlyTransferEntries = getMonthlyTransferEntryInAccountInFiscalYear(account: account) {
            print(dataBaseMonthlyTransferEntries)
            for dataBaseMonthlyTransferEntry in dataBaseMonthlyTransferEntries {
                // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                if DateManager.shared.isInPeriod(date: dataBaseMonthlyTransferEntry.date) {
                    // 範囲内
                } else {
                    // 範囲外
                    do {
                        try DataBaseManager.realm.write {
                            DataBaseManager.realm.delete(dataBaseMonthlyTransferEntry)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    // 削除　月次残高振替仕訳 今年度の勘定別の月次残高振替仕訳のうち、日付（年月）が重複している場合、削除する
    func deleteDuplicatedMonthlyTransferEntryInAccountInFiscalYear(account: String) {
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for index in 0..<lastDays.count {
            // 取得 月次残高振替仕訳　今年度の勘定別で日付の先方一致 複数
            if let dataBaseMonthlyTransferEntries = getAllMonthlyTransferEntryInAccountBeginsWith(
                account: account,
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
            ) {
                while dataBaseMonthlyTransferEntries.count > 1 {
                    if let dataBaseMonthlyTransferEntry = dataBaseMonthlyTransferEntries.first {
                        do {
                            try DataBaseManager.realm.write {
                                DataBaseManager.realm.delete(dataBaseMonthlyTransferEntry)
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                    }
                }
            }
        }
    }
    
}
