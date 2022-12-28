//
//  DataBaseManagerAccountingBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerAccountingBooks: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(dataBase: DataBaseAccountingBooks, fiscalYear: Int) -> Bool { // 年度を追加する場合
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    // データベースにモデルが存在するかどうかをチェックする
    func checkOpeningAccountingBook() -> Bool { // 帳簿が一冊の場合
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true)) // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        ])
        return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitializing() -> Bool { // 帳簿が一冊もない場合
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseAccountingBooks.self) // TODO: DataBaseManager に統合する
        return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addAccountingBooks(fiscalYear: Int) -> Int {

        var number = 0
        // 会計帳簿棚　のオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseAccountingBooksShelf.self, key: 1) else { return number } // 会社に会計帳簿棚はひとつ
        // オブジェクトを作成 会計帳簿
        let dataBaseAccountingBooks = DataBaseAccountingBooks(
            fiscalYear: fiscalYear,
            dataBaseJournals: nil,
            dataBaseGeneralLedger: nil,
            dataBaseFinancialStatements: nil,
            openOrClose: !checkOpeningAccountingBook() ? true : false // 会計帳簿がひとつだけならこの帳簿を開く
        )
        // (2)書き込みトランザクション内でデータを追加する

        do {
            try DataBaseManager.realm.write {
                number = dataBaseAccountingBooks.save() //　自動採番
                // 年度　の数だけ増える
                object.dataBaseAccountingBooks.append(dataBaseAccountingBooks) // 会計帳簿棚に会計帳簿を追加する
            }
            return number
        } catch let error as NSError {
            print(error)
            return number
        }
    }
    // モデルオブフェクトの削除　会計帳簿
    func deleteAccountingBooks(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseAccountingBooks.self, key: number) else { return false } // 会社に会計帳簿棚はひとつ
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseAccountingBooks.self)
        // 会計帳簿が一つしかない場合は、削除しない
        if objects.count >= 1 {
            // 会計帳簿だけではなく、仕訳帳、総勘定元帳なども削除する
            // 仕訳帳画面
            let dataBaseManagerJournals = JournalsModel()
            // データベースに仕訳帳画面の仕訳帳があるかをチェック
            if dataBaseManagerJournals.checkInitialising(dataBase: DataBaseJournals(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerJournals.deleteJournals(number: object.number)
                print(isInvalidated)
            }
            // 総勘定元帳画面
            let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
            // データベースに勘定画面の勘定があるかをチェック
            if dataBaseManagerGeneralLedger.checkInitialising(dataBase: DataBaseGeneralLedger(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerGeneralLedger.deleteGeneralLedger(number: object.number)
                print(isInvalidated)
            }
            // 決算書画面
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            // データベースに勘定画面の勘定があるかをチェック
            if dataBaseManagerFinancialStatements.checkInitialising(dataBase: DataBaseFinancialStatements(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerFinancialStatements.deleteFinancialStatements(number: object.number)
                print(isInvalidated)
            }
        }
        do {

            try DataBaseManager.realm.write {
                DataBaseManager.realm.delete(object)
            }
            // 開く会計帳簿を最新の帳簿にする
            for i in 0..<objects.count {
                DataBaseManagerSettingsPeriod.shared.setMainBooksOpenOrClose(tag: objects[i].number)
            }
            return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
        } catch let error as NSError {
            print(error)
            return false
        }
    }
}
