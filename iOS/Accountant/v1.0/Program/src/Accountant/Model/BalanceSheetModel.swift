//
//  BalanceSheetModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/02.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol BalanceSheetModelInput {
    func initializeBS() -> BalanceSheetData
    func initializePdfMaker(balanceSheetData: BalanceSheetData, completion: (URL?) -> Void)
}
// 貸借対照表クラス　個人事業主
class BalanceSheetModel: BalanceSheetModelInput {
    // 印刷機能
    let pDFMaker = PDFMakerBalanceSheet()
    // 初期化 PDFメーカー
    func initializePdfMaker(balanceSheetData: BalanceSheetData, completion: (URL?) -> Void) {
        pDFMaker.initialize(balanceSheetData: balanceSheetData, completion: { PDFpath in
            completion(PDFpath)
        })
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
        
    // MARK: 読み出し
    
    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        // 合計額
        var result: Int64 = 0
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            } else {
                return "-"
            }
        }
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
    func getTotalRank0(rank0: Int, lastYear: Bool) -> String {
        var result: Int64 = 0            // 累計額
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            } else {
                return "-"
            }
        }
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
            case 5: // 資本
                result = balanceSheet.Capital_total
            default:
                print(result)
            }
        }
        return StringUtility.shared.setComma(amount: result)
    }
    
    // MARK: Local method　読み出し
    
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得 借又貸を取得
    private func getTotalAmountDebitOrCredit(
        big5: Int? = nil,
        bigCategory: Int? = nil,
        midCategory: Int? = nil,
        account: String
    ) -> (Int64, String) {
        var result: Int64 = 0
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸

        // 法人/個人フラグ
        let capitalAccount = Constant.capitalAccountName
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if capitalAccount == account {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                        debitOrCredit = "-"
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                if let account = dataBaseGeneralLedger.dataBaseAccounts.first(where: { $0.accountName == account }) {
                    // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                    if account.debit_balance_AfterAdjusting > account.credit_balance_AfterAdjusting {
                        result = account.debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if account.debit_balance_AfterAdjusting < account.credit_balance_AfterAdjusting {
                        result = account.credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        result = account.debit_balance_AfterAdjusting
                        debitOrCredit = "-"
                    }
                }
            }
        }
        if let big5 = big5 {
            switch big5 {
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
        } else {
            if let bigCategory = bigCategory {
                
                switch bigCategory {
                case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
                    switch debitOrCredit {
                    case "貸":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                case 9, 10: // 営業外損益 特別損益
                    if let midCategory = midCategory {
                        
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
        }
        return (result, positiveOrNegative)
    }
    
    // MARK: Update
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS() -> BalanceSheetData {
        // 0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)// 資産
        setTotalBig5(big5: 1)// 負債
        setTotalBig5(big5: 2)// 純資産
        
        setTotalRank0(rank0: 0)// 流動資産
        setTotalRank0(rank0: 1)// 固定資産
        setTotalRank0(rank0: 2)// 繰延資産
        setTotalRank0(rank0: 3)// 流動負債
        setTotalRank0(rank0: 4)// 固定負債
        setTotalRank0(rank0: 5)// 資本　TODO: なぜいままでなかった？

        let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 大区分ごとに設定勘定科目を取得する
        // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
        let objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 0)
        let objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 1)
        let objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 2)
        
        let objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 3)
        let objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 4)
        let objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 5)
        
        let objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 2, rank1: 6)
        
        let objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 7)
        let objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 8)
        
        let objects9 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 4, rank1: 9)

        let objects10 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 10) // 株主資本
        let objects11 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 11) // 評価・換算差額等
        let objects12 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 12) // 新株予約権
        let objects13 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 19) // 非支配株主持分

        // MARK: - "    元入金合計"
        
        // MARK: - "    流動資産合計"
        let currentAssetsTotal = self.getTotalRank0(rank0: 0, lastYear: false)
        let lastCurrentAssetsTotal = self.getTotalRank0(rank0: 0, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "    固定資産合計"
        let fixedAssetsTotal = self.getTotalRank0(rank0: 1, lastYear: false)
        let lastFixedAssetsTotal = self.getTotalRank0(rank0: 1, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "    繰越資産合計"
        let deferredAssetsTotal = self.getTotalRank0(rank0: 2, lastYear: false)
        let lastDeferredAssetsTotal = self.getTotalRank0(rank0: 2, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "    流動負債合計"
        let currentLiabilitiesTotal = self.getTotalRank0(rank0: 3, lastYear: false)
        let lastCurrentLiabilitiesTotal = self.getTotalRank0(rank0: 3, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "    固定負債合計"
        let fixedLiabilitiesTotal = self.getTotalRank0(rank0: 4, lastYear: false)
        let lastFixedLiabilitiesTotal = self.getTotalRank0(rank0: 4, lastYear: true) // 前年度の会計帳簿の存在有無を確認

        // MARK: - "資産合計"
        let assetTotal = self.getTotalBig5(big5: 0, lastYear: false)
        let lastAssetTotal = self.getTotalBig5(big5: 0, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "負債合計"
        let liabilityTotal = self.getTotalBig5(big5: 1, lastYear: false)
        let lastLiabilityTotal = self.getTotalBig5(big5: 1, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "純資産合計"
        let equityTotal = self.getTotalBig5(big5: 2, lastYear: false)
        let lastEquityTotal = self.getTotalBig5(big5: 2, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        // MARK: - "負債純資産合計"
        let liabilityAndEquityTotal = self.getTotalBig5(big5: 3, lastYear: false)
        let lastLiabilityAndEquityTotal = self.getTotalBig5(big5: 3, lastYear: true) // 前年度の会計帳簿の存在有無を確認
        
        return BalanceSheetData(
            company: company,
            fiscalYear: fiscalYear,
            theDayOfReckoning: theDayOfReckoning,
            objects0: objects0,
            objects1: objects1,
            objects2: objects2,
            currentAssetsTotal: currentAssetsTotal,
            lastCurrentAssetsTotal: lastCurrentAssetsTotal,
            objects3: objects3,
            objects4: objects4,
            objects5: objects5,
            fixedAssetsTotal: fixedAssetsTotal,
            lastFixedAssetsTotal: lastFixedAssetsTotal,
            objects6: objects6,
            deferredAssetsTotal: deferredAssetsTotal,
            lastDeferredAssetsTotal: lastDeferredAssetsTotal,
            assetTotal: assetTotal,
            lastAssetTotal: lastAssetTotal,
            objects7: objects7,
            objects8: objects8,
            currentLiabilitiesTotal: currentLiabilitiesTotal,
            lastCurrentLiabilitiesTotal: lastCurrentLiabilitiesTotal,
            objects9: objects9,
            fixedLiabilitiesTotal: fixedLiabilitiesTotal,
            lastFixedLiabilitiesTotal: lastFixedLiabilitiesTotal,
            liabilityTotal: liabilityTotal,
            lastLiabilityTotal: lastLiabilityTotal,
            objects10: objects10,
            objects11: objects11,
            objects12: objects12,
            objects13: objects13,
            equityTotal: equityTotal,
            lastEquityTotal: lastEquityTotal,
            liabilityAndEquityTotal: liabilityAndEquityTotal,
            lastLiabilityAndEquityTotal: lastLiabilityAndEquityTotal
        )
    }
    
    // MARK: 計算　書き込み
    
    // 計算　五大区分
    private func setTotalBig5(big5: Int) {
        var totalAmountOfBig5: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let total = getTotalAmountDebitOrCredit(
                big5: big5,
                account: dataBaseSettingsTaxonomyAccounts[i].category
            ) // 5大区分用の貸又借を使用する　2020/11/09
            if total.1 == "-" {
                totalAmountOfBig5 -= total.0
            } else {
                totalAmountOfBig5 += total.0
            }
        }
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
    private func setTotalRank0(rank0: Int) {
        var totalAmountOfRank0: Int64 = 0
        // 設定画面の勘定科目一覧にある勘定を取得する
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            let total = getTotalAmountDebitOrCredit(
                bigCategory: rank0,
                midCategory: Int(dataBaseSettingsTaxonomyAccounts[i].Rank1), // WARNING: Rank1（中区分）がない勘定科目も存在する
                account: dataBaseSettingsTaxonomyAccounts[i].category
            )
            if total.1 == "-" {
                totalAmountOfRank0 -= total.0
            } else {
                totalAmountOfRank0 += total.0
            }
        }
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
                    case 5: // 資本
                        balanceSheet.Capital_total = totalAmountOfRank0
                    default:
                        print(totalAmountOfRank0)
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    
    // MARK: Delete
    
}
