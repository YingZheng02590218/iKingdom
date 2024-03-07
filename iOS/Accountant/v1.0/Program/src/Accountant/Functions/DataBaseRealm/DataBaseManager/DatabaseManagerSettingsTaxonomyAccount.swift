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

    public static let shared = DatabaseManagerSettingsTaxonomyAccount()

    private init() {
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // 追加　設定勘定科目　新規作成　（元入金、事業主貸、事業主借、新規の勘定科目を作成時に使用している）
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
                // シリアルナンバー
                dataBaseSettingsTaxonomyAccount.serialNumber = number
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
    // 取得　引数と同じ勘定科目名がの設定勘定科目
    func getSettingsTaxonomyAccount(category: String) -> DataBaseSettingsTaxonomyAccount? {
        let dataBaseSettingsTaxonomyAccounts = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "category LIKE %@", NSString(string: category))
        ])
        return dataBaseSettingsTaxonomyAccounts.first
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
    // 取得　設定勘定科目　スイッチ
    func getSettingsTaxonomyAccountAdjustingSwitch(adjustingAndClosingEntries: Bool, switching: Bool) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            // FIXME: 使用していないプロパティを使っている
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
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)' OR Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)' OR Rank0 LIKE '\(5)' OR Rank0 LIKE '\(12)'") // FIXME: 12 は使用していない
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
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "category LIKE %@", NSString(string: category)) // 勘定科目を絞る
        ])
        return Int(objects[0].numberOfTaxonomy) ?? 0
    }
    // 取得 勘定科目連番から表示科目連番を取得
    func getNumberOfTaxonomy(number: Int) -> Int {
        // 勘定科目モデルを取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return 0 }
        return Int(object.numberOfTaxonomy) ?? 0
    }
    // 取得 勘定科目の連番から設定勘定科目を取得
    func getSettingsTaxonomyAccount(number: Int) -> DataBaseSettingsTaxonomyAccount? {
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return nil }
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
    // 取得　設定勘定科目　五大区分
    func getAccountsInBig5(big5: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.read(type: DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch big5 {
        case 0: // 資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)'") // 流動資産, 固定資産, 繰延資産
        case 1: // 負債
            objects = objects.filter("Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)'") // 流動負債, 固定負債
        case 2: // 純資産
            objects = objects.filter("Rank0 LIKE '\(5)'") // 資本, 2020/11/09 不使用　評価・換算差額等　 OR Rank0 LIKE '\(12)'
        default:
            print("")
        }
        return objects
    }
    // 取得　設定勘定科目　大区分
    func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "Rank0 LIKE %@", NSString(string: String(rank0)))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得　設定勘定科目　中区分
    func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "Rank1 LIKE %@", NSString(string: String(rank1)))
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得 大区分、中区分、小区分
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        var predicates = [
            NSPredicate(format: "Rank0 LIKE %@", NSString(string: String(rank0))) // 大区分　流動資産
            // .filter("Rank2 LIKE '\(Rank2)'") // 小区分　未使用
        ]
        if let rank1 = rank1 {
            predicates.append(NSPredicate(format: "Rank1 LIKE %@", NSString(string: String(rank1)))) // 中区分　当座資産
        }
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: predicates)
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主
    func getDataBaseSettingsTaxonomyAccountInRankValid(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        var predicates = [
            NSPredicate(format: "Rank0 LIKE %@", NSString(string: String(rank0))), // 大区分　流動資産
            // .filter("Rank2 LIKE '\(Rank2)'") // 小区分　未使用
            NSPredicate(format: "switching == %@", NSNumber(value: true)) // 勘定科目がONだけに絞る
        ]
        if let rank1 = rank1 {
            predicates.append(NSPredicate(format: "Rank1 LIKE %@", NSString(string: String(rank1)))) // 中区分　当座資産
        }
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: predicates)
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 取得 大区分別に、スイッチONの勘定科目
    func getSettingsSwitchingOn(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "Rank0 LIKE %@", NSString(string: String(rank0))),
            NSPredicate(format: "switching == %@", NSNumber(value: true)) // 勘定科目がONだけに絞る
        ])
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        if accountName == "損益" {
            return 0
        } else {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
                // DataBaseAccount.self) 2020/11/08
                NSPredicate(format: "category LIKE %@", NSString(string: accountName)) // "accountName LIKE '\(accountName)'")// 2020/11/08
            ])
            // 設定勘定科目のプライマリーキーを取得する
            if let numberOfAccount = objects.first {
                return numberOfAccount.number
            } else {
                return 0 // クラッシュ対応
            }
        }
    }

    // MARK: Update
    
    // 初期化
    func initializeSettingsTaxonomyAccount() {
        // 勘定科目のスイッチを設定する　表示科目科目が選択されていなければOFFにする
        let objects = getSettingsTaxonomyAccountAll() // 設定勘定科目を全て取得
        for i in 0..<objects.count {
            if objects[i].switching == true { // 設定勘定科目 スイッチ
                if objects[i].numberOfTaxonomy.isEmpty { // 表示科目に紐付けしていない場合
                    // 勘定クラス　勘定ないの仕訳を取得
                    let objectss = DataBaseManagerJournalEntry.shared.getAllJournalEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    let objectsss = DataBaseManagerAdjustingEntry.shared.getAllAdjustingEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    if !objectss.isEmpty || !objectsss.isEmpty {
                        updateSettingsCategorySwitching(tag: objects[i].number, isOn: true)
                    } else {
                        updateSettingsCategorySwitching(tag: objects[i].number, isOn: false)
                    }
                }
            } else if objects[i].switching == false { // 表示科目科目が選択されていて仕訳データがあればONにする
                if !objects[i].numberOfTaxonomy.isEmpty { // 表示科目に紐付けしている場合
                    // 勘定クラス　勘定ないの仕訳を取得
                    let objectss = DataBaseManagerJournalEntry.shared.getAllJournalEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    let objectsss = DataBaseManagerAdjustingEntry.shared.getAllAdjustingEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
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
    //    // 更新　勘定科目名を変更
    //    func updateAccountNameOfSettingsTaxonomyAccount(number: Int, accountName: String) { // すべての影響範囲に修正が必要
    //        do {
    //            // (2)書き込みトランザクション内でデータを更新する
    //            try DataBaseManager.realm.write {
    //                let value: [String: Any] = ["number": number, "category": accountName]
    //                DataBaseManager.realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
    //            }
    //        } catch {
    //            print("エラーが発生しました")
    //        }
    //    }
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
    
    // 採番　並び替えの順序のためのシリアルナンバーを更新する
    func makeSerialNumbers(objects: [SeializingObject]) {
        // 採番をやりなおす
        for sortedObject in objects.enumerated() {
            print("採番:", sortedObject.0, "number:", sortedObject.1.number, "serialNumber:", sortedObject.1.serialNumber)
            do {
                // (2)書き込みトランザクション内でデータを更新する
                try DataBaseManager.realm.write {
                    let value: [String: Any] = ["number": sortedObject.1.number, "serialNumber": sortedObject.0]
                    DataBaseManager.realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
                }
            } catch {
                print("エラーが発生しました")
            }
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
    // 削除　設定勘定科目
    func deleteSettingsTaxonomyAccount(number: Int) -> Bool {
        // 削除　勘定、よく使う仕訳
        let isInvalidated = deleteAccount(number: number)
        if isInvalidated {
            do {
                // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
                if let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsTaxonomyAccount.self, key: number) {
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

    // 削除　勘定、よく使う仕訳　設定勘定科目を削除するときに呼ばれる
    func deleteAccount(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return false }
        // 勘定　全年度　取得
        let dataBaseAccounts = RealmManager.shared.readWithPredicate(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "accountName LIKE %@", NSString(string: object.category))
        ])
        // 仕訳
        let objectss = DataBaseManagerJournalEntry.shared.getAllJournalEntryInAccountAll(account: object.category) // 全年度の通常仕訳データを確認する
        print(objectss)
        // 決算整理仕訳
        let objectsss = DataBaseManagerAdjustingEntry.shared.getAllAdjustingEntryInAccountAll(account: object.category) // 全年度の決算整理仕訳データを確認する
        print(objectsss)
        // 損益振替仕訳
        let objectssss = DataBaseManagerTransferEntry.shared.getAllTransferEntryInPLAccountAll(account: object.category) // 全年度の損益振替仕訳データを確認する
        print(objectssss)
        // 残高振替仕訳
        let dataBaseTransferEntry = DataBaseManagerTransferEntry.shared.getAllTransferEntry(account: object.category) // 全年度の残高振替仕訳データを確認する
        print(dataBaseTransferEntry)
        // 開始仕訳
        let dataBaseOpeningJournalEntry = DataBaseManagerAccount.shared.getAllOpeningJournalEntryInAccountAll(account: object.category) // 全年度の開始仕訳データを確認する
        print(dataBaseOpeningJournalEntry)
        // 設定開始残高勘定
        let dataBaseSettingTransferEntry = DataBaseManagerAccountingBooksShelf.shared.getAllTransferEntry(account: object.category) // 設定残高振替仕訳データを確認する
        print(dataBaseSettingTransferEntry)
        // よく使う仕訳
        let dataBaseSettingsOperatingJournalEntry = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(account: object.category)
        print(dataBaseSettingsOperatingJournalEntry)

        // 仕訳クラス　仕訳を削除
        var isInvalidated = true // 初期値は真とする。仕訳データが0件の場合の対策
        var isInvalidated2 = true
        var isInvalidated3 = true
        var isInvalidated4 = true
        var isInvalidated5 = true
        var isInvalidated6 = true
        var isInvalidated7 = true
        // 仕訳を削除
        for _ in 0..<objectss.count {
            isInvalidated = DataBaseManagerJournalEntry.shared.deleteJournalEntry(number: objectss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 決算整理仕訳を削除
        for _ in 0..<objectsss.count {
            isInvalidated2 = DataBaseManagerAdjustingEntry.shared.deleteAdjustingJournalEntry(number: objectsss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 損益振替仕訳を削除
        for _ in 0..<objectssss.count {
            isInvalidated3 = DataBaseManagerTransferEntry.shared.deleteTransferEntry(number: objectssss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 残高振替仕訳を削除
        for _ in 0..<dataBaseTransferEntry.count {
            isInvalidated4 = DataBaseManagerTransferEntry.shared.deleteTransferEntry(number: dataBaseTransferEntry[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 開始仕訳を削除
        for _ in 0..<dataBaseOpeningJournalEntry.count {
            isInvalidated5 = DataBaseManagerAccount.shared.deleteOpeningJournalEntry(primaryKey: dataBaseOpeningJournalEntry[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 設定残高振替仕訳を削除
        for _ in 0..<dataBaseSettingTransferEntry.count {
            isInvalidated6 = DataBaseManagerAccountingBooksShelf.shared.deleteTransferEntry(number: dataBaseSettingTransferEntry[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // よく使う仕訳を削除
        for _ in 0..<dataBaseSettingsOperatingJournalEntry.count {
            isInvalidated7 = DataBaseManagerSettingsOperatingJournalEntry.shared.deleteJournalEntry(number: dataBaseSettingsOperatingJournalEntry[0].number)
        }

        if isInvalidated7 {
            if isInvalidated6 {
                if isInvalidated5 {
                    if isInvalidated4 {
                        if isInvalidated3 {
                            if isInvalidated2 {
                                if isInvalidated {
                                    do {
                                        try DataBaseManager.realm.write {
                                            for _ in 0..<dataBaseAccounts.count {
                                                // 仕訳が残ってないか
                                                DataBaseManager.realm.delete(dataBaseAccounts[0])
                                            }
                                        }
                                    } catch {
                                        print("エラーが発生しました")
                                    }
                                    return true // objectsssss.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }

}
