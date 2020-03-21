//
//  TableViewControllerA.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerA: UITableViewController {

    let JournalEntries = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","31",]     //["4","5","6","7","8","9","10","11","12","1","2","3"] //["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let summary_debit = ["現金","普通預金","旅費交通費","交際費","交通費","受取利息","減価償却費","雑益","雑損","減価償却累計額","k","l","m","n","o","p","q","減価償却累計額","s","t","u","v","w","x","y","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額"]
    let summary_credit = ["現金","普通預金","旅費交通費","交際費","交通費","受取利息","減価償却費","雑益","雑損","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","o","p","q","減価償却累計額","s","減価償却累計額","u","減価償却累計額","w","x","y","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額","減価償却累計額"]
    let debit = ["100","1000","10000","100000","1000000","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999",]
    let credit = ["100","1000","10000","100000","1000000","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999","9999999",]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    //セクションの数はreturn 1でひとつに設定します。12ヶ月分にする
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 12
    }
    //セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25 //セクションヘッダーの高さを50に設定
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
        var section_num = section + 4//4月スタートを補正
        //todo セクションヘッダーは12ヶ月分にする
        if section_num >= 13 {
            section_num -= 12
        }
        let header_title = section_num.description + "  月"
        return header_title
    }
    //セルの数を、categories.countで、categories配列の要素の数に指定します。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return JournalEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //①
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCell
        //②
        //todo
        cell.label_list_summary.text = JournalEntries[indexPath.row]
        cell.label_list_summary_debit.text = "(" + summary_debit[indexPath.row] + ")"
        cell.label_list_summary_credit.text = "(" + summary_credit[indexPath.row] + ")"
        cell.label_list_data.text = JournalEntries[indexPath.row]
        cell.label_list_number.text = JournalEntries[indexPath.row]
        cell.label_list_debit.text = debit[indexPath.row]
        cell.label_list_credit.text = credit[indexPath.row]
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
