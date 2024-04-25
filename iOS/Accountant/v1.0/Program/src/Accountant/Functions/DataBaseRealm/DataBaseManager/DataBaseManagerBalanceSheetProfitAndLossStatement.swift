//
//  DataBaseManagerBalanceSheetProfitAndLossStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/10.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift
import WidgetKit

// ウィジェット　貸借対照表と損益計算書
class DataBaseManagerBalanceSheetProfitAndLossStatement {
    
    public static let shared = DataBaseManagerBalanceSheetProfitAndLossStatement()
    
    private init() {
    }
    
    // ウィジェット　貸借対照表と損益計算書の、五大区分の合計額と当期純利益の額を再計算する
    func setupAmountForBsAndPL() {
        // 貸借対照表
        // 0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)// 資産
        setTotalBig5(big5: 1)// 負債
        setTotalBig5(big5: 2)// 純資産
        
        // 損益計算書
        // データベースに書き込み　//4:収益 3:費用
        setTotalRank0(rank0: 6) // 営業収益9     売上
        setTotalRank0(rank0: 7) // 営業費用5     売上原価
        setTotalRank0(rank0: 8) // 営業費用5     販売費及び一般管理費
        // setTotalRank0(rank0: 9) // 営業外損益　TODO: なぜいままでなかった？
        // setTotalRank0(rank0: 10) // 特別損益　TODO: なぜいままでなかった？
        setTotalRank0(rank0: 11) // 税等8        法人税等 税金
        
        setTotalRank1(big5: 4, rank1: 15) // 営業外収益10 営業外損益    営業外収益
        setTotalRank1(big5: 3, rank1: 16) // 営業外費用6  営業外損益    営業外費用
        setTotalRank1(big5: 4, rank1: 17) // 特別利益11   特別損益    特別利益
        setTotalRank1(big5: 3, rank1: 18) // 特別損失7    特別損益    特別損失
        
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
        
        // ウィジェット 5大区分　合計額
        let userDefault = UserDefaults(suiteName: AppGroups.appGroupsId)
        
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
            // 費用
            var expense = profitAndLossStatement.CostOfGoodsSold // 商品売上原価 Cost of goods sold
            expense += profitAndLossStatement.SellingGeneralAndAdministrativeExpenses // 販売費及び一般管理費 Selling, general and administrative expenses
            expense += profitAndLossStatement.IncomeTaxes // 法人税等 ⇒ Income taxes
            expense += profitAndLossStatement.NonOperatingExpenses // 営業外費用 ⇒ Non-operating expenses
            expense += profitAndLossStatement.ExtraordinaryLosses // 特別損失 ⇒ Extraordinary losses
            userDefault?.set(expense, forKey: "expense" )
            print("ウィジェット　expense        ", expense)
            // 収益
            var income = profitAndLossStatement.NetSales // 売上高 Net sales
            income += profitAndLossStatement.NonOperatingIncome // 営業外収益 ⇒ Non-operating income
            income += profitAndLossStatement.ExtraordinaryIncome // 特別利益 ⇒ Extraordinary income
            userDefault?.set(income, forKey: "income" )
            print("ウィジェット　income         ", income)
        }
        
        let assets = userDefault?.double(forKey: UserDefaults.Keys.assets.rawValue) ?? 0
        let liabilities = userDefault?.double(forKey: UserDefaults.Keys.liabilities.rawValue) ?? 0
        let netAssets = userDefault?.double(forKey: UserDefaults.Keys.netAssets.rawValue) ?? 0
        let netIncomeOrLoss = userDefault?.double(forKey: UserDefaults.Keys.netIncomeOrLoss.rawValue) ?? 0
        let expense = userDefault?.double(forKey: UserDefaults.Keys.expense.rawValue) ?? 0
        let income = userDefault?.double(forKey: UserDefaults.Keys.income.rawValue) ?? 0
        print("ウィジェット　資産       　　　　　  　  　     ", assets)
        print("ウィジェット　負債・純資産 　　　　　　          ", liabilities + netAssets)
        print("ウィジェット　資産 == 負債・純資産  　　　　　　  ", assets == liabilities + netAssets)
        print("ウィジェット　費用・当期純利益    　  　　　　　  ", expense + (netIncomeOrLoss >= 0 ? netIncomeOrLoss : 0))
        print("ウィジェット　収益・当期純損失        　　　　　　", income + (netIncomeOrLoss >= 0 ? 0 : netIncomeOrLoss))
        print("ウィジェット　費用・当期純利益 == 収益・当期純損失 ", (expense + (netIncomeOrLoss >= 0 ? netIncomeOrLoss : 0) == income + (netIncomeOrLoss >= 0 ? 0 : netIncomeOrLoss)))
        
        let left = assets + expense + (netIncomeOrLoss >= 0 ? netIncomeOrLoss : 0)
        let right = liabilities + netAssets + income + (netIncomeOrLoss >= 0 ? 0 : netIncomeOrLoss)
        print("ウィジェット　借方         　     ", left)
        print("ウィジェット　貸方         　     ", right)
        print("ウィジェット　借方==貸方           ", left == right)
        
        if #available(iOS 14.0, *) {
            // アプリ側からWidgetを更新する
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: 計算　書き込み Widget
    
