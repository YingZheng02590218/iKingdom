//
//  DataBaseManagerGeneralLedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerGeneralLedger {
    
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising(fiscalYear: Int) -> Bool { // 共通化したい
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseGeneralLedger.self) // DataBaseAccountモデル
        objects = objects.filter("fiscalYear == \(fiscalYear)") // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // 設定画面の勘定科目一覧にある勘定を取得する
    func getObjects() -> Results<DataBaseSettingsCategory> {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
    
        return objects
    }
    // モデルオブフェクトの追加　総勘定元帳
    func addGeneralLedger(number: Int){
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 主要簿　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトを作成
        let dataBaseGeneralLedger = DataBaseGeneralLedger() // 総勘定元帳
        dataBaseGeneralLedger.fiscalYear = object.fiscalYear // Todo
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjects()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let number = dataBaseGeneralLedger.save() //　自動採番
            print("addGeneralLedger",number)
            // オブジェクトを作成 勘定
            for i in 0..<objects.count{
                let dataBaseAccount = DataBaseAccount() // 勘定
                let number = dataBaseAccount.save() //　自動採番
                print("dataBaseAccount",number)
                dataBaseAccount.fiscalYear = object.fiscalYear
                dataBaseAccount.accountName = objects[i].category
                dataBaseGeneralLedger.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
            }
            // 年度　の数だけ増える　ToDo
//            realm.add(dataBaseGeneralLedger)
            object.dataBaseGeneralLedger = dataBaseGeneralLedger
        }
    }
    // モデルオブフェクトの取得　総勘定元帳
    func getGeneralLedger() -> DataBaseGeneralLedger {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalsモデルをひとつ取得する
//        let object = realm.object(ofType: DataBaseGeneralLedger.self, forPrimaryKey: 1)! //ToDo // DataBaseJournalsモデル
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        // (2)データベース内に保存されているモデルをひとつ取得する
        var objects = realm.objects(DataBaseAccountingBooks.self)
        // 希望する勘定だけを抽出する
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0].dataBaseGeneralLedger!
    }
}
