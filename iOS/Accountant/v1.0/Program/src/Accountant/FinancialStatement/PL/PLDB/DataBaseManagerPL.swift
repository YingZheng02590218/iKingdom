//
//  DataBaseManagerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerPL {
    
    func initializeBenefits(){
        // データベースに書き込み　//4:収益 3:費用
        // 大分類
        setMiddleCategoryTotal(big_category: 4,mid_category: 9) //営業収益9
        setMiddleCategoryTotal(big_category: 4,mid_category: 10)//営業外収益10
        setMiddleCategoryTotal(big_category: 3,mid_category: 6) //営業外費用6
        setMiddleCategoryTotal(big_category: 4,mid_category: 11)//特別利益11
        setMiddleCategoryTotal(big_category: 3,mid_category: 7) //特別損失7
        setMiddleCategoryTotal(big_category: 3,mid_category: 8) //税等8 法人税等
        // 小分類
        setSmallCategoryTotal(big_category: 4, small_category: 10)//営業収益9 売上高10
        setSmallCategoryTotal(big_category: 3, small_category: 8) //営業費用5  売上原価8
        setSmallCategoryTotal(big_category: 3, small_category: 9) //営業費用5  販管費9
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
    }
    
    // 利益　計算
    func setBenefitTotal() {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        // 利益5種類　売上総利益、営業利益、経常利益、税金等調整前当期純利益、当期純利益
        for i in 0..<5 {
            // データベース　書き込み
            // (1)Realmのインスタンスを生成する
            let realm = try! Realm()
            // (2)データベース内に保存されているモデルを全て取得する
            var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
            // 希望する勘定だけを抽出する
            objectss = objectss.filter("fiscalYear == \(fiscalYear)")
            // (2)書き込みトランザクション内でデータを追加する
            try! realm.write {
                switch i {
                case 0: //売上総利益
                    objectss[0].GrossProfitOrLoss = objectss[0].NetSales - objectss[0].CostOfGoodsSold
                    break
                case 1: //営業利益
                    objectss[0].OtherCapitalSurpluses_total = objectss[0].GrossProfitOrLoss - objectss[0].SellingGeneralAndAdministrativeExpenses
                    break
                case 2: //経常利益
                    objectss[0].OrdinaryIncomeOrLoss = objectss[0].OtherCapitalSurpluses_total + objectss[0].NonOperatingIncome - objectss[0].NonOperatingExpenses
                    break
                case 3: //税引前当期純利益（損失）
                    objectss[0].IncomeOrLossBeforeIncomeTaxes = objectss[0].OrdinaryIncomeOrLoss + objectss[0].ExtraordinaryIncome - objectss[0].ExtraordinaryLosses
                    break
                case 4: //当期純利益（損失）
                    objectss[0].NetIncomeOrLoss = objectss[0].IncomeOrLossBeforeIncomeTaxes - objectss[0].IncomeTaxes
                    break
                default:
                    print()
                }
            }
        }
    }
    // 利益　取得
    func getBenefitTotal(benefit: Int) -> String {
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
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        switch benefit {
        case 0: //売上総利益
            result = objectss[0].GrossProfitOrLoss
            break
        case 1: //営業利益
            result = objectss[0].OtherCapitalSurpluses_total
            break
        case 2: //経常利益
            result = objectss[0].OrdinaryIncomeOrLoss
            break
        case 3: //税引前当期純利益（損失）
            result = objectss[0].IncomeOrLossBeforeIncomeTaxes
            break
        case 4: //当期純利益（損失）
            result = objectss[0].NetIncomeOrLoss
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
    // 中分類　取得
    func getMiddleCategoryTotal(big_category: Int, mid_category: Int) -> String {
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
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        switch mid_category {
        case 9: //営業収益9
            result = objectss[0].NetSales
            break
//        case 5: //営業費用5
//            result = objectss[0].FixedAssets_total
//            break
        case 10: //営業外収益10
            result = objectss[0].NonOperatingIncome
            break
        case  6: //営業外費用6
            result = objectss[0].NonOperatingExpenses
            break
        case 11: //特別利益11
            result = objectss[0].ExtraordinaryIncome
            break
        case  7: //特別損失7
            result = objectss[0].ExtraordinaryLosses
            break
        case  8: //税等8 法人税等
            result = objectss[0].IncomeTaxes
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
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            switch mid_category {
//            case 9: //営業収益9 == 売上高10
//                objectss[0].NetSales = middleCategoryTotalAmount
//                break
            case 10: //営業外収益10
                objectss[0].NonOperatingIncome = middleCategoryTotalAmount
                break
            case  6: //営業外費用6
                objectss[0].NonOperatingExpenses = middleCategoryTotalAmount
                break
            case 11: //特別利益11
                objectss[0].ExtraordinaryIncome = middleCategoryTotalAmount
                break
            case  7: //特別損失7
                objectss[0].ExtraordinaryLosses = middleCategoryTotalAmount
                break
            case  8: //税等8 法人税等
                objectss[0].IncomeTaxes = middleCategoryTotalAmount
                break
            default:
                print()
            }
        }
    }
    // 小分類　取得
    func getSmallCategoryTotal(big_category: Int, small_category: Int) -> String {
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
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        
        switch small_category {
        case 10: //売上高10
            result = objectss[0].NetSales
            break
        case  8: //売上原価8
            result = objectss[0].CostOfGoodsSold
            break
        case  9: //販売費及び一般管理費9
            result = objectss[0].SellingGeneralAndAdministrativeExpenses
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
    // 小分類　計算
    func setSmallCategoryTotal(big_category: Int, small_category: Int) {
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjectsInSmallCategory(small_category: small_category)
        var smallCategoryTotalAmount:Int64 = 0            // 累計額
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            //            calculateAccountTotal(account: objects[i].category)
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                smallCategoryTotalAmount -= totalAmount
            }else {
                smallCategoryTotalAmount += totalAmount
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
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            switch small_category {
            case 10://収益 営業収益9 売上高10
                objectss[0].NetSales = smallCategoryTotalAmount
                break
            case 8: //費用 営業費用5  売上原価8 小分類で計算する
                objectss[0].CostOfGoodsSold = smallCategoryTotalAmount
                break
            case 9: //費用 営業費用5  販管費9 小分類で計算する
                objectss[0].SellingGeneralAndAdministrativeExpenses = smallCategoryTotalAmount
                break
            default:
                print()
            }
        }
    }
    // 小分類　設定画面の勘定科目一覧にある勘定を取得する
    func getObjectsInSmallCategory(small_category: Int) -> Results<DataBaseSettingsCategory> {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("small_category == \(small_category)")
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
        // 借方と貸方で金額が大きい方はどちらか
//        if objectss[0].dataBaseAccounts[number].debit_total > objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }else if objectss[0].dataBaseAccounts[number].debit_total < objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].credit_total
//        }else {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }
        // 決算整理後の値を利用する
        if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting > objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting
        }else if objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting < objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting {
            result = objectss[0].dataBaseAccounts[number].credit_total_AfterAdjusting
        }else {
            result = objectss[0].dataBaseAccounts[number].debit_total_AfterAdjusting
        }
        return result
    }
    // 中分類　設定画面の勘定科目一覧にある勘定を取得する
    func getObjectsInMiddleCategory(mid_category: Int) -> Results<DataBaseSettingsCategory> {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("mid_category == \(mid_category)")
        return objects
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, account: String) ->String {
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
        //        print("number\(number)")
        
        var DebitOrCredit:String = "" // 借又貸
        // 借方と貸方で金額が大きい方はどちらか
        if objectss[0].dataBaseAccounts[number].debit_balance > objectss[0].dataBaseAccounts[number].credit_balance {
            DebitOrCredit = "借"
        }else if objectss[0].dataBaseAccounts[number].debit_balance < objectss[0].dataBaseAccounts[number].credit_balance {
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
//        print("getTotalDebitOrCredit")
//        print(account, objectss[0].dataBaseAccounts[number].debit_balance)
//        print(account, objectss[0].dataBaseAccounts[number].credit_balance)
        
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
//    // モデルオブフェクトの取得
//    func getMiddleCategoryFromGeneralLedger(mid_category: Int) -> Results<DataBaseAccount> {
//
//        // 開いている会計帳簿を取得
//        let dataBaseManagerPeriod = DataBaseManagerPeriod()
//        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        // 開いている会計帳簿の年度を取得
//        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
//
//        // データベース
//        let databaseManagerSettings = DatabaseManagerSettingsCategory()
//        // 中分類　中分類ごとの数を取得
//        let objectsFromSettings = databaseManagerSettings.getMiddleCategory(mid_category: mid_category)
//
//        // データベース　読み込み
//        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
//        // (2)データベース内に保存されているモデルを全て取得する
//        var objects = realm.objects(DataBaseAccount.self)
//        // 希望する勘定だけを抽出する
//        objects = objects.filter("fiscalYear == \(fiscalYear)")
//         //ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
//        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
//        return objects
//    }
}
