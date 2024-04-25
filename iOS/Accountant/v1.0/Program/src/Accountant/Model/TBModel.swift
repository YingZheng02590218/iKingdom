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
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount>
    
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64
}

// 合計残高試算表クラス
class TBModel: TBModelInput {
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // MARK: 設定勘定科目
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
        DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: rank0, rank1: rank1)
    }
    
    // MARK: 勘定
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64 {
        var result: Int64 = 0
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if account == Constant.capitalAccountName || account == "資本金勘定" { // TODO: "資本金勘定"はこない
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
            if account == Constant.capitalAccountName || account == "資本金勘定" { // TODO: "資本金勘定"はこない
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
    
    // MARK: 合計残高試算表
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
    // MARK: 勘定
    // 設定　仕訳と決算整理後　勘定クラス　全ての勘定
    /// 実行タイミング
    /// ・仕訳帳画面で再集計したとき
    /// ・開始残高画面で編集モードを終了したとき
    /// ・勘定科目体系を変更したとき（法人　個人事業主）
    /// ・年度を変更したとき
    func setAllAccountTotal() {
        // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
        let dataBaseSettingsTaxonomyAccounts = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 1)
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            // 開始仕訳　残高振替仕訳の逆仕訳をする
            DataBaseManagerAccount.shared.addOpeningJournalEntryFromClosingBalanceAccount(
                account: dataBaseSettingsTaxonomyAccounts[i].category
            )
            // クリア
            clearAccountTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理前）
            calculateAccountTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理）
            calculateAccountTotalAdjusting(account: dataBaseSettingsTaxonomyAccounts[i].category)
            // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
            calculateAccountTotalAfterAdjusting(account: dataBaseSettingsTaxonomyAccounts[i].category)
        }
        // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
        let dataBaseSettingsTaxonomyAccountsBS = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOnBSorPL(BSorPL: 0)
        for i in 0..<dataBaseSettingsTaxonomyAccountsBS.count {
            // 開始仕訳　残高振替仕訳の逆仕訳をする
            DataBaseManagerAccount.shared.addOpeningJournalEntryFromClosingBalanceAccount(
                account: dataBaseSettingsTaxonomyAccountsBS[i].category
            )
            // クリア
            clearAccountTotal(account: dataBaseSettingsTaxonomyAccountsBS[i].category)
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: dataBaseSettingsTaxonomyAccountsBS[i].category)
            // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理）
            calculateAccountTotalAdjusting(account: dataBaseSettingsTaxonomyAccountsBS[i].category)
            // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
            calculateAccountTotalAfterAdjusting(account: dataBaseSettingsTaxonomyAccountsBS[i].category)
        }
        // 資本振替仕訳、資本金勘定の残高振替仕訳 を行う
        transferJournals()
        // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
        for i in 0..<dataBaseSettingsTaxonomyAccounts.count {
            // 月次損益振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
            calculateAccountMonthlyTotal(account: dataBaseSettingsTaxonomyAccounts[i].category)
        }
        // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
        for i in 0..<dataBaseSettingsTaxonomyAccountsBS.count {
            // 月次損益振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
            calculateAccountMonthlyTotal(account: dataBaseSettingsTaxonomyAccountsBS[i].category)
        }
        // 月次資本振替仕訳、資本金勘定の月次残高振替仕訳 を行う
        monthlyTransferJournals()
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            // 設定表示科目　初期化 毎回行うと時間がかかる
            DataBaseManagerTaxonomy.shared.initializeTaxonomy()
        }
    }
    
    // 集計処理
    // 設定　仕訳と決算整理後　勘定クラス　個別の勘定別
    /// 処理内容
    /// ・開始仕訳をする
    /// ・勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理前）
    /// ・勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
    /// ・月次損益振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
    /// ・資本振替仕訳、資本金勘定の残高振替仕訳 を行う
    /// 実行タイミング
    /// ・仕訳　（追加　更新　削除）
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
        // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理前）
        calculateAccountTotal(account: accountLeft ) // 借方
        calculateAccountTotal(account: accountRight) // 貸方
        // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
        calculateAccountTotalAfterAdjusting(account: accountLeft )
        calculateAccountTotalAfterAdjusting(account: accountRight)
        // 資本振替仕訳、資本金勘定の残高振替仕訳 を行う
        transferJournals()
        // 月次損益振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
        calculateAccountMonthlyTotal(account: accountLeft)
        calculateAccountMonthlyTotal(account: accountRight)
        // 月次資本振替仕訳、資本金勘定の月次残高振替仕訳 を行う
        monthlyTransferJournals()
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
    }
    // 設定　決算整理仕訳と決算整理後　勘定クラス　個別の勘定別　決算整理仕訳データを追加後に、呼び出される
    /// 実行タイミング
    /// ・決算整理仕訳　（追加　更新　削除）
    func setAccountTotalAdjusting(accountLeft: String, accountRight: String) {
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理）
        calculateAccountTotalAdjusting(account: accountLeft) // 借方
        calculateAccountTotalAdjusting(account: accountRight) // 貸方
        // 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
        calculateAccountTotalAfterAdjusting(account: accountLeft)
        calculateAccountTotalAfterAdjusting(account: accountRight)
        // 資本振替仕訳、資本金勘定の残高振替仕訳 を行う
        transferJournals()
        // 月次損益振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
        calculateAccountMonthlyTotal(account: accountLeft)
        calculateAccountMonthlyTotal(account: accountRight)
        // 月次資本振替仕訳、資本金勘定の月次残高振替仕訳 を行う
        monthlyTransferJournals()
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
    }
    
    // MARK: - 帳簿締切
    // クリア
    // 計算 決算整理前
    // 計算 決算整理仕訳
    // 計算 決算整理後
    
    // 資本振替仕訳、資本金勘定の残高振替仕訳 を行う
    func transferJournals() {
        // 損益勘定で資本振替仕訳
        clearAccountTotalPLAccount() // クリア
        calculateAccountTotalPLAccount() // 集計　損益振替
        calculateAccountTotalAdjustingPLAccount() // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjustingPLAccount() // 集計　決算整理後
        // 資本振替仕訳後に、繰越利益勘定の決算整理前と決算整理仕訳、決算整理後の合計額と残高額の集計は必要ないのか？
        
        // 資本金勘定で残高振替仕訳
        clearAccountTotalCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalAdjustingCapitalAccount() // 集計 資本金勘定
        calculateAccountTotalAfterAdjustingCapitalAccount() // 集計 資本金勘定
    }
    
    // 月次資本振替仕訳、資本金勘定の月次残高振替仕訳 を行う
    func monthlyTransferJournals() {
        // 月次資本振替仕訳 損益勘定を使用せずに月次資本振替仕訳を行う 13ヶ月分
        calculateMonthlyPLAccountAndAddTransferEntryToNetWorth()
        // 月次残高振替仕訳 資本金勘定を使用せずに月次残高振替仕訳を行う 13ヶ月分
        calculateMonthlyAccountTotalAfterAdjustingCapitalAccount()
    }
    
    // MARK: 勘定　損益振替仕訳、残高振替仕訳
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
    
    /// 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理前）
    /// 処理内容
    /// ・開始仕訳と仕訳を集計して勘定の借方合計と貸方合計、借方残高と貸方残高を算出する
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
    
    /// 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理）
    /// 処理内容
    /// ・決算整理仕訳を集計して勘定の借方合計と貸方合計、借方残高と貸方残高を算出する
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
    
    /// 勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする
    /// 処理内容
    /// ・開始仕訳と仕訳、決算整理仕訳を集計して勘定の借方合計と貸方合計、借方残高と貸方残高を算出する
    ///     ・合計額 開始仕訳、仕訳＋決算整理仕訳＝決算整理後
    /// ・決算振替仕訳
    ///     ・損益振替仕訳をする
    ///     ・残高振替仕訳をする
    private func calculateAccountTotalAfterAdjusting(account: String) {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 決算振替仕訳　損益勘定振替
        if let dataBaseGeneralLedger = dataBaseAccountingBooks.dataBaseGeneralLedger {
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
    
    // MARK: 損益勘定　資本振替仕訳
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
    
    // MARK: 資本金勘定　（繰越利益、元入金）　残高振替仕訳
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
        // 法人/個人フラグ
        let account = Constant.capitalAccountName
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        // 開始仕訳 勘定別に取得
        let dataBaseOpeningJournalEntry = dataBaseManagerAccount.getOpeningJournalEntryInAccount(account: account)
        if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
            // 勘定が借方と貸方のどちらか
            if account == dataBaseOpeningJournalEntry.debit_category || dataBaseOpeningJournalEntry.debit_category == "資本金勘定" { // 借方 // TODO: "資本金勘定"はこない
                left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
            } else if account == dataBaseOpeningJournalEntry.credit_category || dataBaseOpeningJournalEntry.credit_category == "資本金勘定" { // 貸方 // TODO: "資本金勘定"はこない
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
        // 法人/個人フラグ
        let account = Constant.capitalAccountName
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
    
    // MARK: 月次損益振替仕訳、月次残高振替仕訳、月次資本振替仕訳、資本金勘定の月次残高振替仕訳
    
    /// 月次損益振替仕訳、月次残高振替仕訳　勘定の借方合計と貸方合計、借方残高と貸方残高を算出する（決算整理後）そして、決算振替仕訳をする　13ヶ月分
    /// 処理内容
    /// ・今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
    /// ・今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付（年月）が重複している場合、削除する
    /// ・仕訳を集計して、勘定の借方合計と貸方合計、借方残高と貸方残高を算出する
    ///     ・開始仕訳
    ///     ・仕訳
    ///     ・決算整理仕訳
    ///     ・期首の月以外は前月の　月次損益振替仕訳、月次残高振替仕訳　の金額を加味する
    /// ・決算振替仕訳
    ///     ・損益振替仕訳をする
    ///     ・残高振替仕訳をする
    private func calculateAccountMonthlyTotal(account: String) {
        // 削除　月次損益振替仕訳、月次残高振替仕訳 今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
        DataBaseManagerMonthlyTransferEntry.shared.deleteMonthlyTransferEntryInAccountInFiscalYear(account: account)
        // 削除　月次損益振替仕訳、月次残高振替仕訳 今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付（年月）が重複している場合、削除する
        DataBaseManagerMonthlyTransferEntry.shared.deleteDuplicatedMonthlyTransferEntryInAccountInFiscalYear(account: account)
        
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        // 開始仕訳 勘定別に取得
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
            // 損益計算書に関する勘定科目のみに絞る
            if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                // 月次損益推移表では、前月の金額を加味しない
            } else {
                if index > 0 {
                    // 前月の　月次損益振替仕訳、月次残高振替仕訳　の金額を加味する
                    // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                    if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                        account: account,
                        yearMonth: "\(lastDays[index - 1].year)" + "/" + "\(String(format: "%02d", lastDays[index - 1].month))" // BEGINSWITH 前方一致
                    ) {
                        // 勘定が借方と貸方のどちらか
                        print(dataBaseMonthlyTransferEntry)
                        if account == "\(dataBaseMonthlyTransferEntry.debit_category)" { // 借方
                            // 借方勘定　＊貸方勘定を振替える
                            right += dataBaseMonthlyTransferEntry.balance_right // 累計額に追加
                        } else if account == "\(dataBaseMonthlyTransferEntry.credit_category)" { // 貸方
                            // 貸方勘定　＊借方勘定を振替える
                            left += dataBaseMonthlyTransferEntry.balance_left // 累計額に追加
                        }
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
            // 決算月は、次期繰越があるので、不要 → やっぱり必要
            // 決算整理仕訳
            let dataBaseAdjustingEntries = dataBaseManagerAccount.getAdjustingEntryInAccountInMonth(
                account: account,
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))"
            )
            for i in 0..<dataBaseAdjustingEntries.count { // 勘定内のすべての仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(dataBaseAdjustingEntries[i].debit_category)" { // 借方
                    left += dataBaseAdjustingEntries[i].debit_amount // 累計額に追加
                } else if account == "\(dataBaseAdjustingEntries[i].credit_category)" { // 貸方
                    right += dataBaseAdjustingEntries[i].credit_amount // 累計額に追加
                }
            }
            // 損益計算書に関する勘定科目のみに絞る
            if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                // 月次損益振替は損益科目のみ
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    // 月次損益振替仕訳
                    DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingProfitAndLossAccount(
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                        debitCategory: account,
                        creditCategory: "損益",
                        debitAmount: left,
                        creditAmount: right,
                        balanceLeft: left - right, // 差額を格納
                        balanceRight: 0
                    )
                } else if left < right {
                    // 月次損益振替仕訳
                    DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingProfitAndLossAccount(
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                        debitCategory: "損益",
                        creditCategory: account,
                        debitAmount: left,
                        creditAmount: right,
                        balanceLeft: 0,
                        balanceRight: right - left
                    )
                } else {
                    // 月次損益振替仕訳
                    DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingProfitAndLossAccount(
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                        debitCategory: account,
                        creditCategory: "損益",
                        debitAmount: left,
                        creditAmount: right,
                        balanceLeft: 0,
                        balanceRight: 0
                    )
                }
            } else {
                // 月次残高振替は貸借科目のみ
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
            }
            // 月別に合計を計算する
            left = 0
            right = 0
        }
    }
    
    // 月次資本振替仕訳 損益勘定を使用せずに月次資本振替仕訳を行う 13ヶ月分
    private func calculateMonthlyPLAccountAndAddTransferEntryToNetWorth() {
        // 削除　月次資本振替仕訳 今年度の月次資本振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
        DataBaseManagerMonthlyPLAccount.shared.deleteMonthlyTransferEntryInAccountInFiscalYear()
        // 削除　月次資本振替仕訳 今年度の勘定別の月次資本振替仕訳のうち、日付（年月）が重複している場合、削除する
        DataBaseManagerMonthlyPLAccount.shared.deleteDuplicatedMonthlyTransferEntryInAccountInFiscalYear()
        
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        
        for index in 0..<lastDays.count {
            // 取得　月次損益振替仕訳 今年度の勘定別で日付の先方一致 複数
            if let dataBaseMonthlyTransferEntries = DataBaseManagerMonthlyTransferEntry.shared.getAllMonthlyTransferEntryInPLAccountBeginsWith(
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
            ) {
                for i in 0..<dataBaseMonthlyTransferEntries.count { // 勘定内のすべての仕訳データ
                    // 勘定が借方と貸方のどちらか
                    if "損益" == "\(dataBaseMonthlyTransferEntries[i].debit_category)" { // 借方
                        left += dataBaseMonthlyTransferEntries[i].debit_amount // 累計額に追加
                    } else if "損益" == "\(dataBaseMonthlyTransferEntries[i].credit_category)" { // 貸方
                        right += dataBaseMonthlyTransferEntries[i].credit_amount // 累計額に追加
                    }
                }
                // 決算振替仕訳　損益勘定振替
                
                // 残高額　借方と貸方で金額が大きい方はどちらか
                if left > right {
                    // 決算振替仕訳　損益勘定の締切り
                    DataBaseManagerMonthlyPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "損益",
                        amount: left - right, // 差額を格納
                        creditCategory: "資本金勘定", // FIXME: 資本金勘定
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))" // 月次決算日
                    ) // 仕訳画面で繰越利益を選択して仕訳入力した場合、実行される
                } else if left < right {
                    // 決算振替仕訳　損益勘定の締切り
                    DataBaseManagerMonthlyPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "資本金勘定", // FIXME: 資本金勘定
                        amount: right - left,
                        creditCategory: "損益",
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))" // 月次決算日
                    )
                } else {
                    // 決算振替仕訳　損益勘定の締切り 記述漏れ　2020/11/05
                    DataBaseManagerMonthlyPLAccount.shared.addTransferEntryToNetWorth(
                        debitCategory: "資本金勘定", // FIXME: 資本金勘定
                        amount: 0,
                        creditCategory: "損益",
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))" // 月次決算日
                    )
                }
                // 月別に合計を計算する
                left = 0
                right = 0
            }
        }
    }
    
    /// 月次残高振替仕訳 資本金勘定を使用せずに月次残高振替仕訳を行う 13ヶ月分
    /// 処理内容
    /// ・今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
    /// ・今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付（年月）が重複している場合、削除する
    /// ・仕訳を集計して、勘定の借方合計と貸方合計、借方残高と貸方残高を算出する
    ///     ・開始仕訳
    ///     ・仕訳
    ///     ・決算整理仕訳
    ///     ・資本振替仕訳
    ///     ・期首の月以外は前月の　月次損益振替仕訳、月次残高振替仕訳　の金額を加味する
    /// ・決算振替仕訳
    ///     ・残高振替仕訳をする
    private func calculateMonthlyAccountTotalAfterAdjustingCapitalAccount() {
        // 削除　月次損益振替仕訳、月次残高振替仕訳 今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付が会計期間の範囲外の場合、削除する
        DataBaseManagerMonthlyTransferEntry.shared.deleteMonthlyTransferEntryInAccountInFiscalYear(account: "資本金勘定")
        // 削除　月次損益振替仕訳、月次残高振替仕訳 今年度の勘定別の月次損益振替仕訳、月次残高振替仕訳のうち、日付（年月）が重複している場合、削除する
        DataBaseManagerMonthlyTransferEntry.shared.deleteDuplicatedMonthlyTransferEntryInAccountInFiscalYear(account: "資本金勘定")
        
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        // 法人/個人フラグ
        let account = Constant.capitalAccountName
        
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        // 開始仕訳 勘定別に取得
        let dataBaseOpeningJournalEntry = dataBaseManagerAccount.getOpeningJournalEntryInAccount(
            account: account
        )
        if let dataBaseOpeningJournalEntry = dataBaseOpeningJournalEntry {
            // 勘定が借方と貸方のどちらか
            print(dataBaseOpeningJournalEntry)
            if account == dataBaseOpeningJournalEntry.debit_category || dataBaseOpeningJournalEntry.debit_category == "資本金勘定" { // 借方
                left += dataBaseOpeningJournalEntry.debit_amount // 累計額に追加
            } else if account == dataBaseOpeningJournalEntry.credit_category || dataBaseOpeningJournalEntry.credit_category == "資本金勘定" { // 貸方
                right += dataBaseOpeningJournalEntry.credit_amount // 累計額に追加
            }
        }
        
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        
        for index in 0..<lastDays.count {
            if index > 0 {
                // 前月の　月次損益振替仕訳、月次残高振替仕訳　の金額を加味する
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: account,
                    yearMonth: "\(lastDays[index - 1].year)" + "/" + "\(String(format: "%02d", lastDays[index - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 勘定が借方と貸方のどちらか
                    print(dataBaseMonthlyTransferEntry)
                    if account == dataBaseMonthlyTransferEntry.debit_category || dataBaseMonthlyTransferEntry.debit_category == "資本金勘定" { // 借方
                        // 借方勘定　＊貸方勘定を振替える
                        right += dataBaseMonthlyTransferEntry.balance_right // 累計額に追加
                    } else if account == dataBaseMonthlyTransferEntry.credit_category || dataBaseMonthlyTransferEntry.credit_category == "資本金勘定" { // 貸方
                        // 貸方勘定　＊借方勘定を振替える
                        left += dataBaseMonthlyTransferEntry.balance_left // 累計額に追加
                    }
                }
                
                // 前月の　月次資本振替仕訳　の金額を加味する 差し引く
                // 取得 月次資本振替仕訳 資本金勘定から月別に取得
                if let dataBaseCapitalTransferJournalEntry = DataBaseManagerMonthlyPLAccount.shared.getCapitalTransferJournalEntryInAccount(
                    yearMonth: "\(lastDays[index - 1].year)" + "/" + "\(String(format: "%02d", lastDays[index - 1].month))"
                ) {
                    // 勘定が借方と貸方のどちらか
                    print(dataBaseCapitalTransferJournalEntry)
                    if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.debit_category)" { // 借方
                        // 前月の　月次資本振替仕訳　の金額を 差し引く
                        left -= dataBaseCapitalTransferJournalEntry.debit_amount // 累計額に追加
                    } else if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.credit_category)" { // 貸方
                        // 前月の　月次資本振替仕訳　の金額を 差し引く
                        right -= dataBaseCapitalTransferJournalEntry.credit_amount // 累計額に追加
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
            // 決算月は、次期繰越があるので、不要 → やっぱり必要
            // 決算整理仕訳
            let dataBaseAdjustingEntries = dataBaseManagerAccount.getAdjustingEntryInAccountInMonth(
                account: account,
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))"
            )
            for i in 0..<dataBaseAdjustingEntries.count { // 勘定内のすべての仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(dataBaseAdjustingEntries[i].debit_category)" { // 借方
                    left += dataBaseAdjustingEntries[i].debit_amount // 累計額に追加
                } else if account == "\(dataBaseAdjustingEntries[i].credit_category)" { // 貸方
                    right += dataBaseAdjustingEntries[i].credit_amount // 累計額に追加
                }
            }
            // 月次資本振替仕訳　決算整理の処理と同時に資本振替仕訳も処理する
            // 取得 月次資本振替仕訳 資本金勘定から月別に取得
            if let dataBaseCapitalTransferJournalEntry = DataBaseManagerMonthlyPLAccount.shared.getCapitalTransferJournalEntryInAccount(
                yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))"
            ) {
                // 勘定が借方と貸方のどちらか
                if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.debit_category)" { // 借方
                    left += dataBaseCapitalTransferJournalEntry.debit_amount // 累計額に追加
                } else if "資本金勘定" == "\(dataBaseCapitalTransferJournalEntry.credit_category)" { // 貸方
                    right += dataBaseCapitalTransferJournalEntry.credit_amount // 累計額に追加
                }
            }
            // 損益計算書に関する勘定科目のみに絞る
            if DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                // 月次損益振替は損益科目のみ
            } else {
                // 月次残高振替は貸借科目のみ
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    // 月次残高振替仕訳
                    DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingBalanceAccount(
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                        debitCategory: "資本金勘定",
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
                        creditCategory: "資本金勘定",
                        debitAmount: left,
                        creditAmount: right,
                        balanceLeft: 0,
                        balanceRight: right - left
                    )
                } else {
                    // 月次残高振替仕訳
                    DataBaseManagerMonthlyTransferEntry.shared.addMonthlyTransferEntryForClosingBalanceAccount(
                        date: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" + "\(String(format: "%02d", lastDays[index].day))",
                        debitCategory: "資本金勘定",
                        creditCategory: "残高",
                        debitAmount: left,
                        creditAmount: right,
                        balanceLeft: 0,
                        balanceRight: 0
                    )
                }
            }
            // 月別に合計を計算する
            left = 0
            right = 0
        }
    }
    
    // MARK: Delete
    
}
