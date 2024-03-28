//
//  DataBaseManagerMonthlyBSnPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/03/18.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 月次貸借対照表、月次損益計算書
class DataBaseManagerMonthlyBSnPL {
    
    public static let shared = DataBaseManagerMonthlyBSnPL()
    
    private init() {
    }
    
    // MARK: - 月次貸借対照表

    // MARK: - CRUD

    // MARK: Create
    
    // 月次貸借対照表と月次損益計算書の、五大区分の合計額と、大区分の合計額と当期純利益の額を再計算する
    func setupAmountForBsAndPL() {
        // 削除　月次貸借対照表 今年度の月次貸借対照表のうち、日付が会計期間の範囲外の場合、削除する
        DataBaseManagerMonthlyBSnPL.shared.deleteMonthlyyBalanceSheetInFiscalYear()
        // 削除　月次貸借対照表 今年度の月次貸借対照表のうち、日付（年月）が重複している場合、削除する
        DataBaseManagerMonthlyBSnPL.shared.deleteDuplicatedMonthlyyBalanceSheetInFiscalYear()
        
        // 月別の月末日を取得 12ヶ月分
        let dates = DateManager.shared.getTheDayOfEndingOfMonth()
        for date in dates {
            let yearMonth = "\(date.year)" + "/" + "\(String(format: "%02d", date.month))"
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(yearMonth: yearMonth) {
                // 月次貸借対照表　があるとき
                
            } else {
                // 月次貸借対照表　がないとき
                // 追加　月次貸借対照表
                addMonthlyBalanceSheet(
                    date: "\(date.year)" + "/" + "\(String(format: "%02d", date.month))" + "/" + "\(String(format: "%02d", date.day))",
                    CurrentAssets_total: 0,
                    FixedAssets_total: 0,
                    DeferredAssets_total: 0,
                    Asset_total: 0,
                    CurrentLiabilities_total: 0,
                    FixedLiabilities_total: 0,
                    Liability_total: 0,
                    CapitalStock_total: 0,
                    OtherCapitalSurpluses_total: 0,
                    Capital_total: 0,
                    Equity_total: 0
                )
            }
            // 貸借対照表
            setTotalRank0(rank0: 0, yearMonth: yearMonth) // 流動資産
            setTotalRank0(rank0: 1, yearMonth: yearMonth) // 固定資産
            setTotalRank0(rank0: 2, yearMonth: yearMonth) // 繰延資産
            setTotalRank0(rank0: 3, yearMonth: yearMonth) // 流動負債
            setTotalRank0(rank0: 4, yearMonth: yearMonth) // 固定負債
            setTotalRank0(rank0: 5, yearMonth: yearMonth) // 資本　TODO: なぜいままでなかった？
            
            // 0:資産 1:負債 2:純資産 4:収益 3:費用
            setTotalBig5(big5: 0, yearMonth: yearMonth) // 資産
            setTotalBig5(big5: 1, yearMonth: yearMonth) // 負債
            setTotalBig5(big5: 2, yearMonth: yearMonth) // 純資産
    //        // setTotalBig5(big5: 3)// 費用　TODO: なぜいままでなかった？
    //        // setTotalBig5(big5: 4)// 収益　TODO: なぜいままでなかった？
        }

//        setTotalRank1(big5: 2, rank1: 10) // 株主資本
//        setTotalRank1(big5: 2, rank1: 11) // その他の包括利益累計額
        
//        // 損益計算書
//        setTotalRank0(rank0: 6, yearMonth: yearMonth) // 営業収益9     売上
//        setTotalRank0(rank0: 7, yearMonth: yearMonth) // 営業費用5     売上原価
//        setTotalRank0(rank0: 8, yearMonth: yearMonth) // 営業費用5     販売費及び一般管理費
//        // setTotalRank0(rank0: 9) // 営業外損益　TODO: なぜいままでなかった？
//        // setTotalRank0(rank0: 10) // 特別損益　TODO: なぜいままでなかった？
//        setTotalRank0(rank0: 11, yearMonth: yearMonth) // 税等8        法人税等 税金
//
//        setTotalRank1(big5: 4, rank1: 15) // 営業外収益10 営業外損益
//        setTotalRank1(big5: 3, rank1: 16) // 営業外費用6  営業外損益
//        setTotalRank1(big5: 4, rank1: 17) // 特別利益11   特別損益
//        setTotalRank1(big5: 3, rank1: 18) // 特別損失7    特別損益
//
//        // 利益を計算する関数を呼び出す todo
//        setBenefitTotal()
    }

