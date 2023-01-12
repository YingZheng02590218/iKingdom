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

        if accountName == "損益" {
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

    /**
     * 勘定科目　読込みメソッド
     * 勘定名別の残高をデータベースから読み込む。
     * @param rank0 設定勘定科目の大区分
     * @param rank1 設定勘定科目の中区分
     * @param accountNameOfSettingsTaxonomyAccount 設定勘定科目の勘定科目名
     * @param number 設定勘定科目の連番
     * @return result 勘定名別の残高額
     */
    func getTotalOfTaxonomyAccount(rank0: Int, rank1: Int, accountNameOfSettingsTaxonomyAccount: String, lastYear: Bool) -> String {
        var result: Int64 = 0
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸

        var capitalAccount = ""
        // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            capitalAccount = CapitalAccountType.retainedEarnings.rawValue
        } else {
            capitalAccount = CapitalAccountType.capital.rawValue
        }

        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        // 勘定クラス
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            if capitalAccount == accountNameOfSettingsTaxonomyAccount {
                if let dataBaseCapitalAccount = dataBaseGeneralLedger.dataBaseCapitalAccount {
                    print("借方残高", dataBaseCapitalAccount.debit_balance_AfterAdjusting)
                    print("貸方残高", dataBaseCapitalAccount.credit_balance_AfterAdjusting)
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseCapitalAccount.debit_balance_AfterAdjusting > dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if dataBaseCapitalAccount.debit_balance_AfterAdjusting < dataBaseCapitalAccount.credit_balance_AfterAdjusting {
                        result = dataBaseCapitalAccount.credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            } else {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<dataBaseGeneralLedger.dataBaseAccounts.count where dataBaseGeneralLedger.dataBaseAccounts[i].accountName == accountNameOfSettingsTaxonomyAccount {
                    print("借方残高", dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting)
                    print("貸方残高", dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting)
                    // 借方と貸方で金額が大きい方はどちらか
                    if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting > dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting
                        debitOrCredit = "借"
                    } else if dataBaseGeneralLedger.dataBaseAccounts[i].debit_balance_AfterAdjusting < dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                        result = dataBaseGeneralLedger.dataBaseAccounts[i].credit_balance_AfterAdjusting
                        debitOrCredit = "貸"
                    } else {
                        debitOrCredit = "-"
                    }
                }
            }
            switch rank0 {
            case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            case 9, 10: // 営業外損益 特別損益
                if rank1 == 15 || rank1 == 17 { // 営業外損益
                    switch debitOrCredit {
                    case "借":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                } else if rank1 == 16 || rank1 == 18 { // 特別損益
                    switch debitOrCredit {
                    case "貸":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                }
            default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
                switch debitOrCredit {
                case "借":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            }
        }
        if positiveOrNegative == "-" {
            // 残高がマイナスの場合、三角のマークをつける
            result = (result * -1)
        }

        // カンマを追加して文字列に変換した値を返す
        return StringUtility.shared.setComma(amount: result)
    }

    // 取得　損益振替仕訳、残高振替仕訳 勘定別に取得
    func getTransferEntryInAccount(account: String) -> DataBaseTransferEntry? {
        if account == Constant.capitalAccountName || account == "資本金勘定" {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseCapitalAccount
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
            return dataBaseTransferEntry
        } else {
            let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
                NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
            ])
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseTransferEntry = dataBaseAccount?.dataBaseTransferEntry
            return dataBaseTransferEntry
        }
    }

    // MARK: Update

    // MARK: Delete

}
