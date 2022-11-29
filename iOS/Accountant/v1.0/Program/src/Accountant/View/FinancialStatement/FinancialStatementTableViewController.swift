//
//  FinancialStatementTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 決算書クラス
class FinancialStatementTableViewController: UITableViewController {

    
    @IBOutlet var gADBannerView: GADBannerView!
    
    @IBOutlet var TableViewFS: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = .AccentColor

        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.title = "決算書"
        //largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .AccentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {        
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOB_ID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.rowHeight)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1)
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }

    }
    
    // リロード機能
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = TBModel() 
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        let WSModel = WSModel()
        WSModel.initialize()
        // 設定表示科目　初期化
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        dataBaseManagerTaxonomy.initializeTaxonomy()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            // 決算報告手続き
        case 0: return    "財務諸表"
            // 決算本手続き 帳簿の締切
        case 1: return    "決算振替仕訳"
        case 2: return    "決算整理仕訳"
            // 決算予備手続き
        case 3: return    "試算表"
            // TODO: 開始手続き
        // case 4: return    "再振替仕訳"
        // case 5: return    "開始仕訳"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 貸借対照表、損益計算書、キャッシュフロー計算書
            return 2//3
        case 1:
            // 損益勘定
            return 1
        case 2:
            // 精算書
            return 1
        case 3:
            // 試算表
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "BS", for: indexPath)
                cell.textLabel?.text = "貸借対照表"
                cell.textLabel?.textColor = .TextColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "PL", for: indexPath)
                cell.textLabel?.text = "損益計算書"
                cell.textLabel?.textColor = .TextColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "CF", for: indexPath)
//                cell.textLabel?.text = "キャッシュフロー計算書"
//                cell.textLabel?.textAlignment = NSTextAlignment.center
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textColor = .TextColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            }
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PLAccount", for: indexPath)
            cell.textLabel?.text = "損益勘定"
            cell.textLabel?.textColor = .TextColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        }
        else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "WS", for: indexPath)
            cell.textLabel?.text = "精算表"
            cell.textLabel?.textColor = .TextColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TB", for: indexPath)
            cell.textLabel?.text = "試算表"
            cell.textLabel?.textColor = .TextColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        }

        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")!.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.AccentColor
        cell.accessoryView = disclosureView

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let viewController = BSViewController.init(nibName: "BSViewController", bundle: nil)
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }else{
                    let navigation = UINavigationController(rootViewController:viewController)
                    self.present(navigation, animated: true, completion: nil)
                }
                break
            case 1:
                let viewController = PLViewController.init(nibName: "PLViewController", bundle: nil)
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }else{
                    let navigation = UINavigationController(rootViewController:viewController)
                    self.present(navigation, animated: true, completion: nil)
                }
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
//        if IndexPath(row: 2, section: 0) == self.TableViewFS.indexPathForSelectedRow! { //キャッシュ・フロー計算書　未対応
//            return false //false:画面遷移させない
//        }
        return true
    }
    // 画面遷移の準備　貸借対照表画面 損益計算書画面 キャッシュフロー計算書
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableViewFS.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        switch segue.identifier {
            // 損益勘定
        case "segue_PLAccount": //“セグウェイにつけた名称”:
            // ③遷移先ViewCntrollerの取得
            let navigationController = segue.destination as! UINavigationController
            let viewControllerGenearlLedgerAccount = navigationController.topViewController as! GenearlLedgerAccountViewController
            // 遷移先のコントローラに値を渡す
            viewControllerGenearlLedgerAccount.account = "損益勘定" // セルに表示した勘定名を設定
            // 遷移先のコントローラー.条件用の属性 = “条件”
            break
        default:
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