    // 追加　月次貸借対照表
    func addMonthlyBalanceSheet(
        date: String,
        CurrentAssets_total: Int64,
        FixedAssets_total: Int64,
        DeferredAssets_total: Int64,
        Asset_total: Int64,
        CurrentLiabilities_total: Int64,
        FixedLiabilities_total: Int64,
        Liability_total: Int64,
        CapitalStock_total: Int64,
        OtherCapitalSurpluses_total: Int64,
        Capital_total: Int64,
        Equity_total: Int64
    ) {
        var number = 0 // 自動採番
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // オブジェクトを作成
        let dataBaseMonthlyBalanceSheet = DataBaseMonthlyBalanceSheet(
            fiscalYear: dataBaseAccountingBook.fiscalYear, // 年度
            date: date,
            CurrentAssets_total: CurrentAssets_total,
            FixedAssets_total: FixedAssets_total,
            DeferredAssets_total: DeferredAssets_total,
            Asset_total: Asset_total,
            CurrentLiabilities_total: CurrentLiabilities_total,
            FixedLiabilities_total: FixedLiabilities_total,
            Liability_total: Liability_total,
            CapitalStock_total: CapitalStock_total,
            OtherCapitalSurpluses_total: OtherCapitalSurpluses_total,
            Capital_total: Capital_total,
            Equity_total: Equity_total
        )
        // 取得　月次損益振替仕訳、月次残高振替仕訳 勘定別に取得　今年度の勘定別で日付が同一
        if let monthlyBalanceSheet = getMonthlyBalanceSheet(date: date) {
            // 月次貸借対照表　が存在する場合は　更新
            number = updateBalanceSheet(
                primaryKey: monthlyBalanceSheet.number,
                date: dataBaseMonthlyBalanceSheet.date,
                CurrentAssets_total: dataBaseMonthlyBalanceSheet.CurrentAssets_total,
                FixedAssets_total: dataBaseMonthlyBalanceSheet.FixedAssets_total,
                DeferredAssets_total: dataBaseMonthlyBalanceSheet.DeferredAssets_total,
                Asset_total: dataBaseMonthlyBalanceSheet.Asset_total,
                CurrentLiabilities_total: dataBaseMonthlyBalanceSheet.CurrentLiabilities_total,
                FixedLiabilities_total: dataBaseMonthlyBalanceSheet.FixedLiabilities_total,
                Liability_total: dataBaseMonthlyBalanceSheet.Liability_total,
                CapitalStock_total: dataBaseMonthlyBalanceSheet.CapitalStock_total,
                OtherCapitalSurpluses_total: dataBaseMonthlyBalanceSheet.OtherCapitalSurpluses_total,
                Capital_total: dataBaseMonthlyBalanceSheet.Capital_total,
                Equity_total: dataBaseMonthlyBalanceSheet.Equity_total
            )
        } else {
            number = dataBaseMonthlyBalanceSheet.save() // 自動採番
            print(number)
            do {
                try DataBaseManager.realm.write {
                    
                    DataBaseManager.realm.add(dataBaseMonthlyBalanceSheet)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Read
    // 取得　月次貸借対照表 今年度のすべて取得
    func getMonthlyBalanceSheetInFiscalYear() -> Results<DataBaseMonthlyBalanceSheet>? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyBalanceSheets = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyBalanceSheet.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0))
            ]
        )
        print("月次損益振替仕訳、月次残高振替仕訳 12ヶ月分　今年度の勘定別にすべて取得", dataBaseMonthlyBalanceSheets)
        return dataBaseMonthlyBalanceSheets
    }
    // 取得　月次貸借対照表 今年度の勘定別で日付が同一
    func getMonthlyBalanceSheet(date: String) -> DataBaseMonthlyBalanceSheet? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyBalanceSheets = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyBalanceSheet.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0)),
                NSPredicate(format: "date LIKE %@", NSString(string: date))
            ]
        )
        print("月次損益振替仕訳、月次残高振替仕訳 \(date)　今年度の勘定別で日付が同一", dataBaseMonthlyBalanceSheets)
        return dataBaseMonthlyBalanceSheets.first
    }
    // 取得 月次貸借対照表　今年度で日付の前方一致
    func getMonthlyBalanceSheet(yearMonth: String) -> DataBaseMonthlyBalanceSheet? {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyBalanceSheets = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyBalanceSheet.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0)),
                // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                NSPredicate(format: "date BEGINSWITH %@", NSString(string: yearMonth))
            ]
        )
        print("月次貸借対照表 \(yearMonth)　今年度 複数", dataBaseMonthlyBalanceSheets)
        return dataBaseMonthlyBalanceSheets.first
    }
    // 取得 月次貸借対照表　今年度 複数
    func getMonthlyBalanceSheets(yearMonth: String) -> Results<DataBaseMonthlyBalanceSheet>? {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseMonthlyBalanceSheets = RealmManager.shared.readWithPredicate(
            type: DataBaseMonthlyBalanceSheet.self,
            predicates: [
                NSPredicate(format: "fiscalYear == %@", NSNumber(value: dataBaseAccountingBook?.fiscalYear ?? 0)),
                // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                NSPredicate(format: "date BEGINSWITH %@", NSString(string: yearMonth))
            ]
        )
        print("月次貸借対照表 \(yearMonth)　今年度 複数", dataBaseMonthlyBalanceSheets)
        return dataBaseMonthlyBalanceSheets
    }
    
    // MARK: Update
    
    // 更新 月次貸借対照表
    func updateBalanceSheet(
        primaryKey: Int,
        date: String,
        CurrentAssets_total: Int64,
        FixedAssets_total: Int64,
        DeferredAssets_total: Int64,
        Asset_total: Int64,
        CurrentLiabilities_total: Int64,
        FixedLiabilities_total: Int64,
        Liability_total: Int64,
        CapitalStock_total: Int64,
        OtherCapitalSurpluses_total: Int64,
        Capital_total: Int64,
        Equity_total: Int64
    ) -> Int {
        // 編集前の借方勘定と貸方勘定をメモする
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "date": date,
                    "CurrentAssets_total": CurrentAssets_total,
                    "FixedAssets_total": FixedAssets_total,
                    "DeferredAssets_total": DeferredAssets_total,
                    "Asset_total": Asset_total,
                    "CurrentLiabilities_total": CurrentLiabilities_total,
                    "FixedLiabilities_total": FixedLiabilities_total,
                    "Liability_total": Liability_total,
                    "CapitalStock_total": CapitalStock_total,
                    "OtherCapitalSurpluses_total": OtherCapitalSurpluses_total,
                    "Capital_total": Capital_total,
                    "Equity_total": Equity_total
                ]
                DataBaseManager.realm.create(DataBaseMonthlyBalanceSheet.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        return primaryKey
    }
    
    // MARK: Delete
    // 削除　月次貸借対照表 今年度の月次貸借対照表のうち、日付が会計期間の範囲外の場合、削除する
    func deleteMonthlyyBalanceSheetInFiscalYear() {
        // 今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別にすべて取得
        if let dataBaseMonthlyBalanceSheets = getMonthlyBalanceSheetInFiscalYear() {
            print(dataBaseMonthlyBalanceSheets)
            for dataBaseMonthlyBalanceSheet in dataBaseMonthlyBalanceSheets {
                // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                if DateManager.shared.isInPeriod(date: dataBaseMonthlyBalanceSheet.date) {
                    // 範囲内
                } else {
                    // 範囲外
                    do {
                        try DataBaseManager.realm.write {
                            DataBaseManager.realm.delete(dataBaseMonthlyBalanceSheet)
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    // 削除　月次貸借対照表 今年度の月次貸借対照表のうち、日付（年月）が重複している場合、削除する
    func deleteDuplicatedMonthlyyBalanceSheetInFiscalYear() {
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for index in 0..<lastDays.count {
            // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致 複数
            if let dataBaseMonthlyBalanceSheets = getMonthlyBalanceSheets(
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
            ) {
                while dataBaseMonthlyBalanceSheets.count > 1 {
                    if let dataBaseMonthlyBalanceSheet = dataBaseMonthlyBalanceSheets.first {
                        do {
                            try DataBaseManager.realm.write {
                                DataBaseManager.realm.delete(dataBaseMonthlyBalanceSheet)
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Local method　読み出し
    
    // 合計残高　月別、勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String, yearMonth: String) -> Int64 {
        var result: Int64 = 0
        
        var capitalAccount = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            capitalAccount = CapitalAccountType.retainedEarnings.rawValue
        } else {
            capitalAccount = CapitalAccountType.capital.rawValue
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBooks.dataBaseGeneralLedger {
//            if capitalAccount == account {
//                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
//                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
//                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
//                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
//                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
//                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting
//                    } else {
//                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
//                    }
//                }
//            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    // 月次損益振替仕訳、月次残高振替仕訳
                    if let dataBaseMonthlyBalanceSheet = dataBaseGeneralLedger.dataBaseAccounts[i].dataBaseMonthlyTransferEntries
                    // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                        .filter("date BEGINSWITH '\(yearMonth)'").first {
                        // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                        if dataBaseMonthlyBalanceSheet.balance_left > dataBaseMonthlyBalanceSheet.balance_right {
                            result = dataBaseMonthlyBalanceSheet.balance_left
                        } else if dataBaseMonthlyBalanceSheet.balance_left < dataBaseMonthlyBalanceSheet.balance_right {
                            result = dataBaseMonthlyBalanceSheet.balance_right
                        } else {
                            result = dataBaseMonthlyBalanceSheet.balance_left
                        }
                    }
                }
//            }
        }
        return result
    }
    // 借又貸を取得
    private func getTotalDebitOrCredit(bigCategory: Int, midCategory: Int, account: String, yearMonth: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        var capitalAccount = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            capitalAccount = CapitalAccountType.retainedEarnings.rawValue
        } else {
            capitalAccount = CapitalAccountType.capital.rawValue
        }
        
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
//            if capitalAccount == account {
//                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
//                    // 借方と貸方で金額が大きい方はどちらか
//                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
//                        debitOrCredit = "借"
//                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
//                        debitOrCredit = "貸"
//                    } else {
//                        debitOrCredit = "-"
//                    }
//                }
//            } else {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                // 月次損益振替仕訳、月次残高振替仕訳
                if let dataBaseMonthlyBalanceSheet = dataBaseGeneralLedger.dataBaseAccounts[i].dataBaseMonthlyTransferEntries
                    // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                    .filter("date BEGINSWITH '\(yearMonth)'").first {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if dataBaseMonthlyBalanceSheet.balance_left > dataBaseMonthlyBalanceSheet.balance_right {
                        debitOrCredit = "借"
                    } else if dataBaseMonthlyBalanceSheet.balance_left < dataBaseMonthlyBalanceSheet.balance_right {
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            }
//            }
            switch bigCategory {
            case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            case 9, 10: // 営業外損益 特別損益
                if midCategory == 15 || midCategory == 17 {
                    switch debitOrCredit {
                    case "借":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                } else if midCategory == 16 || midCategory == 18 {
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
        return positiveOrNegative
    }
    
    // 借又貸を取得 5大区分用  月次
    private func getTotalDebitOrCreditForBig5(bigCategory: Int, account: String, yearMonth: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        var capitalAccount = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            capitalAccount = CapitalAccountType.retainedEarnings.rawValue
        } else {
            capitalAccount = CapitalAccountType.capital.rawValue
        }
        
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            //            if capitalAccount == account {
            //                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
            //                    // 借方と貸方で金額が大きい方はどちらか
            //                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
            //                        debitOrCredit = "借"
            //                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
            //                        debitOrCredit = "貸"
            //                    } else {
            //                        debitOrCredit = "-"
            //                    }
            //                }
            //            } else {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                // 月次損益振替仕訳、月次残高振替仕訳
                if let dataBaseMonthlyBalanceSheet = dataBaseGeneralLedger.dataBaseAccounts[i].dataBaseMonthlyTransferEntries
                    // BEGINSWITH 先頭が指定した文字で始まるデータを検索
                    .filter("date BEGINSWITH '\(yearMonth)'").first {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if dataBaseMonthlyBalanceSheet.balance_left > dataBaseMonthlyBalanceSheet.balance_right {
                        debitOrCredit = "借"
                    } else if dataBaseMonthlyBalanceSheet.balance_left < dataBaseMonthlyBalanceSheet.balance_right {
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            }
        }
        switch bigCategory {
        case 0, 3: // 資産　費用
            switch debitOrCredit {
            case "貸":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        default: // 1,2,4（負債、純資産、収益）
            switch debitOrCredit {
            case "借":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        }
        //        }
        return positiveOrNegative
    }
        
    // MARK: 計算　書き込み
    
    // 計算　五大区分 月次
    private func setTotalBig5(big5: Int, yearMonth: String) {
        // 累計額
        var totalAmountOfBig5: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category, yearMonth: yearMonth)
            let totalDebitOrCredit = getTotalDebitOrCreditForBig5(
                bigCategory: big5,
                account: dataBaseSettingsTaxonomyAccounts[i].category,
                yearMonth: yearMonth
            ) // 5大区分用の貸又借を使用する　2020/11/09
            if totalDebitOrCredit == "-" {
                totalAmountOfBig5 -= totalAmount
            } else {
                totalAmountOfBig5 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 取得 月次貸借対照表　今年度で日付の前方一致
        if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(yearMonth: yearMonth) {
            do {
                try DataBaseManager.realm.write {
                    switch big5 {
                    case 0: // 資産
                        dataBaseMonthlyBalanceSheet.Asset_total = totalAmountOfBig5
                    case 1: // 負債
                        dataBaseMonthlyBalanceSheet.Liability_total = totalAmountOfBig5
                    case 2: // 純資産
                        dataBaseMonthlyBalanceSheet.Equity_total = totalAmountOfBig5
                    default:
                        print("bigCategoryTotalAmount", totalAmountOfBig5)
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 計算　階層0 大区分
    private func setTotalRank0(rank0: Int, yearMonth: String) {
        // 累計額
        var totalAmountOfRank0: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(
                account: dataBaseSettingsTaxonomyAccounts[i].category,
                yearMonth: yearMonth
            )
            let totalDebitOrCredit = getTotalDebitOrCredit(
                bigCategory: rank0,
                midCategory: Int(dataBaseSettingsTaxonomyAccounts[i].Rank1) ?? 999,
                account: dataBaseSettingsTaxonomyAccounts[i].category,
                yearMonth: yearMonth
            )
            if totalDebitOrCredit == "-" {
                totalAmountOfRank0 -= totalAmount
            } else {
                totalAmountOfRank0 += totalAmount
            }
        }
//        // 開いている会計帳簿の年度を取得
//        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 取得 月次貸借対照表　今年度で日付の前方一致
        if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(yearMonth: yearMonth) {
            do {
                // (2)書き込みトランザクション内でデータを追加する
                try DataBaseManager.realm.write {
                    switch rank0 {
                    case 0: // 流動資産
                        dataBaseMonthlyBalanceSheet.CurrentAssets_total = totalAmountOfRank0
                    case 1: // 固定資産
                        dataBaseMonthlyBalanceSheet.FixedAssets_total = totalAmountOfRank0
                    case 2: // 繰延資産
                        dataBaseMonthlyBalanceSheet.DeferredAssets_total = totalAmountOfRank0
                    case 3: // 流動負債
                        dataBaseMonthlyBalanceSheet.CurrentLiabilities_total = totalAmountOfRank0
                    case 4: // 固定負債
                        dataBaseMonthlyBalanceSheet.FixedLiabilities_total = totalAmountOfRank0
                    case 5: // 資本
                        dataBaseMonthlyBalanceSheet.Capital_total = totalAmountOfRank0
                    default:
                        print(totalAmountOfRank0)
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
//        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
//            do {
//                try DataBaseManager.realm.write {
//                    switch rank0 {
//                    case 6: // 営業収益9     売上
//                        profitAndLossStatement.NetSales = totalAmountOfRank0
//                    case 7: // 営業費用5     売上原価
//                        profitAndLossStatement.CostOfGoodsSold = totalAmountOfRank0
//                    case 8: // 営業費用5     販売費及び一般管理費
//                        profitAndLossStatement.SellingGeneralAndAdministrativeExpenses = totalAmountOfRank0
//                        // case 9:
//                        // 営業外損益　TODO: なぜいままでなかった？
//                        // case 10:
//                        // 特別損益　TODO: なぜいままでなかった？
//                    case 11: // 税等8 法人税等 税金
//                        profitAndLossStatement.IncomeTaxes = totalAmountOfRank0
//                    default:
//                        print()
//                    }
//                }
//            } catch {
//                print("エラーが発生しました")
//            }
//        }
    }
//    // 計算　階層1 中区分
//    private func setTotalRank1(big5: Int, rank1: Int) {
//        var totalAmountOfRank1: Int64 = 0
//        // 設定画面の勘定科目一覧にある勘定を取得する
//        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInRank1(rank1: rank1)
//        // オブジェクトを作成 勘定
//        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
//            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
//            if let rank0 = Int(dataBaseSettingsTaxonomyAccounts[i].Rank0) {
//                let totalDebitOrCredit = getTotalDebitOrCredit(
//                    bigCategory: rank0,
//                    midCategory: rank1,
//                    account: dataBaseSettingsTaxonomyAccounts[i].category
//                )
//                if totalDebitOrCredit == "-" {
//                    totalAmountOfRank1 -= totalAmount
//                } else {
//                    totalAmountOfRank1 += totalAmount
//                }
//            }
//        }
//        // 開いている会計帳簿の年度を取得
//        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
//        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
//            do {
//                try DataBaseManager.realm.write {
//                    switch rank1 {
//                    case 10: // 株主資本
//                        balanceSheet.CapitalStock_total = totalAmountOfRank1
//                    case 11: // 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
//                        balanceSheet.OtherCapitalSurpluses_total = totalAmountOfRank1
//                        //　case 12: //新株予約権
//                        //　case 19: //非支配株主持分
//                    default:
//                        print()
//                    }
//                }
//            } catch {
//                print("エラーが発生しました")
//            }
//        }
//        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
//            do {
//                try DataBaseManager.realm.write {
//                    switch rank1 {
//                    case 15: // 営業外収益10  営業外損益
//                        profitAndLossStatement.NonOperatingIncome = totalAmountOfRank1
//                    case 16: // 営業外費用6  営業外損益
//                        profitAndLossStatement.NonOperatingExpenses = totalAmountOfRank1
//                    case 17: // 特別利益11   特別損益
//                        profitAndLossStatement.ExtraordinaryIncome = totalAmountOfRank1
//                    case 18: // 特別損失7    特別損益
//                        profitAndLossStatement.ExtraordinaryLosses = totalAmountOfRank1
//                    default:
//                        print()
//                    }
//                }
//            } catch {
//                print("エラーが発生しました")
//            }
//        }
//    }
    
    // MARK: 計算　書き込み
    
    // 利益　計算
    private func setBenefitTotal() {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 利益5種類　売上総利益、営業利益、経常利益、税金等調整前当期純利益、当期純利益
        for i in 0..<5 {
            if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
                do {
                    try DataBaseManager.realm.write {
                        switch i {
                        case 0: // 売上総利益
                            profitAndLossStatement.GrossProfitOrLoss = profitAndLossStatement.NetSales - profitAndLossStatement.CostOfGoodsSold
                        case 1: // 営業利益
                            profitAndLossStatement.OtherCapitalSurpluses_total = profitAndLossStatement.GrossProfitOrLoss - profitAndLossStatement.SellingGeneralAndAdministrativeExpenses
                        case 2: // 経常利益
                            profitAndLossStatement.OrdinaryIncomeOrLoss = profitAndLossStatement.OtherCapitalSurpluses_total + profitAndLossStatement.NonOperatingIncome - profitAndLossStatement.NonOperatingExpenses
                        case 3: // 税引前当期純利益（損失）
                            profitAndLossStatement.IncomeOrLossBeforeIncomeTaxes = profitAndLossStatement.OrdinaryIncomeOrLoss + profitAndLossStatement.ExtraordinaryIncome - profitAndLossStatement.ExtraordinaryLosses
                        case 4: // 当期純利益（損失）
                            profitAndLossStatement.NetIncomeOrLoss = profitAndLossStatement.IncomeOrLossBeforeIncomeTaxes - profitAndLossStatement.IncomeTaxes
                        default:
                            print()
                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
}

// データベース

// 五大区分
// 0 資産
// 1 負債
// 2 純資産
// 3 負債純資産
// 費用
// 収益

// 大区分
// 0 "流動資産"
// 1 "固定資産"
// 2 "繰延資産"
// 3 "流動負債"
// 4 "固定負債"
// 5 "資本"
// 6 "売上"
// 7 "売上原価"
// 8 "販売費及び一般管理費"
// 9 "営業外損益"
// 10 "特別損益"
// 11 "税金"

// 小区分
// "流動資産"
// 0 "当座資産"
// 1 "棚卸資産"
// 2 "その他の流動資産"
// "固定資産"
// 3 "有形固定資産"
// 4 "無形固定資産"
// 5 "投資その他の資産"
// "繰延資産"
// 6 "繰延資産"
// "流動負債"
// 7 "仕入債務"
// 8 "その他の流動負債"
// "固定負債"
// 9 "長期債務"
// "資本"
// 10 株主資本
// 11 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
// 12 新株予約権
// 19 非支配株主持分
// "売上"

// "売上原価"
// 13 "売上原価"
// 14 "製造原価"
// "販売費及び一般管理費"
// "営業外損益"
// 15 営業外収益10
// 16 営業外費用6
// "特別損益"
// 17 特別利益11
// 18 特別損失7
// "税金"
