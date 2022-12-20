//
//  GenearlLedgerAccountViewController.swift
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
class GenearlLedgerAccountViewController: UIViewController {
    
    // MARK: - var let

   var gADBannerView: GADBannerView!
    /// 勘定　上部
    @IBOutlet var dateYearLabel: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet var listHeadingLabel: UILabel!
    @IBOutlet var printBarButtonItem: UIBarButtonItem!
    /// 勘定　下部
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
//    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
//    let edged = false
    
    // 勘定名
    var account: String = ""
    // 印刷機能
    let pDFMaker = PDFMakerAccount()

    /// GUIアーキテクチャ　MVP
    private var presenter: GenearlLedgerAccountPresenterInput!
    func inject(presenter: GenearlLedgerAccountPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = GenearlLedgerAccountPresenter.init(view: self, model: GeneralLedgerAccountModel(), account: account)
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
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

    // カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はviewDidLoadで行う
    func addComma(string: String) -> String {
        if string != "" { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        } else {
            return ""
        }
    }
    
    private func initializeGenearlLedgerAccount() {
        // 3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
    }
    
    // MARK: - Action
    
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func printButtonTapped(_ sender: Any) {
        // 初期化
        pDFMaker.initialize(account: account)
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
}

extension GenearlLedgerAccountViewController: UITableViewDelegate, UITableViewDataSource {
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // 通常仕訳　決算整理仕訳　空白行
        return 3
    }
    // セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 通常仕訳
            return presenter.numberOfDatabaseJournalEntries
        } else if section == 1 {
            // 決算整理仕訳
            return presenter.numberOfDataBaseAdjustingEntries
        } else {
            // 空白行
            return 21 // 空白行を表示するため+21行を追加
        }
    }
    // セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger_account", for: indexPath) as? GeneralLedgerAccountTableViewCell else { return UITableViewCell() }
        
        var date: String = ""                      // 日付
        var upperCellMonth: String = ""         // 日付
        var oneOfCaractorAtLast: String = ""    // 末尾1文字の「日」         //日付
        var twoOfCaractorAtLast: String = ""    // 末尾2文字の「日」         //日付
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

        if indexPath.section == 0 || indexPath.section == 1 {
            
            if indexPath.section == 0 {
                // 通常仕訳　通常仕訳 勘定別
                date = "\(presenter.databaseJournalEntries(forRow: indexPath.row).date)"                              // 日付
                if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                    upperCellMonth = "\(presenter.databaseJournalEntries(forRow: indexPath.row - 1).date)"             // 日付
                }
                oneOfCaractorAtLast = "\(presenter.databaseJournalEntries(forRow: indexPath.row).date.suffix(1))"     // 末尾1文字の「日」         //日付
                twoOfCaractorAtLast = "\(presenter.databaseJournalEntries(forRow: indexPath.row).date.suffix(2))"     // 末尾2文字の「日」         //日付
                debitCategory = presenter.databaseJournalEntries(forRow: indexPath.row).debit_category          // 借方勘定の場合                      //この勘定が借方の場合
                creditCategory = presenter.databaseJournalEntries(forRow: indexPath.row).credit_category      // 摘要　相手方勘定なので貸方
                debitAmount = presenter.databaseJournalEntries(forRow: indexPath.row).debit_amount            // 借方金額
                creditAmount = presenter.databaseJournalEntries(forRow: indexPath.row).credit_amount             // 貸方金額
                numberOfAccountCredit = presenter.getNumberOfAccount(accountName: "\(creditCategory)")// 損益勘定の場合はエラーになる
                numberOfAccountDebit = presenter.getNumberOfAccount(accountName: "\(debitCategory)")// 損益勘定の場合はエラーになる

                // 差引残高　差引残高クラスで計算した計算結果を取得
                balanceAmount = presenter.getBalanceAmount(indexPath: indexPath)
                balanceDebitOrCredit = presenter.getBalanceDebitOrCredit(indexPath: indexPath)
                
                // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
                if DateManager.shared.isInPeriod(date: presenter.databaseJournalEntries(forRow: indexPath.row).date) {
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
            } else if indexPath.section == 1 {
                // 決算整理仕訳　勘定別　損益勘定以外
                date = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row).date)"
                if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                    upperCellMonth = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row - 1).date)"
                }
                oneOfCaractorAtLast = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row).date.suffix(1))"
                twoOfCaractorAtLast = "\(presenter.dataBaseAdjustingEntries(forRow: indexPath.row).date.suffix(2))"
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
            }