    // 計算　五大区分
    private func setTotalBig5(big5: Int) {
        var totalAmountOfBig5: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            let totalDebitOrCredit = getTotalDebitOrCreditForBig5(
                bigCategory: big5,
                account: dataBaseSettingsTaxonomyAccounts[i].category
            ) // 5大区分用の貸又借を使用する　2020/11/09
            if totalDebitOrCredit == "-" {
                totalAmountOfBig5 -= totalAmount
            } else {
                totalAmountOfBig5 += totalAmount
            }
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            // ウィジェット 5大区分　合計額
            let userDefault = UserDefaults(suiteName: AppGroups.appGroupsId)
            do {
                try DataBaseManager.realm.write {
                    switch big5 {
                    case 0: // 資産
                        balanceSheet.Asset_total = totalAmountOfBig5
                        userDefault?.set(totalAmountOfBig5, forKey: "assets" )
                        print("ウィジェット　assets         ", totalAmountOfBig5)
                    case 1: // 負債
                        balanceSheet.Liability_total = totalAmountOfBig5
                        userDefault?.set(totalAmountOfBig5, forKey: "liabilities" )
                        print("ウィジェット　liabilities    ", totalAmountOfBig5)
                    case 2: // 純資産
                        balanceSheet.Equity_total = totalAmountOfBig5
                        userDefault?.set(totalAmountOfBig5, forKey: "netAssets" )
                        print("ウィジェット　netAssets      ", totalAmountOfBig5)
                    default:
                        print("bigCategoryTotalAmount", totalAmountOfBig5)
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Local method　読み出し
    
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String) -> Int64 {
        var result: Int64 = 0
        // 法人/個人フラグ
        let capitalAccount = Constant.capitalAccountName
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBooks.dataBaseGeneralLedger {
            if capitalAccount == account {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting
                    } else {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                    } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting
                    } else {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                    }
                }
            }
        }
        return result
    }
    
    // 借又貸を取得 5大区分用
    private func getTotalDebitOrCreditForBig5(bigCategory: Int, account: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        // 法人/個人フラグ
        let capitalAccount = Constant.capitalAccountName
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if capitalAccount == account {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        debitOrCredit = "借"
                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        debitOrCredit = "借"
                    } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
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
        }
        return positiveOrNegative
    }
    
    // MARK: 計算　書き込み
    
    // 計算　階層0 大区分
    private func setTotalRank0(rank0: Int) {
        var totalAmountOfRank0: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(bigCategory: rank0, midCategory: Int(dataBaseSettingsTaxonomyAccounts[i].Rank1) ?? 999, account: dataBaseSettingsTaxonomyAccounts[i].category)
            if totalDebitOrCredit == "-"{
                totalAmountOfRank0 -= totalAmount
            } else {
                totalAmountOfRank0 += totalAmount
            }
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
            do {
                try DataBaseManager.realm.write {
                    switch rank0 {
                    case 6: // 営業収益9     売上
                        profitAndLossStatement.NetSales = totalAmountOfRank0
                    case 7: // 営業費用5     売上原価
                        profitAndLossStatement.CostOfGoodsSold = totalAmountOfRank0
                    case 8: // 営業費用5     販売費及び一般管理費
                        profitAndLossStatement.SellingGeneralAndAdministrativeExpenses = totalAmountOfRank0
                    case 11: // 税等8 法人税等 税金
                        profitAndLossStatement.IncomeTaxes = totalAmountOfRank0
                    default:
                        print()
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 計算　階層1 中区分
    private func setTotalRank1(big5: Int, rank1: Int) {
        var totalAmountOfRank1: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInRank1(rank1: rank1)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            if let rank0 = dataBaseSettingsTaxonomyAccounts[i].Rank0 as? String {
                let totalDebitOrCredit = getTotalDebitOrCredit(
                    bigCategory: Int(rank0) ?? 0,
                    midCategory: rank1,
                    account: dataBaseSettingsTaxonomyAccounts[i].category
                )
                if totalDebitOrCredit == "-" {
                    totalAmountOfRank1 -= totalAmount
                } else {
                    totalAmountOfRank1 += totalAmount
                }
            }
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
            do {
                try DataBaseManager.realm.write {
                    switch rank1 {
                    case 15: // 営業外収益10  営業外損益    営業外収益
                        profitAndLossStatement.NonOperatingIncome = totalAmountOfRank1
                    case 16: // 営業外費用6  営業外損益    営業外費用
                        profitAndLossStatement.NonOperatingExpenses = totalAmountOfRank1
                    case 17: // 特別利益11   特別損益    特別利益
                        profitAndLossStatement.ExtraordinaryIncome = totalAmountOfRank1
                    case 18: // 特別損失7    特別損益    特別損失
                        profitAndLossStatement.ExtraordinaryLosses = totalAmountOfRank1
                    default:
                        print()
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 利益　計算
    private func setBenefitTotal() {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 利益5種類　売上総利益、営業利益、経常利益、税金等調整前当期純利益、当期純利益
        for i in 0..<5 {
            if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
                // ウィジェット 5大区分　合計額
                let userDefault = UserDefaults(suiteName: AppGroups.appGroupsId)
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
                            userDefault?.set(profitAndLossStatement.IncomeOrLossBeforeIncomeTaxes - profitAndLossStatement.IncomeTaxes, forKey: "netIncomeOrLoss" )
                            print("ウィジェット　netIncomeOrLoss", profitAndLossStatement.IncomeOrLossBeforeIncomeTaxes - profitAndLossStatement.IncomeTaxes)
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
    // 借又貸を取得
    private func getTotalDebitOrCredit(bigCategory: Int, midCategory: Int, account: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBooks.dataBaseGeneralLedger {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    debitOrCredit = "借"
                } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    debitOrCredit = "貸"
                } else {
                    debitOrCredit = "-"
                }
            }
            
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
    
}
extension UserDefaults {
    enum Keys: String {
        case assets
        case liabilities
        case netAssets
        
        case expense
        case income
        
        case netIncomeOrLoss
        
        case isThousand
    }
}
