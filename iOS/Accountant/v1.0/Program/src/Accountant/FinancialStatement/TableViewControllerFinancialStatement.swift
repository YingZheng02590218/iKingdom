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
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 2, section: 0) == self.TableViewFS.indexPathForSelectedRow! { //キャッシュ・フロー計算書　未対応
            return false //false:画面遷移させない
        }
        return true
    }
    // 画面遷移の準備　貸借対照表画面 損益計算書画面 キャッシュフロー計算書
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableViewFS.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得

//        switch segue.identifier {
//        case "segue_PL": //“セグウェイにつけた名称”:
//          // segue.destinationの型はUIViewController
//          let controller = segue.destination as! TableViewControllerPL
////          遷移先のコントローラー.条件用の属性 = “条件”
//        default:
//          break
//        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
