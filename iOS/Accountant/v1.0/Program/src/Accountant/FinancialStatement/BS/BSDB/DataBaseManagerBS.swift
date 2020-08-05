//
//  DataBaseManagerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerBS {
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS(){
        // データベースに書き込み　//0:資産 1:負債 2:純資産
        setMiddleCategoryTotal(big_category: 0, mid_category: 0)//流動資産
        setMiddleCategoryTotal(big_category: 0, mid_category: 1)//固定資産
        setMiddleCategoryTotal(big_category: 0, mid_category: 12)//繰延資産12
        setBigCategoryTotal(big_category: 0)
        setMiddleCategoryTotal(big_category: 1, mid_category: 2)
        setMiddleCategoryTotal(big_category: 1, mid_category: 3)
        setBigCategoryTotal(big_category: 1)
        setMiddleCategoryTotal(big_category: 2, mid_category: 4) //株主資本合計
        setMiddleCategoryTotal(big_category: 2, mid_category: 12)//その他の包括利益累計額
        setBigCategoryTotal(big_category: 2)
    }
    // 中分類　計算
    func setMiddleCategoryTotal(big_category: Int, mid_category: Int) {
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjectsInMiddleCategory(mid_category: mid_category)
        var middleCategoryTotalAmount:Int64 = 0            // 累計額
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
//            calculateAccountTotal(account: objects[i].category)
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                middleCategoryTotalAmount -= totalAmount
            }else {
                middleCategoryTotalAmount += totalAmount
            }
        }
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseBalanceSheet.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            switch mid_category {
            case 0: //流動資産
                objectss[0].CurrentAssets_total = middleCategoryTotalAmount
                break
            case 1: //固定資産
                objectss[0].FixedAssets_total = middleCategoryTotalAmount
                break
            case 12: //繰延資産
                objectss[0].DeferredAssets_total = middleCategoryTotalAmount
                break
            case 2: //流動負債
                objectss[0].CurrentLiabilities_total = middleCategoryTotalAmount
                break
            case 3: //固定負債
                objectss[0].FixedLiabilities_total = middleCategoryTotalAmount
                break
            case 4: //株主資本
                objectss[0].CapitalStock_total = middleCategoryTotalAmount
                break
            case 5: //その他の包括利益累計額
                objectss[0].OtherCapitalSurpluses_total = middleCategoryTotalAmount
                break
            default:
                print(middleCategoryTotalAmount)
            }
        }
    }
    // 大分類　計算
    func setBigCategoryTotal(big_category: Int) {
        var bigCategoryTotalAmount:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjectsInBigCategory(big_category: big_category)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
//            calculateAccountTotal(account: objects[i].category)
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                bigCategoryTotalAmount -= totalAmount
            }else {
                bigCategoryTotalAmount += totalAmount
            }
        }
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseBalanceSheet.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            switch big_category {
            case 0: //資産
                objectss[0].Asset_total = bigCategoryTotalAmount
                break
            case 1: //負債
                objectss[0].Liability_total = bigCategoryTotalAmount
                break
            case 2: //純資産
                objectss[0].Equity_total = bigCategoryTotalAmount
                break
            default:
                print("bigCategoryTotalAmount", bigCategoryTotalAmount)
            }
        }
    }
    // 中分類　設定画面の勘定科目一覧にある勘定を取得する
    func getObjectsInMiddleCategory(mid_category: Int) -> Results<DataBaseSettingsCategory> {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("mid_category == \(mid_category)")
        return objects
    }
    // 大分類　設定画面の勘定科目一覧にある勘定を取得する
    func getObjectsInBigCategory(big_category: Int) -> Results<DataBaseSettingsCategory> {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("big_category == \(big_category)")
        return objects
    }
    // 合計残高　勘定別の合計と借又貸 取得
    func getAccountTotal(big_category: Int, account: String) -> String {
        let totalAmount = getTotalAmount(account: account)  // 合計を取得
        let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: account) // 借又貸を取得

        return "\(totalDebitOrCredit) \(setComma(amount: totalAmount))"
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return addComma(string: amount.description)
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String) ->Int64 {
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
        
        // 勘定の丁数(プライマリーキー)を取得
        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
        number -= 1 // 0スタートに補正
        
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
        if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting > objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting
        }else if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting < objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting
        }else {
            result = objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting
        }
        return result
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, account: String) ->String {
        let dataBaseManagerAccount = DataBaseManagerAccount()
//        let objects = dataBaseManagerAccount.getAccountAll(account: account)
//        let objects_local: Results<DataBaseJournalEntry>! //注意：ローカル変数を用意しないとこのクラスのフィールド変数のobjectsにフィルターをかけてしまう。
//        objects_local = objects
//        var DebitOrCredit:String = "" // 借又貸
//        for r in 0..<objects_local.count {
//            if objects_local[r].balance_left > objects_local[r].balance_right {
//                DebitOrCredit = "借"
//            }else if objects_local[r].balance_left < objects_local[r].balance_right {
//                DebitOrCredit = "貸"
//            }else {
//                DebitOrCredit = "-"
//            }
//        }
//        var PositiveOrNegative:String = "" // 借又貸
//        switch big_category {
//        case 0,3:
//            switch DebitOrCredit {
//            case "貸":
//                PositiveOrNegative = "-"
//            default:
//                PositiveOrNegative = ""
//            }
//        default: // 1,2,4（負債、純資産、収益）
//            switch DebitOrCredit {
//                case "借":
//                PositiveOrNegative = "-"
//                break
//            default:
//                PositiveOrNegative = ""
//            }
//        }
//        print(account, DebitOrCredit)
//        return PositiveOrNegative
        
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
        
        // 勘定の丁数(プライマリーキー)を取得
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
            default:
                PositiveOrNegative = ""
            }
        default: // 1,2,4（負債、純資産、収益）
            switch DebitOrCredit {
                case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
            }
        }
        return PositiveOrNegative
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
    // 中分類　取得
    func getMiddleCategoryTotal(big_category: Int, mid_category: Int) -> String {
        // データベースに書き込み　todo
//        setMiddleCategoryTotal(big_category: big_category,mid_category: mid_category)
        var result:Int64 = 0            // 累計額
        
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseBalanceSheet.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        switch mid_category {
        case 0: //流動資産
            result = objectss[0].CurrentAssets_total
            break
        case 1: //固定資産
            result = objectss[0].FixedAssets_total
            break
        case 2: //流動負債
            result = objectss[0].CurrentLiabilities_total
            break
        case 3: //固定負債
            result = objectss[0].FixedLiabilities_total
            break
        case 4: //株主資本
            result = objectss[0].CapitalStock_total
            break
        case 5: //その他の包括利益累計額
            result = objectss[0].OtherCapitalSurpluses_total
            break
        default:
            print(result)
        }
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return addComma(string: result.description)
    }
    // 大分類　取得
    func getBigCategoryTotal(big_category: Int) -> String {
//        // データベースに書き込み　todo
//        setBigCategoryTotal(big_category: big_category)
        var result:Int64 = 0            // 累計額
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
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseBalanceSheet.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        switch big_category {
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
        }
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return addComma(string: result.description)
    }
}
