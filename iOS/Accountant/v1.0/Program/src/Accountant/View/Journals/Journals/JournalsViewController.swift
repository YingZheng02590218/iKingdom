//
//  JournalsViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/01.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import Firebase // イベントログ対応
import GoogleMobileAds // マネタイズ対応
import QuickLook
import UIKit

// 仕訳帳クラス
class JournalsViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - var let

   var gADBannerView: GADBannerView!
    // 仕訳帳　上部
    // まとめて編集機能
    @IBOutlet private var editWithSlectionButton: UIButton! // 選択した項目を編集ボタン
    @IBOutlet private var addBarButtonItem: UIBarButtonItem!
    @IBOutlet private var pdfBarButtonItem: UIBarButtonItem!
    @IBOutlet private var labelCompanyName: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closingDateLabel: UILabel!
    @IBOutlet private var listDateYearLabel: UILabel!
    /// 仕訳帳　下部
    @IBOutlet private var tableView: UITableView! // アウトレット接続 Referencing Outlets が接続されていないとnilとなるので注意
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false

    fileprivate let refreshControl = UIRefreshControl()
    // まとめて編集機能
    var indexPaths: [IndexPath] = []
    var dBJournalEntry: DBJournalEntry?
    var primaryKeys: [Int]? // 通常仕訳の連番
    var primaryKeysAdjusting: [Int]? // 決算整理仕訳の連番
    // 編集機能
    var tappedIndexPath: IndexPath?
    // スクロール
    var numberOfEdittedJournalEntry: Int? // 編集した仕訳の連番
    var tappedIndexPathSection: Int? // 通常仕訳か決算整理仕訳か
    private var indexPathForAutoScroll: IndexPath?
    var indexPathLocal = IndexPath(row: 0, section: 0) // 初期表示オートスクロール
    // セルが画面に表示される直前に表示される ※セルが0個の場合は呼び出されない
    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
    var scrollAdding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)

    /// GUIアーキテクチャ　MVP
    private var presenter: JournalsPresenterInput!
    func inject(presenter: JournalsPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = JournalsPresenter.init(view: self, model: JournalsModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        // 通常、このメソッドは遷移先のViewController(仕訳画面)から戻る際には呼ばれないので、遷移先のdismiss()のクロージャにこのメソッドを指定する
        // presentingViewController?.beginAppearanceTransition(false, animated: animated)
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
        // まとめて編集機能 setEditingメソッドを使用するため、Storyboard上の編集ボタンを上書きしてボタンを生成する
        editButtonItem.tintColor = .accentColor
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true // 複数選択を可能にする
        editWithSlectionButton.isHidden = true
        editWithSlectionButton.tintColor = tableView.isEditing ? .accentBlue : UIColor.clear// 色
        
        // title設定
        navigationItem.title = "仕訳帳"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
    }
    
    private func setButtons() {

        pdfBarButtonItem.tintColor = .accentColor
        addBarButtonItem.tintColor = .accentColor

        // 空白行対応
        if presenter.numberOfobjects + presenter.numberOfobjectsss >= 1 { // 仕訳が1件以上ある場合
            // ボタンを活性にする
            if !tableView.isEditing { // 編集モードではない場合
                pdfBarButtonItem.isEnabled = true
            }
            navigationItem.leftBarButtonItem?.isEnabled = true
        } else { // 仕訳が0件の場合
            // ボタンを不活性にする
            pdfBarButtonItem.isEnabled = false // 印刷ボタン
            navigationItem.leftBarButtonItem?.isEnabled = false // 編集ボタン
        }
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
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    private func setLongPressRecognizer() {
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent: ") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        tableView.addGestureRecognizer(longPressRecognizer)
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
        if let viewController = UIStoryboard(name: "JournalsViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_Journals") as? AnnotationViewControllerJournals {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    // チュートリアル対応 コーチマーク型
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
    
    // まとめて編集機能 アラートのポップアップを表示　年度を変更する　仕訳内容を編集する
    @IBAction func editBarButtonItemTapped(_ sender: Any) {
        // 選択されたセル
        if let indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows {
            let sortedIndexPaths = indexPathsForSelectedRows.sorted { $0.row > $1.row }
            for indexPath in sortedIndexPaths {
                // 選択されたセルに表示していたデータ(仕訳オブジェクトのindexPath)を配列にまとめる
                self.indexPaths.append(indexPath) // アンラップする
            }
            
            // ①UIAlertControllerクラスのインスタンスを生成する
            // titleにタイトル, messegeにメッセージ, prefereedStyleにスタイルを指定する
            // preferredStyleにUIAlertControllerStyle.actionSheetを指定してアクションシートを表示する
            let actionSheet = UIAlertController(
                title: "\(self.indexPaths.count) 件 の仕訳データ",
                message: nil,
                preferredStyle: UIAlertController.Style.actionSheet
            )
            
            // ②選択肢の作成と追加
            // titleに選択肢のテキストを、styleに.defaultを
            // handlerにボタンが押された時の処理をクロージャで実装する
            actionSheet.addAction(
                UIAlertAction(
                    title: "年度を変更する",
                    style: .default,
                    handler: { (action: UIAlertAction!) -> Void in
                        print("年度を変更する")
                        // 年度変更画面を表示
                        if let viewController = UIStoryboard(name: "PeriodYearViewController", bundle: nil).instantiateInitialViewController() as? PeriodYearViewController {
                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                )
            )
            
            // ②選択肢の作成と追加
            actionSheet.addAction(
                UIAlertAction(
                    title: "仕訳内容を編集する",
                    style: .default,
                    handler: { (action: UIAlertAction!) -> Void in
                        print("仕訳内容を編集する")
                        print("選択されたセル", self.indexPaths)
                        // 仕訳編集画面を表示して、一括変更したい内容に修正させる
                        if let viewController = UIStoryboard(name: "JournalEntryViewController", bundle: nil).instantiateInitialViewController() as? JournalEntryViewController {
                            viewController.journalEntryType = "JournalEntriesPackageFixing" // セルに表示した仕訳タイプを取得

                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                )
            )
            
            // ②選択肢の作成と追加
            actionSheet.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: { (action: UIAlertAction!) -> Void in
                        print("Cancel")
                    }
                )
            )
            
            // iPad の場合のみ、ActionSheetを表示するための必要な設定
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                actionSheet.popoverPresentationController?.sourceRect = CGRect(
                    x: screenSize.size.width / 2,
                    y: screenSize.size.height,
                    width: 0,
                    height: 0
                )
            } else {
                // ③表示するViewと表示位置を指定する
                actionSheet.popoverPresentationController?.sourceView = view
                actionSheet.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
            }
            
            // ④アクションシートを表示
            present(actionSheet, animated: true, completion: nil)
        }
    }
    // リロード機能
    @objc private func refreshTable() {
        
        presenter.refreshTable(isEditing: tableView.isEditing)
    }
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc private func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 編集中ではない場合
        if !tableView.isEditing {
            if recognizer.state == UIGestureRecognizer.State.began {
                // 押された位置でcellのPathを取得
                let point = recognizer.location(in: tableView)
                let indexPath = tableView.indexPathForRow(at: point)
                
                if let indexPath = indexPath {
                    if indexPath.section == 1 {
                        // 損益振替仕訳の場合
                        if presenter.objectsss(forRow: indexPath.row).debit_category == "損益勘定" ||
                            presenter.objectsss(forRow: indexPath.row).credit_category == "損益勘定" {
                            
                        } else {
                            // 長押しされた場合の処理
                            print("長押しされたcellのindexPath:\(String(describing: indexPath.row))")
                            // ロングタップされたセルの位置をフィールドで保持する
                            self.tappedIndexPath = indexPath
                            tableView.deselectRow(at: indexPath, animated: true)
                            presenter.cellLongPressed(indexPath: indexPath)
                        }
                    } else if indexPath.section == 2 {
                        print("空白行を長押し")
                    } else {
                        // 長押しされた場合の処理
                        print("長押しされたcellのindexPath:\(String(describing: indexPath.row))")
                        // ロングタップされたセルの位置をフィールドで保持する
                        self.tappedIndexPath = indexPath
                        tableView.deselectRow(at: indexPath, animated: true)
                        presenter.cellLongPressed(indexPath: indexPath)
                    }
                }
            }
        }
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "仕訳データを削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            print("OK アクションをタップした時の処理")
            // // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
            // let objects = dataBaseManager.getJournalEntry(section: indexPath.section) // 何月のセクションに表示するセルかを判別するため引数で渡す
            // print(objects)
            if indexPath.section == 1 {
                // 設定操作
                // let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
                // let object = dataBaseManagerSettingsOperating.getSettingsOperating()
                // let objectss = dataBaseManager.getJournalAdjustingEntry(section: indexPath.section,
                // EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                // 決算整理仕訳データを削除
                let result = self.presenter.deleteAdjustingJournalEntry(number: self.presenter.objectsss(forRow: indexPath.row).number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALS,
                        AnalyticsParameterItemID: Constant.DELETEADJUSTINGJOURNALENTRY
                    ])
                }
            } else if indexPath.section == 0 {
                // 仕訳データを削除
                let result = self.presenter.deleteJournalEntry(number: self.presenter.objects(forRow: indexPath.row).number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALS,
                        AnalyticsParameterItemID: Constant.DELETEJOURNALENTRY
                    ])
                }
            }
            // ボタンを更新
            self.setButtons()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     * 印刷ボタン押下時メソッド
     * 仕訳帳画面　Extend Edges: Under Top Bar, Under Bottom Bar のチェックを外すと,仕訳データの行が崩れてしまう。
     */
    @IBAction func pdfBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        presenter.pdfBarButtonItemTapped()
    }
    
    func updateFiscalYear(fiscalYear: Int) {
        
        presenter.updateFiscalYear(indexPaths: indexPaths, fiscalYear: fiscalYear)
    }
    
    func updateSelectedJournalEntries() {
        guard let dBJournalEntry = dBJournalEntry else {
            return
        }
        presenter.updateSelectedJournalEntries(indexPaths: indexPaths, dBJournalEntry: dBJournalEntry)
    }

    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            // 編集中ではない場合
            if !tableView.isEditing { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                if let _ = self.tappedIndexPath { // 代入に成功したら、ロングタップだと判断できる
                    return true // true: 画面遷移させる
                }
            }
        } else if identifier == "buttonTapped" {
            return true
        }
        return false // false:画面遷移させない
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        if let controller = segue.destination as? JournalEntryViewController {
            // 遷移先のコントローラに値を渡す
            if segue.identifier == "buttonTapped" {
                controller.journalEntryType = "JournalEntries" // セルに表示した仕訳タイプを取得
            } else if segue.identifier == "longTapped" {
                // 編集中ではない場合
                if !tableView.isEditing {
                    if let tappedIndexPath = tappedIndexPath { // nil:ロングタップではない
                        controller.journalEntryType = "JournalEntriesFixing" // セルに表示した仕訳タイプを取得
                        controller.tappedIndexPath = tappedIndexPath // アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                        if tappedIndexPath.section == 0 {
                            controller.primaryKey = presenter.objects(forRow: tappedIndexPath.row).number
                        } else {
                            controller.primaryKey = presenter.objectsss(forRow: tappedIndexPath.row).number
                        }
                        self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
                    }
                }
            }
        }
    }
    // 仕訳入力ボタンから仕訳画面へ遷移して入力が終わったときに呼ばれる。通常仕訳:0 決算整理仕訳:1
    func autoScrollToCell(number: Int, tappedIndexPathSection: Int) {
        
        presenter.autoScroll(number: number, tappedIndexPathSection: tappedIndexPathSection)
    }
}

