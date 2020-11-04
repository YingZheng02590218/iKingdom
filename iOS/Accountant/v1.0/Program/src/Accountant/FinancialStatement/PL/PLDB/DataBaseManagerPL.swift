//
//  DataBaseManagerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益計算書クラス
class DataBaseManagerPL {
    
    // 初期化　中区分、大区分　ごとに計算
    func initializeBenefits(){
        // データベースに書き込み　//4:収益 3:費用
        setTotalRank0(big5: 4,rank0:  6) //営業収益9     売上
        setTotalRank0(big5: 3,rank0:  7) //営業費用5     売上原価
        setTotalRank0(big5: 3,rank0:  8) //営業費用5     販売費及び一般管理費
        setTotalRank0(big5: 3,rank0: 11) //税等8        法人税等 税金

        setTotalRank1(big5: 4, rank1: 15) //営業外収益10 営業外損益    営業外収益
        setTotalRank1(big5: 3, rank1: 16) //営業外費用6  営業外損益    営業外費用
        setTotalRank1(big5: 4, rank1: 17) //特別利益11   特別損益    特別利益
        setTotalRank1(big5: 3, rank1: 18) //特別損失7    特別損益    特別損失
        
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
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
                print(i, TotalAmountOfRank0, "-=", totalAmount)
            }else {
                TotalAmountOfRank0 += totalAmount
                print(i, TotalAmountOfRank0, "+=", totalAmount)
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        try! realm.write {
            switch rank0 {
            case 6: //営業収益9     売上
                objectss[0].NetSales = TotalAmountOfRank0
                break
            case 7: //営業費用5     売上原価
                objectss[0].CostOfGoodsSold = TotalAmountOfRank0
                break
            case 8: //営業費用5     販売費及び一般管理費
                objectss[0].SellingGeneralAndAdministrativeExpenses = TotalAmountOfRank0
                break
            case 11: //税等8 法人税等 税金
                objectss[0].IncomeTaxes = TotalAmountOfRank0
                break
            default:
                print()
            }
        }
    }
    // 取得　階層0 大区分
    func getTotalRank0(big5: Int, rank0: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        var result:Int64 = 0
        switch rank0 {
            case 6: //営業収益9     売上
                result = objectss[0].NetSales
                break
            case 7: //営業費用5     売上原価
                result = objectss[0].CostOfGoodsSold
                break
            case 8: //営業費用5     販売費及び一般管理費
                result = objectss[0].SellingGeneralAndAdministrativeExpenses
                break
            case 11: //税等8 法人税等 税金
                result = objectss[0].IncomeTaxes
                break
        default:
            print(result)
        }
        return addComma(string: result.description)
    }
    // 計算　階層1 中区分
    func setTotalRank1(big5: Int, rank1: Int) {
        var TotalAmountOfRank1:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank1(rank1: rank1)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big5, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank1 -= totalAmount
            }else {
                TotalAmountOfRank1 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        let realm = try! Realm()
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        try! realm.write {
            switch rank1 {
            case 15: //営業外収益10  営業外損益    営業外収益
                objectss[0].NonOperatingIncome = TotalAmountOfRank1
                break
            case 16: //営業外費用6  営業外損益    営業外費用
                objectss[0].NonOperatingExpenses = TotalAmountOfRank1
                break
            case 17: //特別利益11   特別損益    特別利益
                objectss[0].ExtraordinaryIncome = TotalAmountOfRank1
                break
            case 18: //特別損失7    特別損益    特別損失
                objectss[0].ExtraordinaryLosses = TotalAmountOfRank1
                break
            default:
                print()
                break
            }
        }
    }
    // 取得　設定勘定科目　中区分
    func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank1 LIKE '\(rank1)'")
        return objects
    }
    // 取得　階層1 中区分
    func getTotalRank1(big5: Int, rank1: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        var result:Int64 = 0            // 累計額
        switch rank1 {
        case 15: //営業外収益10  営業外損益    営業外収益
            result = objectss[0].NonOperatingIncome
            break
        case 16: //営業外費用6  営業外損益    営業外費用
            result = objectss[0].NonOperatingExpenses
            break
        case 17: //特別利益11   特別損益    特別利益
            result = objectss[0].ExtraordinaryIncome
            break
        case 18: //特別損失7    特別損益    特別損失
            result = objectss[0].ExtraordinaryLosses
            break
        default:
            print(result)
            break
        }
        return addComma(string: result.description)
    }
    // 合計残高　勘定別の合計と借又貸 取得
    func getAccountTotal(big_category: Int, account: String) -> String {
        let totalAmount = getTotalAmount(account: account)  // 合計を取得
        let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: account) // 借又貸を取得
        return "\(totalDebitOrCredit) \(setComma(amount: totalAmount))"
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
            let realm = try! Realm()
            var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
            objectss = objectss.filter("fiscalYear == \(fiscalYear)")
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
                    break
                }
            }
        }
    }
    // 利益　取得
    func getBenefitTotal(benefit: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        var objectss = realm.objects(DataBaseProfitAndLossStatement.self) // モデル
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
        var result:Int64 = 0            // 累計額
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
            break
        }

        return addComma(string: result.description)
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
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger//realm.objects(DataBaseGeneralLedger.self)
//        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
//        // 勘定の丁数(プライマリーキー)を取得
//        let dataBaseManagerAccount = DataBaseManagerAccount()
//        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
//        number -= 1 // 0スタートに補正
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか
//        if objectss[0].dataBaseAccounts[number].debit_total > objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }else if objectss[0].dataBaseAccounts[number].debit_total < objectss[0].dataBaseAccounts[number].credit_total {
//            result = objectss[0].dataBaseAccounts[number].credit_total
//        }else {
//            result = objectss[0].dataBaseAccounts[number].debit_total
//        }
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 決算整理後の値を利用する
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting
                }else {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }
            }
        }
        return result
    }
    // 取得　設定勘定科目　大区分
    func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger//realm.objects(DataBaseGeneralLedger.self) // モデル
//        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
//        // 勘定の丁数(プライマリーキー)を取得
//        let dataBaseManagerAccount = DataBaseManagerAccount()
//        var number = dataBaseManagerAccount.getNumberOfAccount(accountName: account)
//        number -= 1 // 0スタートに補正
        var DebitOrCredit:String = "" // 借又貸
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "借"
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "貸"
                }else {
                    DebitOrCredit = "-"
                }
            }
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
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String{
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
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
