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
    func initializePDFMaker(bSData: BSData, completion: ([URL]?) -> Void)
}
// 貸借対照表クラス
class BSModel: BSModelInput {
    // 印刷機能
    let pDFMaker = PDFMakerBS()
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS() -> BSData {
        // 0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)// 資産
        setTotalBig5(big5: 1)// 負債
        setTotalBig5(big5: 2)// 純資産

        setTotalRank0(big5: 0, rank0: 0)// 流動資産
        setTotalRank0(big5: 0, rank0: 1)// 固定資産
        setTotalRank0(big5: 0, rank0: 2)// 繰延資産
        setTotalRank0(big5: 1, rank0: 3)// 流動負債
        setTotalRank0(big5: 1, rank0: 4)// 固定負債

        setTotalRank1(big5: 2, rank1: 10)// 株主資本
        setTotalRank1(big5: 2, rank1: 11)// その他の包括利益累計額

        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 階層3　中区分ごとの数を取得
        let objects0100 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "0", category3: "0") // 流動資産
        let objects0102 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "0", category3: "2") // 繰延資産
        let objects0114 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "1", category3: "4") // 流動負債
        let objects0115 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "1", category3: "5") // 固定負債
        let objects0129 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "2", category3: "9") // 株主資本14
        let objects01210 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "2", category3: "10") // 評価・換算差額等15
        //            0    1    2    11                    新株予約権
        //            0    1    2    12                    自己新株予約権
        //            0    1    2    13                    非支配株主持分
        //            0    1    2    14                    少数株主持分
        let objects01211 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "2", category3: "11") // 新株予約権16
        let objects01213 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0", category1: "1", category2: "2", category3: "13") // 非支配株主持分22
        // 階層4 小区分
        let objects010142 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0", category1: "1", category2: "0", category3: "1", category4: "42") // 有形固定資産3
        let objects010143 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0", category1: "1", category2: "0", category3: "1", category4: "43") // 無形固定資産4
        let objects010144 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0", category1: "1", category2: "0", category3: "1", category4: "44") // 投資その他の資産5
        // MARK: - "    株主資本合計"
        let capitalStockTotal = self.getTotalRank1(big5: 2, rank1: 10, lastYear: false) // 中区分の合計を取得
        let lastCapitalStockTotal = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 2, rank1: 10, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    その他の包括利益累計額合計"
        let otherCapitalSurplusesTotal = self.getTotalRank1(big5: 2, rank1: 11, lastYear: false) // 中区分の合計を取得
        let lastOtherCapitalSurplusesTotal = self.checkSettingsPeriod() ? self.getTotalRank1(big5: 2, rank1: 11, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    流動資産合計"
        let currentAssetsTotal = self.getTotalRank0(big5: 0, rank0: 0, lastYear: false)
        let lastCurrentAssetsTotal = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 0, rank0: 0, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    固定資産合計"
        let fixedAssetsTotal = self.getTotalRank0(big5: 0, rank0: 1, lastYear: false)
        let lastFixedAssetsTotal = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 0, rank0: 1, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    繰越資産合計"
        let deferredAssetsTotal = self.getTotalRank0(big5: 0, rank0: 2, lastYear: false)
        let lastDeferredAssetsTotal = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 0, rank0: 2, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    流動負債合計"
        let currentLiabilitiesTotal = self.getTotalRank0(big5: 1, rank0: 3, lastYear: false)
        let lastCurrentLiabilitiesTotal = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 1, rank0: 3, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "    固定負債合計"
        let fixedLiabilitiesTotal = self.getTotalRank0(big5: 1, rank0: 4, lastYear: false)
        let lastFixedLiabilitiesTotal = self.checkSettingsPeriod() ? self.getTotalRank0(big5: 1, rank0: 4, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "資産合計"
        let assetTotal = self.getTotalBig5(big5: 0, lastYear: false)
        let lastAssetTotal = self.checkSettingsPeriod() ? self.getTotalBig5(big5: 0, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "負債合計"
        let liabilityTotal = self.getTotalBig5(big5: 1, lastYear: false)
        let lastLiabilityTotal = self.checkSettingsPeriod() ? self.getTotalBig5(big5: 1, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "純資産合計"
        let equityTotal = self.getTotalBig5(big5: 2, lastYear: false)
        let lastEquityTotal = self.checkSettingsPeriod() ? self.getTotalBig5(big5: 2, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認

        // MARK: - "負債純資産合計"
        let liabilityAndEquityTotal = self.getTotalBig5(big5: 3, lastYear: false)
        let lastLiabilityAndEquityTotal = self.checkSettingsPeriod() ? self.getTotalBig5(big5: 3, lastYear: true) : "-" // 前年度の会計帳簿の存在有無を確認
        
        return BSData(
            company: company,
            fiscalYear: fiscalYear,
            theDayOfReckoning: theDayOfReckoning,
            objects0100: objects0100,
            currentAssetsTotal: currentAssetsTotal,
            lastCurrentAssetsTotal: lastCurrentAssetsTotal,
            objects010142: objects010142,
            objects010143: objects010143,
            objects010144: objects010144,
            fixedAssetsTotal: fixedAssetsTotal,
            lastFixedAssetsTotal: lastFixedAssetsTotal,
            objects0102: objects0102,
            deferredAssetsTotal: deferredAssetsTotal,
            lastDeferredAssetsTotal: lastDeferredAssetsTotal,
            assetTotal: assetTotal,
            lastAssetTotal: lastAssetTotal,
            objects0114: objects0114,
            currentLiabilitiesTotal: currentLiabilitiesTotal,
            lastCurrentLiabilitiesTotal: lastCurrentLiabilitiesTotal,
            objects0115: objects0115,
            fixedLiabilitiesTotal: fixedLiabilitiesTotal,
            lastFixedLiabilitiesTotal: lastFixedLiabilitiesTotal,
            liabilityTotal: liabilityTotal,
            lastLiabilityTotal: lastLiabilityTotal,
            objects0129: objects0129,
            capitalStockTotal: capitalStockTotal,
            lastCapitalStockTotal: lastCapitalStockTotal,
            objects01210: objects01210,
            otherCapitalSurplusesTotal: otherCapitalSurplusesTotal,
            lastOtherCapitalSurplusesTotal: lastOtherCapitalSurplusesTotal,
            objects01211: objects01211,
            objects01213: objects01213,
            equityTotal: equityTotal,
            lastEquityTotal: lastEquityTotal,
            liabilityAndEquityTotal: liabilityAndEquityTotal,
            lastLiabilityAndEquityTotal: lastLiabilityAndEquityTotal
        )
    }
    // 前年度の会計帳簿の存在有無を確認
    func checkSettingsPeriod() -> Bool {
        DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod()
    }

    // MARK: 計算　書き込み

    // 計算　五大区分
    private func setTotalBig5(big5: Int) {
        // 累計額
        var totalAmountOfBig5: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = getAccountsInBig5(big5: big5)
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
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            do {
                try DataBaseManager.realm.write {
                    switch big5 {
                    case 0: // 資産
                        balanceSheet.Asset_total = totalAmountOfBig5
                    case 1: // 負債
                        balanceSheet.Liability_total = totalAmountOfBig5
                    case 2: // 純資産
                        balanceSheet.Equity_total = totalAmountOfBig5
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
    private func setTotalRank0(big5: Int, rank0: Int) {
        // 累計額
        var totalAmountOfRank0: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let totalAmount = getTotalAmount(account: dataBaseSettingsTaxonomyAccounts[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(
                bigCategory: rank0,
                midCategory: Int(dataBaseSettingsTaxonomyAccounts[i].Rank1) ?? 999,
                account: dataBaseSettingsTaxonomyAccounts[i].category
            )
            if totalDebitOrCredit == "-" {
                totalAmountOfRank0 -= totalAmount
            } else {
                totalAmountOfRank0 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            do {
                // (2)書き込みトランザクション内でデータを追加する
                try DataBaseManager.realm.write {
                    switch rank0 {
                    case 0: // 流動資産
                        balanceSheet.CurrentAssets_total = totalAmountOfRank0
                    case 1: // 固定資産
                        balanceSheet.FixedAssets_total = totalAmountOfRank0
                    case 2: // 繰延資産
                        balanceSheet.DeferredAssets_total = totalAmountOfRank0
                    case 3: // 流動負債
                        balanceSheet.CurrentLiabilities_total = totalAmountOfRank0
                    case 4: // 固定負債
                        balanceSheet.FixedLiabilities_total = totalAmountOfRank0
                    default:
                        print(totalAmountOfRank0)
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 計算　階層1 中区分
    private func setTotalRank1(big5: Int, rank1: Int) {
        var totalAmountOfRank1: Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank1(rank1: rank1)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count {
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(bigCategory: Int(objects[i].Rank0)!, midCategory: rank1, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                totalAmountOfRank1 -= totalAmount
            } else {
                totalAmountOfRank1 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            do {
                try DataBaseManager.realm.write {
                    switch rank1 {
                    case 10: // 株主資本
                        balanceSheet.CapitalStock_total = totalAmountOfRank1
                    case 11: // 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                        balanceSheet.OtherCapitalSurpluses_total = totalAmountOfRank1
                        //　case 12: //新株予約権
                        //　case 19: //非支配株主持分
                    default:
                        print()
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }

    // MARK: 読み出し

    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        // 合計額
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            switch big5 {
            case 0: // 資産
                result = balanceSheet.Asset_total
            case 1: // 負債
                result = balanceSheet.Liability_total
            case 2: // 純資産
                result = balanceSheet.Equity_total
            case 3: // 負債純資産
                result = balanceSheet.Liability_total + balanceSheet.Equity_total
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        var result: Int64 = 0            // 累計額
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            switch rank0 {
            case 0: // 流動資産
                result = balanceSheet.CurrentAssets_total
            case 1: // 固定資産
                result = balanceSheet.FixedAssets_total
            case 2: // 繰延資産
                result = balanceSheet.DeferredAssets_total
            case 3: // 流動負債
                result = balanceSheet.CurrentLiabilities_total
            case 4: // 固定負債
                result = balanceSheet.FixedLiabilities_total
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        var result: Int64 = 0            // 累計額
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        if let balanceSheet = dataBaseAccountingBooks.dataBaseFinancialStatements?.balanceSheet {
            switch rank1 {
            case 10: // 株主資本
                result = balanceSheet.CapitalStock_total
            case 11: // 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                result = balanceSheet.OtherCapitalSurpluses_total
                // case 12: //新株予約権
                // case 19: //非支配株主持分
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }

    // MARK: Local method　読み出し

    // 取得　設定勘定科目　五大区分
    private func getAccountsInBig5(big5: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch big5 {
        case 0: // 資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)'") // 流動資産, 固定資産, 繰延資産
        case 1: // 負債
            objects = objects.filter("Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)'") // 流動負債, 固定負債
        case 2: // 純資産
            objects = objects.filter("Rank0 LIKE '\(5)'") // 資本, 2020/11/09 不使用　評価・換算差額等　 OR Rank0 LIKE '\(12)'
        default:
            print("")
        }
        return objects
    }
    // 取得　設定勘定科目　大区分
    private func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "Rank0 LIKE %@", NSString(string: String(rank0)))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得　設定勘定科目　中区分
    private func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "Rank1 LIKE %@", NSString(string: String(rank1)))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    private func getTotalAmount(account: String) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
        return result
    }
    // 借又貸を取得
    private func getTotalDebitOrCredit(bigCategory: Int, midCategory: Int, account: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
    // 借又貸を取得 5大区分用
    private func getTotalDebitOrCreditForBig5(bigCategory: Int, account: String) -> String {
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
    // 初期化 PDFメーカー
    func initializePDFMaker(bSData: BSData, completion: ([URL]?) -> Void) {
        pDFMaker.initialize(bSData: bSData, completion: { PDFpath in
            completion(PDFpath)
        })
    }
}
