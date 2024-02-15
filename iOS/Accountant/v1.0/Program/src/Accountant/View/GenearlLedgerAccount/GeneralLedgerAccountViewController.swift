//
//  GeneralLedgerAccountViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import QuickLook
import UIKit

// 勘定クラス
class GeneralLedgerAccountViewController: UIViewController {
    
    // MARK: - var let
    
    var gADBannerView: GADBannerView!
    /// 勘定　上部
    @IBOutlet private var dateYearLabel: UILabel!
    @IBOutlet private var topView: UIView!
    @IBOutlet private var listHeadingLabel: UILabel!
    @IBOutlet private var printBarButtonItem: UIBarButtonItem!
    @IBOutlet private var csvBarButtonItem: UIBarButtonItem!
    /// 勘定　下部
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.register(
                UINib(nibName: String(describing: AccountTableViewHeaderFooterView.self), bundle: nil),
                forHeaderFooterViewReuseIdentifier: String(describing: AccountTableViewHeaderFooterView.self)
            )
        }
    }
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    // グラデーションレイヤー　書類系画面
    let gradientLayer = CAGradientLayer()
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    // 勘定名
    var account: String = ""
    
    /// GUIアーキテクチャ　MVP
    private var presenter: GeneralLedgerAccountPresenterInput!
    func inject(presenter: GeneralLedgerAccountPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = GeneralLedgerAccountPresenter.init(view: self, model: GeneralLedgerAccountModel(), account: account)
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
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    // ボタンのデザインを指定する
    private func createButtons() {
        
        printBarButtonItem.tintColor = .accentColor
        csvBarButtonItem.tintColor = .accentColor
        
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
    }
    
    // MARK: - Action
    
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: Any) {
        presenter.pdfBarButtonItemTapped()
    }
    
    @IBAction func csvBarButtonItemTapped(_ sender: Any) {
        presenter.csvBarButtonItemTapped()
    }
}

