//
//  AfterClosingTrialBalanceModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol AfterClosingTrialBalanceModelInput {
    func calculateAmountOfBSAccounts(dataBaseSettingsTaxonomyAccounts: Results<DataBaseSettingsTaxonomyAccount>)
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount>

    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64
}

// 繰越試算表クラス
class AfterClosingTrialBalanceModel: AfterClosingTrialBalanceModelInput {
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
        DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: rank0, rank1: rank1)
    }
    
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account == Constant.capitalAccountName || account == "資本金勘定" { // TODO: "資本金勘定"はこない
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = dataBaseCapitalAccount.debit_total_AfterAdjusting // 決算振替後で、当期純利益を含む
                    case 1: // 合計　貸方
                        result = dataBaseCapitalAccount.credit_total_AfterAdjusting // 決算振替後で、当期純利益を含む
                    case 2: // 残高　借方
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting // 決算振替後で、当期純利益を含む
                    case 3: // 残高　貸方
                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting // 決算振替後で、当期純利益を含む
                    default:
                        print("getTotalAmount 資本金勘定")
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                if let account = dataBaseGeneralLedger.dataBaseAccounts.first(where: { $0.accountName == account }) {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = account.debit_total_AfterAdjusting
                    case 1: // 合計　貸方
                        result = account.credit_total_AfterAdjusting
                    case 2: // 残高　借方
                        result = account.debit_balance_AfterAdjusting
                    case 3: // 残高　貸方
                        result = account.credit_balance_AfterAdjusting
                    default:
                        print("getTotalAmountAfterAdjusting")
                    }
                }
            }
        }
        return result
    }
    
    // MARK: Update
    
    // 計算　繰越試算表クラス　合計（借方、貸方）、残高（借方、貸方）の集計
    func calculateAmountOfBSAccounts(dataBaseSettingsTaxonomyAccounts: Results<DataBaseSettingsTaxonomyAccount>) {
        // 財務諸表　取得
        let object = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
        do {
            try DataBaseManager.realm.write {
                for r in 0..<4 { // 注意：3になっていた。誤り
                    var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                    // 設定勘定科目　貸借科目
                    for dataBaseSettingsTaxonomyAccount in dataBaseSettingsTaxonomyAccounts {
                        l += getTotalAmountAfterAdjusting(account: dataBaseSettingsTaxonomyAccount.category, leftOrRight: r) // 累計額に追加
                    }
                    switch r {
                    case 0: // 合計　借方
                        object.afterClosingTrialBalance?.debit_total_total = l // + k
                    case 1: // 合計　貸方
                        object.afterClosingTrialBalance?.credit_total_total = l // + k
                    case 2: // 残高　借方
                        object.afterClosingTrialBalance?.debit_balance_total = l // + k
                    case 3: // 残高　貸方
                        object.afterClosingTrialBalance?.credit_balance_total = l // + k
                    default:
                        print("default calculateAmountOfAllAccount")
                    }
                }
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Delete
    
}
