//
//  CategoryListModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/14.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol CategoryListModelInput {

    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount>
    func getSettingsSwitchingOn(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount>

    func updateSettingsCategorySwitching(tag: Int, isOn: Bool)
    func deleteSettingsTaxonomyAccount(number: Int) -> Bool
}

// クラス
class CategoryListModel: CategoryListModelInput {

    // 取得 大区分、中区分、小区分
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = DataBaseManager.realm.objects(DataBaseSettingsTaxonomyAccount.self)
            .sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
            .filter("Rank0 LIKE '\(rank0)'") // 大区分　流動資産
            // .filter("Rank2 LIKE '\(Rank2)'") // 小区分　未使用
        if let rank1 = rank1 {
            objects = objects.filter("Rank1 LIKE '\(rank1)'") // 中区分　当座資産
        }
        return objects
    }
    // 取得 大区分別に、スイッチONの勘定科目
    func getSettingsSwitchingOn(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = DataBaseManager.realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
            .filter("switching == \(true)") // 勘定科目がONだけに絞る
        return objects
    }
    // 更新　スイッチの切り替え
    func updateSettingsCategorySwitching(tag: Int, isOn: Bool) {
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": tag, "switching": isOn]
                DataBaseManager.realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 削除　設定勘定科目
    func deleteSettingsTaxonomyAccount(number: Int) -> Bool {
        // 勘定クラス　勘定を削除
        let dataBaseManagerAccount = GenearlLedgerAccountModel()
        let isInvalidated = dataBaseManagerAccount.deleteAccount(number: number)
        if isInvalidated {
            do {
                // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
                if let object = DataBaseManager.realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number) {
                    try DataBaseManager.realm.write {
                        // 仕訳が残ってないか
                        // 勘定を削除
                        DataBaseManager.realm.delete(object)
                    }
                    return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
                }
            } catch {
                print("エラーが発生しました")
            }
        }
        return false // 勘定を削除できたら、設定勘定科目を削除する
    }
}
