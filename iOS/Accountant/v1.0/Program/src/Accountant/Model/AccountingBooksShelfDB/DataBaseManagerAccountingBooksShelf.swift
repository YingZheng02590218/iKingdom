//
//  DataBaseManagerAccountingBooksShelf.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerAccountingBooksShelf: DataBaseManager {
    
    public static let shared = DataBaseManagerAccountingBooksShelf()
    
    /**
     * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
     * モデルオブジェクトをデータベースから読み込む。
     * @param DataBase モデルオブジェクト
     * @param fiscalYear 年度
     * @return モデルオブジェクトが存在するかどうか
     */
    func checkInitialising(dataBase: DataBaseAccountingBooksShelf, fiscalYear: Int) -> Bool {
        super.checkInitialising(dataBase: dataBase, fiscalYear: fiscalYear)
    }
    // モデルオブフェクトの追加
    func addAccountingBooksShelf(company: String) -> Int {
        // オブジェクトを作成
        let dataBaseAccountingBooksShelf = DataBaseAccountingBooksShelf() // 会計帳簿棚
        dataBaseAccountingBooksShelf.companyName = company 
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        do {
            try DataBaseManager.realm.write {
                number = dataBaseAccountingBooksShelf.save() //　自動採番
                // 会社　の数だけ増える
                DataBaseManager.realm.add(dataBaseAccountingBooksShelf)
            }
        } catch {
            print("エラーが発生しました")
        }
        return number
    }
    // 事業者名の取得
    func getCompanyName() -> String {
        // (2)データベース内に保存されているモデルをひとつ取得する
        let object = DataBaseManager.realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)!
        return object.companyName // 事業者名を返す
    }
    // モデルオブフェクトの更新
    func updateCompanyName(companyName: String) {
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": 1, "companyName": companyName]
                DataBaseManager.realm.create(DataBaseAccountingBooksShelf.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
}
