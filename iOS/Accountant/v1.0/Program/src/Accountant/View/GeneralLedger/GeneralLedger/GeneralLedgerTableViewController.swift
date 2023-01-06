//
//  TableViewControllerGeneralRedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 総勘定元帳クラス
class GeneralLedgerTableViewController: UITableViewController {

    // MARK: - var let

   var gADBannerView: GADBannerView!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
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
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.rowHeight)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView!.rowHeight * -1)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
    }

    // リロード機能
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = TBModel()
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        // 精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
//        let WSModel = WSModel()
//        WSModel.calculateAmountOfAllAccount()
//        WSModel.calculateAmountOfAllAccountForBS()
//        WSModel.calculateAmountOfAllAccountForPL()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
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
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
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
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let objectss = dataBaseManagerAccount.getJournalEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 勘定別に取得
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 決算整理仕訳
        let objectssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: "\(objects[indexPath.row].category as String)") // 損益勘定
        let objectsssss = dataBaseManagerAccount.getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: "\(objects[indexPath.row].category as String)") // 繰越利益
        if !objectss.isEmpty || !objectsss.isEmpty || !objectssss.isEmpty || !objectsssss.isEmpty {
            cell.textLabel?.textColor = .textColor
        } else {
            cell.textLabel?.textColor = .lightGray
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
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
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
