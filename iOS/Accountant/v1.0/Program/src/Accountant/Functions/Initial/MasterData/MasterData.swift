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
                    // numberOfTaxonomy: line.components(separatedBy: ",")[3], // 紐づけた表示科目　表示科目を廃止
                    category: line.components(separatedBy: ",")[4], // 勘定科目名
                    AdjustingAndClosingEntries: false, // TODO: 決算整理仕訳　使用していない 2020/10/07
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
                print("連番: \(number), 勘定科目　CSVファイルを読み込み")
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
}
