//
//  DataBaseManagerTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 表示科目クラス
class DataBaseManagerTaxonomy {
    
    public static let shared = DataBaseManagerTaxonomy()

    private init() {
    }

    // MARK: - CRUD
    
    // MARK: Create
    
    // 初期化
    func initializeTaxonomy() {
        // 設定表示科目
        let objects = DataBaseManagerSettingsTaxonomy.shared.getAllSettingsTaxonomySwitichON()
        // 設定表示科目に存在する表示科目の数だけ、計算とDBへの書き込みを行う
        for i in 0..<objects.count {
            setTotalOfTaxonomy(numberOfSettingsTaxonomy: objects[i].number)
        }
    }
    
    // 追加 表示科目　マイグレーション
    func addTaxonomyAll() {
        // 会計帳簿棚　を取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooksShelf.self, key: 1) else { return }
        // 設定表示科目　を取得
        let objects = DataBaseManagerSettingsTaxonomy.shared.getAllSettingsTaxonomy()
        // 会計帳簿　の数の分だけ表示科目を作成
        for y in 0..<object.dataBaseAccountingBooks.count where object.dataBaseAccountingBooks[y].dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy.count ?? 0 > 0 {
            // 表示科目　オブジェクトを作成
            for i in 0..<objects.count {
                do {
                    // (2)書き込みトランザクション内でデータを追加する
                    try DataBaseManager.realm.write {
                        let dataBaseTaxonomy = DataBaseTaxonomy(
                            fiscalYear: object.dataBaseAccountingBooks[y].fiscalYear, // 帳簿ごとの年度
                            accountName: objects[i].category, // 設定表示科目の表示科目名
                            total: 0,
                            numberOfTaxonomy: objects[i].number // 設定表示科目の連番を保持する　マイグレーション
                        )
                        let number = dataBaseTaxonomy.save() //　自動採番
                        print(number)
                        // 表示科目を追加
                        object.dataBaseAccountingBooks[y].dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy.append(dataBaseTaxonomy)   // 既にある貸借対照表に新たに表示科目を追加する
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    
    // MARK: Read
    
    /**
     * 合計　取得メソッド
     * 勘定の借方の合計と貸方の合計でより大きい方の合計を返す。
     * @param account 勘定名
     * @return debit_total 借方合計　決算整理後
     * @return  credit_total 貸方合計　決算整理後
     */
    func getTotalAmount(account: String) -> Int64 {
        var result: Int64 = 0
        // 引数に空白が入るのでインデックスエラーとなる　TaxonomyAccount.csvの最下行に余計な行が生成されている　2020/10/24
        // 開いている会計帳簿を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // (2)データベース内に保存されているモデルを全て取得する
        if let dataBaseGeneralLedger = object.dataBaseGeneralLedger {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            if let dataBaseAccount = dataBaseGeneralLedger.dataBaseAccounts.where({ $0.accountName == account }).first {
                print(dataBaseAccount)
                // 借方と貸方で金額が大きい方はどちらか　2020/10/12 決算整理後の合計　→ 決算整理後の残高
                if dataBaseAccount.debit_balance_AfterAdjusting > dataBaseAccount.credit_balance_AfterAdjusting {
                    result = dataBaseAccount.debit_balance_AfterAdjusting
                } else if dataBaseAccount.debit_balance_AfterAdjusting < dataBaseAccount.credit_balance_AfterAdjusting {
                    result = dataBaseAccount.credit_balance_AfterAdjusting
                } else {
                    result = dataBaseAccount.debit_balance_AfterAdjusting
                }
            }
        }
        return result
    }
    
    /**
     * 借又貸　取得メソッド
     * @param big_category 大分類名
     * @param account 勘定名
     * @return "-" マイナス
     * @return  "" プラス
     */
    func getTotalDebitOrCredit(bigCategory: Int, midCategory: Int, account: String) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        if let objectss = object.dataBaseGeneralLedger {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<objectss.dataBaseAccounts.count where objectss.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if objectss.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    debitOrCredit = "借"
                } else if objectss.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    debitOrCredit = "貸"
                } else {
                    debitOrCredit = "-"
                }
            }
            switch bigCategory {
            case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            case 9, 10: // 営業外損益 特別損益
                if midCategory == 15 || midCategory == 17 {
                    switch debitOrCredit {
                    case "借":
                        positiveOrNegative = "-"
                    default:
                        positiveOrNegative = ""
                    }
                } else if midCategory == 16 || midCategory == 18 {
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
        return positiveOrNegative
    }
    // 取得　設定勘定科目　設定表示科目の連番から設定表示科目別の設定勘定科目
    func getAccountsInTaxonomy(numberOfTaxonomy: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        // 設定勘定科目クラス
        let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [
            NSPredicate(format: "numberOfTaxonomy LIKE %@", NSString(string: String(numberOfTaxonomy)))
        ])
        if objects.isEmpty {
            // print("ゼロ　getAccountsInTaxonomy", numberOfTaxonomy)
        } else {
            print("getAccountsInTaxonomy", numberOfTaxonomy)
        }
        return objects
    }
    
    /**
     * 表示科目　読込みメソッド
     * 表示名別の合計をデータベースから読み込む。
     * @param number 設定表示科目の連番
     * @return result 合計額
     */
    // 取得 表示科目　表示名別の合計
    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: lastYear)
        // 設定表示科目の連番から表示科目の名称を取得
        //        let accountName = getNameOfSettingsTaxonomy(number: numberOfSettingsTaxonomy)
        var result: Int64 = 0
        // 表示科目クラス
        if let objectss = object.dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy {
            // 貸借対照表のなかの表示科目で、計算したい表示科目と同じ場合
            for i in 0..<objectss.count where objectss[i].numberOfTaxonomy == numberOfSettingsTaxonomy && i == (objectss[i].number % objectss.count) - 1 {
                print(objectss[i].total)
                result = objectss[i].total
            }
        }
        // カンマを追加して文字列に変換した値を返す
        return StringUtility.shared.setComma(amount: result)
    }
    
    /**
     * 表示科目　計算メソッド
     * 表示名に該当する勘定の合計を計算して合計額を返す。
     * @param number 設定表示科目の連番
     * @return BSAndPLCategoryTotalAmount 合計額
     */
    func culculatAmountOfTaxonomy(numberOfTaxonomy: Int) -> Int64 {
        // 設定表示科目に紐づけられた設定勘定科目を取得する
        let objects = getAccountsInTaxonomy(numberOfTaxonomy: numberOfTaxonomy)
        var BSAndPLCategoryTotalAmount: Int64 = 0            // 累計額
        // オブジェクトを作成 勘定
        for i in 0..<objects.count where // 表示科目に該当する勘定の金額を合計する
        !objects[i].category.isEmpty { // ここで空白が入っている　TaxonomyAccount.csvの最下行に余計な行が生成されている　2020/10/24
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(
                bigCategory: Int(objects[i].Rank0)!,
                midCategory: Int(objects[i].Rank1) ?? 999,
                account: objects[i].category
            ) // big_categoryは、表示科目の階層2ではなく勘定科目の大区分を使う　2020/11/09
            if totalDebitOrCredit == "-"{
                BSAndPLCategoryTotalAmount -= totalAmount
            } else {
                BSAndPLCategoryTotalAmount += totalAmount
            }
        }
        return BSAndPLCategoryTotalAmount
    }
    
    // MARK: Update
    
    /**
     * 表示科目　書込みメソッド
     * 表示科目別の合計額をデータベースに書き込む。
     * @param number 設定表示科目の連番
     * @return なし
     */
    func setTotalOfTaxonomy(numberOfSettingsTaxonomy: Int) {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 設定表示科目の名称を取得
        // let accountName = getNameOfSettingsTaxonomy(number: numberOfSettingsTaxonomy)
        // let category2 = getCategory2OfSettingsTaxonomy(number: number) // 2020/11/09 計算方法修正のため不使用
        // 計算
        let bSAndPLCategoryTotalAmount = culculatAmountOfTaxonomy(numberOfTaxonomy: numberOfSettingsTaxonomy) // 五大区分は表示科目の階層2ではなく、勘定科目の大区分を使用する
        if let objectss = object.dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy {
            // 貸借対照表のなかの表示科目で、計算したい表示科目と同じ場合
            for i in 0..<objectss.count where objectss[i].numberOfTaxonomy == numberOfSettingsTaxonomy && i == (objectss[i].number % objectss.count) - 1 {
                do {
                    // (2)書き込みトランザクション内でデータを追加する
                    try DataBaseManager.realm.write {
                        print(bSAndPLCategoryTotalAmount)
                        objectss[i].total = bSAndPLCategoryTotalAmount
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }
    
    // MARK: Delete
    
    // 削除 表示科目　マイグレーション
    func deleteTaxonomyAll() -> Bool {
        // 会計帳簿棚　を取得
        guard let object = RealmManager.shared.readWithPrimaryKey(type: DataBaseAccountingBooksShelf.self, key: 1) else { return false }
        // 会計帳簿　の数の分だけ表示科目を削除
        for y in 0..<object.dataBaseAccountingBooks.count where object.dataBaseAccountingBooks[y].dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy[0].numberOfTaxonomy == 0 {
            // 表示科目　オブジェクトを削除
            if let dataBaseTaxonomy = object.dataBaseAccountingBooks[y].dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy {
                for _ in 0..<dataBaseTaxonomy.count {
                    do {
                        // (2)書き込みトランザクション内でデータを追加する
                        try DataBaseManager.realm.write {
                            // 表示科目を削除
                            DataBaseManager.realm.delete(dataBaseTaxonomy[0])   // 既にある表示科目を削除する
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                }
            }
        }
        return object.dataBaseAccountingBooks[object.dataBaseAccountingBooks.count - 1].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy.isEmpty // 成功したら true まだ失敗時の動きは確認していない
    }
}
