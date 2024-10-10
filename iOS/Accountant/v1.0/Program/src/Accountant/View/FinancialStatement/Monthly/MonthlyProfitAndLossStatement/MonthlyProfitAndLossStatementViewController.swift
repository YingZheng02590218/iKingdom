//
//  MonthlyProfitAndLossStatementViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/04/23.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import QuickLook
import SpreadsheetView
import UIKit

// 月次損益計算書
class MonthlyProfitAndLossStatementViewController: UIViewController {
    
    /// 貸借対照表　上部
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var closingDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var spreadsheetView: SpreadsheetView!
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    @IBOutlet private var csvBarButtonItem: UIBarButtonItem!
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    // グラデーションレイヤー　書類系画面
    let gradientLayer = CAGradientLayer()
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    // 月別の月末日を取得 12ヶ月分
    let dates = DateManager.shared.getTheDayOfEndingOfMonth()
    // 大区分ごとに設定勘定科目を取得する
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
    var objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 6, rank1: nil)
    
    var objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 13)
    var objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 14)
    
    var objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 8, rank1: nil)
    
    var objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 15)
    var objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 16)
    
    var objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 17)
    var objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 18)
    
    var objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 11, rank1: nil)
    // ヘッダーの行数
    let headerRowCount = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "月次推移表"
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        spreadsheetView.intercellSpacing = CGSize(width: 2, height: 1)
        // spreadsheetView.gridStyle = .none
        spreadsheetView.allowsMultipleSelection = true
        spreadsheetView.indicatorStyle = .black
        
        spreadsheetView.register(DateCell.self, forCellWithReuseIdentifier: String(describing: DateCell.self))
        spreadsheetView.register(TimeTitleCell.self, forCellWithReuseIdentifier: String(describing: TimeTitleCell.self))
        spreadsheetView.register(TimeCell.self, forCellWithReuseIdentifier: String(describing: TimeCell.self))
        spreadsheetView.register(ScheduleCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCell.self))
        
        companyNameLabel.text = DataBaseManagerAccountingBooksShelf.shared.getCompanyName() // 社名
        let theDayOfReckoning = DateManager.shared.getEndingOfYearDate()
        if let date = DateManager.shared.dateFormatter.date(from: theDayOfReckoning) {
            closingDateLabel.text = "\(date.year)年\(date.month)月\(date.day)日" // 決算日を表示する
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = "損益計算書"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        
        // 月次推移表を更新する　true: リロードする 仕訳入力時にフラグを立てる。フラグが立っていれば下記の処理を実行する
        if Constant.needToReload {
            // ローディング処理
            // インジゲーターを開始
            self.showActivityIndicatorView()
            // 集計処理
            DispatchQueue.global(qos: .default).async {
                // 月次貸借対照表と月次損益計算書の、五大区分の合計額と、大区分の合計額と当期純利益の額を再計算する
                DataBaseManagerMonthlyBSnPL.shared.setupAmountForBsAndPL()
                // 重要: 仕訳データを参照する際、メインスレッドで行う
                DispatchQueue.main.async {
                    // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
                    self.objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 6, rank1: nil)
                    
                    self.objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 13)
                    self.objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 14)
                    
                    self.objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 8, rank1: nil)
                    
                    self.objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 15)
                    self.objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 16)
                    
                    self.objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 17)
                    self.objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 18)
                    
                    self.objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 11, rank1: nil)
                    // 月次推移表を更新する　true: リロードする
                    Constant.needToReload = false
                    
                    self.spreadsheetView.reloadData()
                    // インジケーターを終了
                    self.finishActivityIndicatorView()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        spreadsheetView.flashScrollIndicators()
        
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // アップグレード画面を表示
            // showUpgradeScreen()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ボタン作成
        createButtons()
    }
    
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
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
        
        csvBarButtonItem.tintColor = .accentColor
    }
    
    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
    private func getBalanceAmount(rank0: Int, rank1: Int?, left: Int64, right: Int64) -> String {
        var result: Int64 = 0
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        // 借方と貸方で金額が大きい方はどちらか
        if left > right {
            result = left
            debitOrCredit = "借"
        } else if left < right {
            result = right
            debitOrCredit = "貸"
        } else {
            debitOrCredit = "-"
        }
        
        switch rank0 {
        case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
            switch debitOrCredit {
            case "貸":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        case 9, 10: // 営業外損益 特別損益
            if rank1 == 15 || rank1 == 17 { // 営業外損益
                switch debitOrCredit {
                case "借":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            } else if rank1 == 16 || rank1 == 18 { // 特別損益
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            }
        default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
            switch debitOrCredit {
            case "借":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        }
        
        if positiveOrNegative == "-" {
            // 残高がマイナスの場合、三角のマークをつける
            result = (result * -1)
        }
        
        // カンマを追加して文字列に変換した値を返す
        return StringUtility.shared.setComma(amount: result)
    }
    
    @IBAction func csvBarButtonItemTapped(_ sender: Any) {
        csvBarButtonItemTapped()
    }
    
    // CSV機能
    func csvBarButtonItemTapped() {
        // 初期化
        initializeCsvMaker(completion: { csvPath in
            
            self.filePath = csvPath
            self.showPreview()
        })
    }
    // PDF,CSVファイルのパス
    var filePath: URL?
    // CSV機能
    let csvFileMaker = CsvFileMakerMonthlyProfitAndLossStatement()
    // 初期化
    func initializeCsvMaker(completion: (URL?) -> Void) {
        
        csvFileMaker.initialize(completion: { filePath in
            completion(filePath)
        })
    }
    
    // アップグレード画面を表示
    func showUpgradeScreen() {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: "SettingsUpgradeViewController",
                bundle: nil
            ).instantiateViewController(withIdentifier: "SettingsUpgradeViewController") as? SettingsUpgradeViewController {
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                self.present(navigation, animated: true, completion: nil)
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

extension MonthlyProfitAndLossStatementViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if let _ = filePath {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let filePath = filePath else {
            return "" as! QLPreviewItem
        }
        return filePath as QLPreviewItem
    }
}

extension MonthlyProfitAndLossStatementViewController: SpreadsheetViewDataSource {
    
    // MARK: DataSource
    // 列
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + dates.count
    }
    // 行
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRowCount
        + objects0.count
        + 1 // 売上高
        + objects1.count
        + objects2.count
        + 1 // 売上原価
        + 1 // 売上総利益
        + objects3.count
        + 1 // 販売費及び一般管理費
        + 1 // 営業利益
        + objects4.count
        + 1 // 営業外収益
        + objects5.count
        + 1 // 営業外費用
        + 1 // 経常利益
        + objects6.count
        + 1 // 特別利益
        + objects7.count
        + 1 // 特別損失
        + 1 // 税引前当期純利益
        + objects8.count
        + 1 // 法人税、住民税及び事業税
        + 1 // 当期純利益
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 160
        } else {
            return 100
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 24
        } else if case 1 = row {
            return 32
        } else {
            return 25
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        2
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        // 行
        // 勘定科目0
        let objects0Count = objects0.count + headerRowCount
        let pl0Count = objects0Count + 1 // 売上高
        
        let objects1Count = objects1.count + pl0Count
        let objects2Count = objects2.count + objects1Count
        let pl2Count = objects2Count + 1 // 売上原価
        let big2Count = pl2Count + 1 // 売上総利益
        
        let objects3Count = objects3.count + big2Count
        let pl3Count = objects3Count + 1 // 販売費及び一般管理費
        let big3Count = pl3Count + 1 // 営業利益
        
        let objects4Count = objects4.count + big3Count
        let pl4Count = objects4Count + 1 // 営業外収益
        let objects5Count = objects5.count + pl4Count
        let pl5Count = objects5Count + 1 // 営業外費用
        let big5Count = pl5Count + 1 // 経常利益
        
        let objects6Count = objects6.count + big5Count
        let pl6Count = objects6Count + 1 // 特別利益
        let objects7Count = objects7.count + pl6Count
        let pl7Count = objects7Count + 1 // 特別損失
        let big7Count = pl7Count + 1 // 税引前当期純利益
        
        let objects8Count = objects8.count + big7Count
        let pl8Count = objects8Count + 1 // 法人税、住民税及び事業税
        let big8Count = pl8Count + 1 // 当期純利益
        
        // ＜虹の色＞ 7色 ＝ 赤・橙・黄・緑・青・藍・紫
        
        if case (0, 0) = (indexPath.column, indexPath.row) {
            // 0列目、0行目
            // 空白
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ""
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.1)
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, 1) = (indexPath.column, indexPath.row) {
            // 0列目、1行目
            // 勘定科目タイトル
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "勘定科目"
                cell.label.textAlignment = .center
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.1)
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
            
        } else if case (0, headerRowCount..<(objects0Count)) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目0
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects0[indexPath.row - headerRowCount].category
                //            cell.backgroundColor = .red.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects0Count..<pl0Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.sales.getTotalAmount() // 売上高
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl0Count..<objects1Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目1
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects1[indexPath.row - pl0Count].category
                //            cell.backgroundColor = .red.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects1Count..<objects2Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目2
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects2[indexPath.row - objects1Count].category
                //            cell.backgroundColor = .red.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects2Count..<pl2Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.costOfGoodsSold.getTotalAmount() // 売上原価
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl2Count..<big2Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = ProfitAndLossStatement.Benefits.grossProfitOrLoss.rawValue // 売上総利益
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
        } else if case (0, big2Count..<objects3Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目3
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects3[indexPath.row - big2Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects3Count..<pl3Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.getTotalAmount() // 販売費及び一般管理費
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl3Count..<big3Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = ProfitAndLossStatement.Benefits.otherCapitalSurplusesTotal.rawValue // 営業利益
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
        } else if case (0, big3Count..<objects4Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目4
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects4[indexPath.row - big3Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects4Count..<pl4Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.nonOperatingIncome.getTotalAmount() // 営業外収益
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl4Count..<objects5Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目5
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects5[indexPath.row - pl4Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects5Count..<pl5Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.nonOperatingExpenses.getTotalAmount() // 営業外費用
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl5Count..<big5Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = ProfitAndLossStatement.Benefits.ordinaryIncomeOrLoss.rawValue // 経常利益
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
        } else if case (0, big5Count..<objects6Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目6
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects6[indexPath.row - big5Count].category
                //            cell.backgroundColor = .yellow.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects6Count..<pl6Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.extraordinaryProfits.getTotalAmount() // 特別利益
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl6Count..<objects7Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目7
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects7[indexPath.row - pl6Count].category
                //            cell.backgroundColor = .green.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects7Count..<pl7Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.extraordinaryLoss.getTotalAmount() // 特別損失
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl7Count..<big7Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = ProfitAndLossStatement.Benefits.incomeOrLossBeforeIncomeTaxes.rawValue // 税引前当期純利益
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
        } else if case (0, big7Count..<objects8Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目8
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects8[indexPath.row - big7Count].category
                //            cell.backgroundColor = .green.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects8Count..<pl8Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ProfitAndLossStatement.Block.incomeTaxes.getTotalAmount() // 法人税、住民税及び事業税
                cell.label.textAlignment = .right
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, pl8Count..<big8Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = ProfitAndLossStatement.Benefits.netIncomeOrLoss.rawValue // 当期純利益
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
        } else if case (1...(dates.count + 1), 0) = (indexPath.column, indexPath.row) {
            // 1〜列目、0行目
            // 日付
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as? DateCell {
                cell.label.text = "\(dates[indexPath.column - 1].year)" + "-" + "\(String(format: "%02d", dates[indexPath.column - 1].month))"
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.1)
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (1...(dates.count + 1), 1) = (indexPath.column, indexPath.row) {
            // 1〜列目、1行目
            // 空白 曜日
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as? DateCell {
                cell.label.text = ""
                cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.1)
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
            
            
        } else if case (1...(dates.count + 1), headerRowCount..<(objects0Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目0
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects0[indexPath.row - headerRowCount].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 6,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects0Count..<pl0Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.NetSales)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl0Count..<(objects1Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目1
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects1[indexPath.row - pl0Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 7,
                        rank1: 13,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
        } else if case (1...(dates.count + 1), objects1Count..<(objects2Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目2
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects2[indexPath.row - objects1Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 7,
                        rank1: 14,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects2Count..<pl2Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.CostOfGoodsSold)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl2Count..<big2Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.GrossProfitOrLoss)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
            
        } else if case (1...(dates.count + 1), big2Count..<(objects3Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目3
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects3[indexPath.row - big2Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 8,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects3Count..<pl3Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.SellingGeneralAndAdministrativeExpenses)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl3Count..<big3Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.OtherCapitalSurpluses_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
            
        } else if case (1...(dates.count + 1), big3Count..<(objects4Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目4
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects4[indexPath.row - big3Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 9,
                        rank1: 15,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects4Count..<pl4Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.NonOperatingIncome)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl4Count..<(objects5Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目5
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects5[indexPath.row - pl4Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 9,
                        rank1: 16,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects5Count..<pl5Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.NonOperatingExpenses)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl5Count..<big5Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.OrdinaryIncomeOrLoss)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
            
        } else if case (1...(dates.count + 1), big5Count..<objects6Count) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目6
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects6[indexPath.row - big5Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 10,
                        rank1: 17,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects6Count..<pl6Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.ExtraordinaryIncome)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl6Count..<(objects7Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目7
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects7[indexPath.row - pl6Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 10,
                        rank1: 18,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects7Count..<pl7Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.ExtraordinaryLosses)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl7Count..<big7Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.IncomeOrLossBeforeIncomeTaxes)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
            
        } else if case (1...(dates.count + 1), big7Count..<(objects8Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目8
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects8[indexPath.row - big7Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(
                        rank0: 11,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .clear
                    cell.borders.top = .none
                    cell.borders.bottom = .none
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), objects8Count..<pl8Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.IncomeTaxes)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), pl8Count..<big8Count) = (indexPath.column, indexPath.row) {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益計算書　今年度で日付の前方一致
                if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyProfitAndLossStatement.NetIncomeOrLoss)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .paperTextColor
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
                //                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
        }
        
        return nil
    }
    
}

extension MonthlyProfitAndLossStatementViewController: SpreadsheetViewDelegate {
    
    /// Delegate
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didUnhighlightItemAt indexPath: IndexPath) {
        
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt: (row: \(indexPath.row), column: \(indexPath.column))")
        // 残高金額 勘定科目13
        if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
            cell.isSelected = true
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didDeselectItemAt indexPath: IndexPath) {
        print("didDeselectItemAt: (row: \(indexPath.row), column: \(indexPath.column))")
        // 残高金額 勘定科目13
        if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
            cell.isSelected = false
        }
    }
}

