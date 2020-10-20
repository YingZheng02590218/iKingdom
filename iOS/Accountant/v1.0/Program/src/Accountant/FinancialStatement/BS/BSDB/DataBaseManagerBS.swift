//
//  DataBaseManagerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 貸借対照表クラス
class DataBaseManagerBS {
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS(){
        //0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)//資産
        setTotalBig5(big5: 1)//負債
        setTotalBig5(big5: 2)//純資産
        setTotalRank0(big5: 0, rank0: 0)//流動資産
        setTotalRank0(big5: 0, rank0: 1)//固定資産
        setTotalRank0(big5: 0, rank0: 2)//繰延資産
        setTotalRank0(big5: 1, rank0: 3)//流動負債
        setTotalRank0(big5: 1, rank0: 4)//固定負債
        setTotalRank0(big5: 2, rank0: 5) //株主資本合計
        setTotalRank0(big5: 2, rank0: 12)//その他の包括利益累計額
    }
    // 計算　五大区分
    func setTotalBig5(big5: Int) {
        var TotalAmountOfBig5:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big5, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfBig5 -= totalAmount
            }else {
                TotalAmountOfBig5 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseBalanceSheet.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        try! realm.write {
            switch big5 {
            case 0: //資産
                objectss[0].Asset_total = TotalAmountOfBig5
                break
            case 1: //負債
                objectss[0].Liability_total = TotalAmountOfBig5
                break
            case 2: //純資産
                objectss[0].Equity_total = TotalAmountOfBig5
                break
            default:
                print("bigCategoryTotalAmount", TotalAmountOfBig5)
                break
            }
        }
    }
    // 取得　設定勘定科目　五大区分
    func getAccountsInBig5(big5: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch big5 {
        case 0: // 資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)'") // 流動資産, 固定資産, 繰延資産
            break
        case 1: // 負債
            objects = objects.filter("Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)'") // 流動負債, 固定負債
            break
        case 2: // 純資産
            objects = objects.filter("Rank0 LIKE '\(5)' OR Rank0 LIKE '\(12)'") // 資本, 評価・換算差額等
            break
        default:
            print("")
        }
        return objects
    }
    // 取得　五大区分
    func getTotalBig5(big5: Int) -> String {
//        // データベースに書き込み　todo
//        setBigCategoryTotal(big_category: big_category)
//        // 設定画面の勘定科目一覧にある勘定を取得する
//        let objects = getObjectsInBigCategory(big_category: big_category)
//        // オブジェクトを作成 勘定
//        for i in 0..<objects.count{
//            calculateAccountTotal(account: objects[i].category)
//            let totalAmount = getTotalAmount(account: objects[i].category)
//            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: objects[i].category)
//            if totalDebitOrCredit == "-"{
//                bigCategoryTotalAmount -= totalAmount
//            }else {
//                bigCategoryTotalAmount += totalAmount
//            }
//        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseBalanceSheet.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        var result:Int64 = 0            // 累計額
        switch big5 {
        case 0: //資産
            result = objectss[0].Asset_total
            break
        case 1: //負債
            result = objectss[0].Liability_total
            break
        case 2: //純資産
            result = objectss[0].Equity_total
            break
        case 3: //負債純資産
            result = objectss[0].Liability_total+objectss[0].Equity_total
            break
        default:
            print(result)
            break
        }
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return addComma(string: result.description)
    }
    // 計算　階層0 大区分
    func setTotalRank0(big5: Int, rank0: Int) {
        var TotalAmountOfRank0:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big5, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank0 -= totalAmount
            }else {
                TotalAmountOfRank0 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseBalanceSheet.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        try! realm.write {
            switch rank0 {
            case 0: //流動資産
                objectss[0].CurrentAssets_total = TotalAmountOfRank0
                break
            case 1: //固定資産
                objectss[0].FixedAssets_total = TotalAmountOfRank0
                break
            case 2: //繰延資産
                objectss[0].DeferredAssets_total = TotalAmountOfRank0
                break
            case 3: //流動負債
                objectss[0].CurrentLiabilities_total = TotalAmountOfRank0
                break
            case 4: //固定負債
                objectss[0].FixedLiabilities_total = TotalAmountOfRank0
                break
            case 5: //株主資本
                objectss[0].CapitalStock_total = TotalAmountOfRank0
                break
            case 12: //その他の包括利益累計額 評価・換算差額等のこと？　　→  その通り2020/09/28
                objectss[0].OtherCapitalSurpluses_total = TotalAmountOfRank0
                break
            default:
                print(TotalAmountOfRank0)
                break
            }
        }
    }
    // 取得　設定勘定科目　大区分
    func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 取得　階層0 大区分
    func getTotalRank0(big5: Int, rank0: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseBalanceSheet.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        var result:Int64 = 0            // 累計額
        switch rank0 {
        case 0: //流動資産
            result = objectss[0].CurrentAssets_total
            break
        case 1: //固定資産
            result = objectss[0].FixedAssets_total
            break
        case 2: //繰延資産
            result = objectss[0].DeferredAssets_total
            break
        case 3: //流動負債
            result = objectss[0].CurrentLiabilities_total
            break
        case 4: //固定負債
            result = objectss[0].FixedLiabilities_total
            break
        case 5: //株主資本
            result = objectss[0].CapitalStock_total
            break
        case 12: //その他の包括利益累計額 評価・換算差額等のこと
            result = objectss[0].OtherCapitalSurpluses_total
            break
        default:
            print(result)
            break
        }
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // 三角形はマイナスの意味
        if result < 0 { //0の場合は、空白を表示する
            let amauntFix = result * -1
            return "△ \(addComma(string: amauntFix.description))"
        }else {
            return addComma(string: result.description)
        }
    }
    // 取得　設定勘定科目　中区分
//    func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
//        let realm = try! Realm()
//        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
//        objects = objects.sorted(byKeyPath: "number", ascending: true)
//        objects = objects.filter("Rank1 LIKE '\(rank1)'")
//        return objects
//    }
    // 合計残高　勘定別の合計と借又貸 取得
    func getAccountTotal(big_category: Int, account: String) -> String {
        let totalAmount = getTotalAmount(account: account)  // 合計を取得
        let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: account) // 借又貸を取得

