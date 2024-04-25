//
//  DataBaseManagerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 勘定クラス
class DataBaseManagerAccount {

    public static let shared = DataBaseManagerAccount()

    private init() {
    }
    
    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して勘定を取得する
     * @param  勘定名
     * @return  勘定
     */
    func getAccountByAccountNameWithFiscalYear(accountName: String, fiscalYear: Int) -> DataBaseAccount? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        if accountName == Constant.capitalAccountName || accountName == "資本金勘定" {
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
            return dataBaseAccount
        } else {
            let dataBaseAccounts = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(accountName)'")
            guard let dataBaseAccount = dataBaseAccounts?.first else {
                return nil
            }
            return dataBaseAccount
        }
    }
    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して勘定を取得する 元入金、繰越利益　専用
     * @param  勘定名
     * @return  勘定
     */
    func getAccountByAccountNameWithFiscalYearForCapital(accountName: String, fiscalYear: Int) -> DataBaseAccount? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        let dataBaseAccounts = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(accountName)'")
        guard let dataBaseAccount = dataBaseAccounts?.first else {
            return nil
        }
        return dataBaseAccount
    }
    
    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 勘定名と年度を指定して勘定を取得する
     * @param accountName 勘定名、fiscalYear 年度
     * @return  DataBaseAccount? 勘定、DataBasePLAccount? 損益勘定、DataBaseCapitalAccount? 資本金勘定
     * 特殊化方法: 戻り値からの型推論による特殊化　戻り値の代入先の型が決まっている必要がある
     */
    func getAccountByAccountNameWithFiscalYear<T>(accountName: String, fiscalYear: Int) -> T? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        if /*accountName == Constant.capitalAccountName ||*/ accountName == "資本金勘定" {
            // 資本金勘定の場合
            guard let dataBaseCapitalAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount else {
                return nil
            }
            return dataBaseCapitalAccount as? T
        } else if accountName == "損益" {
            // 損益勘定の場合
            guard let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount else {
                return nil
            }
            return dataBasePLAccount as? T
        } else {
            // 資本金勘定、損益勘定　以外の勘定の場合
            guard let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                    .filter("accountName LIKE '\(accountName)'")
                    .first else {
                        return nil
                    }
            return dataBaseAccount as? T
        }
    }
    
    // 取得　勘定名から勘定を取得
    func getAccountByAccountName(accountName: String) -> DataBaseAccount? {
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let dataBaseAccount = RealmManager.shared.read(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "accountName LIKE %@", NSString(string: accountName))
        ])
        return dataBaseAccount
    }

    /**
     * 勘定科目　読込みメソッド
     * 勘定名別の残高をデータベースから読み込む。
     * @param rank0 設定勘定科目の大区分
     * @param rank1 設定勘定科目の中区分
     * @param accountNameOfSettingsTaxonomyAccount 設定勘定科目の勘定科目名
     * @param number 設定勘定科目の連番
     * @return result 勘定名別の残高額
     */
    func getTotalOfTaxonomyAccount(rank0: Int, rank1: Int, accountNameOfSettingsTaxonomyAccount: String, lastYear: Bool) -> String {
        var result: Int64 = 0
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        // 法人/個人フラグ
        let capitalAccount = Constant.capitalAccountName
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        // 勘定クラス
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if capitalAccount == accountNameOfSettingsTaxonomyAccount {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    print("借方残高", dataBaseCapitalAccount.debit_balance_AfterAdjusting)
                    print("貸方残高", dataBaseCapitalAccount.credit_balance_AfterAdjusting)
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == accountNameOfSettingsTaxonomyAccount {
                    print("借方残高", dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting)
                    print("貸方残高", dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting)
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            }
            switch rank0 {
            case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            case 9, 10: // 営業外損益 特別損益
                if rank1 == 15 || rank1 == 17 { // 営業外損益
                    switch debitOrCredit {
                    case "借":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                } else if rank1 == 16 || rank1 == 18 { // 特別損益
                    switch debitOrCredit {
                    case "貸":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                }
            default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
                switch debitOrCredit {
                case "借":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            }
        }
        if positiveOrNegative == "-" {
            // 残高がマイナスの場合、三角のマークをつける
            result = (result * -1)
        }

        // カンマを追加して文字列に変換した値を返す
        return StringUtility.shared.setComma(amount: result)
    }

    // 取得　損益振替仕訳、残高振替仕訳 勘定別に取得
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry? {
        if account == Constant.capitalAccountName || account == "資本金勘定" {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
            return dataBaseTransferEntry
        } else {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
            return dataBaseTransferEntry
        }
    }
    // 取得　開始仕訳 勘定別に取得
    func getOpeningJournalEntryInAccount(account: String) -> DataBaseOpeningJournalEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        // NOTE: 資本金勘定を使用せずに月次残高振替仕訳する際に使用している
        if account == Constant.capitalAccountName || account == "資本金勘定" {
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseOpeningJournalEntry
            return dataBaseTransferEntry
        } else {
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseOpeningJournalEntry
            return dataBaseTransferEntry
        }
    }
    // 取得　開始仕訳（前年度の残高振替仕訳） 勘定別に取得
    func getTransferEntryInAccountLastYear(account: String) -> DataBaseTransferEntry? {
        if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])

            guard let fiscalYear = dataBaseAccountingBook?.fiscalYear else { return nil }

            let lastDataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear - 1))
            ])
            if account == Constant.capitalAccountName || account == "資本金勘定" {
                let dataBaseAccount = lastDataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
                let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
                return dataBaseTransferEntry
            } else {
                let dataBaseAccount = lastDataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                    .filter("accountName LIKE '\(account)'").first
                let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
                return dataBaseTransferEntry
            }
        } else {
            // 前年度の会計帳簿　が存在しない
            return nil
        }
    }
    // 取得　開始仕訳（設定開始残高勘定の残高振替仕訳） 勘定別に取得
    func getSettingTransferEntryInAccountLastYear(account: String) -> DataBaseSettingTransferEntry? {
        // 初期設定開始残高勘定を参照する
        var dataBaseSettingTransferEntries = DataBaseManagerAccountingBooksShelf.shared.getTransferEntriesInOpeningBalanceAccount()
        dataBaseSettingTransferEntries = dataBaseSettingTransferEntries
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
        return dataBaseSettingTransferEntries.first
    }

    // MARK: Update

    // MARK: Delete

    // MARK: - 開始仕訳

    // MARK: - CRUD

    // MARK: Create
    // 追加　開始仕訳　（例:　現金 / 残高）
    func addOpeningJournalEntryFromClosingBalanceAccount(account: String) {
        // 貸借科目　のみに絞る
        if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            // 損益科目　は対象外
            let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
                do {
                    for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                        try DataBaseManager.realm.write {
                            // 勘定から削除前開始仕訳データの関連を削除
                            dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseOpeningJournalEntry = nil
                        }

                        break
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        } else {
            // 前年度の残高振替仕訳を取得
            if let dataBaseTransferEntry = DataBaseManagerAccount.shared.getTransferEntryInAccountLastYear(
                account: account
            ) {
                var account: String = "" // 開始仕訳の相手勘定
                if dataBaseTransferEntry.debit_category == "残高" {
                    account = dataBaseTransferEntry.credit_category
                } else if dataBaseTransferEntry.credit_category == "残高" {
                    account = dataBaseTransferEntry.debit_category
                }
                var number = 0 // 仕訳番号 自動採番にした
                let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
                // 期首
                let beginningOfYearDate = DateManager.shared.getBeginningOfYearDate()
                // オブジェクトを作成
                let dataBaseJournalEntry = DataBaseOpeningJournalEntry(
                    fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
                    date: beginningOfYearDate,
                    debit_category: dataBaseTransferEntry.credit_category, // 借方勘定　＊引数の貸方勘定を振替える
                    debit_amount: dataBaseTransferEntry.credit_amount, // 借方金額
                    credit_category: dataBaseTransferEntry.debit_category, // 貸方勘定　＊引数の借方勘定を振替える
                    credit_amount: dataBaseTransferEntry.debit_amount, // 貸方金額
                    smallWritting: "開始仕訳", // 小書き
                    balance_left: 0,
                    balance_right: 0
                )
                // 開始仕訳　が1件超が存在する場合は　削除
                let objects = checkOpeningJournalEntry(account: account)
            outerLoop: while objects.count > 1 {
                for i in 0..<objects.count {
                    let isInvalidated = deleteOpeningJournalEntry(primaryKey: objects[i].number)
                    print("削除", isInvalidated, objects.count, "開始仕訳　連番", objects.first?.number)
                    continue outerLoop
                }
                break
            }
                if let dataBaseOpeningJournalEntry = getOpeningJournalEntryInAccount(account: account) { // 勘定内に仕訳が存在するか
                    // 諸勘定の開始仕訳にリレーションがある場合
                    print(dataBaseOpeningJournalEntry)
                } else {
                    // 諸勘定の開始仕訳にリレーションがない場合　開始仕訳を全削除
                outerLoop: while objects.count >= 1 {
                    for i in 0..<objects.count {
                        let isInvalidated = deleteOpeningJournalEntry(primaryKey: objects[i].number)
                        print("関連削除", isInvalidated, objects.count)
                        continue outerLoop
                    }
                    break
                }
                }
                // 取得　開始仕訳 勘定別に取得
                if let dataBaseOpeningJournalEntry = DataBaseManagerAccount.shared.getOpeningJournalEntryInAccount(account: account) {
                    // 開始仕訳　が存在する場合は　更新
                    number = updateOpeningJournalEntry(
                        primaryKey: dataBaseOpeningJournalEntry.number,
                        date: dataBaseJournalEntry.date,
                        debitCategory: dataBaseJournalEntry.debit_category,
                        debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                        creditCategory: dataBaseJournalEntry.credit_category,
                        creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                        smallWritting: dataBaseJournalEntry.smallWritting
                    )
                } else {
                    // 開始仕訳　が存在しない場合は　作成
                    //            if amount != 0 {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    print(number)
                    do {
                        // 相手方の勘定
                        if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
                            if account == Constant.capitalAccountName || account == "資本金勘定" { // TODO: あってる？
                                try DataBaseManager.realm.write {
                                    dataBaseGeneralLedger.dataBaseCapitalAccount?.dataBaseOpeningJournalEntry = dataBaseJournalEntry
                                }
                            } else {
                                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                    try DataBaseManager.realm.write {
                                        // 開始仕訳データを代入
                                        dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseOpeningJournalEntry = dataBaseJournalEntry
                                    }
                                    break
                                }
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
                //        }
            } else {
                // 前年度の残高振替仕訳を取得（設定開始残高勘定の残高振替仕訳）
                if let dataBaseTransferEntry = DataBaseManagerAccount.shared.getSettingTransferEntryInAccountLastYear(
                    account: account
                ) {
                var account: String = "" // 開始仕訳の相手勘定
                if dataBaseTransferEntry.debit_category == "残高" {
                    account = dataBaseTransferEntry.credit_category
                } else if dataBaseTransferEntry.credit_category == "残高" {
                    account = dataBaseTransferEntry.debit_category
                }
                var number = 0 // 仕訳番号 自動採番にした
                let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
                // 期首
                let beginningOfYearDate = DateManager.shared.getBeginningOfYearDate()
                // オブジェクトを作成
                let dataBaseJournalEntry = DataBaseOpeningJournalEntry(
                    fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
                    date: beginningOfYearDate,
                    debit_category: dataBaseTransferEntry.credit_category, // 借方勘定　＊引数の貸方勘定を振替える
                    debit_amount: dataBaseTransferEntry.credit_amount, // 借方金額
                    credit_category: dataBaseTransferEntry.debit_category, // 貸方勘定　＊引数の借方勘定を振替える
                    credit_amount: dataBaseTransferEntry.debit_amount, // 貸方金額
                    smallWritting: "開始仕訳", // 小書き
                    balance_left: 0,
                    balance_right: 0
                )
                // 開始仕訳　が1件超が存在する場合は　削除
                let objects = checkOpeningJournalEntry(account: account)
            outerLoop: while objects.count > 1 {
                for i in 0..<objects.count {
                    let isInvalidated = deleteOpeningJournalEntry(primaryKey: objects[i].number)
                    print("削除", isInvalidated, objects.count, "開始仕訳　連番", objects.first?.number)
                    continue outerLoop
                }
                break
            }
                if let dataBaseOpeningJournalEntry = getOpeningJournalEntryInAccount(account: account) { // 勘定内に仕訳が存在するか
                    // 諸勘定の開始仕訳にリレーションがある場合
                    print(dataBaseOpeningJournalEntry)
                } else {
                    // 諸勘定の開始仕訳にリレーションがない場合　開始仕訳を全削除
                outerLoop: while objects.count >= 1 {
                    for i in 0..<objects.count {
                        let isInvalidated = deleteOpeningJournalEntry(primaryKey: objects[i].number)
                        print("関連削除", isInvalidated, objects.count)
                        continue outerLoop
                    }
                    break
                }
                }
                // 取得　開始仕訳 勘定別に取得
                if let dataBaseOpeningJournalEntry = DataBaseManagerAccount.shared.getOpeningJournalEntryInAccount(account: account) {
                    // 開始仕訳　が存在する場合は　更新
                    number = updateOpeningJournalEntry(
                        primaryKey: dataBaseOpeningJournalEntry.number,
                        date: dataBaseJournalEntry.date,
                        debitCategory: dataBaseJournalEntry.debit_category,
                        debitAmount: Int64(dataBaseJournalEntry.debit_amount), // カンマを削除してからデータベースに書き込む
                        creditCategory: dataBaseJournalEntry.credit_category,
                        creditAmount: Int64(dataBaseJournalEntry.credit_amount),// カンマを削除してからデータベースに書き込む
                        smallWritting: dataBaseJournalEntry.smallWritting
                    )
                } else {
                    // 開始仕訳　が存在しない場合は　作成
                    //            if amount != 0 {
                    number = dataBaseJournalEntry.save() // 仕訳番号　自動採番
                    print(number)
                    do {
                        // 相手方の勘定
                        if let dataBaseGeneralLedger = dataBaseAccountingBook.dataBaseGeneralLedger {
                            if account == Constant.capitalAccountName || account == "資本金勘定" {
                                try DataBaseManager.realm.write {
                                    dataBaseGeneralLedger.dataBaseCapitalAccount?.dataBaseOpeningJournalEntry = dataBaseJournalEntry
                                }
                            } else {
                                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                                    try DataBaseManager.realm.write {
                                        // 開始仕訳データを代入
                                        dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseOpeningJournalEntry = dataBaseJournalEntry
                                    }
                                    break
                                }
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
                //        }
                }
            }
        }
    }

    // MARK: Read
    // チェック 開始仕訳　存在するかを確認
    func checkOpeningJournalEntry(account: String) -> Results<DataBaseOpeningJournalEntry> {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseOpeningJournalEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "残高"), NSString(string: "残高"))
        ])
        return objects
    }
    // 取得 開始仕訳
    func getAllOpeningJournalEntryInAccountAll(account: String) -> Results<DataBaseOpeningJournalEntry> {
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseOpeningJournalEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "残高"), NSString(string: "残高"))
        ])
        return objects
    }

    // MARK: Update
    // 更新 開始仕訳
    func updateOpeningJournalEntry(primaryKey: Int, date: String, debitCategory: String, debitAmount: Int64, creditCategory: String, creditAmount: Int64, smallWritting: String) -> Int {
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
                DataBaseManager.realm.create(DataBaseOpeningJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }

    // MARK: Delete
    // 削除 開始仕訳
    func deleteOpeningJournalEntry(primaryKey: Int) -> Bool {
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseOpeningJournalEntry.self, key: primaryKey) else { return false }
        var account: String = "" // 開始仕訳の相手勘定
        if dataBaseJournalEntry.debit_category == "残高" {
            account = dataBaseJournalEntry.credit_category
        } else if dataBaseJournalEntry.credit_category == "残高" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: account,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else {
            return false // FIXME: 資本金勘定　ははじかれてる
        }
        // 勘定から削除前開始仕訳データの関連を削除
        do {
            try DataBaseManager.realm.write {
                oldLeftObject.dataBaseOpeningJournalEntry = nil
            }
        } catch {
            print("エラーが発生しました")
        }

        if !dataBaseJournalEntry.isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    // 開始仕訳データを削除
                    DataBaseManager.realm.delete(dataBaseJournalEntry)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }

}
