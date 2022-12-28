//
//  DataBaseManagerGeneralLedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 総勘定元帳クラス
class DataBaseManagerGeneralLedger: DataBaseManager {
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseGeneralLedger, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    // 設定画面の勘定科目一覧にある勘定を取得する
    func getObjects() -> Results<DataBaseSettingsTaxonomyAccount> {
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 追加　総勘定元帳
    func addGeneralLedger(number: Int) {
        // 主要簿　のオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseAccountingBooks.self, key: number) else { return }
        // オブジェクトを作成 総勘定元帳
        let dataBaseGeneralLedger = DataBaseGeneralLedger(
            fiscalYear: object.fiscalYear,
            dataBasePLAccount: nil
        )
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjects()
        do {
            try DataBaseManager.realm.write {
                let number = dataBaseGeneralLedger.save() //　自動採番
                print("addGeneralLedger", number)
                // オブジェクトを作成 勘定
                for i in 0..<objects.count {
                    // オブジェクトを作成 勘定
                    let dataBaseAccount = DataBaseAccount(
                        fiscalYear: object.fiscalYear,
                        accountName: objects[i].category,
                        debit_total: 0,
                        credit_total: 0,
                        debit_balance: 0,
                        credit_balance: 0,
                        debit_total_Adjusting: 0,
                        credit_total_Adjusting: 0,
                        debit_balance_Adjusting: 0,
                        credit_balance_Adjusting: 0,
                        debit_total_AfterAdjusting: 0,
                        credit_total_AfterAdjusting: 0,
                        debit_balance_AfterAdjusting: 0,
                        credit_balance_AfterAdjusting: 0
                    )
                    let number = dataBaseAccount.save() //　自動採番
                    print("dataBaseAccount", number)
                    dataBaseGeneralLedger.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
                }
                // オブジェクトを作成 損益勘定
                let dataBasePLAccount = DataBasePLAccount(
                    fiscalYear: object.fiscalYear,
                    accountName: "損益勘定",
                    debit_total: 0,
                    credit_total: 0,
                    debit_balance: 0,
                    credit_balance: 0,
                    debit_total_Adjusting: 0,
                    credit_total_Adjusting: 0,
                    debit_balance_Adjusting: 0,
                    credit_balance_Adjusting: 0,
                    debit_total_AfterAdjusting: 0,
                    credit_total_AfterAdjusting: 0,
                    debit_balance_AfterAdjusting: 0,
                    credit_balance_AfterAdjusting: 0
                )
                let numberr = dataBasePLAccount.save() //　自動採番
                print("dataBasePLAccount", numberr)
                dataBaseGeneralLedger.dataBasePLAccount = dataBasePLAccount   // 損益勘定を作成して総勘定元帳に追加する
                // 年度　の数だけ増える
                object.dataBaseGeneralLedger = dataBaseGeneralLedger
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // モデルオブフェクトの削除
    func deleteGeneralLedger(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseGeneralLedger.self, key: number) else { return false }
        do {
            try DataBaseManager.realm.write {
                // 勘定を削除
                DataBaseManager.realm.delete(object.dataBaseAccounts)
                // 会計帳簿を削除
                DataBaseManager.realm.delete(object)
            }
        } catch {
            print("エラーが発生しました")
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
    // モデルオブフェクトの取得　年度を指定　総勘定元帳
    func getGeneralLedger(fiscalYear: Int) -> DataBaseGeneralLedger {
        // (2)データベース内に保存されているモデルをひとつ取得する
        var objects = DataBaseManager.realm.objects(DataBaseAccountingBooks.self)
        // 希望する勘定だけを抽出する
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0].dataBaseGeneralLedger!
    }
    // 取得　総勘定元帳　開いている会計帳簿内の元帳
    func getGeneralLedger() -> DataBaseGeneralLedger {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])
        return objects[0].dataBaseGeneralLedger!
    }
}
