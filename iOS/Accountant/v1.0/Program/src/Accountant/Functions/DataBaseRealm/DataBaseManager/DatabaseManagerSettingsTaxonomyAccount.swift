//
//  DatabaseManagerSettingsTaxonomyAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定勘定科目クラス
class DatabaseManagerSettingsTaxonomyAccount {
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　設定勘定科目　新規作成
    func addSettingsTaxonomyAccount(rank0: String, rank1: String, rank2: String, numberOfTaxonomy: String, category: String, switching: Bool) -> Int {
        // オブジェクトを作成
        let dataBaseSettingsTaxonomyAccount = DataBaseSettingsTaxonomyAccount(
            Rank0: rank0,
            Rank1: rank1,
            Rank2: rank2,
            numberOfTaxonomy: numberOfTaxonomy,
            category: category,
            AdjustingAndClosingEntries: false, // 決算整理仕訳　使用していない2020/10/07
            switching: switching
        )
        var number = 0
        
        do {
            try DataBaseManager.realm.write {
                number = dataBaseSettingsTaxonomyAccount.save() //　自動採番
                // 設定勘定科目を追加
                DataBaseManager.realm.add(dataBaseSettingsTaxonomyAccount)
            }
        } catch {
            print("エラーが発生しました")
        }
        // オブジェクトを作成 勘定クラス
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        dataBaseManagerAccount.addGeneralLedgerAccount(number: number)
        return number
    }
    
    // MARK: Read
    
    // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
    func isExistSettingsTaxonomyAccount(category: String) -> Bool {
        let dataBaseSettingsTaxonomyAccounts = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "category LIKE %@", NSString(string: category))
        ])
        if !dataBaseSettingsTaxonomyAccounts.isEmpty {
            return true // ある
        } else {
            return false // ない
        }
    }
    // チェック
    func checkInitialising() -> Bool {
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        print("DataBaseSettingsTaxonomyAccount", objects.count)
        return objects.count >= 229 // モデルオブフェクトが229以上ある場合はtrueを返す　ユーザーが作成した勘定科目があるため
    }
    // チェック　勘定科目名から大区分が損益計算書の区分かを参照する
    func checkSettingsTaxonomyAccountRank0(account: String) -> Bool {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "category LIKE %@", NSString(string: account)) // 勘定科目を絞る
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch objects[0].Rank0 {
        case "6", "7", "8", "9", "10", "11":
            return true // 損益計算書の科目である
        default:
            return false // 損益計算書の科目ではない
        }
    }
    // 取得　決算整理仕訳　スイッチ
    func getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: Bool, switching: Bool) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "AdjustingAndClosingEntries == %@", NSNumber(value: adjustingAndClosingEntries)),
            NSPredicate(format: "switching == %@", NSNumber(value: switching)) // 勘定科目がONだけに絞る
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得 全ての勘定科目
    func getSettingsTaxonomyAccountAll() -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
    func getSettingsSwitchingOnBSorPL(BSorPL: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "switching == %@", NSNumber(value: true)) // 勘定科目がONだけに絞る
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch BSorPL {
        case 0: // 貸借対照表　資産 負債 純資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)' OR Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)' OR Rank0 LIKE '\(5)' OR Rank0 LIKE '\(12)'")
        case 1: // 損益計算書　費用 収益
            objects = objects.filter("Rank0 LIKE '\(6)' OR Rank0 LIKE '\(7)' OR Rank0 LIKE '\(8)' OR Rank0 LIKE '\(9)' OR Rank0 LIKE '\(10)' OR Rank0 LIKE '\(11)'")
        default:
            print(objects) // ありえない
        }
        return objects
    }
    // 取得 設定勘定科目連番　から　表示科目別に勘定科目を取得
    func getSettingsTaxonomyAccountInTaxonomy(number: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        // 設定勘定科目連番から設定勘定科目を取得
        let object = DataBaseManager.realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number)
        // 勘定科目モデルの階層と同じ勘定科目モデルを取得
        let objects = getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: object!.numberOfTaxonomy)
            .filter("switching == \(true)") // 勘定科目がONだけに絞る
        print(number, objects)
        return objects
    }
    // 取得 勘定科目の勘定科目名から表示科目連番を取得
    func getNumberOfTaxonomy(category: String) -> Int {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "category LIKE %@", NSString(string: category)) // 勘定科目を絞る
        ])
        return Int(objects[0].numberOfTaxonomy) ?? 0
    }
    // 取得 勘定科目連番から表示科目連番を取得
    func getNumberOfTaxonomy(number: Int) -> Int {
        // 勘定科目モデルを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return 0 }
        return Int(object.numberOfTaxonomy) ?? 0
    }
    // 取得 勘定科目の連番から勘定科目を取得
    func getSettingsTaxonomyAccount(number: Int) -> DataBaseSettingsTaxonomyAccount? {
        guard let object = RealmManager.shared.findFirst(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return nil }
        return object
    }
    // 取得 設定表示科目連番から表示科目別に設定勘定科目を取得
    func getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "numberOfTaxonomy LIKE %@", NSString(string: numberOfTaxonomy)) // 表示科目別に絞る
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    
    // MARK: Update
    
    // 初期化
    func initializeSettingsTaxonomyAccount() {
        // 勘定科目のスイッチを設定する　表示科目科目が選択されていなければOFFにする
        let objects = getSettingsTaxonomyAccountAll() // 設定勘定科目を全て取得
        for i in 0..<objects.count {
            if objects[i].switching == true { // 設定勘定科目 スイッチ
                if objects[i].numberOfTaxonomy.isEmpty { // 表示科目に紐付けしていない場合
                    updateSettingsCategorySwitching(tag: objects[i].number, isOn: false)
                }
            } else if objects[i].switching == false { // 表示科目科目が選択されていて仕訳データがあればONにする
                if !objects[i].numberOfTaxonomy.isEmpty { // 表示科目に紐付けしている場合
                    // 勘定クラス　勘定ないの仕訳を取得
                    let dataBaseManagerAccount = GeneralLedgerAccountModel()
                    let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    if !objectss.isEmpty || !objectsss.isEmpty {
                        updateSettingsCategorySwitching(tag: objects[i].number, isOn: true)
                    }
                }
            }
        }
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
    // 更新　勘定科目名を変更
    func updateAccountNameOfSettingsTaxonomyAccount(number: Int, accountName: String) { // すべての影響範囲に修正が必要
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": number, "category": accountName]
                DataBaseManager.realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 更新　設定勘定科目　設定勘定科目連番から、紐づける表示科目を変更
    func updateTaxonomyOfSettingsTaxonomyAccount(number: Int, numberOfTaxonomy: String) {
        do {
            // (2)書き込みトランザクション内でデータを更新する
            try DataBaseManager.realm.write {
                let value: [String: Any] = ["number": number, "numberOfTaxonomy": numberOfTaxonomy]
                DataBaseManager.realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    
    // MARK: Delete
    
    // 削除 勘定科目
    func deleteAllOfSettingsTaxonomyAccount() {
        let objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        // 表示科目　オブジェクトを削除
        for object in objects {
            do {
                try DataBaseManager.realm.write {
                    DataBaseManager.realm.delete(object)
                }
            } catch {
                print("エラーが発生しました")
            }
        }
    }
}