// 月
            // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
            if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                // 一行上のセルに表示した月とこの行の月を比較する
                // let upperCellMonth = "\(presenter.objectss(forRow: indexPathRowFixed - 1).date)" // 日付
                let dateMonth = date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                    if upperCellMonth[upperCellMonth.index(
                        upperCellMonth.startIndex,
                        offsetBy: 5
                    )..<upperCellMonth.index(
                        upperCellMonth.startIndex,
                        offsetBy: 7
                    )
                    ] != "\(date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 7)])" {
                        cell.listDateMonthLabel.text = "\(date[date.index(date.startIndex, offsetBy: 6)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
                    } else {
                        cell.listDateMonthLabel.text = "" // 注意：空白を代入しないと、変な値が入る。
                    }
                } else {
                    print(upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)])
                    print("\(date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 7)])")
                    if upperCellMonth[upperCellMonth.index(
                        upperCellMonth.startIndex,
                        offsetBy: 5
                    )..<upperCellMonth.index(
                        upperCellMonth.startIndex,
                        offsetBy: 7
                    )
                    ] != "\(date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 7)])" {
                        cell.listDateMonthLabel.text = "\(date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
                    } else {
                        cell.listDateMonthLabel.text = "" // 注意：空白を代入しないと、変な値が入る。
                    }
                }
            } else { // 先頭行は月を表示
                let dateMonth = date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                    cell.listDateMonthLabel.text = "\(date[date.index(date.startIndex, offsetBy: 6)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
                } else {
                    cell.listDateMonthLabel.text = "\(date[date.index(date.startIndex, offsetBy: 5)..<date.index(date.startIndex, offsetBy: 7)])" // 「月」
                }
            }
// 日
            let date = date[date.index(date.startIndex, offsetBy: 8)..<date.index(date.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
            if date == "0" { // 日の十の位が0の場合は表示しない
                cell.listDateDayLabel.text = "\(oneOfCaractorAtLast)" // 末尾1文字の「日」         //日付
            } else {
                cell.listDateDayLabel.text = "\(twoOfCaractorAtLast)" // 末尾2文字の「日」         //日付
            }
            cell.listDateDayLabel.textAlignment = NSTextAlignment.right
            // 摘要
            if account == "\(debitCategory)" { // 借方勘定の場合                      //この勘定が借方の場合
                cell.listSummaryLabel.text = "\(creditCategory) "             // 摘要　相手方勘定なので貸方
                cell.listSummaryLabel.textAlignment = NSTextAlignment.right
                // 丁数
                if creditCategory == "損益勘定" { // 損益勘定の場合
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = ""                                            // 丁数　相手方勘定なので貸方
                } else {
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = numberOfAccountCredit.description                    // 丁数　相手方勘定なので貸方
                }
                //　借方金額
                cell.listDebitLabel.text = "\(addComma(string: String(debitAmount))) "        // 借方金額
                //　貸方金額
                cell.listCreditLabel.text = ""                                                 // 貸方金額 注意：空白を代入しないと、変な値が入る。
            } else if account == "\(creditCategory)" {  // 貸方勘定の場合
                cell.listSummaryLabel.text = "\(debitCategory) "              // 摘要　相手方勘定なので借方
                cell.listSummaryLabel.textAlignment = NSTextAlignment.left
                if debitCategory == "損益勘定" { // 損益勘定の場合
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = ""                               // 丁数　相手方勘定なので貸方
                } else {
                    // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                    cell.listNumberLabel.text = numberOfAccountDebit.description                               // 丁数　相手方勘定なので貸方
                }
                cell.listDebitLabel.text = ""                                                                         // 借方金額 注意：空白を代入しないと、変な値が入る。
                cell.listCreditLabel.text = "\(addComma(string: String(creditAmount))) "      // 貸方金額
            }
            
            cell.listBalanceLabel.text = "\(addComma(string: balanceAmount.description))"    // 差引残高
            cell.listDebitOrCreditLabel.text = balanceDebitOrCredit                          // 借又貸
            // セルの選択を許可
            cell.selectionStyle = .default
        } else if indexPath.section == 2 {
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
        case 2:
            return nil
        default:
            return indexPath
        }
    }
}

extension GenearlLedgerAccountViewController: GenearlLedgerAccountPresenterOutput {

    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        initializeGenearlLedgerAccount()

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
        if presenter.numberOfDatabaseJournalEntries + presenter.numberOfDataBaseAdjustingEntries >= 1 {
            printBarButtonItem.isEnabled = true
        } else {
            printBarButtonItem.isEnabled = false
        }
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
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
                gADBannerView.isHidden = true
            }
        }
    }

    func setupViewForViewDidAppear() {
    
    }
}

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension GenearlLedgerAccountViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if let PDFpath = pDFMaker.PDFpath {
            return PDFpath.count
        } else {
            return 0
        }
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let pdfFilePath = pDFMaker.PDFpath?[index] else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
}
