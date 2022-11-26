//
//  SettingsPeriodTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 会計期間クラス
class SettingsPeriodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {


    @IBOutlet var gADBannerView: GADBannerView!

    private var interstitial: GADInterstitialAd?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // テーブルビューセル　作成
        createTableViewCell()
        tableView.allowsMultipleSelection = false
        self.navigationItem.title = "会計期間"
        //largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // iPhone X のポートレート決め打ちです　→ 仕訳帳のタブバーの上にバナー広告が表示されるように調整した。
    //        print(self.view.frame.size.height)
    //        print(gADBannerView.frame.height)
    //        gADBannerView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - gADBannerView.frame.height + tableView.contentOffset.y) // スクロール時の、広告の位置を固定する
    //        gADBannerView.frame.size = CGSize(width: self.view.frame.width, height: gADBannerView.frame.height)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOB_ID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.visibleCells[tableView.visibleCells.count-1].frame.height)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count-1].frame.height * -1)
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }
        // セットアップ AdMob
        setupAdMob()
    }
    // インタースティシャル広告を表示　マネタイズ対応
    func showAd() {
        
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            }
            else {
                print("Ad wasn't ready")
                // セットアップ AdMob
                setupAdMob()
            }
        }
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
    }
    
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingPeriod"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        }
        else {
            // チュートリアル対応 コーチマーク型
            finishAnnotation()
        }
    }
    // チュートリアル対応 コーチマーク型
    func presentAnnotation() {
        //タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        let viewController = UIStoryboard(name: "SettingsPeriodTableViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_SettingPeriod") as! AnnotationViewControllerSettingPeriod
        viewController.alpha = 0.7
        present(viewController, animated: true, completion: nil)
    }
    
    func finishAnnotation() {
        //タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
    }
    // 前準備
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // セグエで場合分け
        if segue.identifier == "identifier_theDayOfReckoning"{ // 決算日設定
            // ③遷移先ViewCntrollerの取得
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! SettingsTheDayOfReckoningTableViewController
            // 選択されたセルを取得
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
            // 遷移先のコントローラに値を渡す
            if indexPath.row == 0 {
                viewController.month = true // 決算日　月
            }else if indexPath.row == 1 {
                viewController.month = false // 決算日　日
            }
        }else{
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
    }
    
    // MARK: - Setting
    
    // セルを登録
    func createTableViewCell() {
        //xib読み込み
        let nib = UINib(nibName: "WithLabelTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
    }
    
    // MARK: GADInterstitialAd
    // セットアップ AdMob
    func setupAdMob() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView プロパティを設定する
            // GADInterstitial を作成する
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: Constant.ADMOB_ID_INTERSTITIAL,
                                   request: request,
                                   completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
            }
            )
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算日"
        case 1:
            return "会計年度"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    // セクションフッターのテキスト決める
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算日は、財務諸表や仕訳帳、精算表、試算表に表示されます。"
        case 1:
            let dataBaseManagerJournalEntry = DataBaseManagerJournalEntry()
            let results = dataBaseManagerJournalEntry.getJournalEntryCount()
            let resultss = dataBaseManagerJournalEntry.getAdjustingEntryCount()
            return "データ総数:　仕訳: \(results.count),　決算整理仕訳: \(resultss.count)"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 決算日
            return 2
        case 1:
            // 会計年度
            let counts = DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount()
            return counts
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // 決算日
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_theDayOfReckoning", for: indexPath) as! SettingsPeriodTableViewCell
            let object = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            // 会計帳簿の年度をセルに表示する
            if indexPath.row == 0 {
                cell.textLabel?.text = "月"
                let d = object
                let date = d[d.index(d.startIndex, offsetBy: 0)..<d.index(d.startIndex, offsetBy: 2)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel2.text = "\(date)"
                print(date)
            }else {
                cell.textLabel?.text = "日"
                let d = object
                let date = d[d.index(d.startIndex, offsetBy: 3)..<d.index(d.startIndex, offsetBy: 5)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel2.text = "\(date)"
                print(date)
            }
            return cell
        case 1:
            // 会計年度
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithLabelTableViewCell
            // データベース
            let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
            let objectsJournalEntry = DataBaseManagerSettingsPeriod.shared.getJournalEntryCount(fiscalYear: objects[indexPath.row].fiscalYear)
            let objectsAdjustingEntry = DataBaseManagerSettingsPeriod.shared.getAdjustingEntryCount(fiscalYear: objects[indexPath.row].fiscalYear)
            // 会計帳簿の年度をセルに表示する
            cell.leftTextLabel.text = " \(objects[indexPath.row].fiscalYear as Int)"
#if DEBUG
            cell.rightdetailTextLabel.text = "データ数: \((objects[indexPath.row].dataBaseJournals?.dataBaseJournalEntries.count)! as Int):\(objectsJournalEntry.count),  \((objects[indexPath.row].dataBaseJournals?.dataBaseAdjustingEntries.count)! as Int):\(objectsAdjustingEntry.count)"
#else
            cell.rightdetailTextLabel.text = "データ数:　\(objectsJournalEntry.count), \(objectsAdjustingEntry.count)"
#endif
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithLabelTableViewCell
            return cell
        }
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // 会計年度
            let cell = tableView.cellForRow(at:indexPath)
            // チェックマークを入れる
            cell?.accessoryType = .checkmark
            // ここからデータベースを更新する
            pickAccountingBook(tag: cell!.tag) //会計帳簿の連番
            // 年度を選択時に会計期間画面を更新する
            tableView.reloadData()
            break
        default:
            print("")
            break
        }
    }
    // チェックマークの切り替え　データベースを更新
    func pickAccountingBook(tag: Int) {
        // データベース
        DataBaseManagerSettingsPeriod.shared.setMainBooksOpenOrClose(tag: tag)
        // 帳簿の年度を切り替えた場合、設定勘定科目と勘定の勘定科目を比較して、不足している勘定を追加する　2020/11/08
        let dataBaseManagerAccount = GenearlLedgerAccountModel()
        dataBaseManagerAccount.addGeneralLedgerAccountLack() 
    }
    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at:indexPath)
            // チェックマークを外す
            cell?.accessoryType = .none
        }
    }
    // 削除機能 セルを左へスワイプ
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        print("選択されたセルを取得: \(indexPath.section), \(indexPath.row)") //  1行目 [4, 0] となる　7月の仕訳データはsection4だから
        // スタイルには、normal と　destructive がある
        let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            // なんか処理
            // 確認のポップアップを表示したい
            self.showPopover(indexPath: indexPath)
            completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
        }
        action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "会計帳簿を削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース
            let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
            if objects.count > 1 {
                // 会計帳簿を削除
                let dataBaseManager = DataBaseManagerAccountingBooks()
                let result = dataBaseManager.deleteAccountingBooks(number: objects[indexPath.row].number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップオーバーされる
        return .none
    }
}

// MARK: - GADFullScreenContentDelegate

extension SettingsPeriodTableViewController: GADFullScreenContentDelegate {
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
        // セットアップ AdMob
        setupAdMob()
    }
}