extension JournalsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // 通常仕訳　決算整理仕訳　空白行
        return 3
    }
    // セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 通常仕訳
            return presenter.numberOfobjects
        } else if section == 1 {
            // 決算整理仕訳
            return presenter.numberOfobjectsss
        } else {
            // 空白行
            return 5 // 空白行を表示するため+5行を追加
        }
    }
    // セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as? JournalsTableViewCell else {
            return UITableViewCell()
        }

        let dataBaseManager = DataBaseManagerJournalEntry()

        if indexPath.section == 0 {
            // 通常仕訳
            print("通常仕訳", indexPath)
            // ② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
            /// 日付
            let date = "\(presenter.objects(forRow: indexPath.row).date)"
            // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
            if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                // 一行上のセルに表示した月とこの行の月を比較する
                let upperCellMonth = "\(presenter.objects(forRow: indexPath.row - 1).date)" // 日付
                // 日付の6文字目にある月の十の位を抽出
                cell.listDateMonthLabel.text = StringUtility.shared.pickupMonth(date: date, upperCellMonth: upperCellMonth)
            } else { // 先頭行は月を表示
                cell.listDateMonthLabel.text = StringUtility.shared.pickupMonth(date: date)
            }
            // 日付の9文字目にある日の十の位を抽出
            cell.listDateLabel.text = StringUtility.shared.pickupDay(date: date)
            cell.listDateLabel.textAlignment = NSTextAlignment.right
            /// 借方勘定
            cell.listSummaryDebitLabel.text = " (\(presenter.objects(forRow: indexPath.row).debit_category))"
            cell.listSummaryDebitLabel.textAlignment = NSTextAlignment.left
            /// 貸方勘定
            cell.listSummaryCreditLabel.text = "(\(presenter.objects(forRow: indexPath.row).credit_category)) "
            cell.listSummaryCreditLabel.textAlignment = NSTextAlignment.right
            /// 小書き
            cell.listSummaryLabel.text = "\(presenter.objects(forRow: indexPath.row).smallWritting) "
            cell.listSummaryLabel.textAlignment = NSTextAlignment.left
            /// 丁数　借方
            if presenter.objects(forRow: indexPath.row).debit_category == "損益勘定" { // 損益勘定の場合
                cell.listNumberLeftLabel.text = ""
            } else {
                print(presenter.objects(forRow: indexPath.row).debit_category)
                let numberOfAccountLeft = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objects(forRow: indexPath.row).debit_category)")  // 丁数を取得
                cell.listNumberLeftLabel.text = numberOfAccountLeft.description                                // 丁数　借方
            }
            /// 丁数　貸方
            if presenter.objects(forRow: indexPath.row).credit_category == "損益勘定" { // 損益勘定の場合
                cell.listNumberRightLabel.text = ""
            } else {
                print(presenter.objects(forRow: indexPath.row).credit_category)
                let numberOfAccountRight = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objects(forRow: indexPath.row).credit_category)")    // 丁数を取得
                cell.listNumberRightLabel.text = numberOfAccountRight.description                                   // 丁数　貸方
            }
            cell.listDebitLabel.text = "\(StringUtility.shared.addComma(string: String(presenter.objects(forRow: indexPath.row).debit_amount))) "        // 借方金額
            cell.listCreditLabel.text = "\(StringUtility.shared.addComma(string: String(presenter.objects(forRow: indexPath.row).credit_amount))) "      // 貸方金額

            // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
            cell.setTextColor(isInPeriod: DateManager.shared.isInPeriod(date: presenter.objects(forRow: indexPath.row).date))
            // セルの選択を許可
            cell.selectionStyle = .default
        } else if indexPath.section == 1 {
            // 決算整理仕訳
            print("決算整理仕訳", indexPath)
            // ② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
            /// 日付
            let date = "\(presenter.objectsss(forRow: indexPath.row).date)"
            // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
            if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                // 一行上のセルに表示した月とこの行の月を比較する
                let upperCellMonth = "\(presenter.objectsss(forRow: indexPath.row - 1).date)" // 日付
                // 日付の6文字目にある月の十の位を抽出
                cell.listDateMonthLabel.text = StringUtility.shared.pickupMonth(date: date, upperCellMonth: upperCellMonth)
            } else { // 先頭行は月を表示
                cell.listDateMonthLabel.text = StringUtility.shared.pickupMonth(date: date)
            }
            // 日付の9文字目にある日の十の位を抽出
            cell.listDateLabel.text = StringUtility.shared.pickupDay(date: date)
            cell.listDateLabel.textAlignment = NSTextAlignment.right
            /// 借方勘定
            cell.listSummaryDebitLabel.text = " (\(presenter.objectsss(forRow: indexPath.row).debit_category))"
            cell.listSummaryDebitLabel.textAlignment = NSTextAlignment.left
            /// 貸方勘定
            cell.listSummaryCreditLabel.text = "(\(presenter.objectsss(forRow: indexPath.row).credit_category)) "
            cell.listSummaryCreditLabel.textAlignment = NSTextAlignment.right
            /// 小書き
            cell.listSummaryLabel.text = "\(presenter.objectsss(forRow: indexPath.row).smallWritting) "
            cell.listSummaryLabel.textAlignment = NSTextAlignment.left
            /// 丁数　借方
            if presenter.objectsss(forRow: indexPath.row).debit_category == "損益勘定" { // 損益勘定の場合
                cell.listNumberLeftLabel.text = ""
            } else {
                print(presenter.objectsss(forRow: indexPath.row).debit_category)
                let numberOfAccountLeft = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objectsss(forRow: indexPath.row).debit_category)")  // 丁数を取得
                cell.listNumberLeftLabel.text = numberOfAccountLeft.description                                // 丁数　借方
            }
            /// 丁数　貸方
            if presenter.objectsss(forRow: indexPath.row).credit_category == "損益勘定" { // 損益勘定の場合
                cell.listNumberRightLabel.text = ""
            } else {
                print(presenter.objectsss(forRow: indexPath.row).credit_category)
                let numberOfAccountRight = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objectsss(forRow: indexPath.row).credit_category)")    // 丁数を取得
                cell.listNumberRightLabel.text = numberOfAccountRight.description                                   // 丁数　貸方
            }
            cell.listDebitLabel.text = "\(StringUtility.shared.addComma(string: String(presenter.objectsss(forRow: indexPath.row).debit_amount))) "        // 借方金額
            cell.listCreditLabel.text = "\(StringUtility.shared.addComma(string: String(presenter.objectsss(forRow: indexPath.row).credit_amount))) "      // 貸方金額

            // 年度変更機能　仕訳の年度が、帳簿の年度とあっているかを判定する
            cell.setTextColor(isInPeriod: DateManager.shared.isInPeriod(date: presenter.objectsss(forRow: indexPath.row).date))
            // セルの選択を許可
            cell.selectionStyle = .default
        } else {
            // 空白行
            print("空白行", indexPath)
            cell.prepareForReuse()
            // セルの選択不可にする
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 初回起動時の場合
        if scroll {
            // セクション数　ゼロスタート補正は不要
            for s in 0..<tableView.numberOfSections {
                for r in 0..<tableView.numberOfRows(inSection: s) {
                    indexPathLocal = IndexPath(row: r, section: s)
                    self.tableView.scrollToRow(at: indexPathLocal, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                }
            }
            // 最後のセルまで表示しされたかどうか
            if indexPath == indexPathLocal {
                // 初期表示位置 OFF
                scroll = false
            }
        }
        // 入力ボタン押下時の場合
        if scrollAdding {
            if indexPath.section == tappedIndexPathSection {

                if tappedIndexPathSection == 0 {
                    // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                    if numberOfEdittedJournalEntry == presenter.objects(forRow: indexPath.row).number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                        cell.setHighlighted(true, animated: true)
                        indexPathForAutoScroll = indexPath
                    }
                }
                // 最後のセルまで表示しされたかどうか
                if indexPath == indexPathLocal {
                    // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
                    if let indexPathForAutoScroll = self.indexPathForAutoScroll {
                        self.tableView.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.top, animated: true) // 追加した仕訳データの行を画面の下方に表示する
                        // 入力ボタン押下時の表示位置 OFF
                        self.scrollAdding = false
                        self.indexPathForAutoScroll = nil
                    } else {
                        // 上へスクロールする
                        scrollToTop()
                    }
                }
            }
        }
        
        if !tableView.isEditing {
            if indexPath.section == tappedIndexPathSection {
                
                if tappedIndexPathSection == 0 {
                    // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                    if numberOfEdittedJournalEntry == presenter.objects(forRow: indexPath.row).number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                        cell.setHighlighted(true, animated: true)
                        indexPathForAutoScroll = indexPath
                    }
                } else if tappedIndexPathSection == 1 {
                    // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                    if numberOfEdittedJournalEntry == presenter.objectsss(forRow: indexPath.row).number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                        cell.setHighlighted(true, animated: true)
                        indexPathForAutoScroll = indexPath
                    }
                }
            }
        }
        // まとめて編集　編集した仕訳のセルをハイライトとする
        if indexPath.section == 0 {
            if let primaryKeys = primaryKeys {
                for i in 0..<primaryKeys.count where primaryKeys[i] == presenter.objects(forRow: indexPath.row).number {
                    cell.setHighlighted(true, animated: true)
                }
            }
        } else if indexPath.section == 1 {
            if let primaryKeysAdjusting = primaryKeysAdjusting {
                for i in 0..<primaryKeysAdjusting.count where primaryKeysAdjusting[i] == presenter.objectsss(forRow: indexPath.row).number {
                    cell.setHighlighted(true, animated: true)
                }
            }
        }
    }
    // 下へスクロールする
    func scrollToBottom() {
        // セクション数　ゼロスタート補正は不要
        for s in 0..<tableView.numberOfSections {
            for r in 0..<tableView.numberOfRows(inSection: s) {
                indexPathLocal = IndexPath(row: r, section: s)
                self.tableView.scrollToRow(at: indexPathLocal, at: UITableView.ScrollPosition.top, animated: true)
                // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                if let _ = self.indexPathForAutoScroll {
                    break
                }
            }
        }
    }
    // 上へスクロールする
    func scrollToTop() {
        // セクション数　ゼロスタート補正は不要
        for s in (0..<tableView.numberOfSections).reversed() {
            for r in (0..<tableView.numberOfRows(inSection: s)).reversed() {
                indexPathLocal = IndexPath(row: r, section: s)
                self.tableView.scrollToRow(at: indexPathLocal, at: UITableView.ScrollPosition.bottom, animated: true)
                // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                if let _ = self.indexPathForAutoScroll {
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 1:
            // 損益振替仕訳の場合
            if presenter.objectsss(forRow: indexPath.row).debit_category == "損益勘定" ||
                presenter.objectsss(forRow: indexPath.row).credit_category == "損益勘定" {
                return nil
            } else {
                return indexPath
            }
        case 2:
            return nil
        default:
            return indexPath
        }
    }
    // 削除機能 セルを左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 2 {
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
        } else { // 空白行をスワイプした場合
            let configuration = UISwipeActionsConfiguration(actions: [])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

        editWithSlectionButton.isHidden = !editing
        editWithSlectionButton.isEnabled = false // まとめて編集ボタン
        editWithSlectionButton.tintColor = editing ? .accentBlue : UIColor.clear // 色
        pdfBarButtonItem.isEnabled = !editing ? presenter.numberOfobjects + presenter.numberOfobjectsss >= 1 : false // 印刷ボタン
        addBarButtonItem.isEnabled = !editing // 仕訳入力ボタン
        // 編集中の場合
        if editing {
            self.indexPaths = [] // 初期化
        }
        navigationItem.title = "仕訳帳"
    }
    // 編集モード時の左端のチェックマーク　仕訳まとめて編集、年度変更
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            // 損益振替仕訳の場合
            if presenter.objectsss(forRow: indexPath.row).debit_category == "損益勘定" ||
                presenter.objectsss(forRow: indexPath.row).credit_category == "損益勘定" {
                return false
            } else {
                return true
            }
        } else if indexPath.section == 2 {
            // 空白行対応
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集中の場合
        if tableView.isEditing {
            // 選択されたセル
            if let indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows {
                editWithSlectionButton.isEnabled = !indexPathsForSelectedRows.isEmpty ? true : false // まとめて編集ボタン
                // title設定
                navigationItem.title = !indexPathsForSelectedRows.isEmpty ? "\(indexPathsForSelectedRows.count)件選択" : "仕訳帳"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 編集中の場合
        if tableView.isEditing {
            // 選択されたセル
            if let indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows {
                editWithSlectionButton.isEnabled = !indexPathsForSelectedRows.isEmpty ? true : false // まとめて編集ボタン
                // title設定
                navigationItem.title = !indexPathsForSelectedRows.isEmpty ? "\(indexPathsForSelectedRows.count)件選択" : "仕訳帳"
            } else {
                editWithSlectionButton.isEnabled = false
                navigationItem.title = "仕訳帳"
            }
        }
    }
}

extension JournalsViewController: JournalsPresenterOutput {

    func reloadData(primaryKeys: [Int]?, primaryKeysAdjusting: [Int]?) {
        // まとめて編集の場合以外は、セルをハイライトにしない
        self.primaryKeys = primaryKeys
        self.primaryKeysAdjusting = primaryKeysAdjusting
        self.indexPaths = [] // 初期化
        // 編集機能
        numberOfEdittedJournalEntry = nil
        tappedIndexPathSection = nil
        indexPathForAutoScroll = nil
        // 更新処理
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // クルクルを止める
            self.refreshControl.endRefreshing()
        }
        // ボタンを更新
        setButtons()
    }
    
    func reloadData() {
        // クルクルを止める
        self.refreshControl.endRefreshing()
    }
    
    func setupCellLongPressed(indexPath: IndexPath) {
        // 別の画面に遷移 仕訳画面
        performSegue(withIdentifier: "longTapped", sender: nil)
    }

    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        setRefreshControl()
        setLongPressRecognizer()
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
        //        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(pdfBarButtonItem))
        //        //ナビゲーションに定義したボタンを置く
        //        self.navigationItem.rightBarButtonItem = printoutButton
        self.navigationItem.title = "仕訳帳"
        // 初期表示位置 ON
        scroll = true
    }
    
    func setupViewForViewWillAppear() {
        // UIViewControllerの表示画面を更新・リロード
        //        self.loadView() // エラー発生　2020/07/31　Thread 1: EXC_BAD_ACCESS (code=1, address=0x600022903198)
        if !tableView.isEditing {
            self.tableView.reloadData() // エラーが発生しないか心配
        }
        if let company = presenter.company {
            labelCompanyName.text = company // 社名
        }
        if let theDayOfReckoning = presenter.theDayOfReckoning {
            if let fiscalYear = presenter.fiscalYear {
                if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                    closingDateLabel.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                } else {
                    closingDateLabel.text = String(fiscalYear + 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
                // データベース　注意：Initialより後に記述する
                listDateYearLabel.text = fiscalYear.description + "年"
            }
        }
        titleLabel.text = "仕訳帳"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        // ボタンを更新
        setButtons()

        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.rowHeight)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: (tableView.rowHeight + 8) * -1)
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
        if let indexPath = tableView.indexPathsForVisibleRows {// テーブル上で見えているセルを取得する
            print("tableView.indexPathsForVisibleRows: \(String(describing: indexPath))")
            // テーブルをスクロールさせる。scrollViewDidScrollメソッドを呼び出して、インセットの設定を行うため。
            if !indexPath.isEmpty {
                // チュートリアル対応 コーチマーク型　タグを設定する
                tableView.visibleCells[0].tag = 33
                // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
                let userDefaults = UserDefaults.standard
                let firstLunchKey = "firstLunch_Journals"
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
    }
    // オートスクロール
    func autoScroll(number: Int, tappedIndexPathSection: Int) {
        // TabBarControllerから遷移してきした時のみ、テーブルビューの更新と初期表示位置を指定
        scrollAdding = true
        // 仕訳帳から仕訳入力
        numberOfEdittedJournalEntry = number
        self.tappedIndexPathSection = tappedIndexPathSection // 編集で選択されたセルのセクション
        // 前回の、まとめて編集後のセルのハイライトを戻す
        self.primaryKeys = nil
        self.primaryKeysAdjusting = nil
        self.indexPaths = [] // まとめて編集の選択されたセル　初期化
        // 仕訳入力後に仕訳帳を更新する
        self.tableView.reloadData()
        // ボタンを更新
        setButtons()
        // 下へスクロールする
        scrollToBottom()
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

extension JournalsViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if let PDFpath = presenter.PDFpath {
            return PDFpath.count
        } else {
            return 0
        }
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let pdfFilePath = presenter.PDFpath?[index] else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
}
