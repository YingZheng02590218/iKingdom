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

    func getTotalAmount(account: String, leftOrRight: Int) -> String
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String
}
// 精算表クラス
class WSModel: WSModelInput {
    
    func initialize() {
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        calculateAmountOfAllAccount()
        calculateAmountOfAllAccountForBS()
        calculateAmountOfAllAccountForPL()
    }
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> String { // TODO: 戻り値をカンマ追加後のStringに変換してから返す
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount:databaseManager.getTotalAmount(account: account, leftOrRight: leftOrRight))
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> String {
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount:databaseManager.getTotalAmountAdjusting(account: account, leftOrRight: leftOrRight))
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> String {
        let databaseManager = TBModel()
        return StringUtility.shared.setCommaForTB(amount:databaseManager.getTotalAmountAfterAdjusting(account: account, leftOrRight: leftOrRight))
    }
    
    // 精算表　計算　合計、残高の合計値　修正記入、損益計算書、貸借対照表
    private func calculateAmountOfAllAccount(){
        let dataBaseManager = DataBaseManagerGeneralLedger()
        let objectG = dataBaseManager.getGeneralLedger()
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = TBModel()

        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for r in 0..<4 { //注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.dataBaseAccounts.count {
                    l += dataBaseManagerTB.getTotalAmountAdjusting(account: objectG.dataBaseAccounts[i].accountName, leftOrRight: r) // 累計額に追加
                }
                switch r {
                case 0: // 合計　借方
                    object.workSheet?.debit_adjustingEntries_total_total = l
                    break
                case 1: // 合計　貸方
                    object.workSheet?.credit_adjustingEntries_total_total = l
                    break
                case 2: // 残高　借方
                    object.workSheet?.debit_adjustingEntries_balance_total = l
                    break
                case 3: // 残高　貸方
                    object.workSheet?.credit_adjustingEntries_balance_total = l
                    break
                default:
                    print(l)
                    break
                }
            }
        }
    }
    // 損益計算書　計算　合計、残高の合計値
    private func calculateAmountOfAllAccountForPL(){ // calculateAmountOfAllAccountForBS と共通化したい
        let dataBaseManager = DatabaseManagerSettingsTaxonomyAccount()
        let objectG = dataBaseManager.getSettingsSwitchingOnBSorPL(BSorPL: 1)
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = TBModel()

        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for r in 0..<4 { //注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.count {
                    l += dataBaseManagerTB.getTotalAmountAfterAdjusting(account: objectG[i].category, leftOrRight: r) // 累計額に追加
                }
                switch r {
                case 0: // 合計　借方
                    object.workSheet?.debit_PL_total_total = l
                    break
                case 1: // 合計　貸方
                    object.workSheet?.credit_PL_total_total = l
                    break
                case 2: // 残高　借方
                    object.workSheet?.debit_PL_balance_total = l
                    break
                case 3: // 残高　貸方
                    object.workSheet?.credit_PL_balance_total = l
                    break
                default:
                    print(l)
                    break
                }
            }
            // 当期純利益を計算する
            if object.workSheet!.debit_PL_balance_total > object.workSheet!.credit_PL_balance_total {
                object.workSheet?.netIncomeOrNetLossIncome = object.workSheet!.debit_PL_balance_total - object.workSheet!.credit_PL_balance_total
                object.workSheet?.netIncomeOrNetLossLoss = 0
            }else {
                object.workSheet?.netIncomeOrNetLossIncome = 0
                object.workSheet?.netIncomeOrNetLossLoss = object.workSheet!.credit_PL_balance_total - object.workSheet!.debit_PL_balance_total
            }
        }
    }
    // 貸借対照表　計算　合計、残高の合計値
    private func calculateAmountOfAllAccountForBS(){
        let dataBaseManager = DatabaseManagerSettingsTaxonomyAccount()
        let objectG = dataBaseManager.getSettingsSwitchingOnBSorPL(BSorPL: 0)
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = TBModel()

        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for r in 0..<4 { //注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.count {
                    l += dataBaseManagerTB.getTotalAmountAfterAdjusting(account: objectG[i].category, leftOrRight: r) // 累計額に追加
                }
                switch r {
                case 0: // 合計　借方
                    object.workSheet?.debit_BS_total_total = l
                    break
                case 1: // 合計　貸方
                    object.workSheet?.credit_BS_total_total = l
                    break
                case 2: // 残高　借方
                    object.workSheet?.debit_BS_balance_total = l
                    break
                case 3: // 残高　貸方
                    object.workSheet?.credit_BS_balance_total = l
                    break
                default:
                    print(l)
                    break
                }
            }
        }
    }
}
