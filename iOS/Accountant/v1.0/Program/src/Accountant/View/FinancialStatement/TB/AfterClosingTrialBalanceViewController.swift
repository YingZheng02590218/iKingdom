//
//  AfterClosingTrialBalanceViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 繰越試算表 afterClosingTrialBalance
class AfterClosingTrialBalanceViewController: UIViewController {

    // MARK: - var let

    var gADBannerView: GADBannerView!
    /// 繰越試算表　上部
    @IBOutlet private var companyNameLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closingDateLabel: UILabel!

    @IBOutlet private var printButton: UIButton!
    /// 繰越試算表　下部
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    // グラデーションレイヤー　書類系画面
    let gradientLayer = CAGradientLayer()

    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    var account = "" // 勘定名

    /// GUIアーキテクチャ　MVP
    private var presenter: AfterClosingTrialBalancePresenterInput!
    func inject(presenter: AfterClosingTrialBalancePresenterInput) {
        self.presenter = presenter
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = AfterClosingTrialBalancePresenter.init(view: self, model: AfterClosingTrialBalanceModel())
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
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.paperColor.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
            
            // グラデーション
            gradientLayer.frame = backgroundView.bounds
            gradientLayer.cornerRadius = 15
            gradientLayer.colors = [UIColor.paperGradationStart.cgColor, UIColor.paperGradationEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.6)
            gradientLayer.endPoint = CGPoint(x: 0.4, y: 1)
            if let sublayers = backgroundView.layer.sublayers, sublayers.contains(gradientLayer) {
                backgroundView.layer.replaceSublayer(gradientLayer, with: gradientLayer)
            } else {
                backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }

    // MARK: - Action

    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: UIButton) {

    }
}

extension AfterClosingTrialBalanceViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfsections() + 1 // 合計額の行の分
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < presenter.numberOfsections() {
            presenter.numberOfobjects(section: section)
        } else {
            1 // 合計額の行の分
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < presenter.numberOfsections() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_TB", for: indexPath) as? TBTableViewCell else { 
                return UITableViewCell()
            }
            // 勘定科目をセルに表示する
            cell.accountLabel.text = "\(presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String)"
            cell.accountLabel.textAlignment = NSTextAlignment.center
            // 残高　借方　勘定別の決算整理後の合計額
            cell.debitLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String)", leftOrRight: 2)
            // 残高　貸方　勘定別の決算整理後の合計額
            cell.creditLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String)", leftOrRight: 3)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_last_TB", for: indexPath) as? TBTableViewCell else { 
                return UITableViewCell()
            }
            // 借方　残高　集計
            cell.debitLabel.text = presenter.debit_balance_total()
            // 貸方　残高　集計
            cell.creditLabel.text = presenter.credit_balance_total()
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debitLabel.text != cell.creditLabel.text {
                cell.debitLabel.textColor = .red
                cell.creditLabel.textColor = .red
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        account = presenter.objects(forRow: indexPath.row, section: indexPath.section).category

        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: "GeneralLedgerAccountViewController",
                bundle: nil
            ).instantiateViewController(
                withIdentifier: "GeneralLedgerAccountViewController"
            ) as? GeneralLedgerAccountViewController {
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                // 遷移先のコントローラに値を渡す
                viewController.account = self.account // セルに表示した勘定名を取得
                self.present(navigation, animated: true, completion: nil)
            }
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AfterClosingTrialBalanceViewController: AfterClosingTrialBalancePresenterOutput {

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
        titleLabel.text = " 繰越試算表"
        self.navigationItem.title = " 繰越試算表"
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
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView!.rowHeight * -1)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
        
        tableView.reloadData()
    }

    func setupViewForViewWillDisappear() {
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }

    func setupViewForViewDidAppear() {

    }
}
