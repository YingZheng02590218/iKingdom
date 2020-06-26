//
//  DataBaseManagerTB.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerTB {
    
    // 合計残高試算表　合計、残高の合計値　計算
    func culculatAmountOfAllAccount(){
        let dataBaseManager = DataBaseManagerGeneralLedger()
        let objectG = dataBaseManager.getGeneralLedger()
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for r in 0..<3 {
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectG.dataBaseAccounts.count {
                    l += getTotalAmount(account: objectG.dataBaseAccounts[i].accountName, leftOrRight: r) // 累計額に追加
                }
                switch r {
                case 0: // 合計　借方
                    object.compoundTrialBalance?.debit_total_total = l
                    break
                case 1: // 合計　貸方
                    object.compoundTrialBalance?.credit_total_total = l
                    break
                case 2: // 残高　借方
                    object.compoundTrialBalance?.debit_balance_total = l
                    break
                case 3: // 残高　貸方
                    object.compoundTrialBalance?.credit_balance_total = l
                    break
                default:
                    print(l)
                }
            }
        }
    }
    // 仕訳データを追加後に、呼び出される
    // 合計残高試算表　勘定別の合計 計算して結果をデータベースに書き込む
    func setAccountTotal(account_left: String,account_right: String){
        // 勘定別の合計　計算　勘定ごとに保持している合計と残高を再計算する処理
        calculateAccountTotal(account: account_left) // 借方
        calculateAccountTotal(account: account_right) // 貸方
    }
    // 合計残高試算表　勘定別　計算
    func calculateAccountTotal(account: String) {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getAccountAll(account: account)
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            }else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // 勘定の丁数(プライマリーキー)を取得
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        print("number\(number)")
        
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseGeneralLedger.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            // 借方と貸方で金額が大きい方はどちらか
            if left > right {
                objectss[0].dataBaseAccounts[number].debit_total = left
                objectss[0].dataBaseAccounts[number].credit_total = right
                objectss[0].dataBaseAccounts[number].debit_balance = left - right // 差額を格納
                objectss[0].dataBaseAccounts[number].credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
            }else if left < right {
                objectss[0].dataBaseAccounts[number].debit_total = left
                objectss[0].dataBaseAccounts[number].credit_total = right
                objectss[0].dataBaseAccounts[number].debit_balance = 0
                objectss[0].dataBaseAccounts[number].credit_balance = right - left
            }else {
                objectss[0].dataBaseAccounts[number].debit_total = left
                objectss[0].dataBaseAccounts[number].credit_total = right
                objectss[0].dataBaseAccounts[number].debit_balance = 0 // ゼロを入れないと前回値が残る
                objectss[0].dataBaseAccounts[number].credit_balance = 0
            }
        }
        print(objects)
    }
    
    // 合計残高　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64 {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseGeneralLedger.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        // 勘定の丁数(プライマリーキー)を取得 ※総勘定元帳の何行目にあるかを知るため
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        print("number\(number)")
        
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか
//        if objectss[0].dataBaseAccounts[number].debit_total > objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }else if objectss[0].dataBaseAccounts[number].debit_total < objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].credit_total
//        }else {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }
        switch leftOrRight {
        case 0: // 合計　借方
            result = objectss[0].dataBaseAccounts[number].debit_total
            break
        case 1: // 合計　貸方
            result = objectss[0].dataBaseAccounts[number].credit_total
            break
        case 2: // 残高　借方
            result = objectss[0].dataBaseAccounts[number].debit_balance
            break
        case 3: // 残高　貸方
            result = objectss[0].dataBaseAccounts[number].credit_balance
            break
        default:
            print(result)
        }
        
        print(account, objectss[0].dataBaseAccounts[number].debit_total)
        print(account, objectss[0].dataBaseAccounts[number].credit_total)
        
        return result
    }

}
