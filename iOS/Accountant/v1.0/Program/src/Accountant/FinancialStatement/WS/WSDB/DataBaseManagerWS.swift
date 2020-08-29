//
//  DataBaseManagerWS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerWS {
    
    // 精算表　計算　合計、残高の合計値　修正記入、損益計算書、貸借対照表
    func calculateAmountOfAllAccount(){
        let dataBaseManager = DataBaseManagerGeneralLedger()
        let objectG = dataBaseManager.getGeneralLedger()
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = DataBaseManagerTB()

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
    func calculateAmountOfAllAccountForPL(){
        let dataBaseManager = DatabaseManagerSettingsCategory()
        let objectG = dataBaseManager.getSettingsSwitchingOnBSorPL(BSorPL: 1)
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = DataBaseManagerTB()

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
    func calculateAmountOfAllAccountForBS(){
        let dataBaseManager = DatabaseManagerSettingsCategory()
        let objectG = dataBaseManager.getSettingsSwitchingOnBSorPL(BSorPL: 0)
        
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()
        
        let dataBaseManagerTB = DataBaseManagerTB()

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
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
//        if addComma(string: amount.description) == "0" { //0の場合は、空白を表示する
//            return ""
//        }else {
            return addComma(string: amount.description)
//        }
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
