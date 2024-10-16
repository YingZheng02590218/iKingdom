//
//  WSModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol WSModelInput {
    func initialize()
    
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount>

    func getTotalAmount(account: String, leftOrRight: Int) -> String
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String
}
// 精算表クラス
class WSModel: WSModelInput {

    // MARK: - CRUD

    // MARK: Create

    // MARK: Read
    
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
        DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: rank0, rank1: rank1)
    }
    
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String {
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount: databaseManager.getTotalAmount(account: account, leftOrRight: leftOrRight))
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String {
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount: databaseManager.getTotalAmountAdjusting(account: account, leftOrRight: leftOrRight))
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String {
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount: databaseManager.getTotalAmountAfterAdjusting(account: account, leftOrRight: leftOrRight))
    }

    // MARK: Update

    func initialize() {
        // 精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        calculateAmountOfAllAccount()
        calculateAmountOfAllAccountForBS()
        calculateAmountOfAllAccountForPL()
    }
    // 精算表　計算　合計、残高の合計値　修正記入、損益計算書、貸借対照表
    private func calculateAmountOfAllAccount() {
        if let objectG = DataBaseManagerGeneralLedger.shared.getGeneralLedger() {

            let dataBaseFinancialStatement = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
            if let workSheet = dataBaseFinancialStatement.workSheet {

                let dataBaseManagerTB = TBModel()

                for r in 0..<4 { // 注意：3になっていた。誤り
                    var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                    for i in 0..<objectG.dataBaseAccounts.count {
                        l += dataBaseManagerTB.getTotalAmountAdjusting(account: objectG.dataBaseAccounts[i].accountName, leftOrRight: r) // 累計額に追加
                    }

                    do {
                        try DataBaseManager.realm.write {
                            switch r {
                            case 0: // 合計　借方
                                workSheet.debit_adjustingEntries_total_total = l
                            case 1: // 合計　貸方
                                workSheet.credit_adjustingEntries_total_total = l
                            case 2: // 残高　借方
                                workSheet.debit_adjustingEntries_balance_total = l
                            case 3: // 残高　貸方
                                workSheet.credit_adjustingEntries_balance_total = l
                            default:
                                print(l)
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
    }
    // 損益計算書　計算　合計、残高の合計値
    private func calculateAmountOfAllAccountForPL() { // calculateAmountOfAllAccountForBS と共通化したい
        let objectG = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 1)

        let dataBaseFinancialStatement = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
        if let workSheet = dataBaseFinancialStatement.workSheet {

            let dataBaseManagerTB = TBModel()

            for r in 0..<4 { // 注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.count {
                    l += dataBaseManagerTB.getTotalAmountAfterAdjusting(account: objectG[i].category, leftOrRight: r) // 累計額に追加
                }
                do {
                    try DataBaseManager.realm.write {
                        switch r {
                        case 0: // 合計　借方
                            workSheet.debit_PL_total_total = l
                        case 1: // 合計　貸方
                            workSheet.credit_PL_total_total = l
                        case 2: // 残高　借方
                            workSheet.debit_PL_balance_total = l
                        case 3: // 残高　貸方
                            workSheet.credit_PL_balance_total = l
                        default:
                            print(l)
                        }
                        // 当期純利益を計算する
                        if workSheet.debit_PL_balance_total > workSheet.credit_PL_balance_total {
                            workSheet.netIncomeOrNetLossIncome = workSheet.debit_PL_balance_total - workSheet.credit_PL_balance_total
                            workSheet.netIncomeOrNetLossLoss = 0
                        } else {
                            workSheet.netIncomeOrNetLossIncome = 0
                            workSheet.netIncomeOrNetLossLoss = workSheet.credit_PL_balance_total - workSheet.debit_PL_balance_total
                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    // 貸借対照表　計算　合計、残高の合計値
    private func calculateAmountOfAllAccountForBS() {
        let objectG = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0)

        let dataBaseFinancialStatement = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
        if let workSheet = dataBaseFinancialStatement.workSheet {

            let dataBaseManagerTB = TBModel()

            for r in 0..<4 { // 注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.count {
                    l += dataBaseManagerTB.getTotalAmountAfterAdjusting(account: objectG[i].category, leftOrRight: r) // 累計額に追加
                }
                do {
                    try DataBaseManager.realm.write {
                        switch r {
                        case 0: // 合計　借方
                            workSheet.debit_BS_total_total = l
                        case 1: // 合計　貸方
                            workSheet.credit_BS_total_total = l
                        case 2: // 残高　借方
                            workSheet.debit_BS_balance_total = l
                        case 3: // 残高　貸方
                            workSheet.credit_BS_balance_total = l
                        default:
                            print(l)
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
