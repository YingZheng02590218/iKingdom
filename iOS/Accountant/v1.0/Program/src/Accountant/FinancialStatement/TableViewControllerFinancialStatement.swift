//
//  TableViewControllerFinancialStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 決算書クラス
class TableViewControllerFinancialStatement: UITableViewController {

    @IBOutlet var TableViewFS: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 貸借対照表、損益計算書、キャッシュフロー計算書、精算書、試算表
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BS", for: indexPath)
            cell.textLabel?.text = "貸借対照表"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PL", for: indexPath)
            cell.textLabel?.text = "損益計算書"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CF", for: indexPath)
            cell.textLabel?.text = "キャッシュフロー計算書"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WS", for: indexPath)
            cell.textLabel?.text = "精算表"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TB", for: indexPath)
            cell.textLabel?.text = "試算表"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
            cell.textLabel?.text = ""
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        }        
    }

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

    
    // MARK: - Navigation
    // 画面遷移の準備　貸借対照表画面 損益計算書画面 キャッシュフロー計算書
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableViewFS.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
