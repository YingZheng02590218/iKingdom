//
//  DataBaseManagerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 勘定クラス
class DataBaseManagerAccount {

    public static let shared = DataBaseManagerAccount()

    private init() {
    }
    
    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 年度を指定して勘定を取得する
     * @param  勘定名
     * @return  勘定
     */
    func getAccountByAccountNameWithFiscalYear(accountName: String, fiscalYear: Int) -> DataBaseAccount? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])

        let dataBaseAccounts = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
            .filter("accountName LIKE '\(accountName)'")
        guard let dataBaseAccount = dataBaseAccounts?.first else {
            return nil
        }
        return dataBaseAccount
    }
    /**
     * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
     * 勘定名と年度を指定して勘定を取得する
     * @param accountName 勘定名、fiscalYear 年度
     * @return  DataBaseAccount? 勘定、DataBasePLAccount? 損益勘定
     * 特殊化方法: 戻り値からの型推論による特殊化　戻り値の代入先の型が決まっている必要がある
     */
    func getAccountByAccountNameWithFiscalYear<T>(accountName: String, fiscalYear: Int) -> T? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear))
        ])

        if accountName == "損益勘定" {
            // 損益勘定の場合
            guard let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount else {
                return nil
            }
            return dataBasePLAccount as? T
        } else {
            // 損益勘定以外の勘定の場合
            guard let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                    .filter("accountName LIKE '\(accountName)'")
                    .first else {
                        return nil
                    }
            return dataBaseAccount as? T
        }
    }
    
    // 取得　勘定名から勘定を取得
    func getAccountByAccountName(accountName: String) -> DataBaseAccount? {
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let dataBaseAccount = RealmManager.shared.read(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "accountName LIKE %@", NSString(string: accountName))
        ])
        return dataBaseAccount
    }
    
    // MARK: Update

    // MARK: Delete

}
