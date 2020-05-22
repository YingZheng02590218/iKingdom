//
//  DatabaseManagerSettings.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DatabaseManagerSettings  {
    
    // データベース
    
    // モデルオブフェクトの追加 マスターデータを作成する時のみ使用
    func addCategory(big_category: Int,small_category: Int,category: String,explaining: String,switching: Bool) {
        // オブジェクトを作成
        let dataBaseSettings = DataBaseSettings() //設定
        // 自動採番にした
        var number = 0
        dataBaseSettings.big_category = big_category            //大分類
        dataBaseSettings.small_category = small_category            //小分類
        dataBaseSettings.category = category                    //勘定科目
        dataBaseSettings.explaining = explaining                //説明
        dataBaseSettings.switching = switching                  //有効無効
        
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            number = dataBaseSettings.save() //番号　自動採番
            realm.add(dataBaseSettings)
        }
        print(number)
        print(dataBaseSettings)
    }
    
    // モデルオブフェクトの取得
    func getSettings(section: Int) -> Results<DataBaseSettings> { //DataBaseSettings {
        // .realmファイルを指定する
        let config = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "MasterData", withExtension:"realm"),
            readOnly: true)
        let realm = try! Realm(configuration: config)
        var objects = realm.objects(DataBaseSettings.self).filter("number > 0")
        
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsモデルを全て取得する
//        var objects = realm.objects(DataBaseSettings.self) // DataBaseSettingsモデル
        // ソートする        注意：ascending: true とするとDataBaseSettingsのnumberの自動採番がおかしくなる
//        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        
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
    
}
