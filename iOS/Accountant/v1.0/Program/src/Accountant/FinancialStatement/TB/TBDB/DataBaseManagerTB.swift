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
    
    // 合計残高試算表　計算　合計、残高の合計値
    func calculateAmountOfAllAccount(){
        let dataBaseManager = DataBaseManagerGeneralLedger()
        let objectG = dataBaseManager.getGeneralLedger()
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for r in 0..<4 { //注意：3になっていた。誤り
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
    // 合計残高試算表　計算　全ての勘定　合計、残高
    func setAllAccountTotal(){
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory()
        let objects = databaseManagerSettings.getAllSettingsCategory()
        for i in 0..<objects.count{
            // 勘定別の合計　計算　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: objects[i].category)
            // 勘定別の決算整理後の合計　計算
            calculateAccountTotalAfterAdjusting(account: objects[i].category)
        }
    }
    // 仕訳データを追加後に、呼び出される
    // 合計残高試算表　勘定別の合計 計算して結果をデータベースに書き込む
    func setAccountTotal(account_left: String,account_right: String){
        // 勘定別の合計　計算　勘定ごとに保持している合計と残高を再計算する処理
        calculateAccountTotal(account: account_left) // 借方
        calculateAccountTotal(account: account_right) // 貸方
        // 勘定別の決算整理後の合計　計算
        calculateAccountTotalAfterAdjusting(account: account_left)
        calculateAccountTotalAfterAdjusting(account: account_right)
    }
    // 合計残高試算表　勘定別　計算
    func calculateAccountTotal(account: String) {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getAllAccount(account: account)
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
    }
    // 仕訳データを追加後に、呼び出される
    // 合計残高試算表　勘定別の合計 計算して結果をデータベースに書き込む
    func setAccountTotalAdjusting(account_left: String,account_right: String){
        // 勘定別の合計　計算　勘定ごとに保持している合計と残高を再計算する処理
        calculateAccountTotalAdjusting(account: account_left) // 借方
        calculateAccountTotalAdjusting(account: account_right) // 貸方
        // 勘定別の決算整理後の合計　計算
        calculateAccountTotalAfterAdjusting(account: account_left)
        calculateAccountTotalAfterAdjusting(account: account_right)
    }
    // 勘定別の決算整理後の合計　計算 決算整理前+決算整理事項=決算整理後
    private func calculateAccountTotalAfterAdjusting(account: String) {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // 勘定の丁数(プライマリーキー)を取得
        let dataBaseManagerAccount = DataBaseManagerAccount()
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseGeneralLedger.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
            objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting = objectss[0].dataBaseAccounts[number].debit_total + objectss[0].dataBaseAccounts[number].debit_total_Adjusting
            objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting = objectss[0].dataBaseAccounts[number].credit_total + objectss[0].dataBaseAccounts[number].credit_total_Adjusting
            // 残高額　借方と貸方で金額が大きい方はどちらか
            if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting > objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
                objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting =
                    objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting -
                    objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting // 差額を格納
                objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
            }else if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting < objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
                objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting =
                    objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting -
                    objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting // 差額を格納
                objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
            }else {
                objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
            }
        }
    }
    // 合計残高試算表　勘定別　計算
    func calculateAccountTotalAdjusting(account: String) {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getAllAccountAdjusting(account: account)
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
                objectss[0].dataBaseAccounts[number].debit_total_Adjusting = left
                objectss[0].dataBaseAccounts[number].credit_total_Adjusting = right
                objectss[0].dataBaseAccounts[number].debit_balance_Adjusting = left - right // 差額を格納
                objectss[0].dataBaseAccounts[number].credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
            }else if left < right {
                objectss[0].dataBaseAccounts[number].debit_total_Adjusting = left
                objectss[0].dataBaseAccounts[number].credit_total_Adjusting = right
                objectss[0].dataBaseAccounts[number].debit_balance_Adjusting = 0
                objectss[0].dataBaseAccounts[number].credit_balance_Adjusting = right - left
            }else {
                objectss[0].dataBaseAccounts[number].debit_total_Adjusting = left
                objectss[0].dataBaseAccounts[number].credit_total_Adjusting = right
                objectss[0].dataBaseAccounts[number].debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                objectss[0].dataBaseAccounts[number].credit_balance_Adjusting = 0
            }
        }
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
        return result
    }
    // 合計残高　勘定別決算仕訳の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> Int64 {
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
        
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか
        switch leftOrRight {
        case 0: // 合計　借方
            result = objectss[0].dataBaseAccounts[number].debit_total_Adjusting
            break
        case 1: // 合計　貸方
            result = objectss[0].dataBaseAccounts[number].credit_total_Adjusting
            break
        case 2: // 残高　借方
            result = objectss[0].dataBaseAccounts[number].debit_balance_Adjusting
            break
        case 3: // 残高　貸方
            result = objectss[0].dataBaseAccounts[number].credit_balance_Adjusting
            break
        default:
            print(result)
        }
        return result
    }
    // 合計残高　勘定別決算整理後の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64 {
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
        
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか
        switch leftOrRight {
        case 0: // 合計　借方
            result = objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting
            break
        case 1: // 合計　貸方
            result = objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting
            break
        case 2: // 残高　借方
            result = objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting
            break
        case 3: // 残高　貸方
            result = objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting
            break
        default:
            print(result)
        }
        return result
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        if addComma(string: amount.description) == "0" { //0の場合は、空白を表示する
            return ""
        }else {
            return addComma(string: amount.description)
        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    //カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String{
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
}
