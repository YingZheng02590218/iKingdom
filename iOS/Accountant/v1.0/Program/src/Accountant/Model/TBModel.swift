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
            if account == Constant.capitalAccountName || account == "資本金勘定" {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = dataBaseCapitalAccount.debit_total
                    case 1: // 合計　貸方
                        result = dataBaseCapitalAccount.credit_total
                    case 2: // 残高　借方
                        result = dataBaseCapitalAccount.debit_balance
                    case 3: // 残高　貸方
                        result = dataBaseCapitalAccount.credit_balance
                    default:
                        print("getTotalAmount 資本金勘定")
                    }
                }
            } else {
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
        }
        return result
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account == Constant.capitalAccountName || account == "資本金勘定" {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = dataBaseCapitalAccount.debit_total // 決算振替後ではなく、当期純利益を含まない
                    case 1: // 合計　貸方
                        result = dataBaseCapitalAccount.credit_total // 決算振替後ではなく、当期純利益を含まない
                    case 2: // 残高　借方
                        result = dataBaseCapitalAccount.debit_balance // 決算振替後ではなく、当期純利益を含まない
                    case 3: // 残高　貸方
                        result = dataBaseCapitalAccount.credit_balance // 決算振替後ではなく、当期純利益を含まない
                    default:
                        print("getTotalAmount 資本金勘定")
                    }
                }
            } else {
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
            }
        }
        return result
    }
    
    // MARK: Update
    
    // 計算　合計残高試算表クラス　合計（借方、貸方）、残高（借方、貸方）の集計
    func calculateAmountOfAllAccount() {
        // 総勘定元帳　取得
        if let objectsOfGL = DataBaseManagerGeneralLedger.shared.getGeneralLedger() {
            // 財務諸表　取得
            let object = DataBaseManagerFinancialStatements.shared.getFinancialStatements()
            
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
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccountAll()
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            // 開始仕訳　残高振替仕訳の逆仕訳をする
            DataBaseManagerAccount.shared.addOpeningJournalEntryFromClosingBalanceAccount(
                account: dataBaseSettingsTaxonomyAccounts[i].category
            )
            // クリア
            clearAccountTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定別に決算整理仕訳データを集計
            calculateAccountTotalAdjusting(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: dataBaseSettingsTaxonomyAccounts[i].category)
            //　勘定クラス　勘定別に月次残高振替仕訳データを集計　開始仕訳　仕訳　決算整理仕訳
            calculateAccountMonthlyTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
        }
        // 損益振替仕訳、資本振替仕訳 を行う
        transferJournals()
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            // 設定表示科目　初期化 毎回行うと時間がかかる
            DataBaseManagerTaxonomy.shared.initializeTaxonomy()
        }
    }
    // 設定　仕訳と決算整理後　勘定クラス　個別の勘定別　仕訳データを追加、更新、削除後に、呼び出される
    func setAccountTotal(accountLeft: String, accountRight: String) {
        // 開始仕訳　残高振替仕訳の逆仕訳をする
        DataBaseManagerAccount.shared.addOpeningJournalEntryFromClosingBalanceAccount(
            account: accountLeft
        )
        // 開始仕訳　残高振替仕訳の逆仕訳をする
        DataBaseManagerAccount.shared.addOpeningJournalEntryFromClosingBalanceAccount(
            account: accountRight
        )
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
        calculateAccountTotal(account: accountLeft ) // 借方
        calculateAccountTotal(account: accountRight) // 貸方
        // 勘定別の決算整理後の集計
        calculateAccountTotalAfterAdjusting(account: accountLeft )
        calculateAccountTotalAfterAdjusting(account: accountRight)
        // 損益振替仕訳、資本振替仕訳 を行う
        transferJournals()
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            // 設定表示科目　初期化 毎回行うと時間がかかる
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(category: accountLeft)
            ) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(category: accountRight)
            )
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(
                    category: "繰越利益"
                )
            )
            // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
        }
        //　勘定クラス　勘定別に月次残高振替仕訳データを集計　開始仕訳　仕訳　決算整理仕訳
        calculateAccountMonthlyTotal(account: accountLeft)
        calculateAccountMonthlyTotal(account: accountRight)
    }
    // 設定　決算整理仕訳と決算整理後　勘定クラス　個別の勘定別　決算整理仕訳データを追加後に、呼び出される
    func setAccountTotalAdjusting(accountLeft: String, accountRight: String) {
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        // 勘定別に決算整理仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
        calculateAccountTotalAdjusting(account: accountLeft) // 借方
        calculateAccountTotalAdjusting(account: accountRight) // 貸方
        // 勘定別の決算整理後の集計
        calculateAccountTotalAfterAdjusting(account: accountLeft)
        calculateAccountTotalAfterAdjusting(account: accountRight)
        // 損益振替仕訳、資本振替仕訳 を行う
        transferJournals()
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            // 設定表示科目　初期化 毎回行うと時間がかかる
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(category: accountLeft)
            ) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(category: accountRight)
            )
            DataBaseManagerTaxonomy.shared.setTotalOfTaxonomy(
                numberOfSettingsTaxonomy: DatabaseManagerSettingsTaxonomyAccount.shared.getNumberOfTaxonomy(
                    category: "繰越利益"
                )
            )
            // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
        }
        //　勘定クラス　勘定別に月次残高振替仕訳データを集計　開始仕訳　仕訳　決算整理仕訳
        calculateAccountMonthlyTotal(account: accountLeft)
        calculateAccountMonthlyTotal(account: accountRight)
    }
    
    // MARK: - 帳簿締切
    // クリア
    // 計算 決算整理前
    // 計算 決算整理仕訳
    // 計算 決算整理後
    
    // 損益振替仕訳、資本振替仕訳 を行う
    func transferJournals() {
        // 損益振替仕訳
        clearAccountTotalPLAccount() // クリア
        calculateAccountTotalPLAccount() // 集計　損益振替
        calculateAccountTotalAdjustingPLAccount() // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjustingPLAccount() // 集計　決算整理後
        // 資本振替仕訳
        // 資本振替仕訳後に、繰越利益勘定の決算整理前と決算整理仕訳、決算整理後の合計額と残高額の集計は必要ないのか？
        clearAccountTotalCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalAdjustingCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalAfterAdjustingCapitalAccount() // 集計 資本金勘定
    }
    
    // MARK: 勘定
    //　クリア　勘定クラス　決算整理前、決算整理仕訳、決算整理後（合計、残高）
    private func clearAccountTotal(account: String) {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
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
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    //　勘定クラス　勘定別に仕訳データを集計
    private func calculateAccountTotal(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        // 開始仕訳 勘定別に取得
        let dataBaseOpeningJournalEntry = dataBaseManagerAccount.getOpeningJournalEntryInAccount(account: account)
        if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
            // 勘定が借方と貸方のどちらか
            if account == dataBaseOpeningJournalEntry.debit_category { // 借方
                left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
            } else if account == dataBaseOpeningJournalEntry.credit_category { // 貸方
                right += dataBaseOpeningJournalEntry.credit_amount // 累計額に追加
            }
        }
        // 通常仕訳 勘定別に取得
        let dataBaseJournalEntries = dataBaseManagerAccount.getJournalEntryInAccount(account: account)
        for i in 0..<dataBaseJournalEntries.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseJournalEntries[i].debit_category)" { // 借方
                left += dataBaseJournalEntries[i].debit_amount // 累計額に追加
            } else if account == "\(dataBaseJournalEntries[i].credit_category)" { // 貸方
                right += dataBaseJournalEntries[i].credit_amount // 累計額に追加
            }
        }
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
        }
    }
    //　勘定クラス　勘定別に決算整理仕訳データを集計
    private func calculateAccountTotalAdjusting(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        var objects: Results<DataBaseAdjustingEntry>
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        objects = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account)
        
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
        }
    }
    // 勘定クラス　勘定別の決算整理後の集計 決算整理前+決算整理事項=決算整理後 ※繰越利益、元入金勘定も含まれるが、計算結果は使用しない
    private func calculateAccountTotalAfterAdjusting(account: String) {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算振替仕訳　損益勘定振替
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
                    // 損益計算書に関する勘定科目のみに絞る
                    if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                        // 決算振替仕訳　損益振替
                        DataBaseManagerPLAccount.shared.addTransferEntry(
                            debitCategory: account,
                            amount: dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting,
                            creditCategory: "損益"
                        )
                    } else {
                        // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                        DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                            debitCategory: account,
                            amount: dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting,
                            creditCategory: "残高"
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
                    // 損益計算書に関する勘定科目のみに絞る
                    if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                        // 決算振替仕訳　損益振替
                        DataBaseManagerPLAccount.shared.addTransferEntry(
                            debitCategory: "損益",
                            amount: dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting,
                            creditCategory: account
                        )
                    } else {
                        // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                        DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                            debitCategory: "残高",
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
                    // 損益計算書に関する勘定科目のみに絞る
                    if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                        // 決算振替仕訳　損益振替 差額がない勘定は損益振替しなくてもよいのか？　2020/10/05
                        DataBaseManagerPLAccount.shared.addTransferEntry(
                            debitCategory: "損益",
                            amount: 0,
                            creditCategory: account
                        )
                    } else {
                        // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                        DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                            debitCategory: "残高",
                            amount: 0,
                            creditCategory: account
                        )
                    }
                }
            }
        }
    }
    //　勘定クラス　勘定別に月次残高振替仕訳データを集計　開始仕訳　仕訳　決算整理仕訳
    private func calculateAccountMonthlyTotal(account: String) {
        // 損益計算書に関する勘定科目のみに絞る
        if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            // 月次残高振替は貸借科目のみを対象とする
        } else {
            // 勘定に仕訳が存在するかどうか
            if isExistJournalEntryInAccount(account: account) {
                var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                var right: Int64 = 0
                
                let dataBaseManagerAccount = GeneralLedgerAccountModel()
                // 開始仕訳 勘定別に取得　期首の月の場合
                let dataBaseOpeningJournalEntry = dataBaseManagerAccount.getOpeningJournalEntryInAccount(
                    account: account
                )
                if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
                    // 勘定が借方と貸方のどちらか
                    if account == dataBaseOpeningJournalEntry.debit_category { // 借方
                        left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
                    } else if account == dataBaseOpeningJournalEntry.credit_category { // 貸方
                        right += dataBaseOpeningJournalEntry.credit_amount // 累計額に追加
                    }
                }
                // 月別の月末日を取得 12ヶ月分
                let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
                
                for index in 0..<lastDays.count {
                    if index > 0 {
                        // 前月の　月次残高振替仕訳　の金額を加味する
                        if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccount(
                            account: account,
                            yearMonth: "/" + "\(String(format: "%02d", lastDays[index-1].month))" + "/" // CONTAINS 部分一致
                        ) {
                            // 勘定が借方と貸方のどちらか
                            if account == "\(dataBaseMonthlyTransferEntry.debit_category)" { // 借方
                                // 借方勘定　＊貸方勘定を振替える
                                right += dataBaseMonthlyTransferEntry.balance_right // 累計額に追加
                            } else if account == "\(dataBaseMonthlyTransferEntry.credit_category)" { // 貸方
                                // 貸方勘定　＊借方勘定を振替える
                                left += dataBaseMonthlyTransferEntry.balance_left // 累計額に追加
                            }
                        }
                    }
                    // 通常仕訳 勘定別に月別に取得
                    let dataBaseJournalEntries = dataBaseManagerAccount.getJournalEntryInAccountInMonth(
                        account: account,
                        yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))"
                    )
                    for i in 0..<dataBaseJournalEntries.count { // 勘定内のすべての仕訳データ
                        // 勘定が借方と貸方のどちらか
                        if account == "\(dataBaseJournalEntries[i].debit_category)" { // 借方
                            left += dataBaseJournalEntries[i].debit_amount // 累計額に追加
                        } else if account == "\(dataBaseJournalEntries[i].credit_category)" { // 貸方
                            right += dataBaseJournalEntries[i].credit_amount // 累計額に追加
                        }
                    }
                    // 決算月は、次期繰越があるので、不要
                    //    // 決算整理仕訳
                    //    let dataBaseAdjustingEntries = dataBaseManagerAccount.getAdjustingEntryInAccountInMonth(
                    //        account: account,
                    //        yearMonth: "\(lastDay.year)" + "/" + "\(String(format: "%02d", lastDay.month))"
                    //    )
                    //    for i in 0..<dataBaseAdjustingEntries.count { // 勘定内のすべての仕訳データ
                    //        // 勘定が借方と貸方のどちらか
                    //        if account == "\(dataBaseAdjustingEntries[i].debit_category)" { // 借方
                    //            left += dataBaseAdjustingEntries[i].debit_amount // 累計額に追加
                    //        } else if account == "\(dataBaseAdjustingEntries[i].credit_category)" { // 貸方
                    //            right += dataBaseAdjustingEntries[i].credit_amount // 累計額に追加
                    //        }
                    //    }
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        // 月次残高振替仕訳
                        DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingBalanceAccount(
                            date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                            debitCategory: account,
                            creditCategory: "残高",
                            debitAmount: left,
                            creditAmount: right,
                            balanceLeft: left - right, // 差額を格納
                            balanceRight: 0
                        )
                    } else if left < right {
                        // 月次残高振替仕訳
                        DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingBalanceAccount(
                            date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                            debitCategory: "残高",
                            creditCategory: account,
                            debitAmount: left,
                            creditAmount: right,
                            balanceLeft: 0,
                            balanceRight: right - left
                        )
                    } else {
                        // 月次残高振替仕訳
                        DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingBalanceAccount(
                            date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                            debitCategory: account,
                            creditCategory: "残高",
                            debitAmount: left,
                            creditAmount: right,
                            balanceLeft: 0,
                            balanceRight: 0
                        )
                    }
                    // 月別に合計を計算する
                    left = 0
                    right = 0
                }
            }
        }
    }
    
    // 勘定に仕訳が存在するかどうか
    func isExistJournalEntryInAccount(account: String) -> Bool {
        // 仕訳データがない勘定の表示名をグレーアウトする
        let model = GeneralLedgerAccountModel()
        // 開始仕訳
        let dataBaseOpeningJournalEntry = model.getOpeningJournalEntryInAccount(account: account)
        
        let objectss = model.getJournalEntryInAccount(account: account) // 勘定別に取得
        let objectsss = model.getAllAdjustingEntryInAccount(account: account) // 決算整理仕訳
        
        if !objectss.isEmpty || !objectsss.isEmpty || dataBaseOpeningJournalEntry != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: 損益勘定
    //　クリア　損益勘定クラス　決算整理前、決算整理仕訳、決算整理後（合計、残高）
    private func clearAccountTotalPLAccount() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
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
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    //　損益勘定クラス　勘定別に仕訳データを集計
    private func calculateAccountTotalPLAccount() {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        let objects = DataBaseManagerPLAccount.shared.getTransferEntryInAccount() // 損益勘定から取得
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if "損益" == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            } else if "損益" == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
    //　損益勘定クラス　勘定別に決算整理仕訳データを集計
    private func calculateAccountTotalAdjustingPLAccount() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    dataBaseGeneralLedger.dataBasePLAccount?.debit_total_Adjusting = 0
                    dataBaseGeneralLedger.dataBasePLAccount?.credit_total_Adjusting = 0
                    dataBaseGeneralLedger.dataBasePLAccount?.debit_balance_Adjusting = 0 // 差額を格納
                    dataBaseGeneralLedger.dataBasePLAccount?.credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 損益勘定クラス　勘定別の決算整理後の集計 決算整理前+決算整理事項=決算整理後
    private func calculateAccountTotalAfterAdjustingPLAccount() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算振替仕訳　損益勘定振替
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
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
                    DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "損益",
                        amount: dataBasePLAccount.debit_balance_AfterAdjusting,
                        creditCategory: "資本金勘定" // FIXME: 資本金勘定
                    ) // 仕訳画面で繰越利益を選択して仕訳入力した場合、実行される
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
                    DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "資本金勘定", // FIXME: 資本金勘定
                        amount: dataBasePLAccount.credit_balance_AfterAdjusting,
                        creditCategory: "損益"
                    )
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
                    DataBaseManagerPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "資本金勘定", // FIXME: 資本金勘定
                        amount: 0,
                        creditCategory: "損益"
                    )
                }
            }
        }
    }
    
    // MARK: 資本金勘定　（繰越利益、元入金）
    //　クリア　資本金勘定クラス　決算整理前、決算整理仕訳、決算整理後（合計、残高）
    private func clearAccountTotalCapitalAccount() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance = 0
                    
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total_Adjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total_Adjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance_Adjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance_Adjusting = 0
                    
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total_AfterAdjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total_AfterAdjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance_AfterAdjusting = 0
                    dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance_AfterAdjusting = 0
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    //　資本金勘定クラス　勘定別に仕訳データを集計
    private func calculateAccountTotalCapitalAccount() {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        var account = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            account = CapitalAccountType.retainedEarnings.rawValue
        } else {
            account = CapitalAccountType.capital.rawValue
        }
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        // 開始仕訳 勘定別に取得
        let dataBaseOpeningJournalEntry = dataBaseManagerAccount.getOpeningJournalEntryInAccount(account: account)
        if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
            // 勘定が借方と貸方のどちらか
            if account == dataBaseOpeningJournalEntry.debit_category || dataBaseOpeningJournalEntry.debit_category == "資本金勘定" { // 借方
                left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
            } else if account == dataBaseOpeningJournalEntry.credit_category || dataBaseOpeningJournalEntry.credit_category == "資本金勘定" { // 貸方
                right += dataBaseOpeningJournalEntry.credit_amount // 累計額に追加
            }
        }
        // 取得　通常仕訳 資本金勘定から取得
        let dataBaseJournalEntries = dataBaseManagerAccount.getJournalEntryInAccount(account: account)
        for i in 0..<dataBaseJournalEntries.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(dataBaseJournalEntries[i].debit_category)" { // 借方
                left += dataBaseJournalEntries[i].debit_amount // 累計額に追加
            } else if account == "\(dataBaseJournalEntries[i].credit_category)" { // 貸方
                right += dataBaseJournalEntries[i].credit_amount // 累計額に追加
            }
        }
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance = left - right // 差額を格納
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance = 0
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance = right - left
                    } else {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance = 0 // ゼロを入れないと前回値が残る
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    //　資本金勘定クラス　勘定別に決算整理仕訳データ+資本振替仕訳データを集計
    private func calculateAccountTotalAdjustingCapitalAccount() {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        var objects: Results<DataBaseAdjustingEntry>
        var dataBaseCapitalTransferJournalEntry: DataBaseCapitalTransferJournalEntry?
        
        var account = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            account = CapitalAccountType.retainedEarnings.rawValue
        } else {
            account = CapitalAccountType.capital.rawValue
        }
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        objects = dataBaseManagerAccount.getAdjustingJournalEntryInAccount(account: account)
        dataBaseCapitalTransferJournalEntry = dataBaseManagerAccount.getCapitalTransferJournalEntryInAccount(account: account)
        
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            } else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 資本振替仕訳　決算整理の処理と同時に資本振替仕訳も処理する
        if let dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry {
            // 勘定が借方と貸方のどちらか
            if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.debit_category)" { // 借方
                left += dataBaseCapitalTransferJournalEntry.debit_amount // 累計額に追加
            } else if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.credit_category)" { // 貸方
                right += dataBaseCapitalTransferJournalEntry.credit_amount // 累計額に追加
            }
        }
        
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            do {
                try DataBaseManager.realm.write {
                    // 借方と貸方で金額が大きい方はどちらか
                    if left > right {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total_Adjusting = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total_Adjusting = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance_Adjusting = left - right // 差額を格納
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    } else if left < right {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total_Adjusting = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total_Adjusting = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance_Adjusting = 0
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance_Adjusting = right - left
                    } else {
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_total_Adjusting = left
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_total_Adjusting = right
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                        dataBaseGeneralLedger.dataBaseCapitalAccount?.credit_balance_Adjusting = 0
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
    // 資本金勘定クラス　勘定別の決算整理後の集計 決算整理前+決算整理事項=決算整理後
    private func calculateAccountTotalAfterAdjustingCapitalAccount() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算振替仕訳　損益勘定振替
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                do {
                    try DataBaseManager.realm.write {
                        // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
                        dataBaseCapitalAccount.debit_total_AfterAdjusting = dataBaseCapitalAccount.debit_total + dataBaseCapitalAccount.debit_total_Adjusting
                        dataBaseCapitalAccount.credit_total_AfterAdjusting = dataBaseCapitalAccount.credit_total + dataBaseCapitalAccount.credit_total_Adjusting
                    }
                } catch {
                    print("エラーが発生しました")
                }
                // 残高額　借方と貸方で金額が大きい方はどちらか
                if dataBaseCapitalAccount.debit_total_AfterAdjusting > dataBaseCapitalAccount.credit_total_AfterAdjusting {
                    do {
                        try DataBaseManager.realm.write {
                            dataBaseCapitalAccount.debit_balance_AfterAdjusting =
                            dataBaseCapitalAccount.debit_total_AfterAdjusting -
                            dataBaseCapitalAccount.credit_total_AfterAdjusting // 差額を格納
                            dataBaseCapitalAccount.credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                    DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                        debitCategory: "資本金勘定",
                        amount: dataBaseCapitalAccount.debit_balance_AfterAdjusting,
                        creditCategory: "残高"
                    )
                } else if dataBaseCapitalAccount.debit_total_AfterAdjusting < dataBaseCapitalAccount.credit_total_AfterAdjusting {
                    do {
                        try DataBaseManager.realm.write {
                            dataBaseCapitalAccount.credit_balance_AfterAdjusting =
                            dataBaseCapitalAccount.credit_total_AfterAdjusting -
                            dataBaseCapitalAccount.debit_total_AfterAdjusting // 差額を格納
                            dataBaseCapitalAccount.debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                    DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                        debitCategory: "残高",
                        amount: dataBaseCapitalAccount.credit_balance_AfterAdjusting,
                        creditCategory: "資本金勘定"
                    )
                } else {
                    do {
                        try DataBaseManager.realm.write {
                            dataBaseCapitalAccount.debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                            dataBaseCapitalAccount.credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    // 決算振替仕訳　残高振替仕訳をする closingBalanceAccount
                    DataBaseManagerPLAccount.shared.addTransferEntryForClosingBalanceAccount(
                        debitCategory: "残高",
                        amount: 0,
                        creditCategory: "資本金勘定"
                    )
                }
            }
        }
    }
    
    // MARK: Delete
    
}
