//
//  DatabaseManagerSettings.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DatabaseManagerSettingsCategory  {
    // データベース
    
    // データベースにDataBaseSettingsCategoryモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
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
    
    // モデルオブフェクトの取得
    func getSettings(section: Int) -> Results<DataBaseSettingsCategory> { //DataBaseSettingsCategory {
        // マスターデータから読み取り
        // .realmファイルを指定する
//        let config = Realm.Configuration(   // 構造体
//            fileURL: Bundle.main.url(forResource: "MasterData", withExtension:"realm"), // path: → fileURL 書き方が変更されていた
//            readOnly: true) // 読み取り専用
//        let realm = try! Realm(configuration: config)   // 構造体
//        var objects = realm.objects(DataBaseSettingsCategory.self).filter("number > 0")
        
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // DataBaseSettingsCategoryモデル
        // ソートする        注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
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
            objects = objects.filter("big_category == 0") // ありえない
            break
        }
        return objects
    }
    // モデルオブフェクトの更新
    func setSettingsCategorySwitching(tag: Int, isOn: Bool){
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": tag, "switching": isOn]
            realm.create(DataBaseSettingsCategory.self, value: value, update: .modified) // 一部上書き更新
        }
    }
}
