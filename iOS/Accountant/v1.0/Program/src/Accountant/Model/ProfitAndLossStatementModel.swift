//
//  ProfitAndLossStatementModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/11.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol ProfitAndLossStatementModelInput {
    func initializeBenefits() -> ProfitAndLossStatementData
    func initializePDFMaker(profitAndLossStatementData: ProfitAndLossStatementData, completion: ([URL]?) -> Void)
    
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount>
}
// 損益計算書クラス
class ProfitAndLossStatementModel: ProfitAndLossStatementModelInput {
    // 印刷機能
    let pDFMaker = PDFMakerProfitAndLossStatement()
    // 初期化 PDFメーカー
    func initializePDFMaker(profitAndLossStatementData: ProfitAndLossStatementData, completion: ([URL]?) -> Void) {
        pDFMaker.initialize(profitAndLossStatementData: profitAndLossStatementData, completion: { PDFpath in
            completion(PDFpath)
        })
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: rank0, rank1: rank1)
    }
    
    // MARK: 読み出し
    
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        var result: Int64 = 0
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            } else {
                return "-"
            }
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
            switch rank0 {
            case 6: // 営業収益9     売上
                result = profitAndLossStatement.NetSales
            case 7: // 営業費用5     売上原価
                result = profitAndLossStatement.CostOfGoodsSold
            case 8: // 営業費用5     販売費及び一般管理費
                result = profitAndLossStatement.SellingGeneralAndAdministrativeExpenses
            case 11: // 税等8 法人税等 税金
                result = profitAndLossStatement.IncomeTaxes
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        var result: Int64 = 0
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            } else {
                return "-"
            }
        }
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement {
            switch rank1 {
            case 15: // 営業外収益10  営業外損益    営業外収益
                result = objectss.NonOperatingIncome
            case 16: // 営業外費用6  営業外損益    営業外費用
                result = objectss.NonOperatingExpenses
            case 17: // 特別利益11   特別損益    特別利益
                result = objectss.ExtraordinaryIncome
            case 18: // 特別損失7    特別損益    特別損失
                result = objectss.ExtraordinaryLosses
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 利益　取得　前年度表示対応
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String {
        var result: Int64 = 0
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            } else {
                return "-"
            }
        }
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let profitAndLossStatement = dataBaseAccountingBooks.dataBaseFinancialStatements?.profitAndLossStatement {
            switch benefit {
            case 0: // 売上総利益
                result = profitAndLossStatement.GrossProfitOrLoss
            case 1: // 営業利益
                result = profitAndLossStatement.OtherCapitalSurpluses_total
            case 2: // 経常利益
                result = profitAndLossStatement.OrdinaryIncomeOrLoss
            case 3: // 税引前当期純利益（損失）
                result = profitAndLossStatement.IncomeOrLossBeforeIncomeTaxes
            case 4: // 当期純利益（損失）
                result = profitAndLossStatement.NetIncomeOrLoss
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    
    // MARK: Local method　読み出し
    
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String) -> Int64 {
        var result: Int64 = 0
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = dataBaseAccountingBooks.dataBaseGeneralLedger {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                // 決算整理後の値を利用する
                if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting
                } else {
                    result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }
            }
        }
        return result
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
    
    // MARK: Update
    
    // 初期化　中区分、大区分　ごとに計算
    func initializeBenefits() -> ProfitAndLossStatementData {
        // データベースに書き込み　//4:収益 3:費用
        setTotalRank0(big5: 4, rank0: 6) // 営業収益9     売上
        setTotalRank0(big5: 3, rank0: 7) // 営業費用5     売上原価
        setTotalRank0(big5: 3, rank0: 8) // 営業費用5     販売費及び一般管理費
        setTotalRank0(big5: 3, rank0: 11) // 税等8        法人税等 税金
        
        setTotalRank1(big5: 4, rank1: 15) // 営業外収益10 営業外損益    営業外収益
        setTotalRank1(big5: 3, rank1: 16) // 営業外費用6  営業外損益    営業外費用
        setTotalRank1(big5: 4, rank1: 17) // 特別利益11   特別損益    特別利益
        setTotalRank1(big5: 3, rank1: 18) // 特別損失7    特別損益    特別損失
        
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
        
        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 大区分ごとに設定勘定科目を取得する
        let objects0 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 6, rank1: nil)
        
        let objects1 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 13)
        let objects2 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 14)
        
        let objects3 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 8, rank1: nil)
        
        let objects4 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 15)
        let objects5 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 16)
        
        let objects6 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 17)
        let objects7 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 18)
        
        let objects8 = getDataBaseSettingsTaxonomyAccountInRank(rank0: 11, rank1: nil)
        
        // MARK: - 営業収益9     売上
        let netSales = self.getTotalRank0(big5: 4, rank0: 6, lastYear: false)
        let lastNetSales = self.getTotalRank0(big5: 4, rank0: 6, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業費用5     売上原価
        let costOfGoodsSold = self.getTotalRank0(big5: 3, rank0: 7, lastYear: false)
        let lastCostOfGoodsSold = self.getTotalRank0(big5: 3, rank0: 7, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業費用5     販売費及び一般管理費
        let sellingGeneralAndAdministrativeExpenses = self.getTotalRank0(big5: 3, rank0: 8, lastYear: false)
        let lastSellingGeneralAndAdministrativeExpenses = self.getTotalRank0(big5: 3, rank0: 8, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 税等8 法人税等 税金
        let incomeTaxes = self.getTotalRank0(big5: 3, rank0: 11, lastYear: false)
        let lastIncomeTaxes = self.getTotalRank0(big5: 3, rank0: 11, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - 営業外収益10  営業外損益    営業外収益
        let nonOperatingIncome = self.getTotalRank1(big5: 4, rank1: 15, lastYear: false)
        let lastNonOperatingIncome = self.getTotalRank1(big5: 4, rank1: 15, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業外費用6  営業外損益    営業外費用
        let nonOperatingExpenses = self.getTotalRank1(big5: 3, rank1: 16, lastYear: false)
        let lastNonOperatingExpenses = self.getTotalRank1(big5: 3, rank1: 16, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 特別利益11   特別損益    特別利益
        let extraordinaryIncome = self.getTotalRank1(big5: 4, rank1: 17, lastYear: false)
        let lastExtraordinaryIncome = self.getTotalRank1(big5: 4, rank1: 17, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 特別損失7    特別損益    特別損失
        let extraordinaryLosses = self.getTotalRank1(big5: 3, rank1: 18, lastYear: false)
        let lastExtraordinaryLosses = self.getTotalRank1(big5: 3, rank1: 18, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - 売上総利益
        let grossProfitOrLoss = self.getBenefitTotal(benefit: 0, lastYear: false)
        let lastGrossProfitOrLoss = self.getBenefitTotal(benefit: 0, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業利益
        let otherCapitalSurplusesTotal = self.getBenefitTotal(benefit: 1, lastYear: false)
        let lastOtherCapitalSurplusesTotal = self.getBenefitTotal(benefit: 1, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 経常利益
        let ordinaryIncomeOrLoss = self.getBenefitTotal(benefit: 2, lastYear: false)
        let lastOrdinaryIncomeOrLoss = self.getBenefitTotal(benefit: 2, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 税引前当期純利益（損失）
        let incomeOrLossBeforeIncomeTaxes = self.getBenefitTotal(benefit: 3, lastYear: false)
        let lastIncomeOrLossBeforeIncomeTaxes = self.getBenefitTotal(benefit: 3, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        // MARK: - 当期純利益（損失）
        let netIncomeOrLoss = self.getBenefitTotal(benefit: 4, lastYear: false)
        let lastNetIncomeOrLoss = self.getBenefitTotal(benefit: 4, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        return ProfitAndLossStatementData(
            company: company,
            fiscalYear: fiscalYear,
            theDayOfReckoning: theDayOfReckoning,
            objects0: objects0,
            netSales: netSales,
            lastNetSales: lastNetSales,
            objects1: objects1,
            objects2: objects2,
            costOfGoodsSold: costOfGoodsSold,
            lastCostOfGoodsSold: lastCostOfGoodsSold,
            objects3: objects3,
            sellingGeneralAndAdministrativeExpenses: sellingGeneralAndAdministrativeExpenses,
            lastSellingGeneralAndAdministrativeExpenses: lastSellingGeneralAndAdministrativeExpenses,
            objects4: objects4,
            nonOperatingIncome: nonOperatingIncome,
            lastNonOperatingIncome: lastNonOperatingIncome,
            objects5: objects5,
            nonOperatingExpenses: nonOperatingExpenses,
            lastNonOperatingExpenses: lastNonOperatingExpenses,
            objects6: objects6,
            extraordinaryIncome: extraordinaryIncome,
            lastExtraordinaryIncome: lastExtraordinaryIncome,
            objects7: objects7,
            extraordinaryLosses: extraordinaryLosses,
            lastExtraordinaryLosses: lastExtraordinaryLosses,
            objects8: objects8,
            incomeTaxes: incomeTaxes,
            lastIncomeTaxes: lastIncomeTaxes,
            grossProfitOrLoss: grossProfitOrLoss,
            lastGrossProfitOrLoss: lastGrossProfitOrLoss,
            otherCapitalSurplusesTotal: otherCapitalSurplusesTotal,
            lastOtherCapitalSurplusesTotal: lastOtherCapitalSurplusesTotal,
            ordinaryIncomeOrLoss: ordinaryIncomeOrLoss,
            lastOrdinaryIncomeOrLoss: lastOrdinaryIncomeOrLoss,
            incomeOrLossBeforeIncomeTaxes: incomeOrLossBeforeIncomeTaxes,
            lastIncomeOrLossBeforeIncomeTaxes: lastIncomeOrLossBeforeIncomeTaxes,
            netIncomeOrLoss: netIncomeOrLoss,
            lastNetIncomeOrLoss: lastNetIncomeOrLoss
        )
    }
    
    // MARK: 計算　書き込み
    
    // 計算　階層0 大区分
    private func setTotalRank0(big5: Int, rank0: Int) {
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
    
    // MARK: Delete
    
}
