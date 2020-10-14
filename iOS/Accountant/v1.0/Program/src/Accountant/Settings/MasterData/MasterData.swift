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
//    var categories :[String] = Array<String>()
//    var subCategories_assets :[String] = Array<String>()
//    var subCategories_liabilities :[String] = Array<String>()
//    var subCategories_netAsset :[String] = Array<String>()
//    var subCategories_expends :[String] = Array<String>()
//    var subCategories_revenue :[String] = Array<String>()
    
    // 初期設定データ
//    func setInitialData() {
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
//    }
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
//    func readMasterDataFromCSV() {
//        if let csvPath = Bundle.main.path(forResource: "MasterData", ofType: "csv") {
//            var csvString = ""
//            do{
//                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//            csvString.enumerateLines { (line, stop) -> () in
//                // 保存先のパスを出力しておく
//                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
//                // モデルオブフェクトを生成
//                let dataBaseSettings = DataBaseSettingsCategory()
//                var number = 0 // 自動採番にした
//                dataBaseSettings.big_category = Int(line.components(separatedBy:",")[0])!
//                dataBaseSettings.mid_category = Int(line.components(separatedBy:",")[1])!
//                dataBaseSettings.small_category = Int(line.components(separatedBy:",")[2])!
//                dataBaseSettings.BSAndPL_category = Int(line.components(separatedBy:",")[3])!//貸借対照表と損益計算書の区分
//                dataBaseSettings.AdjustingAndClosingEntries = self.toBoolean(string: line.components(separatedBy:",")[4])//決算整理仕訳
//                dataBaseSettings.category = line.components(separatedBy:",")[5]
//                dataBaseSettings.explaining = line.components(separatedBy:",")[6]
//                dataBaseSettings.switching = self.toBoolean(string: line.components(separatedBy:",")[7])
//                // 書き込み
//                let realm = try! Realm()
//                try! realm.write {
//                    number = dataBaseSettings.save() // 連番　自動採番
//                    realm.add(dataBaseSettings)
//                }
//                print("連番: \(number)")
//            }
//        }
//    }
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
//    func readMasterDataFromCSVOfBSAndPL() {
//        if let csvPath = Bundle.main.path(forResource: "MasterDataBSAndPL", ofType: "csv") {
//            var csvString = ""
//            do{
//                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//            csvString.enumerateLines { (line, stop) -> () in
//                // 保存先のパスを出力しておく
//                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
//                // モデルオブフェクトを生成
//                let dataBaseSettingsCategoryBSAndPL = DataBaseSettingsCategoryBSAndPL()
//                var number = 0 // 自動採番にした
//                dataBaseSettingsCategoryBSAndPL.big_category = Int(line.components(separatedBy:",")[0])!
//                dataBaseSettingsCategoryBSAndPL.mid_category = Int(line.components(separatedBy:",")[1])!
//                dataBaseSettingsCategoryBSAndPL.small_category = Int(line.components(separatedBy:",")[2])!
//                dataBaseSettingsCategoryBSAndPL.BSAndPL_category = Int(line.components(separatedBy:",")[3])! //表示科目
//                dataBaseSettingsCategoryBSAndPL.category = line.components(separatedBy:",")[4]//表示科目
//                dataBaseSettingsCategoryBSAndPL.switching = self.toBoolean(string: line.components(separatedBy:",")[5])
//                // 書き込み
//                let realm = try! Realm()
//                try! realm.write {
//                    number = dataBaseSettingsCategoryBSAndPL.save() // 連番　自動採番
//                    realm.add(dataBaseSettingsCategoryBSAndPL)
//                }
//                print("連番: \(number)")
//            }
//        }
//    }
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
    
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomyAccount() {
        if let csvPath = Bundle.main.path(forResource: "TaxonomyAccount", ofType: "csv") {
            var csvString = ""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in
                // 保存先のパスを出力しておく
                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
                // モデルオブフェクトを生成
                let dataBaseSettingsTaxonomyAccount = DataBaseSettingsTaxonomyAccount()
                var number = 0 // 自動採番にした
                dataBaseSettingsTaxonomyAccount.Rank0 = line.components(separatedBy:",")[0] // 大区分
                dataBaseSettingsTaxonomyAccount.Rank1 = line.components(separatedBy:",")[1] // 中区分
                dataBaseSettingsTaxonomyAccount.Rank2 = line.components(separatedBy:",")[2] // 小区分
                dataBaseSettingsTaxonomyAccount.numberOfTaxonomy = line.components(separatedBy:",")[3] // 紐づけた表示科目
                dataBaseSettingsTaxonomyAccount.category = line.components(separatedBy:",")[4] // 勘定科目名
//                dataBaseSettings.AdjustingAndClosingEntries = self.toBoolean(string: line.components(separatedBy:",")[10])//決算整理仕訳
                dataBaseSettingsTaxonomyAccount.switching = self.toBoolean(string: line.components(separatedBy:",")[5]) // スイッチ
//                dataBaseSettings.explaining = line.components(separatedBy:",")[12]
                // 書き込み
                let realm = try! Realm()
                try! realm.write {
                    number = dataBaseSettingsTaxonomyAccount.save() // 連番　自動採番
                    realm.add(dataBaseSettingsTaxonomyAccount)
                }
                print("連番: \(number)")
            }
        }
    }
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomy() {
        if let csvPath = Bundle.main.path(forResource: "taxonomy", ofType: "csv") {
            var csvString = ""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in
                // 保存先のパスを出力しておく
                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
                // モデルオブフェクトを生成
                let dataBaseSettingsCategoryTaxonomy = DataBaseSettingsTaxonomy()
                var number = 0 // 自動採番にした
                dataBaseSettingsCategoryTaxonomy.category0 = line.components(separatedBy:",")[0]
                dataBaseSettingsCategoryTaxonomy.category1 = line.components(separatedBy:",")[1]
                dataBaseSettingsCategoryTaxonomy.category2 = line.components(separatedBy:",")[2]
                dataBaseSettingsCategoryTaxonomy.category3 = line.components(separatedBy:",")[3]
                dataBaseSettingsCategoryTaxonomy.category4 = line.components(separatedBy:",")[4]
                dataBaseSettingsCategoryTaxonomy.category5 = line.components(separatedBy:",")[5]
                dataBaseSettingsCategoryTaxonomy.category6 = line.components(separatedBy:",")[6]
                dataBaseSettingsCategoryTaxonomy.category7 = line.components(separatedBy:",")[7]
                dataBaseSettingsCategoryTaxonomy.category = line.components(separatedBy:",")[8]//表示科目
                dataBaseSettingsCategoryTaxonomy.abstract = self.toBoolean(string: line.components(separatedBy:",")[9])
                dataBaseSettingsCategoryTaxonomy.switching = self.toBoolean(string: line.components(separatedBy:",")[10])
                // 書き込み
                let realm = try! Realm()
                try! realm.write {
                    number = dataBaseSettingsCategoryTaxonomy.save() // 連番　自動採番
                    realm.add(dataBaseSettingsCategoryTaxonomy)
                }
                print("連番: \(number)")
            }
        }
    }
}
