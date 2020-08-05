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
        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    // リロード機能
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        let databaseManagerWS = DataBaseManagerWS()
        databaseManagerWS.calculateAmountOfAllAccount()
        databaseManagerWS.calculateAmountOfAllAccountForBS()
        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
    }
    override func viewWillAppear(_ animated: Bool) {
        // 総勘定元帳を開いた後で、設定画面の勘定科目のON/OFFを変えるとエラーとなるのでリロードする
        tableView.reloadData()
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
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // 勘定科目の名称をセルに表示する
        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        // 仕訳データがない勘定の表示名をグレーアウトする
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objectss = dataBaseManagerAccount.getAllAccount(account: "\(objects[indexPath.row].category as String)")
        let objectsss = dataBaseManagerAccount.getAllAccountAdjusting(account: "\(objects[indexPath.row].category as String)")
        if objectss.count > 0 || objectsss.count > 0 {
            cell.textLabel?.textColor = .black
        }else {
            cell.textLabel?.textColor = .lightGray
        }
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
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
//        let cell = self.TableView_generalLedger.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // segue.destinationの型はUIViewController
        let viewControllerGenearlLedgerAccount = segue.destination as! ViewControllerGenearlLedgerAccount
        // 遷移先のコントローラに値を渡す
        viewControllerGenearlLedgerAccount.account = "\(objects[indexPath.row].category as String)" // セルに表示した勘定名を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
