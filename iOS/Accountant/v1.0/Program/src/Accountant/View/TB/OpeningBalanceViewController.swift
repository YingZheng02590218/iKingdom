//
//  OpeningBalanceViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 開始残高 openingBalance
class OpeningBalanceViewController: UIViewController {

    // MARK: - var let

    var gADBannerView: GADBannerView!
    /// 開始残高　上部
    @IBOutlet private var companyNameLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closingDateLabel: UILabel!

    @IBOutlet private var printButton: UIButton!
    /// 開始残高　下部
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: EMTNeumorphicView!

    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false

    // 設定残高振替仕訳　連番
    var primaryKey: Int = 0
    // 勘定科目名
    var category: String = ""
    // 電卓画面で入力中の金額は、借方か貸方か
    var debitOrCredit: DebitOrCredit = .credit

    /// GUIアーキテクチャ　MVP
    private var presenter: OpeningBalancePresenterInput!
    func inject(presenter: OpeningBalancePresenterInput) {
        self.presenter = presenter
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = OpeningBalancePresenter.init(view: self, model: OpeningBalanceModel())
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
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
        }
    }

    // MARK: - Action

    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: UIButton) {

    }
}

extension OpeningBalanceViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 合計額の行の分
        return presenter.numberOfobjects + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < presenter.numberOfobjects {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_TB", for: indexPath) as? OpeningBalanceTableViewCell else { return UITableViewCell() }
            // delegate設定
            cell.delegate = self

            var account = ""
            var valueDebitText: Int64 = 0
            var valueCreditText: Int64 = 0

            if presenter.objects(forRow: indexPath.row).debit_category == "残高" { // 借方
                account = presenter.objects(forRow: indexPath.row).credit_category // 相手勘定科目名
                valueDebitText = presenter.objects(forRow: indexPath.row).debit_amount
            } else if presenter.objects(forRow: indexPath.row).credit_category == "残高" { // 貸方
                account = presenter.objects(forRow: indexPath.row).debit_category // 相手勘定科目名
                valueCreditText = presenter.objects(forRow: indexPath.row).credit_amount
            }

            cell.setup(
                primaryKey: presenter.objects(forRow: indexPath.row).number,
                category: account,
                valueDebitText: "\(valueDebitText)",
                valueCreditText: "\(valueCreditText)"
            ) { (textFieldAmountDebit, textFieldAmountCredit) in
                cell.debitLabel.text = textFieldAmountDebit.text
                cell.creditLabel.text = textFieldAmountCredit.text
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_last_TB", for: indexPath) as? TBTableViewCell else { return UITableViewCell() }
            // 残高　借方
            cell.debitLabel.text = presenter.debit_balance_total()
            // 残高　貸方
            cell.creditLabel.text = presenter.credit_balance_total()
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debitLabel.text != cell.creditLabel.text {
                cell.debitLabel.textColor = .red
                cell.creditLabel.textColor = .red
            } else {
                cell.debitLabel.textColor = .textColor
                cell.creditLabel.textColor = .textColor
            }
            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        if let controller = segue.destination as? ClassicCalculatorViewController {

            controller.primaryKey = primaryKey
            controller.debitOrCredit = debitOrCredit
            controller.category = category
        }
    }

    // 金額　電卓画面で入力した値を表示させる
    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit) {
        // 金額を入力後に、電卓画面から仕訳画面へ遷移した場合
        print(numbersOnDisplay, category, debitOrCredit)

        presenter.setAmountValue(primaryKey: primaryKey, numbersOnDisplay: numbersOnDisplay, category: category, debitOrCredit: debitOrCredit)
    }
}

extension OpeningBalanceViewController: InputTextTableCellDelegate {
    // MARK: - InputTextTableCellDelegate
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(primaryKey: Int, category: String, debitOrCredit: DebitOrCredit) {
        // 設定残高振替仕訳　連番
        self.primaryKey = primaryKey
        // 勘定科目名
        self.category = category
        // 借方金額　貸方金額
        self.debitOrCredit = debitOrCredit

        self.view.endEditing(true)
    }
}

extension OpeningBalanceViewController: OpeningBalancePresenterOutput {

    func reloadData() {

        tableView.reloadData()
    }

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
        titleLabel.text = " 開始残高"
        self.navigationItem.title = " 開始残高"
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

    }
}
