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
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()

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
        
        // 編集ボタン setEditingメソッドを使用するため、Storyboard上の編集ボタンを上書きしてボタンを生成する
        editButtonItem.tintColor = .accentColor
        navigationItem.rightBarButtonItem = editButtonItem
        self.navigationItem.title = "開始残高"
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

    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // 編集中の場合
        if editing {
            navigationItem.title = "編集中"
            
            tableView.reloadData()
        } else {
            // 残高　借方　貸方
            if presenter.debit_balance_total() == presenter.credit_balance_total() {
                navigationItem.title = "開始残高"
                // ローディング処理
                // インジゲーターを開始
                self.showActivityIndicatorView()
                // 集計処理
                DispatchQueue.global(qos: .background).async {
                    self.presenter.refreshTable()
                }
            } else {
                // 再度編集中へ戻す
                self.setEditing(true, animated: true)
                // フィードバック
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                let alert = UIAlertController(title: "貸借の合計が不一致", message: "再度、入力してください", preferredStyle: .alert)
                self.present(alert, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
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
            // 編集中 は有効化
            cell.textFieldAmountDebit.isEnabled = self.isEditing
            cell.textFieldAmountCredit.isEnabled = self.isEditing

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
        // 更新処理
        self.tableView.reloadData()
    }
    
    func finishLoading() {
        // インジケーターを終了
        self.finishActivityIndicatorView()
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

        if let theDayOfBeginningOfYear = presenter.theDayOfBeginningOfYear {
            if let fiscalYear = presenter.fiscalYear {
                closingDateLabel.text = String(fiscalYear) + "年\(theDayOfBeginningOfYear.prefix(2))月\(theDayOfBeginningOfYear.suffix(2))日" // 決算日を表示する
            }
        }
        titleLabel.text = "開始残高"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
    }

    func setupViewForViewWillDisappear() {

    }

    func setupViewForViewDidAppear() {

    }
}
