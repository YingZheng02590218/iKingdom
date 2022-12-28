//
//  DataBaseManagerSettingsOperating.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定操作クラス
class DataBaseManagerSettingsOperating {

    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseSettingsOperating.self)
        return !objects.isEmpty // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加　仕訳帳
    func addSettingsOperating() {
        do {
            // オブジェクトを作成  設定仕訳帳
            let dataBaseSettingsOperating = DataBaseSettingsOperating(
                EnglishFromOfClosingTheLedger0: true,
                EnglishFromOfClosingTheLedger1: true
            )
            try DataBaseManager.realm.write {
                let number = dataBaseSettingsOperating.save() // 自動採番
                print(number)
                DataBaseManager.realm.add(dataBaseSettingsOperating)
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 取得
    func getSettingsOperating() -> DataBaseSettingsOperating? {
        guard let object = RealmManager.shared.findFirst(type: DataBaseSettingsOperating.self, key: 1) else { return nil }
        return object
    }
    // 更新　スイッチの切り替え
    func updateSettingsOperating(englishFromOfClosingTheLedger: String, isOn: Bool) {
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": 1,
                    "\(englishFromOfClosingTheLedger)": isOn
                ]
                DataBaseManager.realm.create(DataBaseSettingsOperating.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
}
