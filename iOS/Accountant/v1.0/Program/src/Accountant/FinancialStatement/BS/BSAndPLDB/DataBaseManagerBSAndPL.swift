//
//  DataBaseManagerBSAndPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 設定表記名クラス
class DataBaseManagerBSAndPL {

    func initializeBSAndPL(){
        // 設定表記名
        let DM = DataBaseManagerSettingsCategoryBSAndPL()
        let objects = DM.getAllSettingsCategoryBSAndPL()
        // 設定表記名に存在する表記名の数だけ、計算とDBへの書き込みを行う
        for i in 0..<objects.count {
            setBSAndPLCategoryTotal(big_category: objects[i].big_category, bSAndPL_category: objects[i].BSAndPL_category)
        }
    }
    // 設定表記名　取得　表記名別の勘定
    func getObjectsInBSAndPLCategory(bSAndPL_category: Int) -> Results<DataBaseSettingsCategory> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategory.self) // モデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("BSAndPL_category == \(bSAndPL_category)")
                        .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects
    }
    // 設定表記名　取得　表記名の名称
    func getNameBSAndPLCategory(bSAndPL_category: Int) -> String {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsCategoryBSAndPL.self) // モデル
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("BSAndPL_category == \(bSAndPL_category)")
        if objects.count == 0 {
            print("ゼロ")
        }
        return objects[0].category
    }
    /**
    * 表記名　読込みメソッド
    * 表示名別の合計をデータベースから読み込む。
    * @param account 大分類
    * @param account 勘定名
    * @return result 合計額
    */
    // 表示名　取得 表示名別の合計
    func getBSAndPLCategoryTotal(big_category: Int, bSAndPL_category: Int) -> String {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
                
        // 表記名の名称を取得
        let accountName = getNameBSAndPLCategory(bSAndPL_category: bSAndPL_category)
        
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        // 表記名クラス
        var objectss = realm.objects(DataBaseBSAndPLAccount.self)
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
                            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
//                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため

        let result:Int64 = objectss[0].total
        //カンマを追加して文字列に変換した値を返す
        return setComma(amount: result)
    }
    /**
    * 表記名　書込みメソッド
    * 表示名別の合計額をデータベースに書き込む。
    * @param big_category 大分類
    * @param bSAndPL_category 表記名
    * @return なし
    */
    func setBSAndPLCategoryTotal(big_category: Int, bSAndPL_category: Int) {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear

        // 表記名の名称を取得
        let accountName = getNameBSAndPLCategory(bSAndPL_category: bSAndPL_category)
        
        // 計算
        let BSAndPLCategoryTotalAmount = culculatAmountOfBSAndPLAccount(big_category: big_category, bSAndPL_category: bSAndPL_category)
        
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseBSAndPLAccount.self) // モデル
        // 希望する勘定だけを抽出する 表記名
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
                            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        if objectss.count == 0 {
            print("ゼロ")
        }
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            objectss[0].total = BSAndPLCategoryTotalAmount
        }
    }
    /**
    * 表記名　計算メソッド
    * 表示名に該当する勘定の合計を計算して合計額を返す。
    * @param account 大分類
    * @param bSAndPL_category 表記名
    * @return BSAndPLCategoryTotalAmount 合計額
    */
    func culculatAmountOfBSAndPLAccount(big_category: Int, bSAndPL_category: Int) -> Int64 {
        // 設定表記名にある勘定を取得する
        let objects = getObjectsInBSAndPLCategory(bSAndPL_category: bSAndPL_category)
        var BSAndPLCategoryTotalAmount: Int64 = 0            // 累計額
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{ //表記名に該当する勘定の金額を合計する
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                BSAndPLCategoryTotalAmount -= totalAmount
            }else {
                BSAndPLCategoryTotalAmount += totalAmount
            }
        }
        return BSAndPLCategoryTotalAmount
    }
    // 合計残高　勘定別の合計と借又貸 取得
    func getAccountTotal(big_category: Int, bSAndPL_category: Int) -> String {
        let totalAmount = getBSAndPLCategoryTotal(big_category: big_category, bSAndPL_category: bSAndPL_category)  // 合計を取得
//        let totalDebitOrCredit = getTotalDebitOrCredit(big_category: big_category, account: account) // 借又貸を取得

        return "\(totalAmount)"
    }
    /**
    * 合計　取得メソッド
    * 勘定の借方の合計と貸方の合計でより大きい方の合計を返す。
    * @param account 勘定名
    * @return debit_total 借方合計　決算整理後
    * @return  credit_total 貸方合計　決算整理後
    */
    func getTotalAmount(account: String) -> Int64 {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseAccount.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
                            .filter("accountName LIKE '\(account)'")
//                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため

        if objectss.count == 0 {
            print("ゼロ")
        }
        var result:Int64 = 0
        // 借方と貸方で金額が大きい方はどちらか
        if objectss[0].debit_total_AfterAdjusting > objectss[0].credit_total_AfterAdjusting {
            result = objectss[0].debit_total_AfterAdjusting
        }else if objectss[0].debit_total_AfterAdjusting < objectss[0].credit_total_AfterAdjusting {
            result = objectss[0].credit_total_AfterAdjusting
        }else {
            result = objectss[0].debit_total_AfterAdjusting
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
    func getTotalDebitOrCredit(big_category: Int, account: String) -> String {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 開いている会計帳簿の年度を取得
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objectss = realm.objects(DataBaseAccount.self) // モデル
        // 希望する勘定だけを抽出する
        objectss = objectss.filter("fiscalYear == \(fiscalYear)")
                            .filter("accountName LIKE '\(account)'")
//                            .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
        if objectss.count == 0 {
            print("ゼロ")
        }
        var DebitOrCredit:String = "" // 借又貸
        // 借方と貸方で金額が大きい方はどちらか
        if objectss[0].debit_balance_AfterAdjusting > objectss[0].credit_balance_AfterAdjusting {
            DebitOrCredit = "借"
        }else if objectss[0].debit_balance_AfterAdjusting < objectss[0].credit_balance_AfterAdjusting {
            DebitOrCredit = "貸"
        }else {
            DebitOrCredit = "-"
        }
        var PositiveOrNegative:String = "" // 借又貸
        switch big_category {
        case 0,3:
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
            default:
                PositiveOrNegative = ""
            }
        default: // 1,2,4（負債、純資産、収益）
            switch DebitOrCredit {
                case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
            }
        }
        return PositiveOrNegative
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
//        if addComma(string: amount.description) == "0" { //0の場合は、空白を表示する
//            return ""
//        }else {
        // 三角形はマイナスの意味
        if amount < 0 { //0の場合は、空白を表示する
            let amauntFix = amount * -1
            return "△ \(addComma(string: amauntFix.description))"
        }else {
            return addComma(string: amount.description)
        }
//        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    //カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String{
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
}