        return "\(totalDebitOrCredit) \(setComma(amount: totalAmount))"
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        var objectss = realm.objects(DataBaseGeneralLedger.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        // 勘定の丁数(プライマリーキー)を取得
        let dataBaseManagerAccount = DataBaseManagerAccount()
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        
        // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
        var result:Int64 = 0
        if objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting > objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting
        }else if objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting < objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting
        }else {
            result = objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting
        }
        return result
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        var objectss = realm.objects(DataBaseGeneralLedger.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        // 勘定の丁数(プライマリーキー)を取得
        let dataBaseManagerAccount = DataBaseManagerAccount()
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        
        var DebitOrCredit:String = "" // 借又貸
        // 借方と貸方で金額が大きい方はどちらか
        if objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting > objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting {
            DebitOrCredit = "借"
        }else if objectss[0].dataBaseAccounts[number].debit_balance_AfterAdjusting < objectss[0].dataBaseAccounts[number].credit_balance_AfterAdjusting {
            DebitOrCredit = "貸"
        }else {
            DebitOrCredit = "-"
        }
        var PositiveOrNegative:String = "" // 借又貸
        switch big_category {
        case 0,3:
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        default: // 1,2,4（負債、純資産、収益）
            switch DebitOrCredit {
            case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        }
        return PositiveOrNegative
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // 三角形はマイナスの意味
        if amount < 0 { //0の場合は、空白を表示する
            let amauntFix = amount * -1
            return "△ \(addComma(string: amauntFix.description))"
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
