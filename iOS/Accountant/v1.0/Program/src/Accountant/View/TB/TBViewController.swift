//
//  TBViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 合計残高試算表クラス　決算整理前
class TBViewController: UIViewController, UIPrintInteractionControllerDelegate {
    
    // MARK: - var let
    
    var gADBannerView: GADBannerView!
    /// 合計残高試算表　上部
    @IBOutlet private var companyNameLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closingDateLabel: UILabel!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var printButton: UIButton!
    /// 合計残高試算表　下部
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    var printing = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
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
    /// GUIアーキテクチャ　MVP
    private var presenter: TBPresenterInput!
    func inject(presenter: TBPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = TBPresenter.init(view: self, model: TBModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.viewWillDisappear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ボタン作成
        createButtons()
    }
    
    // MARK: - Setting
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.mainColor2.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
        }
    }
    
    // チュートリアル対応 コーチマーク型
    private func presentAnnotation() {
        // タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        if let viewController = UIStoryboard(name: "TBViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_TrialBalance") as? AnnotationViewController {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func finishAnnotation() {
        // タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func segmentedControl(_ sender: Any) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            titleLabel.text = "決算整理前合計試算表"
            self.navigationItem.title = "決算整理前合計試算表"
        } else {
            titleLabel.text = "決算整理前残高試算表"
            self.navigationItem.title = "決算整理前残高試算表"
        }
        tableView.reloadData()
    }
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: UIButton) {
        
    }
}

extension TBViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 合計額の行の分
        return presenter.numberOfobjects + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < presenter.numberOfobjects {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_TB", for: indexPath) as? TBTableViewCell else { return UITableViewCell() }
            // 勘定科目をセルに表示する
            //        cell.textLabel?.text = "\(presenter.objects(forRow:indexPath.row].category as String)"
            cell.accountLabel.text = "\(presenter.objects(forRow: indexPath.row).category as String)"
            cell.accountLabel.textAlignment = NSTextAlignment.center
            switch segmentedControl.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.debitLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 0)
                // 合計　貸方
                cell.creditLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 1)
            case 1: // 残高　借方
                cell.debitLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 2)
                // 残高　貸方
                cell.creditLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 3)
            default:
                print("cell_TB")
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_last_TB", for: indexPath) as? TBTableViewCell else { return UITableViewCell() }
            //            let r = 0
            //            switch r {
            switch segmentedControl.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.debitLabel.text = presenter.debit_total_total()
                // 合計　貸方
                cell.creditLabel.text = presenter.credit_total_total()
            case 1: // 残高　借方
                cell.debitLabel.text = presenter.debit_balance_total()
                // 残高　貸方
                cell.creditLabel.text = presenter.credit_balance_total()
            default:
                print("cell_last_TB")
            }
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debitLabel.text != cell.creditLabel.text {
                cell.debitLabel.textColor = .red
                cell.creditLabel.textColor = .red
            }
            return cell
        }
    }
}

extension TBViewController: TBPresenterOutput {
    
    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
        //        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(button_print))
        //        //ナビゲーションに定義したボタンを置く
        //        self.navigationItem.rightBarButtonItem = printoutButton
        printButton.isHidden = true
    }
    
    func setupViewForViewWillAppear() {
        if let company = presenter.company {
            // 月末、年度末などの決算日をラベルに表示する
            companyNameLabel.text = company // 社名
        }
        
        if let theDayOfReckoning = presenter.theDayOfReckoning {
            if let fiscalYear = presenter.fiscalYear {
                if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                    closingDateLabel.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                } else {
                    closingDateLabel.text = String(fiscalYear + 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
            }
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            titleLabel.text = "決算整理前合計試算表"
            self.navigationItem.title = "決算整理前合計試算表"
        } else {
            titleLabel.text = "決算整理前残高試算表"
            self.navigationItem.title = "決算整理前残高試算表"
        }
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
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

    func setupViewForViewWillDisappear() {
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }

    func setupViewForViewDidAppear() {
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_TrialBalance"
        if userDefaults.bool(forKey: firstLunchKey) {
            userDefaults.set(false, forKey: firstLunchKey)
            userDefaults.synchronize()
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        } else {
            // チュートリアル対応 コーチマーク型
            finishAnnotation()
        }
    }
}
