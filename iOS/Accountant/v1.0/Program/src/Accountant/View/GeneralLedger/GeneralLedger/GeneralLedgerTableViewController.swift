//
//  TableViewControllerGeneralRedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 総勘定元帳クラス
class GeneralLedgerTableViewController: UITableViewController {

    // MARK: - var let

    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "総勘定元帳"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 総勘定元帳を開いた後で、設定画面の勘定科目のON/OFFを変えるとエラーとなるのでリロードする
        tableView.reloadData()
        
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        Rank0.allCases.count
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Rank0.allCases[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseManagerSettings = CategoryListModel()
        let objects = databaseManagerSettings.getSettingsSwitchingOn(rank0: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let databaseManagerSettings = CategoryListModel()
        let objects = databaseManagerSettings.getSettingsSwitchingOn(rank0: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // 勘定科目の名称をセルに表示する
        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        // 仕訳データがない勘定の表示名をグレーアウトする
        let model = GeneralLedgerAccountModel()
        // 開始仕訳
        let dataBaseOpeningJournalEntry = model.getOpeningJournalEntryInAccount(account: objects[indexPath.row].category)

        let objectss = model.getJournalEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 勘定別に取得
        let objectsss = model.getAllAdjustingEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 決算整理仕訳

        if !objectss.isEmpty || !objectsss.isEmpty || dataBaseOpeningJournalEntry != nil {
            cell.textLabel?.textColor = .textColor
        } else {
            cell.textLabel?.textColor = .lightGray
        }
        // 資本振替仕訳
        let dataBaseCapitalTransferJournalEntry = model.getCapitalTransferJournalEntryInAccount(account: objects[indexPath.row].category)
        let dataBaseSettingsOperating = RealmManager.shared.readWithPrimaryKey(type: DataBaseSettingsOperating.self, key: 1)
        if let englishFromOfClosingTheLedger1 = dataBaseSettingsOperating?.EnglishFromOfClosingTheLedger1 {
            // 資本振替仕訳
            if englishFromOfClosingTheLedger1 {
                // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定
                // 法人/個人フラグ
                if UserDefaults.standard.bool(forKey: "corporation_switch") {
                    if objects[indexPath.row].category == CapitalAccountType.retainedEarnings.rawValue {
                        if dataBaseCapitalTransferJournalEntry != nil {
                            cell.textLabel?.textColor = .textColor
                        } else {
                            cell.textLabel?.textColor = .lightGray
                        }
                    }
                } else {
                    if objects[indexPath.row].category == CapitalAccountType.capital.rawValue {
                        if dataBaseCapitalTransferJournalEntry != nil {
                            cell.textLabel?.textColor = .textColor
                        } else {
                            cell.textLabel?.textColor = .lightGray
                        }
                    }
                }
            }
        }

        return cell
    }
//    var account :String = "" // 勘定名
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 選択されたセルを取得
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath) as! GeneralLedgerTableViewCell
//        account = String(cell.textLabel!.text!) // セルに表示した勘定名を取得
//        // セルの選択を解除
//        tableView.deselectRow(at: indexPath, animated: true)
//        // 別の画面に遷移
//        performSegue(withIdentifier: "identifier_generalLedger", sender: nil)
//    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        if let indexPath: IndexPath = self.tableView.indexPathForSelectedRow {
            // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
            let databaseManagerSettings = CategoryListModel() // データベースマネジャー
            let objects = databaseManagerSettings.getSettingsSwitchingOn(rank0: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
            // ③遷移先ViewCntrollerの取得
            if let navigationController = segue.destination as? UINavigationController,
               let viewControllerGeneralLedgerAccount = navigationController.topViewController as? GeneralLedgerAccountViewController {
                // 遷移先のコントローラに値を渡す
                viewControllerGeneralLedgerAccount.account = "\(objects[indexPath.row].category as String)" // セルに表示した勘定名を取得
            }
            // セルの選択を解除
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
