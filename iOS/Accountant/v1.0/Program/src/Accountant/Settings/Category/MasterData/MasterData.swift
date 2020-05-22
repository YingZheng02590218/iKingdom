//
//  MasterData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class MasterData {
        
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()

    // 初期設定データ
    func setInitialData() {
        // データベース　仕訳データを追加
//        let databaseManagerSettings = DatabaseManagerSettings() //データベースマネジャー
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
//        let number = databaseManagerSettings.addCategory(
//            big_category: big_category,
//            sub_category: sub_category,
//            category: category,
//            explaining: explaining,
//            switching: switching
//        )
    }
    
    // マスターデータ読み込み
    func readMasterDataFromCSV() {
        if let csvPath = Bundle.main.path(forResource: "MasterData", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in

                 // 保存先のパスを出力しておく
                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")

                let dataBaseSettings = DataBaseSettings()
                var number = 0 // 自動採番にした
                dataBaseSettings.big_category = Int(line.components(separatedBy:",")[0])!
                dataBaseSettings.mid_category = Int(line.components(separatedBy:",")[1])!
                dataBaseSettings.small_category = Int(line.components(separatedBy:",")[2])!
                dataBaseSettings.category = line.components(separatedBy:",")[3]
                dataBaseSettings.explaining = line.components(separatedBy:",")[4]
                dataBaseSettings.switching = self.toBoolean(string: line.components(separatedBy:",")[5])

                let realm = try! Realm()
                try! realm.write {
                    number = dataBaseSettings.save() //仕分け番号　自動採番
                    realm.add(dataBaseSettings)
                }
            print("連番: \(number)")
            }
        }
    }
    
    func toBoolean(string:String) -> Bool {
        switch string {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            return false
        default:
            return false
        }
    }
    
}
