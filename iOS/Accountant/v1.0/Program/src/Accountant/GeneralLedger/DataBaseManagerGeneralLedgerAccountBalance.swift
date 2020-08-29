//
//  DataBaseManagerGeneralLedgerAccountBalance.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 差引残高クラス
class DataBaseManagerGeneralLedgerAccountBalance {
    
    var balanceAmount:Int64 = 0            // 差引残高額
    var balanceDebitOrCredit:String = "" // 借又貸
    var objects:Results<DataBaseJournalEntry>! // = Results<DataBaseAccount>()
    var objectss:Results<DataBaseAdjustingEntry>! // 決算整理仕訳

    //
    func calculateBalance(account: String) {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account)
        objectss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account)
        var left: Int64 = 0 // 差引残高 累積　勘定内の仕訳データを全て表示するまで、覚えておく
        var right: Int64 = 0
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            for i in 0..<objects.count { // 勘定内のすべての仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(objects[i].debit_category)" { // 借方
                    left += objects[i].debit_amount // 累計額に追加
                }else if account == "\(objects[i].credit_category)" { // 貸方
                    right += objects[i].credit_amount // 累計額に追加
                }
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objects[i].balance_left = left - right // 差額を格納
                    objects[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objects[i].balance_left = 0
                    objects[i].balance_right = right - left
                }else {
                    objects[i].balance_left = 0 // ゼロを入れないと前回値が残る
                    objects[i].balance_right = 0
                }
            }
            for i in 0..<objectss.count { // 勘定内のすべての決算整理仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(objectss[i].debit_category)" { // 借方
                    left += objectss[i].debit_amount // 累計額に追加
                }else if account == "\(objectss[i].credit_category)" { // 貸方
                    right += objectss[i].credit_amount // 累計額に追加
                }
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objectss[i].balance_left = left - right // 差額を格納
                    objectss[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objectss[i].balance_left = 0
                    objectss[i].balance_right = right - left
                }else {
                    objectss[i].balance_left = 0 // ゼロを入れないと前回値が残る
                    objectss[i].balance_right = 0
                }
            }
        }
    }
    // 差引残高額を取得
    func getBalanceAmount(indexPath: IndexPath) ->Int64 {
        let objects_local: Results<DataBaseJournalEntry>! //注意：ローカル変数を用意しないとこのクラスのフィールド変数のobjectsにフィルターをかけてしまう。
        switch indexPath.section {
        case 0: // April
            objects_local = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects_local = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects_local = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects_local = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects_local = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects_local = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects_local = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects_local = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects_local = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects_local = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects_local = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects_local = objects.filter("date LIKE '*/03/*'")
            break
        default:
            objects_local = objects.filter("date LIKE '*/00/*'") // ありえない
            break
        }
        let r = indexPath.row
        if objects_local[r].balance_left > objects_local[r].balance_right { // 借方と貸方を比較
            balanceAmount = objects_local[r].balance_left// - objects[r].balance_right
        }else if objects_local[r].balance_right > objects_local[r].balance_left {
            balanceAmount = objects_local[r].balance_right// - objects[r].balance_left
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 差引残高額を取得 決算整理仕訳
    func getBalanceAmountAdjusting(indexPath: IndexPath) ->Int64 {
        let objects_local: Results<DataBaseAdjustingEntry>!
        //注意：ローカル変数を用意しないとこのクラスのフィールド変数のobjectsにフィルターをかけてしまう。
        switch indexPath.section {
        case 0: // April
            objects_local = objectss.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects_local = objectss.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects_local = objectss.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects_local = objectss.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects_local = objectss.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects_local = objectss.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects_local = objectss.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects_local = objectss.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects_local = objectss.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects_local = objectss.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects_local = objectss.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects_local = objectss.filter("date LIKE '*/03/*'")
            break
        default:
            objects_local = objectss.filter("date LIKE '*/00/*'") // ありえない
            break
        }
        let r = indexPath.row
        if objects_local[r].balance_left > objects_local[r].balance_right { // 借方と貸方を比較
            balanceAmount = objects_local[r].balance_left// - objects[r].balance_right
        }else if objects_local[r].balance_right > objects_local[r].balance_left {
            balanceAmount = objects_local[r].balance_right// - objects[r].balance_left
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) ->String {
        let objects_local: Results<DataBaseJournalEntry>!
        //注意：ローカル変数を用意しないとこのクラスのフィールド変数のobjectsにフィルターをかけてしまう。
        switch indexPath.section {
        case 0: // April
            objects_local = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects_local = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects_local = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects_local = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects_local = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects_local = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects_local = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects_local = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects_local = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects_local = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects_local = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects_local = objects.filter("date LIKE '*/03/*'")
            break
        default:
            objects_local = objects.filter("date LIKE '*/00/*'") // ありえない
            break
        }
        let r = indexPath.row
        if objects_local[r].balance_left > objects_local[r].balance_right {
            balanceDebitOrCredit = "借"
        }else if objects_local[r].balance_left < objects_local[r].balance_right {
            balanceDebitOrCredit = "貸"
        }else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) ->String {
        let objects_local: Results<DataBaseAdjustingEntry>!
        //注意：ローカル変数を用意しないとこのクラスのフィールド変数のobjectsにフィルターをかけてしまう。
        switch indexPath.section {
        case 0: // April
            objects_local = objectss.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects_local = objectss.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects_local = objectss.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects_local = objectss.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects_local = objectss.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects_local = objectss.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects_local = objectss.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects_local = objectss.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects_local = objectss.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects_local = objectss.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects_local = objectss.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects_local = objectss.filter("date LIKE '*/03/*'")
            break
        default:
            objects_local = objectss.filter("date LIKE '*/00/*'") // ありえない
            break
        }
        let r = indexPath.row
        if objects_local[r].balance_left > objects_local[r].balance_right {
            balanceDebitOrCredit = "借"
        }else if objects_local[r].balance_left < objects_local[r].balance_right {
            balanceDebitOrCredit = "貸"
        }else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
}