extension GeneralLedgerAccountViewController: UITableViewDelegate, UITableViewDataSource {
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // 通常仕訳(12ヶ月分)　決算整理仕訳 損益振替仕訳 資本振替仕訳　空白行
        return 17
    }
    // セクションヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 0
        }
        // セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける
    }
    // セクションフッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11/*, 12, 13*/:
            // 貸借科目　のみに絞る
            if !DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                switch section {
                case 1:
                    // 通常仕訳 期首
                    return presenter.numberOfDatabaseJournalEntries(forSection: 0) == 0 ? 0 : 60
                case 2:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 1) == 0 ? 0 : 60
                case 3:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 2) == 0 ? 0 : 60
                case 4:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 3) == 0 ? 0 : 60
                case 5:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 4) == 0 ? 0 : 60
                case 6:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 5) == 0 ? 0 : 60
                case 7:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 6) == 0 ? 0 : 60
                case 8:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 7) == 0 ? 0 : 60
                case 9:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 8) == 0 ? 0 : 60
                case 10:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 9) == 0 ? 0 : 60
                case 11:
                    return presenter.numberOfDatabaseJournalEntries(forSection: 10) == 0 ? 0 : 60
                    // case 12: // 決算整理仕訳の下に次月繰越を表示させる。月次残高振替仕訳には決算整理仕訳も含まれるため。
                    // 通常仕訳 期末
                default:
                    return 0
                }
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .textColor
            header.textLabel?.textAlignment = .left
            // システムフォントのサイズを設定
            header.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        default:
            return nil
        }
    }
    // セクションフッター
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AccountTableViewHeaderFooterView.self))
        // 貸借科目　のみに絞る
        if !DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
            if let headerView = view as? AccountTableViewHeaderFooterView {
                // TODO: 文字色　次期繰越
                headerView.listDateMonthLabel.textColor = .textColor
                headerView.listDateDayLabel.textColor = .textColor
                headerView.listSummaryLabel.textColor = .textColor
                headerView.listSummarySecondLabel.textColor = .accentRedColor
                headerView.listDebitLabel.textColor = .textColor
                headerView.listDebitSecondLabel.textColor = .accentRedColor
                headerView.listDebitThirdLabel.textColor = .textColor
                headerView.listCreditLabel.textColor = .textColor
                headerView.listCreditSecondLabel.textColor = .accentRedColor
                headerView.listCreditThirdLabel.textColor = .textColor
                headerView.listDebitOrCreditLabel.textColor = .textColor
                headerView.listBalanceLabel.textColor = .textColor
                
                headerView.listSummaryLabel.text = "合計"
                headerView.listSummarySecondLabel.text = "次月繰越"
                
                // 配列のインデックス　月別の月末日を取得 12ヶ月分
                var index: Int?
                // 月別の月末日を取得 12ヶ月分
                let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
                
                switch section {
                case 1:
                    // 通常仕訳 期首
                    index = 0
                case 2:
                    index = 1
                case 3:
                    index = 2
                case 4:
                    index = 3
                case 5:
                    index = 4
                case 6:
                    index = 5
                case 7:
                    index = 6
                case 8:
                    index = 7
                case 9:
                    index = 8
                case 10:
                    index = 9
                case 11:
                    index = 10
                    // case 12: // 決算整理仕訳の下に次月繰越を表示させる。月次残高振替仕訳には決算整理仕訳も含まれるため。
                    // 通常仕訳 期末
                    // index = 11
                    // case 13:
                    // 決算整理仕訳
                default:
                    index = nil
                }
                // 取得　通常仕訳 勘定別に月別に取得
                if let index = index,
                   let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccount(
                    account: account,
                    yearMonth: "/" + "\(String(format: "%02d", lastDays[index].month))" + "/" // CONTAINS 部分一致
                   ) {
                    
                    // 日付
                    if let date = DateManager.shared.dateFormatter.date(from: dataBaseMonthlyTransferEntry.date) {
                        // 月
                        headerView.listDateMonthLabel.text = "\(date.month)"
                        headerView.listDateMonthLabel.textAlignment = NSTextAlignment.right
                        // 日
                        headerView.listDateDayLabel.text = "\(date.day)"
                        headerView.listDateDayLabel.textAlignment = NSTextAlignment.right
                        // 借方
                        headerView.listDebitLabel.text = StringUtility.shared.addComma(string: dataBaseMonthlyTransferEntry.debit_amount.description)
                        headerView.listDebitSecondLabel.text = dataBaseMonthlyTransferEntry.balance_right == 0 ? "" : StringUtility.shared.addComma(string: dataBaseMonthlyTransferEntry.balance_right.description) // 借方勘定　＊引数の貸方勘定を振替える
                        headerView.listDebitThirdLabel.text = StringUtility.shared.addComma(string: (dataBaseMonthlyTransferEntry.debit_amount + dataBaseMonthlyTransferEntry.balance_right).description)
                        // 貸方
                        headerView.listCreditLabel.text = StringUtility.shared.addComma(string: dataBaseMonthlyTransferEntry.credit_amount.description)
                        headerView.listCreditSecondLabel.text = dataBaseMonthlyTransferEntry.balance_left == 0 ? "" : StringUtility.shared.addComma(string: dataBaseMonthlyTransferEntry.balance_left.description) // 貸方勘定　＊引数の借方勘定を振替える
                        headerView.listCreditThirdLabel.text = StringUtility.shared.addComma(string: (dataBaseMonthlyTransferEntry.credit_amount + dataBaseMonthlyTransferEntry.balance_left).description)
                        // 借又貸
                        var balanceDebitOrCredit: String = ""
                        //    if dataBaseMonthlyTransferEntry.balance_left > dataBaseMonthlyTransferEntry.balance_right {
                        //        // 借方勘定　＊引数の貸方勘定を振替える
                        //        balanceDebitOrCredit = "貸"
                        //    } else if dataBaseMonthlyTransferEntry.balance_left < dataBaseMonthlyTransferEntry.balance_right {
                        //        // 貸方勘定　＊引数の借方勘定を振替える
                        //        balanceDebitOrCredit = "借"
                        //    } else {
                        //        balanceDebitOrCredit = "-"
                        //    }
                        balanceDebitOrCredit = ""
                        headerView.listDebitOrCreditLabel.text = balanceDebitOrCredit
                    }
                } else {
                    headerView.listDateMonthLabel.text = ""
                    headerView.listDateDayLabel.text = ""
                    headerView.listDebitLabel.text = ""
                    headerView.listDebitSecondLabel.text = ""
                    headerView.listDebitThirdLabel.text = ""
                    headerView.listCreditLabel.text = ""
                    headerView.listCreditSecondLabel.text = ""
                    headerView.listCreditThirdLabel.text = ""
                    headerView.listDebitOrCreditLabel.text = ""
                }
                return headerView
            }
            return nil
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        20
    }
    // セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 開始仕訳
            return presenter.numberOfDataBaseOpeningJournalEntry
        case 1:
            // 通常仕訳 期首
            return presenter.numberOfDatabaseJournalEntries(forSection: 0)
        case 2:
            return presenter.numberOfDatabaseJournalEntries(forSection: 1)
        case 3:
            return presenter.numberOfDatabaseJournalEntries(forSection: 2)
        case 4:
            return presenter.numberOfDatabaseJournalEntries(forSection: 3)
        case 5:
            return presenter.numberOfDatabaseJournalEntries(forSection: 4)
        case 6:
            return presenter.numberOfDatabaseJournalEntries(forSection: 5)
        case 7:
            return presenter.numberOfDatabaseJournalEntries(forSection: 6)
        case 8:
            return presenter.numberOfDatabaseJournalEntries(forSection: 7)
        case 9:
            return presenter.numberOfDatabaseJournalEntries(forSection: 8)
        case 10:
            return presenter.numberOfDatabaseJournalEntries(forSection: 9)
        case 11:
            return presenter.numberOfDatabaseJournalEntries(forSection: 10)
        case 12:
            // 通常仕訳 期末
            return presenter.numberOfDatabaseJournalEntries(forSection: 11)
        case 13:
            // 決算整理仕訳
            return presenter.numberOfDataBaseAdjustingEntries
        case 14:
            // 資本振替仕訳
            return presenter.numberOfDataBaseCapitalTransferJournalEntry
        case 15:
            // 損益振替仕訳、残高振替仕訳
            return presenter.numberOfDataBaseTransferEntry
        case 16:
            // 空白行
            return 21 // 空白行を表示するため+21行を追加
        default:
            return 0
        }
    }
    // セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger_account", for: indexPath) as? GeneralLedgerAccountTableViewCell else { return UITableViewCell() }
        
        var date: String = ""                      // 日付
        var upperCellMonth: String = ""         // 日付
        var debitCategory: String = ""         // 借方勘定の場合      この勘定が借方の場合
        var creditCategory: String = ""        // 摘要　             相手方勘定なので貸方
        var debitAmount: Int64 = 0             // 借方金額
        var creditAmount: Int64 = 0            // 貸方金額
        var numberOfAccountCredit: Int = 0
        var numberOfAccountDebit: Int = 0
        // 差引残高
        // 差引残高　差引残高クラスで計算した計算結果を取得
        var balanceAmount: Int64 = 0
        var balanceDebitOrCredit: String = ""
        
        if indexPath.section != 16 {
            
            if indexPath.section == 0 {
                // 開始仕訳
                if let dataBaseTransferEntry = presenter.dataBaseOpeningJournalEntries() {
                    date = "\(dataBaseTransferEntry.date)"
                    creditCategory = dataBaseTransferEntry.credit_category == "残高" ? "前期繰越" : dataBaseTransferEntry.credit_category
                    debitCategory = dataBaseTransferEntry.debit_category == "残高" ? "前期繰越" : dataBaseTransferEntry.debit_category
                    creditAmount = dataBaseTransferEntry.credit_amount
                    debitAmount = dataBaseTransferEntry.debit_amount
                    numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")
                    numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")
                    
                    // 差引残高　差引残高クラスで計算した計算結果を取得
                    balanceAmount = presenter.getBalanceAmountOpeningJournalEntry()
                    balanceDebitOrCredit = presenter.getBalanceDebitOrCreditOpeningJournalEntry()
                    
                    // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                    if DateManager.shared.isInPeriod(date: dataBaseTransferEntry.date) {
                        cell.listDateMonthLabel.textColor = .textColor
                        cell.listDateDayLabel.textColor = .textColor
                        cell.listSummaryLabel.textColor = .textColor
                        cell.listNumberLabel.textColor = .textColor
                        cell.listDebitLabel.textColor = .textColor
                        cell.listCreditLabel.textColor = .textColor
                        cell.listDebitOrCreditLabel.textColor = .textColor
                        cell.listBalanceLabel.textColor = .textColor
                    } else {
                        cell.listDateMonthLabel.textColor = .red
                        cell.listDateDayLabel.textColor = .red
                        cell.listSummaryLabel.textColor = .red
                        cell.listNumberLabel.textColor = .red
                        cell.listDebitLabel.textColor = .red
                        cell.listCreditLabel.textColor = .red
                        cell.listDebitOrCreditLabel.textColor = .red
                        cell.listBalanceLabel.textColor = .red
                    }
                }
            } else if indexPath.section == 13 {
                // 決算整理仕訳　勘定別　損益勘定以外
                date = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row).date)"
                if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                    upperCellMonth = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row - 1).date)"
                }
                debitCategory = presenter.dataBaseAdjustingEntries(forRow: indexPath.row).debit_category
                creditCategory = presenter.dataBaseAdjustingEntries(forRow: indexPath.row).credit_category
                debitAmount = presenter.dataBaseAdjustingEntries(forRow: indexPath.row).debit_amount
                creditAmount = presenter.dataBaseAdjustingEntries(forRow: indexPath.row).credit_amount
                numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")// 損益勘定の場合はエラーになる
                numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")// 損益勘定の場合はエラーになる
                
                balanceAmount = presenter.getBalanceAmountAdjusting(indexPath: indexPath) // TODO: メソッドをまとめる
                balanceDebitOrCredit = presenter.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
                
                // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                if DateManager.shared.isInPeriod(date: presenter.dataBaseAdjustingEntries(forRow: indexPath.row).date) {
                    cell.listDateMonthLabel.textColor = .textColor
                    cell.listDateDayLabel.textColor = .textColor
                    cell.listSummaryLabel.textColor = .textColor
                    cell.listNumberLabel.textColor = .textColor
                    cell.listDebitLabel.textColor = .textColor
                    cell.listCreditLabel.textColor = .textColor
                    cell.listDebitOrCreditLabel.textColor = .textColor
                    cell.listBalanceLabel.textColor = .textColor
                } else {
                    cell.listDateMonthLabel.textColor = .red
                    cell.listDateDayLabel.textColor = .red
                    cell.listSummaryLabel.textColor = .red
                    cell.listNumberLabel.textColor = .red
                    cell.listDebitLabel.textColor = .red
                    cell.listCreditLabel.textColor = .red
                    cell.listDebitOrCreditLabel.textColor = .red
                    cell.listBalanceLabel.textColor = .red
                }
            } else if indexPath.section == 14 {
                // 資本振替仕訳
                print("資本振替仕訳", indexPath)
                if let dataBaseCapitalTransferJournalEntry = presenter.dataBaseCapitalTransferJournalEntries() {
                    date = "\(dataBaseCapitalTransferJournalEntry.date)"
                    if dataBaseCapitalTransferJournalEntry.debit_category == "損益" { // 損益勘定の場合
                        debitCategory = dataBaseCapitalTransferJournalEntry.debit_category
                    } else {
                        debitCategory = Constant.capitalAccountName
                    }
                    if dataBaseCapitalTransferJournalEntry.credit_category == "損益" { // 損益勘定の場合
                        creditCategory = dataBaseCapitalTransferJournalEntry.credit_category
                    } else {
                        creditCategory = Constant.capitalAccountName
                    }
                    debitAmount = dataBaseCapitalTransferJournalEntry.debit_amount
                    creditAmount = dataBaseCapitalTransferJournalEntry.credit_amount
                    if creditCategory == "損益" { // 損益勘定の場合
                        numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")
                    } else {
                        numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(Constant.capitalAccountName)")
                    }
                    if debitCategory == "損益" { // 損益勘定の場合
                        numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")
                    } else {
                        numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(Constant.capitalAccountName)")
                    }
                    balanceAmount = presenter.getBalanceAmountCapitalTransferJournalEntry()
                    balanceDebitOrCredit = presenter.getBalanceDebitOrCreditCapitalTransferJournalEntry()
                    
                    // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                    if DateManager.shared.isInPeriod(date: dataBaseCapitalTransferJournalEntry.date) {
                        cell.listDateMonthLabel.textColor = .textColor
                        cell.listDateDayLabel.textColor = .textColor
                        cell.listSummaryLabel.textColor = .textColor
                        cell.listNumberLabel.textColor = .textColor
                        cell.listDebitLabel.textColor = .textColor
                        cell.listCreditLabel.textColor = .textColor
                        cell.listDebitOrCreditLabel.textColor = .textColor
                        cell.listBalanceLabel.textColor = .textColor
                    } else {
                        cell.listDateMonthLabel.textColor = .red
                        cell.listDateDayLabel.textColor = .red
                        cell.listSummaryLabel.textColor = .red
                        cell.listNumberLabel.textColor = .red
                        cell.listDebitLabel.textColor = .red
                        cell.listCreditLabel.textColor = .red
                        cell.listDebitOrCreditLabel.textColor = .red
                        cell.listBalanceLabel.textColor = .red
                    }
                }
            } else if indexPath.section == 15 {
                // 損益振替仕訳、残高振替仕訳
                if let dataBaseTransferEntry = presenter.dataBaseTransferEntries() {
                    date = "\(dataBaseTransferEntry.date)"
                    creditCategory = dataBaseTransferEntry.credit_category == "残高" ? "次期繰越" : dataBaseTransferEntry.credit_category
                    debitCategory = dataBaseTransferEntry.debit_category == "残高" ? "次期繰越" : dataBaseTransferEntry.debit_category
                    creditAmount = dataBaseTransferEntry.credit_amount
                    debitAmount = dataBaseTransferEntry.debit_amount
                    numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")
                    numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")
                    
                    balanceAmount = 0
                    balanceDebitOrCredit = "-"
                    
                    // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                    if DateManager.shared.isInPeriod(date: dataBaseTransferEntry.date) {
                        cell.listDateMonthLabel.textColor = .textColor
                        cell.listDateDayLabel.textColor = .textColor
                        cell.listSummaryLabel.textColor = .textColor
                        cell.listNumberLabel.textColor = .textColor
                        cell.listDebitLabel.textColor = .textColor
                        cell.listCreditLabel.textColor = .textColor
                        cell.listDebitOrCreditLabel.textColor = .textColor
                        cell.listBalanceLabel.textColor = .textColor
                    } else {
                        cell.listDateMonthLabel.textColor = .red
                        cell.listDateDayLabel.textColor = .red
                        cell.listSummaryLabel.textColor = .red
                        cell.listNumberLabel.textColor = .red
                        cell.listDebitLabel.textColor = .red
                        cell.listCreditLabel.textColor = .red
                        cell.listDebitOrCreditLabel.textColor = .red
                        cell.listBalanceLabel.textColor = .red
                    }
                }
            } else {
                // 通常仕訳　通常仕訳 勘定別
                if let databaseJournalEntry = presenter.databaseJournalEntries(forSection: indexPath.section - 1, forRow: indexPath.row) {
                    date = "\(databaseJournalEntry.date)"                              // 日付
                    if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                        if let databaseJournalEntry = presenter.databaseJournalEntries(forSection: indexPath.section - 1, forRow: indexPath.row - 1) {
                            upperCellMonth = "\(databaseJournalEntry.date)"             // 日付
                        }
                    }
                    debitCategory = databaseJournalEntry.debit_category          // 借方勘定の場合                      //この勘定が借方の場合
                    creditCategory = databaseJournalEntry.credit_category      // 摘要　相手方勘定なので貸方
                    debitAmount = databaseJournalEntry.debit_amount            // 借方金額
                    creditAmount = databaseJournalEntry.credit_amount             // 貸方金額
                    numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")// 損益勘定の場合はエラーになる
                    numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")// 損益勘定の場合はエラーになる
                    
                    // 差引残高　差引残高クラスで計算した計算結果を取得
                    // balanceAmount = presenter.getBalanceAmount(indexPath: indexPath)
                    balanceAmount = databaseJournalEntry.balance_left > databaseJournalEntry.balance_right ? databaseJournalEntry.balance_left : databaseJournalEntry.balance_right
                    // balanceDebitOrCredit = presenter.getBalanceDebitOrCredit(indexPath: indexPath)
                    if databaseJournalEntry.balance_left > databaseJournalEntry.balance_right {
                        balanceDebitOrCredit = "借"
                    } else if databaseJournalEntry.balance_left < databaseJournalEntry.balance_right {
                        balanceDebitOrCredit = "貸"
                    } else {
                        balanceDebitOrCredit = "-"
                    }
                    // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                    if DateManager.shared.isInPeriod(date: databaseJournalEntry.date) {
                        cell.listDateMonthLabel.textColor = .textColor
                        cell.listDateDayLabel.textColor = .textColor
                        cell.listSummaryLabel.textColor = .textColor
                        cell.listNumberLabel.textColor = .textColor
                        cell.listDebitLabel.textColor = .textColor
                        cell.listCreditLabel.textColor = .textColor
                        cell.listDebitOrCreditLabel.textColor = .textColor
                        cell.listBalanceLabel.textColor = .textColor
                    } else {
                        cell.listDateMonthLabel.textColor = .red
                        cell.listDateDayLabel.textColor = .red
                        cell.listSummaryLabel.textColor = .red
                        cell.listNumberLabel.textColor = .red
                        cell.listDebitLabel.textColor = .red
                        cell.listCreditLabel.textColor = .red
                        cell.listDebitOrCreditLabel.textColor = .red
                        cell.listBalanceLabel.textColor = .red
                    }
                }
            }
            // 日付
            if let date = DateManager.shared.dateFormatter.date(from: date) {
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                    // 一行上のセルに表示した月とこの行の月を比較する
                    if let upperCellDate = DateManager.shared.dateFormatter.date(from: upperCellMonth) {
                        // 日付の6文字目にある月の十の位を抽出
                        cell.listDateMonthLabel.text = "\(date.month)" == "\(upperCellDate.month)" ? "" : "\(date.month)"
                    }
                } else { // 先頭行は月を表示
                    cell.listDateMonthLabel.text = "\(date.month)"
                }
                // 日付の9文字目にある日の十の位を抽出
                cell.listDateDayLabel.text = "\(date.day)"
                cell.listDateDayLabel.textAlignment = NSTextAlignment.right
            }
            // 摘要
            if account == "\(debitCategory)" || "資本金勘定" == "\(debitCategory)" { // 借方勘定の場合 //この勘定が借方の場合
                cell.listSummaryLabel.text = "\(creditCategory) " // 摘要　相手方勘定なので貸方
                cell.listSummaryLabel.textAlignment = NSTextAlignment.right
                // 丁数
                if creditCategory == "損益" || creditCategory == "次期繰越" || creditCategory == "前期繰越" {
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = "" // 丁数　相手方勘定なので貸方
                } else {
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = numberOfAccountCredit.description // 丁数　相手方勘定なので貸方
                }
                //　借方金額
                cell.listDebitLabel.text = "\(StringUtility.shared.addComma(string: String(debitAmount))) "        // 借方金額
                //　貸方金額
                cell.listCreditLabel.text = ""                                                 // 貸方金額 注意：空白を代入しないと、変な値が入る。
            } else if account == "\(creditCategory)" || "資本金勘定" == "\(creditCategory)" {  // 貸方勘定の場合
                cell.listSummaryLabel.text = "\(debitCategory) " // 摘要　相手方勘定なので借方
                cell.listSummaryLabel.textAlignment = NSTextAlignment.left
                if debitCategory == "損益" || debitCategory == "次期繰越" || debitCategory == "前期繰越"{
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = "" // 丁数　相手方勘定なので貸方
                } else {
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = numberOfAccountDebit.description // 丁数　相手方勘定なので貸方
                }
                cell.listDebitLabel.text = ""                                                                         // 借方金額 注意：空白を代入しないと、変な値が入る。
                cell.listCreditLabel.text = "\(StringUtility.shared.addComma(string: String(creditAmount))) "      // 貸方金額
            }
            
            cell.listBalanceLabel.text = "\(StringUtility.shared.addComma(string: balanceAmount.description))"    // 差引残高
            cell.listDebitOrCreditLabel.text = balanceDebitOrCredit                          // 借又貸
            // セルの選択を許可
            cell.selectionStyle = .default
        } else {
            // 空白行
            cell.listDateMonthLabel.text = ""    // 「月」注意：空白を代入しないと、変な値が入る。
            cell.listDateDayLabel.text = ""      // 末尾2文字の「日」         //日付
            cell.listSummaryLabel.text = ""       // 摘要　相手方勘定なので借方
            cell.listNumberLabel.text = ""        // 丁数　相手方勘定なので貸方
            cell.listDebitLabel.text = ""         // 借方金額 注意：空白を代入しないと、変な値が入る。
            cell.listCreditLabel.text = ""        // 貸方金額
            cell.listBalanceLabel.text = ""       // 差引残高
            cell.listDebitOrCreditLabel.text = "" // 借又貸
            // セルの選択不可にする
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13:
            return indexPath
        default:
            return nil
        }
    }
}

