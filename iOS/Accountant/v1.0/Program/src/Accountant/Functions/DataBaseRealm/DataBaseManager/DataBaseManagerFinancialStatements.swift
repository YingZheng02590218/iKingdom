//
//  DataBaseManagerFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 決算書クラス
class DataBaseManagerFinancialStatements: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(dataBase: DataBaseFinancialStatements, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    // モデルオブフェクトの追加
    func addFinancialStatements(number: Int) {
        // 会計帳簿棚　のオブジェクトを取得
        let object = DataBaseManager.realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトに格納するオブジェクトを作成
        let balanceSheet = DataBaseBalanceSheet(
            fiscalYear: object.fiscalYear,
            CurrentAssets_total: 0,
            FixedAssets_total: 0,
            DeferredAssets_total: 0,
            Asset_total: 0,
            CurrentLiabilities_total: 0,
            FixedLiabilities_total: 0,
            Liability_total: 0,
            CapitalStock_total: 0,
            OtherCapitalSurpluses_total: 0,
            Equity_total: 0
        )
        let profitAndLossStatement = DataBaseProfitAndLossStatement()
        profitAndLossStatement.fiscalYear = object.fiscalYear
        let cashFlowStatement = DataBaseCashFlowStatement()
        cashFlowStatement.fiscalYear = object.fiscalYear
        let workSheet = DataBaseWorkSheet()
        workSheet.fiscalYear = object.fiscalYear
        let compoundTrialBalance = DataBaseCompoundTrialBalance()
        compoundTrialBalance.fiscalYear = object.fiscalYear
        let dataBaseFinancialStatements = DataBaseFinancialStatements(
            fiscalYear: object.fiscalYear,
            balanceSheet: balanceSheet,
            profitAndLossStatement: profitAndLossStatement,
            cashFlowStatement: cashFlowStatement,
            workSheet: workSheet,
            compoundTrialBalance: compoundTrialBalance
        )
        do {
        // (2)書き込みトランザクション内でデータを追加する
        try DataBaseManager.realm.write {
            var number = balanceSheet.save()
            print(number)
             number = profitAndLossStatement.save()
             number = cashFlowStatement.save()
             number = workSheet.save()
             number = compoundTrialBalance.save()
             number = dataBaseFinancialStatements.save() //　自動採番
            // オブジェクトを作成して追加
            // 設定画面の勘定科目一覧にある勘定を取得する
            let objects = DataBaseManagerSettingsTaxonomy.shared.getAllSettingsTaxonomy()
            // オブジェクトを作成 表示科目
            for i in 0..<objects.count {
                let dataBaseTaxonomy = DataBaseTaxonomy(
                    fiscalYear: object.fiscalYear,
                    accountName: objects[i].category,
                    total: 0,
                    numberOfTaxonomy: objects[i].number // 設定表示科目の連番を保持する　マイグレーション
                )
                let number = dataBaseTaxonomy.save() //　自動採番
                print(number)
                balanceSheet.dataBaseTaxonomy.append(dataBaseTaxonomy)   // 表示科目を作成して貸借対照表に追加する
            }
            // 年度　の数だけ増える
            object.dataBaseFinancialStatements = dataBaseFinancialStatements // 会計帳簿に財務諸表を追加する
        }
        } catch {
            print("エラーが発生しました")
        }
    }
    // モデルオブフェクトの削除
    func deleteFinancialStatements(number: Int) -> Bool {
        if let object = DataBaseManager.realm.object(ofType: DataBaseFinancialStatements.self, forPrimaryKey: number) {
            do {
        try DataBaseManager.realm.write {
            // 表示科目を削除
            DataBaseManager.realm.delete(object.balanceSheet!.dataBaseTaxonomy)
            // 貸借対照表、損益計算書、CF計算書、精算表、試算表を削除
            DataBaseManager.realm.delete(object.balanceSheet!)
            DataBaseManager.realm.delete(object.profitAndLossStatement!)
            DataBaseManager.realm.delete(object.cashFlowStatement!)
            DataBaseManager.realm.delete(object.workSheet!)
            DataBaseManager.realm.delete(object.compoundTrialBalance!)
            // 会計帳簿を削除
            DataBaseManager.realm.delete(object)
        }
            } catch {
                print("エラーが発生しました")
            }
            return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
        }

        return false
    }
    // 取得　財務諸表　現在開いている年度
    func getFinancialStatements() -> DataBaseFinancialStatements {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = DataBaseManager.realm.objects(DataBaseFinancialStatements.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0]
    }
}
