//
//  ViewControllerGenearlLedgerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 総勘定元帳　勘定クラス
class ViewControllerGenearlLedgerAccount: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView_account: UITableView!
    @IBOutlet weak var label_date_year: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_account.delegate = self
        TableView_account.dataSource = self
        // ヘッダー部分　勘定名を表示
        label_list_heading.text = account
        // データベース
        let dataBaseManager = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManager.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_date_year.text = fiscalYear.description + "年" 
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // 差引残高　計算
        dataBaseManagerGeneralLedgerAccountBalance.calculateBalance(account: account)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // UIViewControllerの表示画面を更新・リロード 注意：iPadの画面ではレイアウトが合わなくなる。リロードしなければ問題ない。仕訳帳ではリロードしても問題ない。
//        self.loadView()
//        self.viewDidLoad()
    }
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 12     // セクションの数はreturn 12 で 12ヶ月分に設定します。
    }
    // セクションヘッダーの高さを決める
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33 //セクションヘッダーの高さを33に設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.textAlignment = .left
//        let attributedStr = NSMutableAttributedString(string: header.textLabel?.text)
//        let crossAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//        header.textLabel?.text = attributedStr
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var section_num = section + 4//4月スタートに補正する todo 設定の決算月によって変更する
        //セクションヘッダーは1年分の12ヶ月にする
        if section_num >= 13 {  //12ヶ月を超えた場合1月に戻す
            section_num -= 12
        }
        let mon = "月"
//        if section_num > 9 {
//            mon = "月"
//        }
        let header_title = section_num.description + mon
        return header_title
    }
    //セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let dataBaseManagerAccount = DataBaseManagerAccount() //データベースマネジャー
        let counts = dataBaseManagerAccount.getAccountCounts(section: section, account: account) // 何月のセクションに表示するセルかを引数で渡す
//        print("月別のセル数:\(counts)")
        return counts //月別の仕訳データ数
    }
    
    var account :String = "" // 勘定名
    let dataBaseManagerGeneralLedgerAccountBalance = DataBaseManagerGeneralLedgerAccountBalance()
    @IBOutlet weak var label_list_heading: UILabel!
    //セルを生成して返却するメソッド
//    var indexPathForAutoScroll: IndexPath = IndexPath(row: 0, section: 0)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let dataBaseManagerAccount = DataBaseManagerAccount() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = dataBaseManagerAccount.getAccount(section: indexPath.section, account: account) // 何月のセクションに表示するセルかを判別するため引数で渡す
//        let objects = dataBaseManagerAccount.getAccountTest(section: indexPath.section, account: account)
//        print("月別のセル:\(objects)")
        //① UI部品を指定　TableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger_account", for: indexPath) as! TableViewCellGeneralLedgerAccount
        
        //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
        
        let d = "\(objects[indexPath.row].date)" // 日付
        // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
        if indexPath.row == 0 {
            let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
            }else{
                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
            }
        }else{
            cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
        }
        let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
        if date == "0" { // 日の十の位が0の場合は表示しない
            cell.label_list_date_day.text = "\(objects[indexPath.row].date.suffix(1))" // 末尾1文字の「日」         //日付
        }else{
            cell.label_list_date_day.text = "\(objects[indexPath.row].date.suffix(2))" // 末尾2文字の「日」         //日付
        }
        cell.label_list_date_day.textAlignment = NSTextAlignment.right
//        cell.label_list_summary_debit.text = " (\(objects[indexPath.row].debit_category))"     //借方勘定
//        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
//        cell.label_list_summary_credit.text = "(\(objects[indexPath.row].credit_category)) "   //貸方勘定
//        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
        if account == "\(objects[indexPath.row].debit_category)" { // 借方勘定の場合                      //この勘定が借方の場合
            cell.label_list_summary.text = "\(objects[indexPath.row].credit_category) "             //摘要　相手方勘定なので貸方
            cell.label_list_summary.textAlignment = NSTextAlignment.right
            let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objects[indexPath.row].credit_category)")
            cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
            cell.label_list_debit.text = "\(addComma(string: String(objects[indexPath.row].debit_amount))) "        //借方金額
            cell.label_list_credit.text = ""                                                                        //貸方金額 注意：空白を代入しないと、変な値が入る。
        }else if account == "\(objects[indexPath.row].credit_category)" {  // 貸方勘定の場合
            cell.label_list_summary.text = "\(objects[indexPath.row].debit_category) "              //摘要　相手方勘定なので借方
            cell.label_list_summary.textAlignment = NSTextAlignment.left
            let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objects[indexPath.row].debit_category)")
            cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
            cell.label_list_debit.text = ""                                                                         //借方金額 注意：空白を代入しないと、変な値が入る。
            cell.label_list_credit.text = "\(addComma(string: String(objects[indexPath.row].credit_amount))) "      //貸方金額
        }
        // 差引残高　差引残高クラスで計算した計算結果を取得
        let balanceAmount = dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmount(indexPath: indexPath)
        cell.label_list_balance.text = "\(addComma(string: balanceAmount.description))"                           //差引残高
        let balanceDebitOrCredit = dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCredit(indexPath: indexPath)
        cell.label_list_debitOrCredit.text = balanceDebitOrCredit                                                 // 借又貸
        
        return cell
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はviewDidLoadで行う
    func addComma(string :String) -> String {
        if(string != "") { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
//    // セルが画面に表示される直前に表示される
//    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
//    var scroll_adding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        var indexPath_local = IndexPath(row: 0, section: 0)
//        if scroll || scroll_adding {     // 初回起動時の場合 入力ボタン押下時の場合
//            for s in 0..<TableView_account.numberOfSections-1 {            //セクション数　ゼロスタート補正
//                if TableView_account.numberOfRows(inSection: s) > 0 {
//                    let r = TableView_account.numberOfRows(inSection: s)-1 //セル数　ゼロスタート補正
//                    indexPath_local = IndexPath(row: r, section: s)
//                    self.TableView_account.scrollToRow(at: indexPath_local, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
//                }
//            }
//        }
//        if scroll_adding {     // 入力ボタン押下時の場合
//            // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
//            if indexPath == indexPath_local { // 最後のセルまで表示しされたかどうか
//                self.TableView_account.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.bottom, animated: false) // 追加した仕訳データの行を画面の下方に表示する
//                // 入力ボタン押下時の表示位置 OFF
//                scroll_adding = false
//            }
//        }
//    }
}
