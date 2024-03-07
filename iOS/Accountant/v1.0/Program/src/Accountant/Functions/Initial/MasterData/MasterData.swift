//
//  MasterData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// マスターデータクラス
class MasterData {

    func toBoolean(string: String) -> Bool {
        switch string {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            return false
        default:
            return false
        }
    }
    
    // 勘定科目　CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomyAccount() {
        if let csvPath = Bundle.main.path(forResource: "taxonomyAccount", ofType: "csv") {
            var csvString = ""
            do {
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> Void in
                // モデルオブフェクトを生成
                let dataBaseSettingsTaxonomyAccount = DataBaseSettingsTaxonomyAccount(
                    Rank0: line.components(separatedBy: ",")[0], // 大区分
                    Rank1: line.components(separatedBy: ",")[1], // 中区分
                    Rank2: line.components(separatedBy: ",")[2], // 小区分
                    numberOfTaxonomy: line.components(separatedBy: ",")[3], // 紐づけた表示科目
                    category: line.components(separatedBy: ",")[4], // 勘定科目名
                    AdjustingAndClosingEntries: false, // 決算整理仕訳　使用していない2020/10/07
                    switching: self.toBoolean(string: line.components(separatedBy: ",")[5]) // スイッチ
                )
                var number = 0 // 自動採番にした
                // 書き込み
                do {
                    try DataBaseManager.realm.write {
                        number = dataBaseSettingsTaxonomyAccount.save() // 連番　自動採番
                        // シリアルナンバー
                        dataBaseSettingsTaxonomyAccount.serialNumber = number
                        DataBaseManager.realm.add(dataBaseSettingsTaxonomyAccount)
                    }
                } catch {
                    print("エラーが発生しました")
                }
                print("連番: \(number), 勘定科目　CSVファイルを読み込み \(dataBaseSettingsTaxonomyAccount.numberOfTaxonomy)")
                if number == 229 {
                    // フラグを倒す 設定勘定科目　初期化
                    let userDefaults = UserDefaults.standard
                    let firstLunchKey = "settings_taxonomy_account"
                    userDefaults.set(false, forKey: firstLunchKey)
                    userDefaults.synchronize()
                    
                    stop = true
                }
            }
            // 保存先のパスを出力しておく
            print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL))")
        }
    }
    // 表示科目　CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomy() {
        if let csvPath = Bundle.main.path(forResource: "taxonomy", ofType: "csv") {
            var csvString = ""
            do {
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> Void in
                // モデルオブフェクトを生成
                let dataBaseSettingsCategoryTaxonomy = DataBaseSettingsTaxonomy(
                    category0: line.components(separatedBy: ",")[0],
                    category1: line.components(separatedBy: ",")[1],
                    category2: line.components(separatedBy: ",")[2],
                    category3: line.components(separatedBy: ",")[3],
                    category4: line.components(separatedBy: ",")[4],
                    category5: line.components(separatedBy: ",")[5],
                    category6: line.components(separatedBy: ",")[6],
                    category7: line.components(separatedBy: ",")[7],
                    category: line.components(separatedBy: ",")[8], // 表示科目
                    abstract: self.toBoolean(string: line.components(separatedBy: ",")[9]),
                    switching: self.toBoolean(string: line.components(separatedBy: ",")[10])
                )
                var number = 0 // 自動採番にした
                number = dataBaseSettingsCategoryTaxonomy.save() // 連番　自動採番
                // 書き込み
                do {
                    try DataBaseManager.realm.write {
                        DataBaseManager.realm.add(dataBaseSettingsCategoryTaxonomy)
                    }
                } catch {
                    print("エラーが発生しました")
                }
                print("連番: \(number) 表示科目　CSVファイルを読み込み")
                if number == 2_068 {
                    // フラグを倒す 設定表示科目　初期化
                    let userDefaults = UserDefaults.standard
                    let firstLunchKey = "settings_taxonomy"
                    userDefaults.set(false, forKey: firstLunchKey)
                    userDefaults.synchronize()
                    
                    stop = true
                }
            }
            // 保存先のパスを出力しておく
            print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL))")
        }
    }
}
