//
//  WSViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 精算表クラス
class WSViewController: UIViewController, UIPrintInteractionControllerDelegate {
    
    // MARK: - var let
    
    var gADBannerView: GADBannerView!
    /// 精算表　上部
    @IBOutlet var labelCompanyName: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet private var labelClosingDate: UILabel!
    /// 精算表　下部
    @IBOutlet private var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    // 仕訳画面表示ボタン
    @IBOutlet private var addButton: UIButton!
    // グラデーションレイヤー　書類系画面
    let gradientLayer = CAGradientLayer()

    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    fileprivate let refreshControl = UIRefreshControl()
    
    var printing = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // 精算表画面で押下された場合は、決算整理仕訳とする
    @IBOutlet private var printButton: UIButton!
    // フィードバック
    let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    /// GUIアーキテクチャ　MVP
    private var presenter: WSPresenterInput!
    func inject(presenter: WSPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = WSPresenter.init(view: self, model: WSModel())
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
            
            // グラデーション
            gradientLayer.frame = backgroundView.bounds
            gradientLayer.cornerRadius = 15
            gradientLayer.colors = [UIColor.cellBackgroundGradationStart.cgColor, UIColor.cellBackgroundGradationEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.6)
            gradientLayer.endPoint = CGPoint(x: 0.4, y: 1)
            if let sublayers = backgroundView.layer.sublayers, sublayers.contains(gradientLayer) {
                backgroundView.layer.replaceSublayer(gradientLayer, with: gradientLayer)
            } else {
                backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        if let addButton = addButton {
            // ボタンを丸くする処理。ボタンが正方形の時、一辺を2で割った数値を入れる。(今回の場合、 ボタンのサイズは70×70であるので、35。)
            addButton.layer.cornerRadius = addButton.frame.width / 2 - 1
            // 影の色を指定。(UIColorをCGColorに変換している)
            addButton.layer.shadowColor = UIColor.black.cgColor
            // 影の縁のぼかしの強さを指定
            addButton.layer.shadowRadius = 3
            // 影の位置を指定
            addButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            // 影の不透明度(濃さ)を指定
            addButton.layer.shadowOpacity = 1.0
        }
    }
    
    // 仕訳画面表示ボタン
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        sender.animateView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 別の画面に遷移 仕訳画面
            self.performSegue(withIdentifier: "buttonTapped2", sender: nil)
        }
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
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
        if let viewController = UIStoryboard(name: "WSViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_WorkSheet") as? AnnotationViewController {
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
    
    @objc private func refreshTable() {
        
        presenter.refreshTable()
    }
    
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        return false // false:画面遷移させない
    }
    
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        if let controller = segue.destination as? JournalEntryViewController {
            // 遷移先のコントローラに値を渡す
            controller.journalEntryType = .AdjustingAndClosingEntries // セルに表示した仕訳タイプを取得
        }
    }
}

