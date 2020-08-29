//
//  DataBaseManagerFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerFinancialStatements: DataBaseManager {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(DataBase: DataBaseFinancialStatements, fiscalYear: Int) -> Bool {
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // モデルオブフェクトの追加
    func addFinancialStatements(number: Int) {
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
//            print("balanceSheet",number)
             number = profitAndLossStatement.save()
//            print("profitAndLossStatement",number)
             number = cashFlowStatement.save()
//            print("cashFlowStatement",number)
             number = workSheet.save()
//            print("workSheet",number)
             number = compoundTrialBalance.save()
//            print("compoundTrialBalance",number)
             number = dataBaseFinancialStatements.save() //　自動採番
//            print("dataBaseFinancialStatements",number)
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
    // モデルオブフェクトの削除
    func deleteFinancialStatements(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseFinancialStatements.self, forPrimaryKey: number)!
        try! realm.write {
            // 表記名を削除
            realm.delete(object.balanceSheet!.dataBaseBSAndPLAccounts)
            // 貸借対照表、損益計算書、CF計算書、精算表、試算表を削除
            realm.delete(object.balanceSheet!)
            realm.delete(object.profitAndLossStatement!)
            realm.delete(object.cashFlowStatement!)
            realm.delete(object.workSheet!)
            realm.delete(object.compoundTrialBalance!)
            // 会計帳簿を削除
            realm.delete(object)
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
    // モデルオブフェクトの取得　総勘定元帳
    func getFinancialStatements() -> DataBaseFinancialStatements {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // (2)データベース内に保存されているモデルを取得する
        var objects = realm.objects(DataBaseFinancialStatements.self)
        // 希望する勘定だけを抽出する
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0]
    }
}
