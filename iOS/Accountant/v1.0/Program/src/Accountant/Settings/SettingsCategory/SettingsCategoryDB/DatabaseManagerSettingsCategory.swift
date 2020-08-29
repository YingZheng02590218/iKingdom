//
//  DatabaseManagerSettings.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 設定勘定科目クラス
class DatabaseManagerSettingsCategory  {
    
    // データベースにDataBaseSettingsCategoryモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsCategory.self)
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加 マスターデータを作成する時のみ使用
//    func addCategory(big_category: Int,small_category: Int,category: String,explaining: String,switching: Bool) {
//        // オブジェクトを作成
//        let dataBaseSettingsCategory = DataBaseSettingsCategory() //設定
//        // 自動採番にした
//        var number = 0
//        dataBaseSettingsCategory.big_category = big_category            //大分類
//        dataBaseSettingsCategory.small_category = small_category            //小分類
//        dataBaseSettingsCategory.category = category                    //勘定科目
//        dataBaseSettingsCategory.explaining = explaining                //説明
//        dataBaseSettingsCategory.switching = switching                  //有効無効
//        // データベース　書き込み
//        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
//        // (2)書き込みトランザクション内でデータを追加する
//        try! realm.write {
//            number = dataBaseSettingsCategory.save() //番号　自動採番
//            realm.add(dataBaseSettingsCategory)
//        }
//        print(number)
//        print(dataBaseSettingsCategory)
//    }
    // モデルオブフェクトの取得　期中の勘定科目　決算整理仕訳以外　設定ONのみ
    func getAllSettingsCategory() -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("AdjustingAndClosingEntries == \(false)")
                            .filter("switching == \(true)") // 勘定科目がONだけに絞る
        return objects
    }
    // モデルオブフェクトの取得　期末の勘定科目　決算整理仕訳のみ　設定ONのみ
    func getAllSettingsCategoryForAdjusting() -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("AdjustingAndClosingEntries == \(true)") // 修正記入の勘定科目に絞る
                            .filter("switching == \(true)") // 勘定科目がONだけに絞る
        return objects
    }
    // モデルオブフェクトの取得 全ての勘定科目
    func getSettings(section: Int) -> Results<DataBaseSettingsCategory> {
        // マスターデータから読み取り
        // .realmファイルを指定する
//        let config = Realm.Configuration(   // 構造体
//            fileURL: Bundle.main.url(forResource: "MasterData", withExtension:"realm"), // path: → fileURL 書き方が変更されていた
//            readOnly: true) // 読み取り専用
//        let realm = try! Realm(configuration: config)   // 構造体
//        var objects = realm.objects(DataBaseSettingsCategory.self).filter("number > 0")

        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        switch section {
        case 0: // 資産
            objects = objects.filter("big_category == 0")
            break
        case 1: // 負債
            objects = objects.filter("big_category == 1")
            break
        case 2: // 純資産
            objects = objects.filter("big_category == 2")
            break
        case 3: // 費用
            objects = objects.filter("big_category == 3")
            break
        case 4: // 収益
            objects = objects.filter("big_category == 4")
            break
        default:
            print(objects) // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの取得 スイッチONの全ての勘定科目
    func getSettingsSwitchingOn(section: Int) -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("switching == \(true)") // 勘定科目がONだけに絞る
        switch section {
        case 0: // 資産
            objects = objects.filter("big_category == 0")
            break
        case 1: // 負債
            objects = objects.filter("big_category == 1")
            break
        case 2: // 純資産
            objects = objects.filter("big_category == 2")
            break
        case 3: // 費用
            objects = objects.filter("big_category == 3")
            break
        case 4: // 収益
            objects = objects.filter("big_category == 4")
            break
        default:
            print(objects) // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの取得 スイッチONのBSかPLの勘定科目
    func getSettingsSwitchingOnBSorPL(BSorPL: Int) -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("switching == \(true)") // 勘定科目がONだけに絞る
        switch BSorPL {
        case 0: // 貸借対照表　資産 負債 純資産
            objects = objects.filter("big_category == 0 || big_category == 1 || big_category == 2")
            break
        case 1: // 損益計算書　費用 収益
            objects = objects.filter("big_category == 3 || big_category == 4")
            break
        default:
            print(objects) // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの取得
    func getMiddleCategory(mid_category: Int) -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        // セクション　資産の部、負債の部、純資産の部
        switch mid_category {
        case 0: // 流動資産
            objects = objects.filter("mid_category == 0")
            break
        case 1: // 固定資産
            objects = objects.filter("mid_category == 1")
            break
        case 2: // 流動負債
            objects = objects.filter("mid_category == 2")
            break
        case 3: // 固定負債
            objects = objects.filter("mid_category == 3")
            break
        case 4: // 株主資本
            objects = objects.filter("mid_category == 4")
            break
        case 5: // 営業費用
            objects = objects.filter("mid_category == 5")
            break
        case 6: // 営業外費用
            objects = objects.filter("mid_category == 6")
            break
        case 7: // 特別損失
            objects = objects.filter("mid_category == 7")
            break
        case 8: // 税等
            objects = objects.filter("mid_category == 8")
            break
        case 9: // 営業収益
            objects = objects.filter("mid_category == 9")
            break
        case 10: // 営業外収益
            objects = objects.filter("mid_category == 10")
            break
        case 11: // 特別利益
            objects = objects.filter("mid_category == 11")
            break
        default:
            objects = objects.filter("mid_category == 0") // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの取得
    func getSmallCategory(section: Int, small_category: Int) -> Results<DataBaseSettingsCategory> {//Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        // セクション　資産の部、負債の部、純資産の部
        objects = objects.filter("big_category == \(section)")
        switch small_category {
        case 0: // 当座資産0
            objects = objects.filter("small_category == 0")
            break
        case 1: // 棚卸資産1
            objects = objects.filter("small_category == 1")
            break
        case 2: // その他の資産2
            objects = objects.filter("small_category == 2")
            break
        case 3: // 有形固定資産3
            objects = objects.filter("small_category == 3")
            break
        case 4: // 無形固定資産4
            objects = objects.filter("small_category == 4")
            break
        case 5: // 投資その他の資産5
            objects = objects.filter("small_category == 5")
            break
        case 6: // 仕入債務6
            objects = objects.filter("small_category == 6")
            break
        case 7: // その他流動負債7
            objects = objects.filter("small_category == 7")
            break
        case 8: // 売上原価8
            objects = objects.filter("small_category == 8")
            break
        case 9: // 販売費及び一般管理費9
            objects = objects.filter("small_category == 9")
            break
        case 10: // 売上高10
            objects = objects.filter("small_category == 10")
            break
//        case 13: // 引当金13
//            objects = objects.filter("small_category == 13")
//            break
        case 23: // 減価償却累計額23
            objects = objects.filter("small_category == 23")
            break
        case 103: // 未収収益103
            objects = objects.filter("small_category == 103")
            break
        case 100: // 前払費用100
            objects = objects.filter("small_category == 100")
            break
        case 101: // 前受収益101
            objects = objects.filter("small_category == 101")
            break
        case 102: // 未払費用102
            objects = objects.filter("small_category == 102")
            break
        case 15: // 評価・換算差額等15
            objects = objects.filter("small_category == 15")
            break
        case 21: // 固定資産売却損21
            objects = objects.filter("small_category == 21")
            break
        default:
            objects = objects.filter("small_category == 0") // ありえない
            break
        }
        return objects//.count
    }
    // モデルオブフェクトの取得 表記名別に勘定科目を取得
    func getSettingsCategoryBSAndPL(bSAndPL_category: Int) -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("BSAndPL_category == \(bSAndPL_category)")// 表記名別に絞る
                            .filter("switching == \(true)") // 勘定科目がONだけに絞る
        return objects
    }
    // モデルオブフェクトの更新　スイッチの切り替え
    func updateSettingsCategorySwitching(tag: Int, isOn: Bool){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": tag, "switching": isOn]
            realm.create(DataBaseSettingsCategory.self, value: value, update: .modified) // 一部上書き更新
        }
    }
}
