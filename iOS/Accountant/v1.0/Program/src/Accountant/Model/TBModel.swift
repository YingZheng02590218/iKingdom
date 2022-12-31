//
//  TBModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol TBModelInput {
    func calculateAmountOfAllAccount()
    func setAllAccountTotal()
    
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64
}

// 合計残高試算表クラス
class TBModel: TBModelInput {
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_total
                    case 1: // 合計　貸方
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_total
                    case 2: // 残高　借方
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance
                    case 3: // 残高　貸方
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance
                    default:
                        print("getTotalAmount")
                    }
                }
            } else {
                if let dataBasePLAccount = dataBaseGeneralLedger.dataBasePLAccount {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = dataBasePLAccount.debit_total
                    case 1: // 合計　貸方
                        result = dataBasePLAccount.credit_total
                    case 2: // 残高　借方
                        result = dataBasePLAccount.debit_balance
                    case 3: // 残高　貸方
                        result = dataBasePLAccount.credit_balance
                    default:
                        print("getTotalAmount 損益勘定")
                    }
                }
            }
        }
        return result
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account == "繰越利益" { // 精算表作成後に、資本振替仕訳を行うので、繰越利益の決算整理仕訳は計算に含まない。
                result = 0
            } else {
                if account != "損益勘定" {
                    // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                    for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting
                        case 1: // 合計　貸方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting
                        case 2: // 残高　借方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_Adjusting
                        case 3: // 残高　貸方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_Adjusting
                        default:
                            print("getTotalAmountAdjusting")
                        }
                    }
                } else {
                    if let dataBasePLAccount = dataBaseGeneralLedger.dataBasePLAccount {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = dataBasePLAccount.debit_total_Adjusting
                        case 1: // 合計　貸方
                            result = dataBasePLAccount.credit_total_Adjusting
                        case 2: // 残高　借方
                            result = dataBasePLAccount.debit_balance_Adjusting
                        case 3: // 残高　貸方
                            result = dataBasePLAccount.credit_balance_Adjusting
                        default:
                            print("getTotalAmountAdjusting 損益勘定")
                        }
                    }
                }
            }
        }
        return result
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account == "繰越利益" { // 精算表作成後に、資本振替仕訳を行うので、繰越利益の決算整理仕訳は計算に含まない。
                result = 0
            } else {
                if account != "損益勘定" {
                    // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                    for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting
                        case 1: // 合計　貸方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting
                        case 2: // 残高　借方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                        case 3: // 残高　貸方
                            result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting
                        default:
                            print("getTotalAmountAfterAdjusting")
                        }
                    }
                } else {
                    if let dataBasePLAccount = dataBaseGeneralLedger.dataBasePLAccount {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = dataBasePLAccount.debit_total_AfterAdjusting
                        case 1: // 合計　貸方
                            result = dataBasePLAccount.credit_total_AfterAdjusting
                        case 2: // 残高　借方
                            result = dataBasePLAccount.debit_balance_AfterAdjusting
                        case 3: // 残高　貸方
                            result = dataBasePLAccount.credit_balance_AfterAdjusting
                        default:
                            print("getTotalAmountAfterAdjusting 損益勘定")
                        }
                    }
                }
            }
        }
        return result
    }
    
    // MARK: Update
    
    // 計算　合計残高試算表クラス　合計（借方、貸方）、残高（借方、貸方）の集計
    func calculateAmountOfAllAccount() {
        // 総勘定元帳　取得
        let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
        if let objectsOfGL = dataBaseManagerGeneralLedger.getGeneralLedger() {
            // 財務諸表　取得
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            
            do {
                try DataBaseManager.realm.write {
                    for r in 0..<4 { // 注意：3になっていた。誤り
                        var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                        for i in 0..<objectsOfGL.dataBaseAccounts.count {
                            l += getTotalAmount(account: objectsOfGL.dataBaseAccounts[i].accountName, leftOrRight: r) // 累計額に追加
                        }
                        switch r {
                        case 0: // 合計　借方
                            object.compoundTrialBalance?.debit_total_total = l // + k
                        case 1: // 合計　貸方
                            object.compoundTrialBalance?.credit_total_total = l // + k
                        case 2: // 残高　借方
                            object.compoundTrialBalance?.debit_balance_total = l // + k
                        case 3: // 残高　貸方
                            object.compoundTrialBalance?.credit_balance_total = l // + k
                        default:
                            print("default calculateAmountOfAllAccount")
                        }
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 設定　仕訳と決算整理後　勘定クラス　全ての勘定
    func setAllAccountTotal() {
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: false, switching: true)
        for i in 0..<objects.count {
            // クリア
            clearAccountTotal(account: objects[i].category)
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: objects[i].category)
            // 勘定別に決算整理仕訳データを集計
            calculateAccountTotalAdjusting(account: objects[i].category)
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: objects[i].category)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        // 資本振替仕訳後に、繰越利益勘定の決算整理前と決算整理仕訳、決算整理後の合計額と残高額の集計は必要ないのか？
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
    }
    // 設定　仕訳と決算整理後　勘定クラス　個別の勘定別　仕訳データを追加後に、呼び出される
    func setAccountTotal(accountLeft: String, accountRight: String) {
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        if accountLeft != "損益勘定" {
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: accountLeft ) // 借方
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: accountLeft )
        }
        if accountRight != "損益勘定" {
            calculateAccountTotal(account: accountRight) // 貸方
            calculateAccountTotalAfterAdjusting(account: accountRight)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
        // 設定表示科目　初期化 毎回行うと時間がかかる
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if accountLeft != "損益勘定" {
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: accountLeft)) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
        }
        if accountRight != "損益勘定" {
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: accountRight))
        }
        DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: "繰越利益"))
        // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
    }
    // 設定　決算整理仕訳と決算整理後　勘定クラス　個別の勘定別　決算整理仕訳データを追加後に、呼び出される
    func setAccountTotalAdjusting(accountLeft: String, accountRight: String) {
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        if accountLeft != "損益勘定" {
            // 勘定別に決算整理仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotalAdjusting(account: accountLeft) // 借方
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: accountLeft)
        }
        if accountRight != "損益勘定" {
            calculateAccountTotalAdjusting(account: accountRight) // 貸方
            calculateAccountTotalAfterAdjusting(account: accountRight)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
        // 設定表示科目　初期化 毎回行うと時間がかかる
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if accountLeft != "損益勘定" {
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: accountLeft)
            ) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
        }
        if accountRight != "損益勘定" {
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: accountRight)
            )
        }
        DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
            numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: "繰越利益")
        )
        // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
    }
    //　クリア　勘定クラス　決算整理前、決算整理仕訳、決算整理後（合計、残高）
    private func clearAccountTotal(account: String) {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
                    if account != "損益勘定" {
                        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                        for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_total = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_total = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance = 0
                            
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_Adjusting = 0
                            
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0
                        }
                    } else { // 損益勘定の場合
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_total = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_total = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_balance = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_balance = 0
                        
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_total_Adjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_total_Adjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_Adjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_Adjusting = 0
                        
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_total_AfterAdjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_total_AfterAdjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_AfterAdjusting = 0
                        dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_AfterAdjusting = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    //　計算 決算整理前　勘定クラス　勘定別に仕訳データを集計
    private func calculateAccountTotal(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let objects = dataBaseManagerAccount.getJournalEntryInAccount(account: account) // 勘定別に取得
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            } else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    do {
                        try DataBaseManager.realm.write {
                            // 借方と貸方で金額が大きい方はどちらか
                            if left > right {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance = left - right // 差額を格納
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            } else if left < right {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance = 0
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance = right - left
                            } else {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance = 0 // ゼロを入れないと前回値が残る
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance = 0
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            } else { // 損益勘定の場合
                do {
                    try DataBaseManager.realm.write {
                        // 借方と貸方で金額が大きい方はどちらか
                        if left > right {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance = left - right // 差額を格納
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        } else if left < right {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance = 0
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance = right - left
                        } else {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance = 0 // ゼロを入れないと前回値が残る
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance = 0
                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    //　計算 決算整理仕訳　勘定クラス　勘定別に決算整理仕訳データを集計
    private func calculateAccountTotalAdjusting(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        var objects: Results<DataBaseAdjustingEntry>
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        if account != "損益勘定" && account != "繰越利益" {
            objects = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account)
        } else if account == "繰越利益" {
            objects = dataBaseManagerAccount.getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: account)
        } else {
            objects = dataBaseManagerAccount.getAllAdjustingEntryInPLAccount(account: account)
        }
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            } else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    do {
                        try DataBaseManager.realm.write {
                            // 借方と貸方で金額が大きい方はどちらか
                            if left > right {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_Adjusting = left - right // 差額を格納
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            } else if left < right {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_Adjusting = 0
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_Adjusting = right - left
                            } else {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting = left
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting = right
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_Adjusting = 0
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            } else { // 損益勘定の場合
                do {
                    try DataBaseManager.realm.write {
                        // 借方と貸方で金額が大きい方はどちらか
                        if left > right {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total_Adjusting = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total_Adjusting = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_Adjusting = left - right // 差額を格納
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        } else if left < right {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total_Adjusting = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total_Adjusting = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_Adjusting = 0
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_Adjusting = right - left
                        } else {
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_total_Adjusting = left
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_total_Adjusting = right
                            dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                            dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_Adjusting = 0
                        }
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    // 計算　決算整理後　勘定クラス　勘定別の決算整理後の集計 決算整理前+決算整理事項=決算整理後
    private func calculateAccountTotalAfterAdjusting(account: String) { // 損益勘定 用も作る
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算振替仕訳　損益勘定振替
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account != "損益勘定" { // } && account != "繰越利益" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == account {
                    do {
                        try DataBaseManager.realm.write {
                            // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting =
                            dataBaseGeneralLedger.dataBaseAccounts[i].debit_total + dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_Adjusting
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting =
                            dataBaseGeneralLedger.dataBaseAccounts[i].credit_total + dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_Adjusting
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    // 残高額　借方と貸方で金額が大きい方はどちらか
                    if dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting {
                        do {
                            try DataBaseManager.realm.write {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting =
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting -
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting // 差額を格納
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定振替
                        if account != "繰越利益" { // 繰越利益の日付が手動で変更される可能性がある
                            DataBaseManagerPLAccount.shared.addTransferEntry(
                                debitCategory: account,
                                amount: dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting,
                                creditCategory: "損益勘定"
                            )
                        }
                    } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting {
                        do {
                            try DataBaseManager.realm.write {
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting =
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_total_AfterAdjusting -
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_total_AfterAdjusting // 差額を格納
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定振替
                        if account != "繰越利益" { // 繰越利益の日付が手動で変更される可能性がある
                            DataBaseManagerPLAccount.shared.addTransferEntry(
                                debitCategory: "損益勘定",
                                amount: dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting,
                                creditCategory: account
                            )
                        }
                    } else {
                        do {
                            try DataBaseManager.realm.write {
                                dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                                dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定振替 差額がない勘定は損益振替しなくてもよいのか？　2020/10/05
                        DataBaseManagerPLAccount.shared.addTransferEntry(debitCategory: "損益勘定", amount: 0, creditCategory: account)
                    }
                }
            } else {
                // 損益勘定の場合
                if let dataBasePLAccount = dataBaseGeneralLedger.dataBasePLAccount {
                    do {
                        try DataBaseManager.realm.write {
                            // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
                            dataBasePLAccount.debit_total_AfterAdjusting = dataBasePLAccount.debit_total + dataBasePLAccount.debit_total_Adjusting
                            dataBasePLAccount.credit_total_AfterAdjusting = dataBasePLAccount.credit_total + dataBasePLAccount.credit_total_Adjusting
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    // 残高額　借方と貸方で金額が大きい方はどちらか
                    if dataBasePLAccount.debit_total_AfterAdjusting > dataBasePLAccount.credit_total_AfterAdjusting {
                        do {
                            try DataBaseManager.realm.write {
                                dataBasePLAccount.debit_balance_AfterAdjusting =
                                dataBasePLAccount.debit_total_AfterAdjusting -
                                dataBasePLAccount.credit_total_AfterAdjusting // 差額を格納
                                dataBasePLAccount.credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定の締切り
                        DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(debitCategory: "損益勘定", amount: dataBasePLAccount.debit_balance_AfterAdjusting, creditCategory: "繰越利益")
                    } else if dataBasePLAccount.debit_total_AfterAdjusting < dataBasePLAccount.credit_total_AfterAdjusting {
                        do {
                            try DataBaseManager.realm.write {
                                dataBasePLAccount.credit_balance_AfterAdjusting =
                                dataBasePLAccount.credit_total_AfterAdjusting -
                                dataBasePLAccount.debit_total_AfterAdjusting // 差額を格納
                                dataBasePLAccount.debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定の締切り
                        DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(debitCategory: "繰越利益", amount: dataBasePLAccount.credit_balance_AfterAdjusting, creditCategory: "損益勘定")
                    } else {
                        do {
                            try DataBaseManager.realm.write {
                                dataBasePLAccount.debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                                dataBasePLAccount.credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                            }
                        } catch {
                            print("エラーが発生しました")
                        }
                        // 決算振替仕訳　損益勘定の締切り 記述漏れ　2020/11/05
                        DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(debitCategory: "繰越利益", amount: 0, creditCategory: "損益勘定")
                    }
                }
            }
        }
    }
    
    // MARK: Delete
    
}
