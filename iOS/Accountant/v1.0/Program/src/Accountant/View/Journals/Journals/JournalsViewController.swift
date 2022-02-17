//
//  JournalsViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/01.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import PDFKit
import GoogleMobileAds // マネタイズ対応

// 仕訳帳クラス
class JournalsViewController: UIViewController, UIGestureRecognizerDelegate, UIPrintInteractionControllerDelegate {

    // MARK: - var let

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    #if DEBUG
    let AdMobTest:Bool = true    // true:テスト
    #else
    let AdMobTest:Bool = false
    #endif
    @IBOutlet var gADBannerView: GADBannerView!
    /// 仕訳帳　上部
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var Label_list_date_year: UILabel!
    /// 仕訳帳　下部
    @IBOutlet var tableView: UITableView! // アウトレット接続 Referencing Outlets が接続されていないとnilとなるので注意
    private var indexPathForAutoScroll: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate let refreshControl = UIRefreshControl()
    // セルが画面に表示される直前に表示される ※セルが0個の場合は呼び出されない
    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
    var scroll_adding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)
    // 追加機能　画面遷移の準備　勘定科目画面
    var tappedIndexPath: IndexPath?
    // スクロール
    var Number = 0
    
    let pDFMaker = PDFMaker()
    let paperSize = CGSize(width: 192 / 25.4 * 72, height: 262 / 25.4 * 72) // B5 192×262mm
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
        //通常、このメソッドは遷移先のViewController(仕訳画面)から戻る際には呼ばれないので、遷移先のdismiss()のクロージャにこのメソッドを指定する
        //        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        presenter.viewDidAppear()
    }
    
    // MARK: - Setting
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    private func setLongPressRecognizer() {
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent:") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: constant),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    // チュートリアル対応
    private func presentAnnotation() {
        let viewController = UIStoryboard(name: "JournalsTableViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_Journals") as! AnnotationViewControllerJournals
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    //カンマ区切りに変換（表示用）
    private let formatter = NumberFormatter() // プロパティの設定はviewDidLoadで行う
    private func initializeJournals() {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
    }
    
    private func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }

    // MARK: - Action

    // リロード機能
    @objc private func refreshTable() {

        presenter.refreshTable()
    }
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc private func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath?.section == 1 {
            print("空白行を長押し")
        }
        else {
            if let indexPath = indexPath {
                if recognizer.state == UIGestureRecognizer.State.began  {
                    // 長押しされた場合の処理
                    print("長押しされたcellのindexPath:\(String(describing: indexPath.row))")
                    // ロングタップされたセルの位置をフィールドで保持する
                    self.tappedIndexPath = indexPath
                    presenter.cellLongPressed(indexPath: indexPath)
                }
            }
        }
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "仕訳データを削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース
            let dataBaseManager = DataBaseManagerJournalEntry()
//            // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
//            let objects = dataBaseManager.getJournalEntry(section: indexPath.section) // 何月のセクションに表示するセルかを判別するため引数で渡す
//            print(objects)
            if indexPath.row >= self.presenter.numberOfobjects {
                // 設定操作
//                let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
//                let object = dataBaseManagerSettingsOperating.getSettingsOperating()
//                let objectss = dataBaseManager.getJournalAdjustingEntry(section: indexPath.section,
//                    EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                // 決算整理仕訳データを削除
                let result = dataBaseManager.deleteAdjustingJournalEntry(number: self.presenter.objectsss(forRow:indexPath.row-self.presenter.numberOfobjects).number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }
            else {
                // 仕訳データを削除
                let result = self.presenter.deleteJournalEntry(number: self.presenter.objects(forRow:indexPath.row).number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    
    @IBOutlet weak var barButtonItem_add: UIBarButtonItem!//ヘッダー部分の追加ボタン
    @IBOutlet weak var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     * 仕訳帳画面　Extend Edges: Under Top Bar, Under Bottom Bar のチェックを外すと,仕訳データの行が崩れてしまう。
     */
    @IBAction func button_print(_ sender: UIButton) {
        // 初期化
        pDFMaker.initialize()
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = "Journals"
        printInfo.duplex = .none
        printInfo.orientation = .portrait
        printController.printInfo = printInfo
        printController.printingItem = self.resizePrintingPaper()
        printController.present(animated: true, completionHandler: nil)
    }

    private func resizePrintingPaper() -> NSData? {
        // CGPDFDocumentを取得
        if let PDFpath = pDFMaker.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            guard let documentRef = document?.documentRef else { return nil }
            
            var pageImages: [UIImage] = []
            
            // 表示しているPDFPageをUIImageに変換
            for pageCount in 0 ..< documentRef.numberOfPages {
                // CGPDFDocument -> CGPDFPage -> UIImage
                if let page = documentRef.page(at: pageCount + 1) {
                    let pageRect = page.getBoxRect(.mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let pageImage = renderer.image { context in
                        UIColor.white.set()
                        context.fill(pageRect)
                        
                        context.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                        context.cgContext.scaleBy(x: 1.0, y: -1.0)
                        
                        context.cgContext.drawPDFPage(page)
                    }
                    // Image配列に格納
                    pageImages.append(pageImage)
                }
            }
            // UIImageにしたPDFPageをNSDataに変換
            let pdfData: NSMutableData = NSMutableData()
            let pdfConsumer: CGDataConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
            
            var mediaBox: CGRect = CGRect(origin: .zero, size: paperSize) // ここに印刷したいサイズを入れる
            let pdfContext: CGContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
            
            pageImages.forEach { image in
                pdfContext.beginPage(mediaBox: &mediaBox)
                pdfContext.draw(image.cgImage!, in: mediaBox)
                pdfContext.endPage()
            }
            
            return pdfData
        }
        return nil
    }
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            if self.tappedIndexPath != nil { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                if let _:IndexPath = self.tappedIndexPath { //代入に成功したら、ロングタップだと判断できる
                    return true //true: 画面遷移させる
                }
            }
        }else if identifier == "buttonTapped" {
            return true
        }
        return false //false:画面遷移させない
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        let controller = segue.destination as! JournalEntryViewController
        // 遷移先のコントローラに値を渡す
        if segue.identifier == "buttonTapped" {
            controller.journalEntryType = "JournalEntries" // セルに表示した仕訳タイプを取得
        }else if segue.identifier == "longTapped" {
            if tappedIndexPath != nil { // nil:ロングタップではない
                controller.journalEntryType = "JournalEntriesFixing" // セルに表示した仕訳タイプを取得
                controller.tappedIndexPath = self.tappedIndexPath!//アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
            }
        }
    }

    func autoScroll(number: Int) {
        // TabBarControllerから遷移してきした時のみ、テーブルビューの更新と初期表示位置を指定
        scroll_adding = true
        Number = number
        // 仕訳入力後に仕訳帳を更新する
        tableView.reloadData()
    }
}

extension JournalsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // 空白行対応
        if presenter.numberOfobjects + presenter.numberOfobjectss <= 12 {
            return 2 // 空白行を表示するためセクションを1つ追加
        }else {
            return 1     // セクションの数はreturn 12 で 12ヶ月分に設定します。
        }
    }
    //セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 空白行対応
        if section == 1 { // 空白行
            if presenter.numberOfobjects + presenter.numberOfobjectss <= 20 {
                return 20 - (presenter.numberOfobjects + presenter.numberOfobjectss) // 空白行を表示するため30行に満たない不足分を追加
            }else {
                return 0 // 8件以上ある場合　不足分は0
            }
        }else {
            return presenter.numberOfobjects + presenter.numberOfobjectsss //月別の仕訳データ数
        }
    }
    //セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 { // 空白行
            //① UI部品を指定　TableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! JournalsTableViewCell
            cell.label_list_date_month.text = ""    // 「月」注意：空白を代入しないと、変な値が入る。
            cell.label_list_date.text = ""     // 末尾2文字の「日」         //日付
            cell.label_list_summary_debit.text = ""     //借方勘定
            cell.label_list_summary_credit.text = ""   //貸方勘定
            cell.label_list_summary.text = ""      //小書き
            cell.label_list_number_left.text = ""       // 丁数
            cell.label_list_number_right.text = ""
            cell.label_list_debit.text = ""        //借方金額 注意：空白を代入しないと、変な値が入る。
            cell.label_list_credit.text = ""       //貸方金額
            // セルの選択不可にする
            //            cell.selectionStyle = .none
            return cell
        }else { // 空白行ではない場合
            //① UI部品を指定　TableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! JournalsTableViewCell
            
            let dataBaseManager = DataBaseManagerJournalEntry()
            
            if indexPath.row >= presenter.numberOfobjects { // 決算整理仕訳
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                if Number == presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                    indexPathForAutoScroll = indexPath                              // セルの位置　を覚えておく
                }
                let d = "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.section == 0 {
                    if indexPath.row > 0 {
                        if indexPath.row-presenter.numberOfobjects > 0 { // 二行目以降は月の先頭のみ、月を表示する
                            // 一行上のセルに表示した月とこの行の月を比較する
                            let upperCellMonth = "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects - 1).date)" // 日付
                            let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                                if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                                }
                                else{
                                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                                }
                            }
                            else{
                                if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                                }
                                else{
                                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                                }
                            }
                        }
                        else { // 先頭行は月を表示
                            let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }
                            else{
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }
                        }
                    }
                    else { // 先頭行は月を表示
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                        else{
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                    }
                }
                else{
                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                }
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date.text = "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).date.suffix(1))" // 末尾1文字の「日」         //日付
                }
                else{
                    cell.label_list_date.text = "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date.textAlignment = NSTextAlignment.right
                cell.label_list_summary_debit.text = " (\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).debit_category))"     //借方勘定
                cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
                cell.label_list_summary_credit.text = "(\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).credit_category)) "   //貸方勘定
                cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                cell.label_list_summary.text = "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).smallWritting) "              //小書き
                cell.label_list_summary.textAlignment = NSTextAlignment.left
                if presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).debit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_left.text = ""
                }
                else{
                    let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).debit_category)")  // 丁数を取得 エラー2020/11/08
                    cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
                }
                if presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).credit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_right.text = ""
                }
                else{
                    let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).credit_category)")    // 丁数を取得　エラー2020/11/08
                    cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
                }
                cell.label_list_debit.text = "\(addComma(string: String(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).debit_amount))) "        //借方金額
                cell.label_list_credit.text = "\(addComma(string: String(presenter.objectsss(forRow:indexPath.row-presenter.numberOfobjects).credit_amount))) "      //貸方金額
                // セルの選択を許可
                cell.selectionStyle = .default
                return cell
            }
            else { // 通常仕訳
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! JournalsTableViewCell
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                if Number == presenter.objects(forRow:indexPath.row).number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                    indexPathForAutoScroll = indexPath                              // セルの位置　を覚えておく
                }
                let d = "\(presenter.objects(forRow:indexPath.row).date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.section == 0 {
                    if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                        // 一行上のセルに表示した月とこの行の月を比較する
                        let upperCellMonth = "\(presenter.objects(forRow:indexPath.row - 1).date)" // 日付
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }
                            else{
                                cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                            }
                        }
                        else{
                            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }
                            else{
                                cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                            }
                        }
                    }
                    else { // 先頭行は月を表示
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                        else{
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                    }
                }
                else{
                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                }
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date.text = "\(presenter.objects(forRow:indexPath.row).date.suffix(1))" // 末尾1文字の「日」         //日付
                }
                else{
                    cell.label_list_date.text = "\(presenter.objects(forRow:indexPath.row).date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date.textAlignment = NSTextAlignment.right
                cell.label_list_summary_debit.text = " (\(presenter.objects(forRow:indexPath.row).debit_category))"     //借方勘定
                cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
                cell.label_list_summary_credit.text = "(\(presenter.objects(forRow:indexPath.row).credit_category)) "   //貸方勘定
                cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                cell.label_list_summary.text = "\(presenter.objects(forRow:indexPath.row).smallWritting) "              //小書き
                cell.label_list_summary.textAlignment = NSTextAlignment.left
                if presenter.objects(forRow:indexPath.row).debit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_left.text = ""
                }
                else{
                    print(presenter.objects(forRow:indexPath.row).debit_category)
                    let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objects(forRow:indexPath.row).debit_category)")  // 丁数を取得
                    cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
                }
                if presenter.objects(forRow:indexPath.row).credit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_right.text = ""
                }
                else{
                    print(presenter.objects(forRow:indexPath.row).credit_category)
                    let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(presenter.objects(forRow:indexPath.row).credit_category)")    // 丁数を取得
                    cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
                }
                cell.label_list_debit.text = "\(addComma(string: String(presenter.objects(forRow:indexPath.row).debit_amount))) "        //借方金額
                cell.label_list_credit.text = "\(addComma(string: String(presenter.objects(forRow:indexPath.row).credit_amount))) "      //貸方金額
                // セルの選択を許可
                cell.selectionStyle = .default
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var indexPath_local = IndexPath(row: 0, section: 0)
        if scroll || scroll_adding {     // 初回起動時の場合 入力ボタン押下時の場合
            for s in 0..<tableView.numberOfSections {            //セクション数　ゼロスタート補正は不要
                if tableView.numberOfRows(inSection: s) > 0 {
                    let r = tableView.numberOfRows(inSection: s)-1 //セル数　ゼロスタート補正
                    indexPath_local = IndexPath(row: r, section: s)
                    self.tableView.scrollToRow(at: indexPath_local, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                }
            }
        }
        if scroll_adding {     // 入力ボタン押下時の場合
            // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
            if indexPath == indexPath_local { // 最後のセルまで表示しされたかどうか
                self.tableView.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.bottom, animated: false) // 追加した仕訳データの行を画面の下方に表示する
                // 入力ボタン押下時の表示位置 OFF
                scroll_adding = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 1:
            return nil
        default:
            return indexPath
        }
    }
    // 削除機能 セルを左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 1 {
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
        }else { // 空白行をスワイプした場合
            let configuration = UISwipeActionsConfiguration(actions: [])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
}