extension GeneralLedgerAccountViewController: GeneralLedgerAccountPresenterOutput {
    
    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        
        self.navigationItem.title = "勘定"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupViewForViewWillAppear() {
        // ヘッダー部分　勘定名を表示
        listHeadingLabel.text = account
        listHeadingLabel.font = UIFont.boldSystemFont(ofSize: 21)
        
        if let fiscalYear = presenter.fiscalYear {
            dateYearLabel.text = fiscalYear.description + "年"
        }
        // 仕訳データが0件の場合、印刷ボタンを不活性にする
        if presenter.numberOfDataBaseOpeningJournalEntry +
            presenter.numberOfDatabaseJournalEntries +
            presenter.numberOfDataBaseAdjustingEntries +
            presenter.numberOfDataBaseCapitalTransferJournalEntry >= 1 {
            printBarButtonItem.isEnabled = true
            csvBarButtonItem.isEnabled = true
        } else {
            printBarButtonItem.isEnabled = false
            csvBarButtonItem.isEnabled = false
        }
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
    }
    
    func setupViewForViewWillDisappear() {
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }
    
    func setupViewForViewDidAppear() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
    }
    
    // PDFのプレビューを表示させる
    func showPreview() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
}

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension GeneralLedgerAccountViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if let _ = presenter.filePath {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let filePath = presenter.filePath else {
            return "" as! QLPreviewItem
        }
        return filePath as QLPreviewItem
    }
}
