//
//  DataBaseManagerSettingsCategoryBSAndPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManagerSettingsCategoryBSAndPL {
    
    // データベースにモデルが存在するかどうかをチェックする　設定表記名クラス
    func checkInitialising() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self)
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // 設定表記名　取得 すべて
    func getAllSettingsCategoryBSAndPL() -> Results<DataBaseSettingsCategoryBSAndPL> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self) // DataBaseSettingsCategoryモデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
//                            .filter("switching == \(true)") // 不要　2020/08/02
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // 設定表記名　取得 ONのみ
    func getAllSettingsCategoryBSAndPLSwitichON() -> Results<DataBaseSettingsCategoryBSAndPL> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self) // DataBaseSettingsCategoryモデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
//                            .filter("switching == \(true)") // 不要　2020/08/02
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // 設定表記名　取得 大分類別
    func getBigCategory(section: Int) -> Results<DataBaseSettingsCategoryBSAndPL> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self) // モデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("big_category == \(section)")
                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
                            .filter("switching == \(true)")
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // 設定表記名　取得 中分類別
    func getMiddleCategory(mid_category: Int) -> Results<DataBaseSettingsCategoryBSAndPL> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self) // モデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("mid_category == \(mid_category)")
                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
                            .filter("switching == \(true)")
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // 設定表記名　取得　小分類別
    func getSmallCategory(section: Int, small_category: Int) -> Results<DataBaseSettingsCategoryBSAndPL> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("small_category == \(small_category)")
                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
                            .filter("switching == \(true)")
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // モデルオブフェクトの更新　スイッチの切り替え
    func updateSettingsCategoryBSAndPLSwitching(){
        let objects = getAllSettingsCategoryBSAndPL()// スイッチオンの表記名を取得
        let dm = DatabaseManagerSettingsCategory()
        for i in 0..<objects.count { // 表記名の数だけ繰り返す
            let oj = dm.getSettingsCategoryBSAndPL(bSAndPL_category: objects[i].BSAndPL_category)
            if oj.count <= 0 { // 表記名に該当する勘定科目がすべてスイッチOFFだった場合
                // データベース　読み込み
                // (1)Realmのインスタンスを生成する
                let realm = try! Realm()
                // (2)書き込みトランザクション内でデータを更新する
                try! realm.write {
                    let value: [String: Any] = ["number": objects[i].number, "switching": false]
                    realm.create(DataBaseSettingsCategoryBSAndPL.self, value: value, update: .modified) // 一部上書き更新
                }
            }else {
                // データベース　読み込み
                // (1)Realmのインスタンスを生成する
                let realm = try! Realm()
                // (2)書き込みトランザクション内でデータを更新する
                try! realm.write {
                    let value: [String: Any] = ["number": objects[i].number, "switching": true]
                    realm.create(DataBaseSettingsCategoryBSAndPL.self, value: value, update: .modified) // 一部上書き更新
                }
            }
        }
    }
}