extension JournalsViewController: JournalsPresenterOutput {

    func reloadData() {
        // 更新処理
        tableView.reloadData()
        // クルクルを止める
        refreshControl.endRefreshing()
    }

    func setupCellLongPressed(indexPath: IndexPath) {
        // 別の画面に遷移 仕訳画面
        performSegue(withIdentifier: "longTapped", sender: nil)
    }

    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        setRefreshControl()
        setLongPressRecognizer()
        initializeJournals()
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
//        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(button_print))
//        //ナビゲーションに定義したボタンを置く
//        self.navigationItem.rightBarButtonItem = printoutButton
        self.navigationItem.title = "仕訳帳"
    }
    
    func setupViewForViewWillAppear() {
        // UIViewControllerの表示画面を更新・リロード
        //        self.loadView() // エラー発生　2020/07/31　Thread 1: EXC_BAD_ACCESS (code=1, address=0x600022903198)
        self.tableView.reloadData() // エラーが発生しないか心配
        
        if let company = presenter.company {
            label_company_name.text = company // 社名
        }
        if let theDayOfReckoning = presenter.theDayOfReckoning {
            if let fiscalYear = presenter.fiscalYear {
                if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                    label_closingDate.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }else {
                    label_closingDate.text = String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
                // データベース　注意：Initialより後に記述する
                Label_list_date_year.text = fiscalYear.description + "年"
            }
        }
        label_title.text = "仕訳帳"
        // 空白行対応
        if presenter.numberOfobjects + presenter.numberOfobjectss >= 1 {
            button_print.isEnabled = true
        }else {
            // 仕訳データが0件の場合、印刷ボタンを不活性にする
            button_print.isEnabled = false
        }
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            if AdMobTest {
                gADBannerView.adUnitID = TEST_ID
            }
            else{
                gADBannerView.adUnitID = AdMobID
            }
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.rowHeight)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView!.rowHeight * -1)
        }
        // ナビゲーションを透明にする処理
        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
        }
    }
    
    func setupViewForViewDidAppear() {
        // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
        view.bringSubviewToFront(gADBannerView)
        
        // 初期表示位置 OFF
        scroll = false
        let indexPath = tableView.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("tableView.indexPathsForVisibleRows: \(String(describing: indexPath))")
        // テーブルをスクロールさせる。scrollViewDidScrollメソッドを呼び出して、インセットの設定を行うため。
        if indexPath != nil && indexPath!.count > 0 {
            self.tableView.scrollToRow(at: indexPath![indexPath!.count-1], at: UITableView.ScrollPosition.bottom, animated: false) //最下行
            self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false) //最上行
            // タグを設定する　チュートリアル対応
            tableView.visibleCells[0].tag = 33
            
            // チュートリアル対応　初回起動時　7行を追加
            let ud = UserDefaults.standard
            let firstLunchKey = "firstLunch_Journals"
            if ud.bool(forKey: firstLunchKey) {
                ud.set(false, forKey: firstLunchKey)
                ud.synchronize()
                // チュートリアル対応
                presentAnnotation()
            }
        }
    }
}
