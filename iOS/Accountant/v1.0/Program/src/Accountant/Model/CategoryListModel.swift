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
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    // 取得 大区分、中区分、小区分
    func getDataBaseSettingsTaxonomyAccountInRank(rank0: Int, rank1: Int?) -> Results<DataBaseSettingsTaxonomyAccount> {
        DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRank(rank0: rank0, rank1: rank1)
    }
    // 取得 大区分別に、スイッチONの勘定科目
    func getSettingsSwitchingOn(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsSwitchingOn(rank0: rank0)
    }
    
    // MARK: Update
    
    // 更新　スイッチの切り替え
    func updateSettingsCategorySwitching(tag: Int, isOn: Bool) {
        DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // スイッチをOFFにする場合
        if isOn == false {
            // 取得 勘定科目の連番から設定勘定科目を取得
            if let dataBaseSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: tag) {
                // 設定開始残高勘定の設定残高振替仕訳があれば、削除する
                // 設定開始残高勘定
                let dataBaseSettingTransferEntry = DataBaseManagerAccountingBooksShelf.shared.getAllTransferEntry(account: dataBaseSettingsTaxonomyAccount.category) // 設定残高振替仕訳データを確認する
                print(dataBaseSettingTransferEntry)
                // 設定残高振替仕訳を削除
                for _ in 0..<dataBaseSettingTransferEntry.count {
                    let isInvalidated6 = DataBaseManagerAccountingBooksShelf.shared.deleteTransferEntry(number: dataBaseSettingTransferEntry[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
                    print(isInvalidated6)
                }
            }
        }
    }
    
    // MARK: Delete
    
    // 削除　設定勘定科目
    func deleteSettingsTaxonomyAccount(number: Int) -> Bool {
        DatabaseManagerSettingsTaxonomyAccount.shared.deleteSettingsTaxonomyAccount(number: number)
    }
}
