//
//  TableViewControllerA.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerJournalEntry: UITableViewController {
    
    @IBAction func showModalView(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//        let test = "testtesttest"
//        let controller = UIViewController(activityItems: [test], applicationActivities: nil)//UIViewController()UIActivityViewController
//        self.present(controller, animated: true, completion: nil)
    }
    // 実装前の暫定的に使用する値
//    let JournalEntries = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","31",]
//    let summary_debit = ["現金","普通預金","旅費交通費","交際費","交通費","受取利息","減価償却費","雑益","雑損","減価償却累計額","k","l","m","n","o","p","q","減価償却累計額","s","t","u","v","w","x","y","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額"]
//    let summary_credit = ["現金","普通預金","旅費交通費","交際費","交通費","受取利息","減価償却費","雑益","雑損","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","o","p","q","減価償却累計額","s","減価償却累計額","u","減価償却累計額","w","x","y","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額"]
//    let debit = ["100","1000","10000","100000","1000000","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999",]
//    let credit = ["100","1000","10000","100000","1000000","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999",]

//    override func loadView(){}
    @IBOutlet var TableView_JournalEntry: UITableView! // アウトレット接続 Referencing Outlets が接続されていないとnilとなるので注意
    @IBOutlet weak var Label_list_date_year: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ToDo
        let initial = Initial()
        initial.initialize()
        // データベース　注意：Initialより後に記述する
        let dataBaseManager = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManager.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        Label_list_date_year.text = fiscalYear.description + "年"
        // 初期表示位置
        scroll = true
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
        //通常、このメソッドは遷移先のViewController(仕訳画面)から戻る際には呼ばれないので、遷移先のdismiss()のクロージャにこのメソッドを指定する
//        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
//        print("viewWillAppear \(String(describing: presentedViewController))")
//        print("viewWillAppear \(String(describing: presentingViewController))")
        // UIViewControllerの表示画面を更新・リロード
        self.loadView()
        self.viewDidLoad()
    }
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // 初期表示位置 OFF
        scroll = false
    }
    
//    override func viewDidDisappear(_ animated: Bool){}
    // MARK: - Table view data source
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    // スクロール
    var Number = 0
    func autoScroll(number: Int) {
        // TabBarControllerから遷移してきした時のみ、テーブルビューの更新と初期表示位置を指定
        scroll_adding = true
        Number = number
        // 仕訳入力後に仕訳帳を更新する
        TableView_JournalEntry.reloadData()
    }
    // セクションの数を設定する
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 12     // セクションの数はreturn 12 で 12ヶ月分に設定します。
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33 //セクションヘッダーの高さを33に設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.textAlignment = .left
//        let attributedStr = NSMutableAttributedString(string: header.textLabel?.text)
//        let crossAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//        header.textLabel?.text = attributedStr
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let dataBaseManager = DataBaseManagerJournalEntry() //データベースマネジャー
        let counts = dataBaseManager.getJournalEntryCounts(section: section) // 何月のセクションに表示するセルかを引数で渡す
//        print("月別のセル数:\(counts)")
        return counts //月別の仕訳データ数
    }
    //セルを生成して返却するメソッド
    var indexPathForAutoScroll: IndexPath = IndexPath(row: 0, section: 0)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let dataBaseManager = DataBaseManagerJournalEntry() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = dataBaseManager.getJournalEntry(section: indexPath.section) // 何月のセクションに表示するセルかを判別するため引数で渡す
//        print("月別のセル:\(objects)")
        //① UI部品を指定　TableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCell
        //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
        // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
        if Number == objects[indexPath.row].number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
            indexPathForAutoScroll = indexPath                              // セルの位置　を覚えておく
        }
        
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
            cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(1))" // 末尾1文字の「日」         //日付
        }else{
            cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(2))" // 末尾2文字の「日」         //日付
        }
        cell.label_list_date.textAlignment = NSTextAlignment.right
        cell.label_list_summary_debit.text = " (\(objects[indexPath.row].debit_category))"     //借方勘定
        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
        cell.label_list_summary_credit.text = "(\(objects[indexPath.row].credit_category)) "   //貸方勘定
        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
        cell.label_list_summary.text = "\(objects[indexPath.row].smallWritting) "              //小書き
        cell.label_list_summary.textAlignment = NSTextAlignment.left
        let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].debit_category)")
        cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
        let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].credit_category)")
        cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
        cell.label_list_debit.text = "\(addComma(string: String(objects[indexPath.row].debit_amount))) "        //借方金額
        cell.label_list_credit.text = "\(addComma(string: String(objects[indexPath.row].credit_amount))) "      //貸方金額
        //③
        
        return cell
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はviewDidLoadで行う
    func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    // セルが画面に表示される直前に表示される
    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
    var scroll_adding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var indexPath_local = IndexPath(row: 0, section: 0)
        if scroll || scroll_adding {     // 初回起動時の場合 入力ボタン押下時の場合
            print(TableView_JournalEntry.numberOfSections)
            for s in 0..<TableView_JournalEntry.numberOfSections {            //セクション数　ゼロスタート補正は不要
                if TableView_JournalEntry.numberOfRows(inSection: s) > 0 {
                    let r = TableView_JournalEntry.numberOfRows(inSection: s)-1 //セル数　ゼロスタート補正
                    indexPath_local = IndexPath(row: r, section: s)
                    self.tableView.scrollToRow(at: indexPath_local, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                }
            }
            // ボツ　見えている範囲のみなので行数が増えると動かない
//            if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last { // 見えている範囲のみなので行数が増えると動かない　.firstの意味は先頭行のこと　エラーがでている
//                print("lastVisibleIndexPath \(lastVisibleIndexPath[0]),\(lastVisibleIndexPath[1])")
//                print("           indexPath \(indexPath[0]),\(indexPath[1])")
//                if indexPath != lastVisibleIndexPath {  // 表示しようとしているセルの行が、最後の行ではない場合
//                    print("           indexPath.row \(indexPath.row), numberOfRows \(tableView.numberOfRows(inSection: indexPath[0]))")
//                    if indexPath.row == tableView.numberOfRows(inSection: indexPath[0])-1 { // 表示しようとしているセル（行）とセルの数を比較。ゼロスタート補正　最大数まで表示した場合
                        // テーブルビューの初期表示位置を指定 セルが表示されるたびにセルの最後尾までスクロールする
//                        self.tableView.scrollToRow(at: lastVisibleIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
//                        self.tableView.scrollToRow(at: lastVisibleIndexPath, at: UITableView.ScrollPosition.middle, animated: true)
//                        self.tableView.scrollToRow(at: lastVisibleIndexPath, at: UITableView.ScrollPosition.none, animated: true)
//                    }
//                }
//            }
        }
        if scroll_adding {     // 入力ボタン押下時の場合
            // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
            if indexPath == indexPath_local { // 最後のセルまで表示しされたかどうか
                self.tableView.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.bottom, animated: false) // 追加した仕訳データの行を画面の下方に表示する
                // 入力ボタン押下時の表示位置 OFF
                scroll_adding = false
            }
        }
    }
}
