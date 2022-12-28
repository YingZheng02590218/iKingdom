//
//  DataBaseManagerSettingsTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// protocol DataBaseManagerSettingsTaxonomyModelInput {
//    func initializeSettingsTaxonomy()
//    func checkInitialising() -> Bool
//    func getAllSettingsTaxonomy() -> Results<DataBaseSettingsTaxonomy>
//    func getAllSettingsTaxonomySwitichON() -> Results<DataBaseSettingsTaxonomy>
//    func getAllSettingsCategoryBSAndPLSwitichON() -> Results<DataBaseSettingsTaxonomy>
//    func getBigCategoryAll(section: Int) -> Results<DataBaseSettingsTaxonomy>
//    func getBigCategory(category0: String,category1: String,category2: String) -> Results<DataBaseSettingsTaxonomy>
//    func getMiddleCategory(category0: String,category1: String,category2: String,category3: String) -> Results<DataBaseSettingsTaxonomy>
//    func getSmallCategory(category0: String,category1: String,category2: String,category3: String,category4: String) -> Results<DataBaseSettingsTaxonomy>
//    func getSettingsTaxonomy(numberOfTaxonomy: Int) -> DataBaseSettingsTaxonomy?
//    func updateSettingsCategoryBSAndPLSwitching(number: Int) //勘定科目　連番
// }
// 設定表示科目クラス
class DataBaseManagerSettingsTaxonomy { // }: DataBaseManagerSettingsTaxonomyModelInput {
    
    public static let shared = DataBaseManagerSettingsTaxonomy()
    // private let serialQueue = DispatchQueue(label: "serialQueue") 2022/03/15 修正　v2.0.2の変更でこのコードが書かれているので、v2.0.6までの間に初期化処理を行なったユーザーの初期化処理は失敗しているはず。
    
