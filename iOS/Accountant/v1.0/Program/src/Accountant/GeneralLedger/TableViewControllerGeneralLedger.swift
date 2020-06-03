//
//  TableViewControllerGeneralRedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerGeneralLedger: UITableViewController {

    @IBOutlet var TableView_generalLedger: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        case 3:
            return "費用の部"
        case 4:
            return "収益の部"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // 勘定科目の名称をセルに表示する
        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        return cell
    }
    
//    var account :String = "" // 勘定名
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 選択されたセルを取得
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath) as! TableViewCellGeneralLedger
//        account = String(cell.textLabel!.text!) // セルに表示した勘定名を取得
//        // セルの選択を解除
//        tableView.deselectRow(at: indexPath, animated: true)
//        // 別の画面に遷移
//        performSegue(withIdentifier: "identifier_generalLedger", sender: nil)
//    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableView_generalLedger.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
//        let cell = self.TableView_generalLedger.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // segue.destinationの型はUIViewController
        let viewControllerGenearlLedgerAccount = segue.destination as! ViewControllerGenearlLedgerAccount
        // 遷移先のコントローラに値を渡す
        viewControllerGenearlLedgerAccount.account = "\(objects[indexPath.row].category as String)" // セルに表示した勘定名を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
