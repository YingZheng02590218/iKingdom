//
//  TableViewControllerSettingsPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerSettingsPeriod: UITableViewController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = false
    }

    // MARK: - Table view data source
    
    // 前準備
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // セグエのポップオーバー接続先を取得
        let popoverCtrl = segue.destination.popoverPresentationController
        // 呼び出し元がUIButtonの場合
        if sender is UIButton {
            // タップされたボタンの領域を取得
            popoverCtrl?.sourceRect = (sender as! UIButton).bounds
        }
        // デリゲートを自分自身に設定
        popoverCtrl?.delegate = self
    }
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップオーバーされる
        return .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "会計年度を選択"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let dataBaseManager = DataBaseManagerPeriod() //データベースマネジャー
        let counts = dataBaseManager.getMainBooksAllCount()
        return counts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // データベース
        let dataBaseManager = DataBaseManagerPeriod() //データベースマネジャー
        // データベースから取得
        let objects = dataBaseManager.getMainBooksAll()
        // 会計帳簿の年度をセルに表示する
        cell.textLabel?.text = " \(objects[indexPath.row].fiscalYear as Int)"
//        cell.textLabel?.text = "2023 年度" // ToDo
        cell.textLabel?.textAlignment = .center
        // 会計帳簿の連番
        cell.tag = objects[indexPath.row].number
        // 開いている帳簿にチェックマークをつける
        if objects[indexPath.row].openOrClose {
            // チェックマークを入れる
            cell.accessoryType = .checkmark
        }else {
            // チェックマークを外す
            cell.accessoryType = .none
        }
        return cell
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを入れる
        cell?.accessoryType = .checkmark
        // ここからデータベースを更新する
        pickAccountingBook(tag: cell!.tag)
        // 年度を選択時に会計期間画面を更新する
        tableView.reloadData()
    }
    // チェックマークの切り替え　データベースを更新
    func pickAccountingBook(tag: Int) {
        // データベース
        let databaseManager = DataBaseManagerPeriod() //データベースマネジャー
        databaseManager.setMainBooksOpenOrClose(tag: tag)
    }
    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを外す
        cell?.accessoryType = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
    }

}