    //    let objects0100: Results<DataBaseSettingsTaxonomy>?
    //    let objects0102: Results<DataBaseSettingsTaxonomy>?
    //    let objects0114: Results<DataBaseSettingsTaxonomy>?
    //    let objects0115: Results<DataBaseSettingsTaxonomy>?
    //    let objects0129: Results<DataBaseSettingsTaxonomy>?
    //    let objects01210: Results<DataBaseSettingsTaxonomy>?
    //    let objects01211: Results<DataBaseSettingsTaxonomy>?
    //    let objects01213: Results<DataBaseSettingsTaxonomy>?
    //    let objects010142: Results<DataBaseSettingsTaxonomy>?
    //    let objects010143: Results<DataBaseSettingsTaxonomy>?
    //    let objects010144: Results<DataBaseSettingsTaxonomy>?
    //
    //    private init() {
    //        // 階層3　中区分ごとの数を取得
    //        objects0100 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "0") // 流動資産
    //        objects0102 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "2") // 繰延資産
    //        objects0114 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "4") // 流動負債
    //        objects0115 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "5") // 固定負債
    //        objects0129 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "9") //株主資本14
    //        objects01210 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "10") //評価・換算差額等15
    //        //            0    1    2    11                    新株予約権
    //        //            0    1    2    12                    自己新株予約権
    //        //            0    1    2    13                    非支配株主持分
    //        //            0    1    2    14                    少数株主持分
    //        objects01211 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "11")//新株予約権16
    //        objects01213 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "13")//非支配株主持分22
    //        // 階層4 小区分
    //        objects010142 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "42") // 有形固定資産3
    //        objects010143 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "43") // 無形固定資産4
    //        objects010144 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "44") // 投資その他の資産5
    //    }
    //
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // データベースにモデルが存在するかどうかをチェックする　設定表示科目クラス
    func checkInitialising() -> Bool {
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomy.self)
        print("DataBaseSettingsTaxonomy", objects.count)
        return objects.count == 2_068 // モデルオブフェクトが2068ある場合はtrueを返す
    }
    // 取得 設定表示科目　階層2より下の階層で抽象項目以外の設定表示科目を取得
    func getAllSettingsTaxonomy() -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            NSPredicate(format: "category2 LIKE %@", NSString(string: "?*")), // nilチェック　大区分以降に値があるもののみに絞る
            NSPredicate(format: "abstract == %@", NSNumber(value: false)),
            // .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
            // .filter("switching == \(true)") // 不要　2020/08/02
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        if objects.isEmpty {
            print("ゼロ　getAllSettingsTaxonomy")
        }
        return objects
    }
    // 取得 設定表示科目　階層2より下の階層で抽象項目以外の設定表示科目を取得
    func getAllSettingsTaxonomySwitichON() -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            NSPredicate(format: "category2 LIKE %@", NSString(string: "?*")), // nilチェック　大区分以降に値があるもののみに絞る
            NSPredicate(format: "abstract == %@", NSNumber(value: false)),
            NSPredicate(format: "switching == %@", NSNumber(value: true))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        if objects.isEmpty {
            print("ゼロ　getAllSettingsTaxonomy")
        }
        return objects
    }
    // 取得 設定表示科目　大区分別　全て
    func getBigCategoryAll(section: Int) -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            NSPredicate(format: "category0 LIKE %@", NSString(string: String(section))) // 決算書の種類　貸借対照表とか損益計算書に絞る
            // .filter("category1 LIKE '\(1)'") // 2020/10/13 階層1で絞る
            // .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        if objects.isEmpty {
            print("ゼロ　getBigCategoryAll")
        }
        return objects
    }
    // 取得 設定表示科目　大区分別　階層2
    func getBigCategory(category0: String, category1: String, category2: String) -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            NSPredicate(format: "category0 LIKE %@", NSString(string: category0)),
            NSPredicate(format: "category1 LIKE %@", NSString(string: category1)),
            NSPredicate(format: "category2 LIKE %@", NSString(string: category2)), // 大区分　資産の部
            NSPredicate(format: "switching == %@", NSNumber(value: true)), // 2020/10/01
            NSPredicate(format: "abstract == %@", NSNumber(value: false)) // 2020/10/01
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        if objects.isEmpty {
            print("ゼロ　getBigCategory")
        }
        return objects
    }
    // 取得　設定表示科目 中区分別　階層3 抽象区分以外
    func getMiddleCategory(category0: String, category1: String, category2: String, category3: String) -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            NSPredicate(format: "category0 LIKE %@", NSString(string: category0)),
            NSPredicate(format: "category1 LIKE %@", NSString(string: category1)),
            NSPredicate(format: "category2 LIKE %@", NSString(string: category2)), // 大区分　資産の部
            NSPredicate(format: "category3 LIKE %@", NSString(string: category3)), // 中区分　流動資産
            // .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
            NSPredicate(format: "switching == %@", NSNumber(value: true)), // いる？　2020/09/23 要る　2020/09/29
            NSPredicate(format: "abstract == %@", NSNumber(value: false))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        if objects.isEmpty {
            print("ゼロ　getMiddleCategory", category0, category1, category2, category3)
        }
        return objects
    }
    // 取得　設定表示科目　小区分別　階層4 抽象区分以外
    func getSmallCategory(category0: String, category1: String, category2: String, category3: String, category4: String) -> Results<DataBaseSettingsTaxonomy> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomy.self, predicates: [
            // セクション　資産の部、負債の部、純資産の部
            NSPredicate(format: "category0 LIKE %@", NSString(string: category0)),
            NSPredicate(format: "category1 LIKE %@", NSString(string: category1)),
            NSPredicate(format: "category2 LIKE %@", NSString(string: category2)), // 大区分　資産の部
            NSPredicate(format: "category3 LIKE %@", NSString(string: category3)), // 中区分　流動資産
            NSPredicate(format: "category4 LIKE %@", NSString(string: category4)),
            NSPredicate(format: "switching == %@", NSNumber(value: true)), // 2020/09/29
            NSPredicate(format: "abstract == %@", NSNumber(value: false))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        if objects.isEmpty {
            print("ゼロ　getSmallCategory", category0, category1, category2, category3, category4)
        }
        return objects
    }
    // 取得　設定表示科目　表示科目の連番から設定表示科目を取得
    func getSettingsTaxonomy(numberOfTaxonomy: Int) -> DataBaseSettingsTaxonomy? {
        guard let object = RealmManager.shared.findFirst(type: DataBaseSettingsTaxonomy.self, key: numberOfTaxonomy) else { return nil }
        return object
    }
    
    // MARK: Update
    
    // 初期化
    func initializeSettingsTaxonomy() {
        // 表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountAll() // 設定勘定科目を全て取得
        for i in 0..<objects.count {
            if objects[i].switching == true { // 設定勘定科目 スイッチ
                if !objects[i].numberOfTaxonomy.isEmpty { // 表示科目に紐付けしている場合
                    updateSettingsCategoryBSAndPLSwitching(number: objects[i].number)
                }
            }
        }
    }
    // モデルオブフェクトの更新　スイッチの切り替え
    func updateSettingsCategoryBSAndPLSwitching(number: Int) { // 勘定科目　連番
        // 勘定科目連番から表示科目連番を取得
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let numberOfTaxonomy = databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(number: number)
        print("勘定科目: ", number)
        print("表示科目: ", numberOfTaxonomy)
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountInTaxonomy(number: number)// スイッチオンの勘定科目を取得
        do {
            if objects.isEmpty { // 表示科目に該当する勘定科目がすべてスイッチOFFだった場合
                // (2)書き込みトランザクション内でデータを更新する
                try DataBaseManager.realm.write {
                    let value: [String: Any] = ["number": numberOfTaxonomy, "switching": false]
                    DataBaseManager.realm.create(DataBaseSettingsTaxonomy.self, value: value, update: .modified) // 一部上書き更新
                }
            } else {
                try DataBaseManager.realm.write {
                    let value: [String: Any] = ["number": numberOfTaxonomy, "switching": true]
                    DataBaseManager.realm.create(DataBaseSettingsTaxonomy.self, value: value, update: .modified) // 一部上書き更新
                }
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Delete
    
    // 削除 表示科目
    func deleteAllOfSettingsTaxonomy() {
        let objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomy.self)
        // 表示科目　オブジェクトを削除
        for object in objects {
            do {
                try DataBaseManager.realm.write {
                    DataBaseManager.realm.delete(object)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
}
