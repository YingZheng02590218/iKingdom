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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBOutlet var tableViewM: UITableView!
    override func viewWillAppear(_ animated: Bool){
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
//        tableViewM.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool){}
    // MARK: - Table view data source

    //セクションの数はreturn 1でひとつに設定します。12ヶ月分にする
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 12
    }
    //セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23 //セクションヘッダーの高さを50に設定
    }
    //セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.textAlignment = .left
//        let attributedStr = NSMutableAttributedString(string: header.textLabel?.text)
//        let crossAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//        header.textLabel?.text = attributedStr
    }
    //セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var section_num = section + 4//4月スタートに補正する todo 設定の決算月によって変更する
        //セクションヘッダーは1年分の12ヶ月にする
        if section_num >= 13 {  //12ヶ月を超えた場合1月に戻す
            section_num -= 12
        }
        let header_title = section_num.description + "  月"
        return header_title
    }
    //セルの数を、JournalEntries.countで、JournalEntries配列の要素の数に指定します。
    //ToDo 仕訳の数にする
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // データベース
        let dataBaseManager = DataBaseManager() //データベースマネジャー
        let objects = dataBaseManager.getJournalEntry()
        
        return objects.count //JournalEntries.count
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let dataBaseManager = DataBaseManager() //データベースマネジャー
        let objects = dataBaseManager.getJournalEntry()
        
        //① UI部品を指定　TableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCell
        
        //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
        // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
        cell.label_list_date.text = objects[indexPath.row].date + " "                               //日付
        cell.label_list_summary_debit.text = " (" + objects[indexPath.row].debit_category + ")"     //借方勘定
        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
        cell.label_list_summary_credit.text = "(" + objects[indexPath.row].credit_category + ") "   //貸方勘定
        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
        cell.label_list_summary.text = objects[indexPath.row].smallWritting + " "                   //小書き
        cell.label_list_summary.textAlignment = NSTextAlignment.right
        // ToDo 勘定科目の番号
        cell.label_list_number.text = "1" //元丁
        cell.label_list_debit.text = String(objects[indexPath.row].debit_amount) + " "        //借方金額
        cell.label_list_credit.text = String(objects[indexPath.row].credit_amount) + " "      //貸方金額
        //③
        
        return cell
    }

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
