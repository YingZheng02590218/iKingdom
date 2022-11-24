//
//  PLModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol PLModelInput {
    
    func initializeBenefits() -> PLData

    func initializePDFMaker(pLData: PLData, completion: ([URL]?) -> Void)
}
// 損益計算書クラス
class PLModel: PLModelInput {
    
    // 印刷機能
    let pDFMaker = PDFMakerPL()

    // 初期化　中区分、大区分　ごとに計算
    func initializeBenefits() -> PLData {
        // データベースに書き込み　//4:収益 3:費用
        setTotalRank0(big5: 4,rank0:  6) //営業収益9     売上
        setTotalRank0(big5: 3,rank0:  7) //営業費用5     売上原価
        setTotalRank0(big5: 3,rank0:  8) //営業費用5     販売費及び一般管理費
        setTotalRank0(big5: 3,rank0: 11) //税等8        法人税等 税金

        setTotalRank1(big5: 4, rank1: 15) //営業外収益10 営業外損益    営業外収益
        setTotalRank1(big5: 3, rank1: 16) //営業外費用6  営業外損益    営業外費用
        setTotalRank1(big5: 4, rank1: 17) //特別利益11   特別損益    特別利益
        setTotalRank1(big5: 3, rank1: 18) //特別損失7    特別損益    特別損失
        
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
        
        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()

        let mid_category10 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "6")//営業外収益10
        let mid_category6 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "7")//営業外費用6
        let mid_category11 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "9")//特別利益11
        let mid_category7 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "10")//特別損失7
        let objects9 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "4")//販売費及び一般管理費9

        // MARK: - 営業収益9     売上
        let NetSales = self.getTotalRank0(big5: 4, rank0: 6, lastYear: false)
        let lastNetSales = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 4, rank0: 6, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業費用5     売上原価
        let CostOfGoodsSold = self.getTotalRank0(big5: 3, rank0: 7, lastYear: false)
        let lastCostOfGoodsSold = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 3, rank0: 7, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業費用5     販売費及び一般管理費
        let SellingGeneralAndAdministrativeExpenses = self.getTotalRank0(big5: 3, rank0: 8, lastYear: false)
        let lastSellingGeneralAndAdministrativeExpenses = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 3, rank0: 8, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 税等8 法人税等 税金
        let IncomeTaxes = self.getTotalRank0(big5: 3, rank0: 11, lastYear: false)
        let lastIncomeTaxes = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 3, rank0: 11, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - 営業外収益10  営業外損益    営業外収益
        let NonOperatingIncome = self.getTotalRank1(big5: 4, rank1: 15, lastYear: false)
        let lastNonOperatingIncome = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 4, rank1: 15, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業外費用6  営業外損益    営業外費用
        let NonOperatingExpenses = self.getTotalRank1(big5: 3, rank1: 16, lastYear: false)
        let lastNonOperatingExpenses = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 3, rank1: 16, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 特別利益11   特別損益    特別利益
        let ExtraordinaryIncome = self.getTotalRank1(big5: 4, rank1: 17, lastYear: false)
        let lastExtraordinaryIncome = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 4, rank1: 17, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 特別損失7    特別損益    特別損失
        let ExtraordinaryLosses = self.getTotalRank1(big5: 3, rank1: 18, lastYear: false)
        let lastExtraordinaryLosses = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 3, rank1: 18, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - 売上総利益
        let GrossProfitOrLoss = self.getBenefitTotal(benefit: 0, lastYear: false)
        let lastGrossProfitOrLoss = self.checkSettingsPeriod() ? self.getBenefitTotal(benefit: 0, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 営業利益
        let OtherCapitalSurpluses_total = self.getBenefitTotal(benefit: 1, lastYear: false)
        let lastOtherCapitalSurpluses_total = self.checkSettingsPeriod() ? self.getBenefitTotal(benefit: 1, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 経常利益
        let OrdinaryIncomeOrLoss = self.getBenefitTotal(benefit: 2, lastYear: false)
        let lastOrdinaryIncomeOrLoss = self.checkSettingsPeriod() ? self.getBenefitTotal(benefit: 2, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 税引前当期純利益（損失）
        let IncomeOrLossBeforeIncomeTaxes = self.getBenefitTotal(benefit: 3, lastYear: false)
        let lastIncomeOrLossBeforeIncomeTaxes = self.checkSettingsPeriod() ? self.getBenefitTotal(benefit: 3, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        // MARK: - 当期純利益（損失）
        let NetIncomeOrLoss = self.getBenefitTotal(benefit: 4, lastYear: false)
        let lastNetIncomeOrLoss = self.checkSettingsPeriod() ? self.getBenefitTotal(benefit: 4, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認


        return PLData(company: company, fiscalYear: fiscalYear, theDayOfReckoning: theDayOfReckoning, CostOfGoodsSold: CostOfGoodsSold, lastCostOfGoodsSold: lastCostOfGoodsSold, objects9: objects9, SellingGeneralAndAdministrativeExpenses: SellingGeneralAndAdministrativeExpenses, lastSellingGeneralAndAdministrativeExpenses: lastSellingGeneralAndAdministrativeExpenses, mid_category6: mid_category6, NonOperatingExpenses: NonOperatingExpenses, lastNonOperatingExpenses: lastNonOperatingExpenses, mid_category7: mid_category7, ExtraordinaryLosses: ExtraordinaryLosses, lastExtraordinaryLosses: lastExtraordinaryLosses, IncomeTaxes: IncomeTaxes, lastIncomeTaxes: lastIncomeTaxes, NetSales: NetSales, lastNetSales: lastNetSales, mid_category10: mid_category10, NonOperatingIncome: NonOperatingIncome, lastNonOperatingIncome: lastNonOperatingIncome, mid_category11: mid_category11, ExtraordinaryIncome: ExtraordinaryIncome, lastExtraordinaryIncome: lastExtraordinaryIncome, GrossProfitOrLoss: GrossProfitOrLoss, lastGrossProfitOrLoss: lastGrossProfitOrLoss, OtherCapitalSurpluses_total: OtherCapitalSurpluses_total, lastOtherCapitalSurpluses_total: lastOtherCapitalSurpluses_total, OrdinaryIncomeOrLoss: OrdinaryIncomeOrLoss, lastOrdinaryIncomeOrLoss: lastOrdinaryIncomeOrLoss, IncomeOrLossBeforeIncomeTaxes: IncomeOrLossBeforeIncomeTaxes, lastIncomeOrLossBeforeIncomeTaxes: lastIncomeOrLossBeforeIncomeTaxes, NetIncomeOrLoss: NetIncomeOrLoss, lastNetIncomeOrLoss: lastNetIncomeOrLoss)
    }
                        // 前年度の会計帳簿の存在有無を確認
                      func checkSettingsPeriod() -> Bool {
            return DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod()
        }
                      
    // 計算　階層0 大区分
    private func setTotalRank0(big5: Int, rank0: Int) {
        var TotalAmountOfRank0:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: rank0, mid_category: Int(objects[i].Rank1) ?? 999, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank0 -= totalAmount
            }else {
                TotalAmountOfRank0 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        
        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        try! realm.write {
            switch rank0 {
            case 6: //営業収益9     売上
                objectss!.NetSales = TotalAmountOfRank0
                break
            case 7: //営業費用5     売上原価
                objectss!.CostOfGoodsSold = TotalAmountOfRank0
                break
            case 8: //営業費用5     販売費及び一般管理費
                objectss!.SellingGeneralAndAdministrativeExpenses = TotalAmountOfRank0
                break
            case 11: //税等8 法人税等 税金
                objectss!.IncomeTaxes = TotalAmountOfRank0
                break
            default:
                print()
            }
        }
    }
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0
        switch rank0 {
        case 6: //営業収益9     売上
            result = objectss!.NetSales
            break
        case 7: //営業費用5     売上原価
            result = objectss!.CostOfGoodsSold
            break
        case 8: //営業費用5     販売費及び一般管理費
            result = objectss!.SellingGeneralAndAdministrativeExpenses
            break
        case 11: //税等8 法人税等 税金
            result = objectss!.IncomeTaxes
            break
        default:
            print(result)
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 計算　階層1 中区分
    private func setTotalRank1(big5: Int, rank1: Int) {
        var TotalAmountOfRank1:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank1(rank1: rank1)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: Int(objects[i].Rank0)!, mid_category: rank1, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank1 -= totalAmount
            }else {
                TotalAmountOfRank1 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)

        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        try! realm.write {
            switch rank1 {
            case 15: //営業外収益10  営業外損益    営業外収益
                objectss!.NonOperatingIncome = TotalAmountOfRank1
                break
            case 16: //営業外費用6  営業外損益    営業外費用
                objectss!.NonOperatingExpenses = TotalAmountOfRank1
                break
            case 17: //特別利益11   特別損益    特別利益
                objectss!.ExtraordinaryIncome = TotalAmountOfRank1
                break
            case 18: //特別損失7    特別損益    特別損失
                objectss!.ExtraordinaryLosses = TotalAmountOfRank1
                break
            default:
                print()
                break
            }
        }
    }
    // 取得　設定勘定科目　中区分
    private func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank1 LIKE '\(rank1)'")
        return objects
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0            // 累計額
        switch rank1 {
        case 15: //営業外収益10  営業外損益    営業外収益
            result = objectss!.NonOperatingIncome
            break
        case 16: //営業外費用6  営業外損益    営業外費用
            result = objectss!.NonOperatingExpenses
            break
        case 17: //特別利益11   特別損益    特別利益
            result = objectss!.ExtraordinaryIncome
            break
        case 18: //特別損失7    特別損益    特別損失
            result = objectss!.ExtraordinaryLosses
            break
        default:
            print(result)
            break
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 利益　計算
    private func setBenefitTotal() {
        // 開いている会計帳簿を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)

        // 利益5種類　売上総利益、営業利益、経常利益、税金等調整前当期純利益、当期純利益
        for i in 0..<5 {
            let realm = try! Realm()
            let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
            try! realm.write {
                switch i {
                case 0: //売上総利益
                    objectss!.GrossProfitOrLoss = objectss!.NetSales - objectss!.CostOfGoodsSold
                    break
                case 1: //営業利益
                    objectss!.OtherCapitalSurpluses_total = objectss!.GrossProfitOrLoss - objectss!.SellingGeneralAndAdministrativeExpenses
                    break
                case 2: //経常利益
                    objectss!.OrdinaryIncomeOrLoss = objectss!.OtherCapitalSurpluses_total + objectss!.NonOperatingIncome - objectss!.NonOperatingExpenses
                    break
                case 3: //税引前当期純利益（損失）
                    objectss!.IncomeOrLossBeforeIncomeTaxes = objectss!.OrdinaryIncomeOrLoss + objectss!.ExtraordinaryIncome - objectss!.ExtraordinaryLosses
                    break
                case 4: //当期純利益（損失）
                    objectss!.NetIncomeOrLoss = objectss!.IncomeOrLossBeforeIncomeTaxes - objectss!.IncomeTaxes
                    break
                default:
                    print()
                    break
                }
            }
        }
    }
    // 利益　取得　前年度表示対応
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0            // 累計額
        switch benefit {
        case 0: //売上総利益
            result = objectss!.GrossProfitOrLoss
            break
        case 1: //営業利益
            result = objectss!.OtherCapitalSurpluses_total
            break
        case 2: //経常利益
            result = objectss!.OrdinaryIncomeOrLoss
            break
        case 3: //税引前当期純利益（損失）
            result = objectss!.IncomeOrLossBeforeIncomeTaxes
            break
        case 4: //当期純利益（損失）
            result = objectss!.NetIncomeOrLoss
            break
        default:
            print(result)
            break
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 決算整理後の値を利用する
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting
                }else {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }
            }
        }
        return result
    }
    // 取得　設定勘定科目　大区分
    private func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 借又貸を取得
    private func getTotalDebitOrCredit(big_category: Int, mid_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var DebitOrCredit:String = "" // 借又貸
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "借"
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "貸"
                }else {
                    DebitOrCredit = "-"
                }
            }
        }
        var PositiveOrNegative:String = "" // 借又貸
        switch big_category {
        case 0,1,2,7,8,11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        case 9,10: // 営業外損益 特別損益
            if mid_category == 15 || mid_category == 17 {
                switch DebitOrCredit {
                case "借":
                    PositiveOrNegative = "-"
                    break
                default:
                    PositiveOrNegative = ""
                    break
                }
            }else if mid_category == 16 || mid_category == 18 {
                switch DebitOrCredit {
                case "貸":
                    PositiveOrNegative = "-"
                    break
                default:
                    PositiveOrNegative = ""
                    break
                }
            }
            break
        default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
            switch DebitOrCredit {
            case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        }
        return PositiveOrNegative
    }
    
    // 初期化 PDFメーカー
    func initializePDFMaker(pLData: PLData, completion: ([URL]?) -> Void) {

        pDFMaker.initialize(pLData: pLData, completion: { PDFpath in
            completion(PDFpath)
        })
    }
}
