//
//  DataBaseManagerMonthlyPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/03/30.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 月次損益勘定クラス
class DataBaseManagerMonthlyPLAccount {
    
    public static let shared = DataBaseManagerMonthlyPLAccount()
    
    private init() {
    }
    
    // MARK: - 月次資本振替仕訳
    
    // MARK: - CRUD
    
    // MARK: Create
    // 追加　決算振替仕訳　月次資本振替仕訳をする
    // 引数：借方勘定、金額、貸方勘定、月次決算日
    func addTransferEntryToNetWorth(debitCategory: String, amount: Int64, creditCategory: String, date: String) {
        var number = 0 // 仕訳番号 自動採番にした
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 月次資本振替仕訳
        let dataBaseJournalEntry = DataBaseMonthlyCapitalTransferJournalEntry(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: date,
            debit_category: creditCategory, // 借方勘定　＊引数の貸方勘定を振替える
            debit_amount: amount, // 借方金額
            credit_category: debitCategory, // 貸方勘定　＊引数の借方勘定を振替える
            credit_amount: amount, // 貸方金額
            smallWritting: "月次資本振替仕訳", // 小書き
            balance_left: 0,
            balance_right: 0
        )
        // 月次資本振替仕訳　が1件超が存在する場合は　削除
        let objects = checkCapitalTransferJournalEntry(date: date)
    outerLoop: while objects.count > 1 {
        for i in 0..<objects.count {
            let isInvalidated = deleteCapitalTransferJournalEntry(primaryKey: objects[i].number)
            print("削除", isInvalidated, objects.count)
            continue outerLoop
        }
        break
    }
        
        if objects.count == 1 {
            // 月次資本振替仕訳　が存在する場合は　更新
            number = updateCapitalTransferJournalEntry(
                primaryKey: objects[0].number,
                date: dataBaseJournalEntry.date,
                debitCategory: dataBaseJournalEntry.debit_category,
                debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                creditCategory: dataBaseJournalEntry.credit_category,
                creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                smallWritting: dataBaseJournalEntry.smallWritting
            )
        } else {
            // 月次資本振替仕訳　が存在しない場合は　作成
            number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
            print(number)
            do {
                // 資本金勘定
                try DataBaseManager.realm.write {
                    // 月次資本振替仕訳
                    dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseCapitalAccount?.dataBaseMonthlyCapitalTransferJournalEntries.append(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Read
    // チェック 月次資本振替仕訳　存在するかを確認
    func checkCapitalTransferJournalEntry(date: String) -> Results<DataBaseMonthlyCapitalTransferJournalEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseMonthlyCapitalTransferJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "date LIKE %@", NSString(string: date)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益"), NSString(string: "損益"))
        ])
        print(objects)
        return objects
    }
    // 取得　月次資本振替仕訳 今年度の勘定別にすべて取得
    func getMonthlyTransferEntryInAccountInFiscalYear() -> Results<DataBaseMonthlyCapitalTransferJournalEntry>? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyCapitalTransferJournalEntries = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyCapitalTransferJournalEntry.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0)),
                NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "資本金勘定"), NSString(string: "資本金勘定"))
            ]
        )
        print("月次資本振替仕訳 12ヶ月分 資本金勘定　今年度の勘定別にすべて取得", dataBaseMonthlyCapitalTransferJournalEntries)
        return dataBaseMonthlyCapitalTransferJournalEntries
    }
    // 取得 月次資本振替仕訳　今年度の勘定別で日付の先方一致 複数
    func getAllMonthlyTransferEntryInAccountBeginsWith(yearMonth: String) -> Results<DataBaseMonthlyCapitalTransferJournalEntry>? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyCapitalTransferJournalEntries = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyCapitalTransferJournalEntry.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0)),
                // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                NSPredicate(format: "date BEGINSWITH %@", NSString(string: yearMonth))
            ]
        )
        return dataBaseMonthlyCapitalTransferJournalEntries.sorted(byKeyPath: "date", ascending: true)
    }
    // 取得 月次資本振替仕訳 資本金勘定から月別に取得
    func getCapitalTransferJournalEntryInAccount(yearMonth: String) -> DataBaseMonthlyCapitalTransferJournalEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseCapitalAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
        let dataBaseMonthlyCapitalTransferJournalEntries = dataBaseCapitalAccount?.dataBaseMonthlyCapitalTransferJournalEntries
        // BEGINSWITH 先頭が指定した文字で始まるデータを検索
            .filter("date BEGINSWITH '\(yearMonth)'")
            .sorted(byKeyPath: "date", ascending: true)
        
        return dataBaseMonthlyCapitalTransferJournalEntries?.first
    }
    
    // MARK: Update
    // 更新 月次資本振替仕訳
    func updateCapitalTransferJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
        // 編集前の借方勘定と貸方勘定をメモする
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date,
                    "debit_category": debitCategory,
                    "debit_amount": debitAmount,
                    "credit_category": creditCategory,
                    "credit_amount": creditAmount,
                    "smallWritting": smallWritting
                ]
                DataBaseManager.realm.create(DataBaseMonthlyCapitalTransferJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    // 削除 月次資本振替仕訳
    func deleteCapitalTransferJournalEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseMonthlyCapitalTransferJournalEntry.self, key: primaryKey) else { return false }
        // 資本金勘定
        guard let oldLeftObject: DataBaseCapitalAccount = DataBaseManagerPLAccount.shared.getCapitalAccountByFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else {
            return false
        }
        // 資本金勘定　から削除前月次資本振替仕訳データの関連を削除
        for i in 0..<oldLeftObject.dataBaseMonthlyCapitalTransferJournalEntries.count {
            if oldLeftObject.dataBaseMonthlyCapitalTransferJournalEntries[i].number == primaryKey {
                do {
                    try DataBaseManager.realm.write {
                        oldLeftObject.dataBaseMonthlyCapitalTransferJournalEntries.remove(at: i)
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
        
        if !dataBaseJournalEntry.isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    // 月次資本振替仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    
    // 削除　月次資本振替仕訳 今年度の月次資本振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
    func deleteMonthlyTransferEntryInAccountInFiscalYear() {
        // 今年度の勘定別の月次資本振替仕訳　今年度の勘定別にすべて取得
        if let dataBaseMonthlyTransferEntries = getMonthlyTransferEntryInAccountInFiscalYear() {
            for dataBaseMonthlyTransferEntry in dataBaseMonthlyTransferEntries {
                // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                if DateManager.shared.isInPeriod(date: dataBaseMonthlyTransferEntry.date) {
                    // 範囲内
                } else {
                    // 範囲外
                    print(dataBaseMonthlyTransferEntry)
                    // 関連を削除する
                    if let dataBaseCapitalAccount: DataBaseCapitalAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                        accountName: "資本金勘定",
                        fiscalYear: dataBaseMonthlyTransferEntry.fiscalYear
                    ) {
                    outerLoop: while true {
                        for i in 0..<dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries.count where dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries[i].number == dataBaseMonthlyTransferEntry.number ||
                        dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries[i].isInvalidated {
                            do {
                                try DataBaseManager.realm.write {
                                    dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries.remove(at: i)
                                }
                            } catch {
                                print("エラーが発生しました")
                            }
                            continue outerLoop
                        }
                        break
                    }
                    }
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
    
    // 削除　月次資本振替仕訳 今年度の勘定別の月次資本振替仕訳のうち、日付（年月）が重複している場合、削除する
    func deleteDuplicatedMonthlyTransferEntryInAccountInFiscalYear() {
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for index in 0..<lastDays.count {
            // 取得 月次資本振替仕訳　今年度の勘定別で日付の先方一致 複数
            if let dataBaseMonthlyCapitalTransferJournalEntries = getAllMonthlyTransferEntryInAccountBeginsWith(
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
            ) {
                while dataBaseMonthlyCapitalTransferJournalEntries.count > 1 {
                    if let dataBaseMonthlyTransferEntry = dataBaseMonthlyCapitalTransferJournalEntries.first {
                        print(dataBaseMonthlyTransferEntry)
                        // 関連を削除する
                        if let dataBaseCapitalAccount: DataBaseCapitalAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
                            accountName: "資本金勘定",
                            fiscalYear: dataBaseMonthlyTransferEntry.fiscalYear
                        ) {
                        outerLoop: while true {
                            for i in 0..<dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries.count where dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries[i].number == dataBaseMonthlyTransferEntry.number ||
                            dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries[i].isInvalidated {
                                do {
                                    try DataBaseManager.realm.write {
                                        dataBaseCapitalAccount.dataBaseMonthlyCapitalTransferJournalEntries.remove(at: i)
                                    }
                                } catch {
                                    print("エラーが発生しました")
                                }
                                continue outerLoop
                            }
                            break
                        }
                        }
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
