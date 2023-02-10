//
//  SettingsPeriodTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 会計期間クラス
class SettingsPeriodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    private var interstitial: GADInterstitialAd?
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    // フィードバック
    private let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // テーブルビューセル　作成
        createTableViewCell()
        tableView.allowsMultipleSelection = false
        tableView.separatorColor = .accentColor

        self.navigationItem.title = "会計期間"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        
        // セットアップ AdMob
        setupAdMob()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // インタースティシャル広告を表示　マネタイズ対応
    func showAd() {
        
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
                // セットアップ AdMob
                setupAdMob()
            }
        }
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
    }
    
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingPeriod"
        if userDefaults.bool(forKey: firstLunchKey) {
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        }
    }
    // チュートリアル対応 コーチマーク型
    func presentAnnotation() {
        // タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        if let viewController = UIStoryboard(
            name: "SettingsPeriodTableViewController",
            bundle: nil
        ).instantiateViewController(withIdentifier: "Annotation_SettingPeriod") as? AnnotationViewControllerSettingPeriod {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    // コーチマーク画面からコール
    func finishAnnotation() {
        // フラグを倒す
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingPeriod"
        userDefaults.set(false, forKey: firstLunchKey)
        userDefaults.synchronize()

        // タブの有効化
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
            if let navigationController = segue.destination as? UINavigationController,
               let viewController = navigationController.topViewController as? SettingsTheDayOfReckoningTableViewController,
               // 選択されたセルを取得
               let indexPath: IndexPath = self.tableView.indexPathForSelectedRow {
                // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
                // 遷移先のコントローラに値を渡す
                if indexPath.row == 0 {
                    viewController.month = true // 決算日　月
                } else if indexPath.row == 1 {
                    viewController.month = false // 決算日　日
                }
            }
        } else {
            // セグエのポップオーバー接続先を取得
            let popoverCtrl = segue.destination.popoverPresentationController
            // 呼び出し元がUIButtonの場合
            if sender is UIButton {
                // タップされたボタンの領域を取得
                if let button = sender as? UIButton {
                    popoverCtrl?.sourceRect = button.bounds
                }
            }
            // デリゲートを自分自身に設定
            popoverCtrl?.delegate = self
        }
    }

    // MARK: - Setting

    // セルを登録
    func createTableViewCell() {
        // xib読み込み
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
            GADInterstitialAd.load(
                withAdUnitID: Constant.ADMOBIDINTERSTITIAL,
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
    // セクションフッターのテキスト決める
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算日は、財務諸表や仕訳帳、精算表、試算表に表示されます。"
        case 1:
            let results = DataBaseManagerJournalEntry.shared.getJournalEntryCount()
            let resultss = DataBaseManagerAdjustingEntry.shared.getAdjustingEntryCount()
            return "開始残高は、最も古い年度の帳簿に適用されます。\n入力データ総数:　仕訳: \(results.count),　決算整理仕訳: \(resultss.count)"
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_theDayOfReckoning", for: indexPath) as? SettingsPeriodTableViewCell else {
                return UITableViewCell()
            }
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            // 会計帳簿の年度をセルに表示する
            if indexPath.row == 0 {
                cell.textLabel?.text = "月"
                let day = theDayOfReckoning
                let date = day[day.index(day.startIndex, offsetBy: 0)..<day.index(day.startIndex, offsetBy: 2)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel2.text = "\(date)"
                print(date)
            } else {
                cell.textLabel?.text = "日"
                let day = theDayOfReckoning
                let date = day[day.index(day.startIndex, offsetBy: 3)..<day.index(day.startIndex, offsetBy: 5)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel2.text = "\(date)"
                print(date)
            }
            // Accessory Color
            let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
            let disclosureView = UIImageView(image: disclosureImage)
            disclosureView.tintColor = UIColor.accentColor
            cell.accessoryView = disclosureView

            return cell
        case 1:
            // 会計年度
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithLabelTableViewCell else {
                return UITableViewCell()
            }
            // データベース
            let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
            let objectsJournalEntry = DataBaseManagerSettingsPeriod.shared.getJournalEntryCount(fiscalYear: objects[indexPath.row].fiscalYear)
            let objectsAdjustingEntry = DataBaseManagerSettingsPeriod.shared.getAdjustingEntryCount(fiscalYear: objects[indexPath.row].fiscalYear)
            // 会計帳簿の年度をセルに表示する
            cell.leftTextLabel.text = " \(objects[indexPath.row].fiscalYear as Int)"
#if DEBUG
            if let dataBaseJournals = objects[indexPath.row].dataBaseJournals {
                print("dataBaseJournals.dataBaseJournalEntries.count", dataBaseJournals.dataBaseJournalEntries.count)
                print("dataBaseJournals.dataBaseAdjustingEntries.count", dataBaseJournals.dataBaseAdjustingEntries.count)
                cell.rightdetailTextLabel.text = "データ数: \((dataBaseJournals.dataBaseJournalEntries.count)):\(objectsJournalEntry.count),  \((dataBaseJournals.dataBaseAdjustingEntries.count)):\(objectsAdjustingEntry.count)"
            }
            print("objectsJournalEntry", objectsJournalEntry.count)
            print("objectsAdjustingEntry", objectsAdjustingEntry.count)
#else
            cell.rightdetailTextLabel.text = "データ数:　\(objectsJournalEntry.count), \(objectsAdjustingEntry.count)"
#endif
            // 会計帳簿の連番
            cell.tag = objects[indexPath.row].number
            // 開いている帳簿にチェックマークをつける
            if objects[indexPath.row].openOrClose {
                // チェックマークを入れる
                cell.accessoryType = .checkmark
            } else {
                // チェックマークを外す
                cell.accessoryType = .none
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithLabelTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // 会計年度
            if let cell = tableView.cellForRow(at: indexPath) {
                // ダイアログ
                showDialog(tag: cell.tag) // 会計帳簿の連番
            }
        default:
            print("")
        }
    }
    // チェックマークの切り替え　データベースを更新
    func pickAccountingBook(tag: Int) {
        // インジゲーターを開始
        self.showActivityIndicatorView()
        DispatchQueue.global(qos: .default).async {
            // データベース
            DataBaseManagerSettingsPeriod.shared.setMainBooksOpenOrClose(tag: tag)
            // 帳簿の年度を切り替えた場合、設定勘定科目と勘定の勘定科目を比較して、不足している勘定を追加する　2020/11/08
            let dataBaseManagerAccount = GeneralLedgerAccountModel()
            dataBaseManagerAccount.addGeneralLedgerAccountLack()
            // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
            let databaseManager = TBModel()
            databaseManager.setAllAccountTotal()            // 集計　合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))
            databaseManager.calculateAmountOfAllAccount()   // 合計額を計算
            // インジケーターを終了
            self.finishActivityIndicatorView()
            Thread.sleep(forTimeInterval: 0.5)
            DispatchQueue.main.async {
                // リロード
                self.tableView.reloadData() // 年度を選択時に会計期間画面を更新する
            }
        }
    }
    // ダイアログ
    func showDialog(tag: Int) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        
        let alert = UIAlertController(
            title: "変更",
            message: "帳簿を変更しますか？",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    // ここからデータベースを更新する
                    self.pickAccountingBook(tag: tag) // 会計帳簿の連番
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            // タブの無効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = false
                    }
                }
            }
            // 背景になるView
            self.backView.backgroundColor = .mainColor
            // 表示位置を設定（画面中央）
            self.activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            self.activityIndicatorView.style = UIActivityIndicatorView.Style.large
            // インジケーターを View に追加
            self.backView.addSubview(self.activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            self.activityIndicatorView.startAnimating()
            
            // tabBarControllerのViewを使う
            guard let tabBarView = self.tabBarController?.view else {
                return
            }
            // 背景をNavigationControllerのViewに貼り付け
            tabBarView.addSubview(self.backView)
            
            // サイズ合わせはAutoLayoutで
            self.backView.translatesAutoresizingMaskIntoConstraints = false
            self.backView.topAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
            self.backView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor).isActive = true
            self.backView.leftAnchor.constraint(equalTo: tabBarView.leftAnchor).isActive = true
            self.backView.rightAnchor.constraint(equalTo: tabBarView.rightAnchor).isActive = true
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        // 非同期処理などが終了したらメインスレッドでアニメーション終了
        DispatchQueue.main.async {
            // 非同期処理などを実行（今回は2秒間待つだけ）
            Thread.sleep(forTimeInterval: 1.0)
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // タブの有効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = true
                    }
                }
            }
            self.backView.removeFromSuperview()
        }
    }

    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
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

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { (action: UIAlertAction!) in
                    print("OK アクションをタップした時の処理")
                    // データベース
                    let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
                    if objects.count > 1 {
                        // 会計帳簿を削除
                        let result = DataBaseManagerAccountingBooks.shared.deleteAccountingBooks(number: objects[indexPath.row].number)
                        if result == true {
                            self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                        }
                    }
                }
            )
        )
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