extension WSViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1 + 1  // + 試算表合計の行の分+修正記入の行の分+当期純利益+修正記入、損益計算書、貸借対照表の合計の分
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セル　決算整理前残高試算表の行
        if indexPath.row < presenter.numberOfobjects {
            // ① UI部品を指定
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
            // 勘定科目をセルに表示する
            cell.accountLabel.text = "\(presenter.objects(forRow: indexPath.row).category as String)"
            cell.accountLabel.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.debitLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 2)
            cell.debitLabel.textAlignment = NSTextAlignment.right
            cell.creditLabel.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 3)
            cell.creditLabel.textAlignment = NSTextAlignment.right
            cell.debitLabel.backgroundColor = .clear
            cell.creditLabel.backgroundColor = .clear
            switch Int(presenter.objects(forRow: indexPath.row).Rank0) {
            case 0, 1, 2, 3, 4, 5, 12: // 大分類　貸借対照表：0,1,2
                // 修正記入
                cell.debit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 0)
                cell.debit1Label.textAlignment = NSTextAlignment.right
                cell.credit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 1)
                cell.credit1Label.textAlignment = NSTextAlignment.right
                cell.debit1Label.backgroundColor = .clear
                cell.credit1Label.backgroundColor = .clear
                // 損益計算書
                cell.debit2Label.text = ""
                cell.credit2Label.text = ""
                cell.debit2Label.backgroundColor = .mainColor
                cell.credit2Label.backgroundColor = .mainColor
                // 貸借対照表 修正記入の分を差し引きして、表示する　WSModelを作成して処理を記述する
                cell.debit3Label.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 2)
                cell.debit3Label.textAlignment = NSTextAlignment.right
                cell.credit3Label.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 3)
                cell.credit3Label.textAlignment = NSTextAlignment.right
                cell.debit3Label.backgroundColor = .clear
                cell.credit3Label.backgroundColor = .clear
            case 6, 7, 8, 9, 10, 11: // 大分類 損益計算書：3,4
                // 修正記入
                cell.debit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 0)
                cell.debit1Label.textAlignment = NSTextAlignment.right
                cell.credit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 1)
                cell.credit1Label.textAlignment = NSTextAlignment.right
                cell.debit1Label.backgroundColor = .clear
                cell.credit1Label.backgroundColor = .clear
                // 損益計算書
                cell.debit2Label.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 2)
                cell.debit2Label.textAlignment = NSTextAlignment.right
                cell.credit2Label.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow: indexPath.row).category as String)", leftOrRight: 3)
                cell.credit2Label.textAlignment = NSTextAlignment.right
                cell.debit2Label.backgroundColor = .clear
                cell.credit2Label.backgroundColor = .clear
                // 貸借対照表
                cell.debit3Label.text = ""
                cell.credit3Label.text = ""
                cell.debit3Label.backgroundColor = .mainColor
                cell.credit3Label.backgroundColor = .mainColor
            default: // 大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("a")
            }
            return cell
        } else if indexPath.row == presenter.numberOfobjects { // セル　試算表の合計の行
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
            cell.accountLabel.text = ""
            // 決算整理前残高試算表
            cell.debitLabel.text = presenter.debit_balance_total()
            cell.creditLabel.text = presenter.credit_balance_total()
            return cell
        } else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss { // セル　修正記入の行
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
            // 勘定科目をセルに表示する
            cell.accountLabel.text = "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)"
            cell.accountLabel.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.debitLabel.text = ""
            cell.creditLabel.text = ""
            cell.debitLabel.backgroundColor = .mainColor
            cell.creditLabel.backgroundColor = .mainColor
            switch Int(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).Rank2) {
            case 0, 1, 2, 3, 4, 5, 12: // 大分類　貸借対照表：0,1,2
                // 修正記入
                cell.debit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 0)
                cell.debit1Label.textAlignment = NSTextAlignment.right
                cell.credit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 1)
                cell.credit1Label.textAlignment = NSTextAlignment.right
                cell.debit1Label.backgroundColor = .clear
                cell.credit1Label.backgroundColor = .clear
                // 損益計算書
                cell.debit2Label.text = ""
                cell.credit2Label.text = ""
                cell.debit2Label.backgroundColor = .clear
                cell.credit2Label.backgroundColor = .clear
                // 貸借対照表
                cell.debit3Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 2)
                cell.debit3Label.textAlignment = NSTextAlignment.right
                cell.credit3Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 3)
                cell.credit3Label.textAlignment = NSTextAlignment.right
                cell.debit3Label.backgroundColor = .clear
                cell.credit3Label.backgroundColor = .clear
            case 6, 7, 8, 9, 10, 11: // 大分類 損益計算書：3,4
                // 修正記入
                cell.debit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 0)
                cell.debit1Label.textAlignment = NSTextAlignment.right
                cell.credit1Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 1)
                cell.credit1Label.textAlignment = NSTextAlignment.right
                cell.debit1Label.backgroundColor = .clear
                cell.credit1Label.backgroundColor = .clear
                // 損益計算書
                cell.debit2Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 2)
                cell.debit2Label.textAlignment = NSTextAlignment.right
                cell.credit2Label.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow: indexPath.row - (presenter.numberOfobjects + 1)).category as String)", leftOrRight: 3)
                cell.credit2Label.textAlignment = NSTextAlignment.right
                cell.debit2Label.backgroundColor = .clear
                cell.credit2Label.backgroundColor = .clear
                // 貸借対照表
                cell.debit3Label.text = ""
                cell.credit3Label.text = ""
                cell.debit3Label.backgroundColor = .clear
                cell.credit3Label.backgroundColor = .clear
            default: // 大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("aa")
            }
            return cell
        } else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1 { // セル　当期純利益の行
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
            // 勘定科目をセルに表示する
            cell.accountLabel.text = "当期純利益"
            cell.accountLabel.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.debitLabel.text = ""
            cell.creditLabel.text = ""
            cell.debitLabel.backgroundColor = .mainColor
            cell.creditLabel.backgroundColor = .mainColor
            // 修正記入
            cell.debit1Label.text = ""
            cell.credit1Label.text = ""
            cell.debit1Label.backgroundColor = .clear
            cell.credit1Label.backgroundColor = .clear
            // 損益計算書
            cell.debit2Label.text = presenter.netIncomeOrNetLossLoss() // 0でも空白にしない
            cell.debit2Label.textAlignment = NSTextAlignment.right
            cell.credit2Label.text = presenter.netIncomeOrNetLossIncome() // 0でも空白にしない
            cell.credit2Label.textAlignment = NSTextAlignment.right
            cell.debit2Label.backgroundColor = .clear
            cell.credit2Label.backgroundColor = .clear
            // 貸借対照表
            cell.debit3Label.text = presenter.netIncomeOrNetLossIncome() // 0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.debit3Label.textAlignment = NSTextAlignment.right
            cell.credit3Label.text = presenter.netIncomeOrNetLossLoss() // 0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.credit3Label.textAlignment = NSTextAlignment.right
            cell.debit3Label.backgroundColor = .clear
            cell.credit3Label.backgroundColor = .clear
            return cell
        } else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1 + 1 { // セル　修正記入と損益計算書、貸借対照表の合計の行
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total_2", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
            cell.accountLabel.text = ""
            // 決算整理前残高試算表
            cell.debitLabel.text = ""
            cell.creditLabel.text = ""
            cell.debitLabel.backgroundColor = .mainColor
            cell.creditLabel.backgroundColor = .mainColor
            // 修正記入
            cell.debit1Label.text = presenter.debit_adjustingEntries_total_total() // 残高ではなく合計
            cell.debit1Label.textAlignment = NSTextAlignment.right
            cell.credit1Label.text = presenter.credit_adjustingEntries_total_total() // 残高ではなく合計
            cell.credit1Label.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debit1Label.text != cell.credit1Label.text {
                cell.debit1Label.textColor = .red
                cell.credit1Label.textColor = .red
            }
            // 損益計算書
            cell.debit2Label.text = presenter.debit_PL_balance_total()// 当期純利益と合計借方とを足す
            cell.debit2Label.textAlignment = NSTextAlignment.right
            cell.credit2Label.text = presenter.credit_PL_balance_total()// 当期純損失と合計貸方とを足す
            cell.credit2Label.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debit2Label.text != cell.credit2Label.text {
                cell.debit2Label.textColor = .red
                cell.credit2Label.textColor = .red
            }
            // 貸借対照表
            cell.debit3Label.text = presenter.debit_BS_balance_total() // 損益計算書とは反対の方に記入する
            cell.debit3Label.textAlignment = NSTextAlignment.right
            cell.credit3Label.text = presenter.credit_BS_balance_total() // 損益計算書とは反対の方に記入する
            cell.credit3Label.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.debit3Label.text != cell.credit3Label.text {
                cell.debit3Label.textColor = .red
                cell.credit3Label.textColor = .red
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as? WSTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension WSViewController: WSPresenterOutput {
    
    func reloadData() {
        // 更新処理
        tableView.reloadData()
        // クルクルを止める
        refreshControl.endRefreshing()
    }
    
    func setupViewForViewDidLoad() {
        // UI
        //        setTableView()
        createButtons() // ボタン作成
        setRefreshControl()
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
        //        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(printButton))
        //        //ナビゲーションに定義したボタンを置く
        //        self.navigationItem.rightBarButtonItem = printoutButton
        printButton.isHidden = true
        self.navigationItem.title = "精算表"
    }
    
    func setupViewForViewWillAppear() {
        
        if let company = presenter.company {
            // 月末、年度末などの決算日をラベルに表示する
            labelCompanyName.text = company // 社名
        }
        if let theDayOfReckoning = presenter.theDayOfReckoning {
            if let fiscalYear = presenter.fiscalYear {
                if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                    labelClosingDate.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                } else {
                    labelClosingDate.text = String(fiscalYear + 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
            }
        }
        labelTitle.text = "精算表"
        labelTitle.font = UIFont.boldSystemFont(ofSize: 18)
        
        // 仕訳画面表示ボタン
        addButton.isEnabled = true

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
            addBannerViewToView(
                gADBannerView,
                constant: (tableView.visibleCells[tableView.visibleCells.count - 3].frame.height +
                           tableView.visibleCells[tableView.visibleCells.count - 2].frame.height +
                           tableView.visibleCells[tableView.visibleCells.count - 1].frame.height + 20) * -1
            ) // 一番したから3行分のスペースを空ける
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
        let firstLunchKey = "firstLunch_WorkSheet"
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
