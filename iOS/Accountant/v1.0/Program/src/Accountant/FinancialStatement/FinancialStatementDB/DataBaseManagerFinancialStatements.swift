//
//  DataBaseManagerFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerFinancialStatements  {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(fiscalYear: Int) -> Bool { // 共通化したい
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseFinancialStatements.self) // モデル
        objects = objects.filter("fiscalYear == \(fiscalYear)") // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addFinancialStatements(number: Int) {
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトに格納するオブジェクトを作成
        let balanceSheet = DataBaseBalanceSheet()
        balanceSheet.fiscalYear = object.fiscalYear
        let profitAndLossStatement = DataBaseProfitAndLossStatement()
        profitAndLossStatement.fiscalYear = object.fiscalYear
        let cashFlowStatement = DataBaseCashFlowStatement()
        cashFlowStatement.fiscalYear = object.fiscalYear
        let workSheet = DataBaseWorkSheet()
        workSheet.fiscalYear = object.fiscalYear
        let compoundTrialBalance = DataBaseCompoundTrialBalance()
        compoundTrialBalance.fiscalYear = object.fiscalYear
        let dataBaseFinancialStatements = DataBaseFinancialStatements() //
        dataBaseFinancialStatements.fiscalYear = object.fiscalYear
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            var number = balanceSheet.save()
            print("balanceSheet",number)
             number = profitAndLossStatement.save()
            print("profitAndLossStatement",number)
             number = cashFlowStatement.save()
            print("cashFlowStatement",number)
             number = workSheet.save()
            print("workSheet",number)
             number = compoundTrialBalance.save()
            print("compoundTrialBalance",number)
             number = dataBaseFinancialStatements.save() //　自動採番
            print("dataBaseFinancialStatements",number)
            // オブジェクトを作成して追加
            // 設定画面の勘定科目一覧にある勘定を取得する
            let DM = DataBaseManagerSettingsCategoryBSAndPL()
            let objects = DM.getAllSettingsCategoryBSAndPL()
            // オブジェクトを作成 表記名
            for i in 0..<objects.count{
                let dataBaseBSAndPLAccount = DataBaseBSAndPLAccount() // 表記名
                let number = dataBaseBSAndPLAccount.save() //　自動採番
                dataBaseBSAndPLAccount.fiscalYear = object.fiscalYear
                dataBaseBSAndPLAccount.accountName = objects[i].category
                balanceSheet.dataBaseBSAndPLAccounts.append(dataBaseBSAndPLAccount)   // 表記名を作成して貸借対照表に追加する
            }
            dataBaseFinancialStatements.balanceSheet = balanceSheet
            dataBaseFinancialStatements.profitAndLossStatement = profitAndLossStatement
            dataBaseFinancialStatements.cashFlowStatement = cashFlowStatement
            dataBaseFinancialStatements.workSheet = workSheet
            dataBaseFinancialStatements.compoundTrialBalance = compoundTrialBalance
            // 年度　の数だけ増える　ToDo
//            realm.add(dataBaseMainBooks)
            object.dataBaseFinancialStatements = dataBaseFinancialStatements // 会計帳簿に財務諸表を追加する
        }
    }
    // モデルオブフェクトの取得　総勘定元帳
    func getFinancialStatements() -> DataBaseFinancialStatements {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルをひとつ取得する
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // (2)データベース内に保存されているモデルをひとつ取得する
        var objects = realm.objects(DataBaseFinancialStatements.self)
        // 希望する勘定だけを抽出する
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0]
    }
}
