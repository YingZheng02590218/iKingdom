//
//  BSModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol BSModelInput {
    
    func initializeBS() -> BSData
    
    func getTotalBig5(big5: Int, lastYear: Bool) -> String
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String
    
    func initializePDFMaker(bSData: BSData, completion: ([URL]?) -> Void)
}
// 貸借対照表クラス
class BSModel: BSModelInput {
    
    // 印刷機能
    let pDFMaker = PDFMakerBS()
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS() -> BSData {
        //0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)//資産
        setTotalBig5(big5: 1)//負債
        setTotalBig5(big5: 2)//純資産
        
        setTotalRank0(big5: 0, rank0: 0)//流動資産
        setTotalRank0(big5: 0, rank0: 1)//固定資産
        setTotalRank0(big5: 0, rank0: 2)//繰延資産
        setTotalRank0(big5: 1, rank0: 3)//流動負債
        setTotalRank0(big5: 1, rank0: 4)//固定負債
        
        setTotalRank1(big5: 2, rank1: 10)//株主資本
        setTotalRank1(big5: 2, rank1: 11)//その他の包括利益累計額
        

        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 階層3　中区分ごとの数を取得
        let objects0100 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "0") // 流動資産
        let objects0102 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "2") // 繰延資産
        let objects0114 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "4") // 流動負債
        let objects0115 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "5") // 固定負債
        let objects0129 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "9") //株主資本14
        let objects01210 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "10") //評価・換算差額等15
        //            0    1    2    11                    新株予約権
        //            0    1    2    12                    自己新株予約権
        //            0    1    2    13                    非支配株主持分
        //            0    1    2    14                    少数株主持分
        let objects01211 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "11")//新株予約権16
        let objects01213 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "13")//非支配株主持分22
        // 階層4 小区分
        let objects010142 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "42") // 有形固定資産3
        let objects010143 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "43") // 無形固定資産4
        let objects010144 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "44") // 投資その他の資産5
        
        // MARK: - "    流動資産合計"
        let CurrentAssets_total = self.getTotalRank0(big5: 0, rank0: 0, lastYear: false)
        var lastCurrentAssets_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastCurrentAssets_total = self.getTotalRank0(big5: 0, rank0: 0, lastYear: true)
        }
        else {
            lastCurrentAssets_total = "-"
        }
        // MARK: - "    固定資産合計"
        let FixedAssets_total = self.getTotalRank0(big5: 0, rank0: 1, lastYear: false)
        var lastFixedAssets_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastFixedAssets_total = self.getTotalRank0(big5: 0, rank0: 1, lastYear: true)
        }
        else {
            lastFixedAssets_total = "-"
        }
        // MARK: - "    繰越資産合計"
        let DeferredAssets_total = self.getTotalRank0(big5: 0, rank0: 2, lastYear: false)
        var lastDeferredAssets_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastDeferredAssets_total = self.getTotalRank0(big5: 0, rank0: 2, lastYear: true)
        }
        else {
            lastDeferredAssets_total = "-"
        }
        // MARK: - "    流動負債合計"
        let CurrentLiabilities_total = self.getTotalRank0(big5: 1, rank0: 3, lastYear: false)
        var lastCurrentLiabilities_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastCurrentLiabilities_total = self.getTotalRank0(big5: 1, rank0: 3, lastYear: true)
        }
        else {
            lastCurrentLiabilities_total = "-"
        }
        // MARK: - "    固定負債合計"
        let FixedLiabilities_total = self.getTotalRank0(big5: 1, rank0: 4, lastYear: false)
        var lastFixedLiabilities_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastFixedLiabilities_total = self.getTotalRank0(big5: 1, rank0: 4, lastYear: true)
        }
        else {
            lastFixedLiabilities_total = "-"
        }
        
        
        // MARK: - "資産合計"
        let Asset_total = self.getTotalBig5(big5: 0, lastYear: false)
        var lastAsset_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastAsset_total = self.getTotalBig5(big5: 0, lastYear: true)
        }
        else {
            lastAsset_total = "-"
        }
        // MARK: - "負債合計"
        let Liability_total = self.getTotalBig5(big5: 1, lastYear: false)
        var lastLiability_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastLiability_total = self.getTotalBig5(big5: 1, lastYear: true)
        }
        else {
            lastLiability_total = "-"
        }
        // MARK: - "純資産合計"
        let Equity_total = self.getTotalBig5(big5: 2, lastYear: false)
        var lastEquity_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastEquity_total = self.getTotalBig5(big5: 2, lastYear: true)
        }
        else {
            lastEquity_total = "-"
        }
        // MARK: - "負債純資産合計"
        let Liability_and_Equity_total = self.getTotalBig5(big5: 3, lastYear: false)
        var lastLiability_and_Equity_total = ""
        if self.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            lastLiability_and_Equity_total = self.getTotalBig5(big5: 3, lastYear: true)
        }
        else {
            lastLiability_and_Equity_total = "-"
        }
        
        return BSData(company: company,
                      fiscalYear: fiscalYear,
                      theDayOfReckoning: theDayOfReckoning,
                      objects0100: objects0100,
                      CurrentAssets_total: CurrentAssets_total,
                      lastCurrentAssets_total: lastCurrentAssets_total,
                      objects010142: objects010142,
                      objects010143: objects010143,
                      objects010144: objects010144,
                      FixedAssets_total: FixedAssets_total,
                      lastFixedAssets_total: lastFixedAssets_total,
                      objects0102: objects0102,
                      DeferredAssets_total: DeferredAssets_total,
                      lastDeferredAssets_total: lastDeferredAssets_total,
                      Asset_total: Asset_total,
                      lastAsset_total: lastAsset_total,
                      objects0114: objects0114,
                      CurrentLiabilities_total: CurrentLiabilities_total,
                      lastCurrentLiabilities_total: lastCurrentLiabilities_total,
                      objects0115: objects0115,
                      FixedLiabilities_total: FixedLiabilities_total,
                      lastFixedLiabilities_total: lastFixedLiabilities_total,
                      Liability_total: Liability_total,
                      lastLiability_total: lastLiability_total,
                      objects0129: objects0129,
                      objects01210: objects01210,
                      objects01211: objects01211,
                      objects01213: objects01213,
                      Equity_total: Equity_total,
                      lastEquity_total: lastEquity_total,
                      Liability_and_Equity_total: Liability_and_Equity_total,
                      lastLiability_and_Equity_total: lastLiability_and_Equity_total
        )
    }
    
    // 前年度の会計帳簿の存在有無を確認
    func checkSettingsPeriod() -> Bool {
        return DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod()
    }
    
    // MARK: 計算　書き込み
    
    // 計算　五大区分
    private func setTotalBig5(big5: Int) {
        // 累計額
        var TotalAmountOfBig5: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count{
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            let totalDebitOrCredit = getTotalDebitOrCreditForBig5(big_category: big5,
                                                                  account: dataBaseSettingsTaxonomyAccounts[i].category) // 5大区分用の貸又借を使用する　2020/11/09
            if totalDebitOrCredit == "-" {
                TotalAmountOfBig5 -= totalAmount
            }
            else {
                TotalAmountOfBig5 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet
        
        let realm = try! Realm()
        try! realm.write {
            switch big5 {
            case 0: //資産
                balanceSheet!.Asset_total = TotalAmountOfBig5
                break
            case 1: //負債
                balanceSheet!.Liability_total = TotalAmountOfBig5
                break
            case 2: //純資産
                balanceSheet!.Equity_total = TotalAmountOfBig5
                break
            default:
                print("bigCategoryTotalAmount", TotalAmountOfBig5)
                break
            }
        }
    }
    // 計算　階層0 大区分
    private func setTotalRank0(big5: Int, rank0: Int) {
        // 累計額
        var TotalAmountOfRank0: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count{
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: rank0,
                                                           mid_category: Int(dataBaseSettingsTaxonomyAccounts[i].Rank1) ?? 999,
                                                           account: dataBaseSettingsTaxonomyAccounts[i].category)
            if totalDebitOrCredit == "-" {
                TotalAmountOfRank0 -= totalAmount
            }
            else {
                TotalAmountOfRank0 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet

        let realm = try! Realm()
        try! realm.write {
            switch rank0 {
            case 0: //流動資産
                balanceSheet!.CurrentAssets_total = TotalAmountOfRank0
                break
            case 1: //固定資産
                balanceSheet!.FixedAssets_total = TotalAmountOfRank0
                break
            case 2: //繰延資産
                balanceSheet!.DeferredAssets_total = TotalAmountOfRank0
                break
            case 3: //流動負債
                balanceSheet!.CurrentLiabilities_total = TotalAmountOfRank0
                break
            case 4: //固定負債
                balanceSheet!.FixedLiabilities_total = TotalAmountOfRank0
                break
            default:
                print(TotalAmountOfRank0)
                break
            }
        }
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
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        try! realm.write {
            switch rank1 {
            case 10: //株主資本
                objectss!.CapitalStock_total = TotalAmountOfRank1
                break
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                objectss!.OtherCapitalSurpluses_total = TotalAmountOfRank1
                break
//            case 12: //新株予約権
//            case 19: //非支配株主持分
            default:
                print()
                break
            }
        }
    }

    // MARK: 読み出し
    
    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        
        let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet
        // 合計額
        var result: Int64 = 0
        switch big5 {
        case 0: //資産
            result = balanceSheet!.Asset_total
            break
        case 1: //負債
            result = balanceSheet!.Liability_total
            break
        case 2: //純資産
            result = balanceSheet!.Equity_total
            break
        case 3: //負債純資産
            result = balanceSheet!.Liability_total + balanceSheet!.Equity_total
            break
        default:
            print(result)
            break
        }
        return StringUtility.shared.setComma(amount: result)
    }
    
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet
        var result: Int64 = 0            // 累計額
        switch rank0 {
        case 0: //流動資産
            result = balanceSheet!.CurrentAssets_total
            break
        case 1: //固定資産
            result = balanceSheet!.FixedAssets_total
            break
        case 2: //繰延資産
            result = balanceSheet!.DeferredAssets_total
            break
        case 3: //流動負債
            result = balanceSheet!.CurrentLiabilities_total
            break
        case 4: //固定負債
            result = balanceSheet!.FixedLiabilities_total
            break
        default:
            print(result)
            break
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        var result:Int64 = 0            // 累計額
        switch rank1 {
            case 10: //株主資本
                result = objectss!.CapitalStock_total
                break
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                result = objectss!.OtherCapitalSurpluses_total
                break
//            case 12: //新株予約権
//            case 19: //非支配株主持分
        default:
            print(result)
            break
        }
        return StringUtility.shared.setComma(amount: result)
    }
    
    // MARK: Local method　読み出し
    
    // 取得　設定勘定科目　五大区分
    private func getAccountsInBig5(big5: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch big5 {
        case 0: // 資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)'") // 流動資産, 固定資産, 繰延資産
            break
        case 1: // 負債
            objects = objects.filter("Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)'") // 流動負債, 固定負債
            break
        case 2: // 純資産
            objects = objects.filter("Rank0 LIKE '\(5)'") // 資本, 2020/11/09 不使用　評価・換算差額等　 OR Rank0 LIKE '\(12)'
            break
        default:
            print("")
        }
        return objects
    }
    // 取得　設定勘定科目　大区分
    private func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 取得　設定勘定科目　中区分
    private func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank1 LIKE '\(rank1)'")
        return objects
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
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
    // 借又貸を取得
    private func getTotalDebitOrCredit(big_category: Int, mid_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
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
    // 借又貸を取得 5大区分用
    private func getTotalDebitOrCreditForBig5(big_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
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
        case 0,3: // 資産　費用
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        default: // 1,2,4（負債、純資産、収益）
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
    func initializePDFMaker(bSData: BSData, completion: ([URL]?) -> Void) {

        pDFMaker.initialize(bSData: bSData, completion: { PDFpath in
            completion(PDFpath)
        })
    }
}
