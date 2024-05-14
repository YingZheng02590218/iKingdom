//
//  MonthlyTrendsBalanceSheetViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/03/15.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import SpreadsheetView
import UIKit

// 月次貸借対照表
class MonthlyTrendsBalanceSheetViewController: UIViewController {

    /// 貸借対照表　上部
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var closingDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var spreadsheetView: SpreadsheetView!
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    
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
    var objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 0)
    var objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 1)
    var objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 2)
    
    var objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 3)
    var objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 4)
    var objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 5)
    
    var objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 2, rank1: 6)
    
    var objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 7)
    var objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 8)
    
    var objects9 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 4, rank1: 9)
    
    var objects10 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 10) // 株主資本
    var objects11 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 11) // 評価・換算差額等
    var objects12 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 12) // 新株予約権
    var objects13 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 19) // 非支配株主持分
    
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
        
        titleLabel.text = "貸借対照表"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        
        // 月次推移表を更新する　true: リロードする 仕訳入力時にフラグを立てる。フラグが立っていれば下記の処理を実行する
        if Constant.needToReload {
            // 月次貸借対照表と月次損益計算書の、五大区分の合計額と、大区分の合計額と当期純利益の額を再計算する
            DataBaseManagerMonthlyBSnPL.shared.setupAmountForBsAndPL(isBs: true)
            
            // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
            objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 0)
            objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 1)
            objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 2)
            
            objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 3)
            objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 4)
            objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 5)
            
            objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 2, rank1: 6)
            
            objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 7)
            objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 8)
            
            objects9 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 4, rank1: 9)
            
            objects10 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 10) // 株主資本
            objects11 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 11) // 評価・換算差額等
            objects12 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 12) // 新株予約権
            objects13 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 19) // 非支配株主持分
            // 月次推移表を更新する　true: リロードする
            Constant.needToReload = false
            
            spreadsheetView.reloadData()
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
    
    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
    private func getBalanceAmount(rank0: Int, rank1: Int, left: Int64, right: Int64) -> String {
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
    
    // アップグレード画面を表示
    func showUpgradeScreen() {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: "SettingsUpgradeViewController",
                bundle: nil
            ).instantiateViewController(withIdentifier: "SettingsUpgradeViewController") as? SettingsUpgradeViewController {
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
}

extension MonthlyTrendsBalanceSheetViewController: SpreadsheetViewDataSource {
    
    // MARK: DataSource
    // 列
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + dates.count
    }
    // 行
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRowCount
        + objects0.count
        + objects1.count
        + objects2.count
        + 1
        + objects3.count
        + objects4.count
        + objects5.count
        + 1
        + objects6.count
        + 1
        + 1
        + objects7.count
        + objects8.count
        + 1
        + objects9.count
        + 1
        + 1
        + objects10.count
        + objects11.count
        + objects12.count
        + objects13.count
        + 1
        + 1
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
        let objects1Count = objects1.count + objects0Count
        let objects2Count = objects2.count + objects1Count
        let bs2Count = objects2Count + 1
        let objects3Count = objects3.count + bs2Count
        let objects4Count = objects4.count + objects3Count
        let objects5Count = objects5.count + objects4Count
        let bs5Count = objects5Count + 1
        let objects6Count = objects6.count + bs5Count
        let bs6Count = objects6Count + 1
        let big6Count = bs6Count + 1
        let objects7Count = objects7.count + big6Count
        let objects8Count = objects8.count + objects7Count
        let bs8Count = objects8Count + 1
        let objects9Count = objects9.count + bs8Count
        let bs9Count = objects9Count + 1
        let big9Count = bs9Count + 1
        let objects10Count = objects10.count + big9Count
        let objects11Count = objects11.count + objects10Count
        let objects12Count = objects12.count + objects11Count
        let objects13Count = objects13.count + objects12Count
        let bs13Count = objects13Count + 1
        let big13Count = bs13Count + 1
        // ＜虹の色＞ 7色 ＝ 赤・橙・黄・緑・青・藍・紫
        
        if case (0, 0) = (indexPath.column, indexPath.row) {
            // 0列目、0行目
            // 空白
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = ""
                cell.backgroundColor = .accentColor.withAlphaComponent(0.1)
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
                cell.backgroundColor = .accentColor.withAlphaComponent(0.1)
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
        } else if case (0, objects0Count..<objects1Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目1
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects1[indexPath.row - objects0Count].category
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
            
        } else if case (0, objects2Count..<bs2Count) = (indexPath.column, indexPath.row) {
            // 流動資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "流動資産　合計"
                cell.label.textAlignment = .right
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs2Count..<objects3Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目3
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects3[indexPath.row - bs2Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects3Count..<objects4Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目4
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects4[indexPath.row - objects3Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects4Count..<objects5Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目5
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects5[indexPath.row - objects4Count].category
                //            cell.backgroundColor = .orange.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects5Count..<bs5Count) = (indexPath.column, indexPath.row) {
            // 固定資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "固定資産　合計"
                cell.label.textAlignment = .right
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs5Count..<objects6Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目6
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects6[indexPath.row - bs5Count].category
                //            cell.backgroundColor = .yellow.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects6Count..<bs6Count) = (indexPath.column, indexPath.row) {
            // 繰越資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = "繰越資産　合計"
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs6Count..<big6Count) = (indexPath.column, indexPath.row) {
            // 資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = "資産　合計"
                cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
        } else if case (0, big6Count..<objects7Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目7
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects7[indexPath.row - big6Count].category
                //            cell.backgroundColor = .green.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects7Count..<objects8Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目8
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects8[indexPath.row - objects7Count].category
                //            cell.backgroundColor = .green.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects8Count..<bs8Count) = (indexPath.column, indexPath.row) {
            // 流動負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "流動負債　合計"
                cell.label.textAlignment = .right
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs8Count..<objects9Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目9
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects9[indexPath.row - bs8Count].category
                //            cell.backgroundColor = .cyan.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects9Count..<bs9Count) = (indexPath.column, indexPath.row) {
            // 固定負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "固定負債　合計"
                cell.label.textAlignment = .right
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs9Count..<big9Count) = (indexPath.column, indexPath.row) {
            // 負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = "負債　合計"
                cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
        } else if case (0, big9Count..<objects10Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目10
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects10[indexPath.row - big9Count].category
                //            cell.backgroundColor = .blue.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects10Count..<objects11Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目11
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects11[indexPath.row - objects10Count].category
                //            cell.backgroundColor = .blue.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects11Count..<objects12Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目12
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects12[indexPath.row - objects11Count].category
                //            cell.backgroundColor = .blue.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (0, objects12Count..<objects13Count) = (indexPath.column, indexPath.row) {
            // 0列目、2〜行目
            // 勘定科目13
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                cell.label.text = objects13[indexPath.row - objects12Count].category
                //            cell.backgroundColor = .blue.withAlphaComponent(0.1)
                cell.backgroundColor = .clear
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
            
        } else if case (0, objects13Count..<bs13Count) = (indexPath.column, indexPath.row) {
            // 資本　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.text = "資本　合計"
                cell.label.textAlignment = .right
                cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 2, color: .lightGray)
                return cell
            }
            
        } else if case (0, bs13Count..<big13Count) = (indexPath.column, indexPath.row) {
            // 純資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as? TimeTitleCell {
                cell.label.textAlignment = .right
                cell.label.text = "純資産　合計"
                cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                cell.borders.top = .none
                cell.borders.bottom = .solid(width: 3, color: .lightGray)
                return cell
            }
            
            
            
        } else if case (1...(dates.count + 1), 0) = (indexPath.column, indexPath.row) {
            // 1〜列目、0行目
            // 日付
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as? DateCell {
                cell.label.text = "\(dates[indexPath.column - 1].year)" + "-" + "\(String(format: "%02d", dates[indexPath.column - 1].month))"
                cell.backgroundColor = .accentColor.withAlphaComponent(0.1)
                cell.borders.top = .none
                cell.borders.bottom = .none
                return cell
            }
        } else if case (1...(dates.count + 1), 1) = (indexPath.column, indexPath.row) {
            // 1〜列目、1行目
            // 空白 曜日
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as? DateCell {
                cell.label.text = ""
                cell.backgroundColor = .accentColor.withAlphaComponent(0.1)
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
                    text = getBalanceAmount(rank0: 0, rank1: 0, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects0Count..<(objects1Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目1
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects1[indexPath.row - objects0Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 0, rank1: 1, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
                    text = getBalanceAmount(rank0: 0, rank1: 2, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects2Count..<bs2Count) = (indexPath.column, indexPath.row) {
            // 流動資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.CurrentAssets_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs2Count..<(objects3Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目3
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects3[indexPath.row - bs2Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 1, rank1: 3, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects3Count..<(objects4Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目4
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects4[indexPath.row - objects3Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 1, rank1: 4, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects4Count..<(objects5Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目5
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects5[indexPath.row - objects4Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 1, rank1: 5, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects5Count..<bs5Count) = (indexPath.column, indexPath.row) {
            // 固定資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.FixedAssets_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs5Count..<objects6Count) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目6
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects6[indexPath.row - bs5Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 2, rank1: 6, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects6Count..<bs6Count) = (indexPath.column, indexPath.row) {
            // 繰越資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.DeferredAssets_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs6Count..<big6Count) = (indexPath.column, indexPath.row) {
            // 資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Asset_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), big6Count..<(objects7Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目7
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects7[indexPath.row - big6Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 3, rank1: 7, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects7Count..<(objects8Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目8
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects8[indexPath.row - objects7Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 3, rank1: 8, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects8Count..<bs8Count) = (indexPath.column, indexPath.row) {
            // 流動負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.CurrentLiabilities_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs8Count..<(objects9Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目9
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects9[indexPath.row - bs8Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 4, rank1: 9, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects9Count..<bs9Count) = (indexPath.column, indexPath.row) {
            // 固定負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.FixedLiabilities_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs9Count..<big9Count) = (indexPath.column, indexPath.row) {
            // 負債　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Liability_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), big9Count..<(objects10Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目10
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects10[indexPath.row - big9Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 5, rank1: 10, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects10Count..<(objects11Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目11
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects11[indexPath.row - objects10Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 5, rank1: 11, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects11Count..<(objects12Count)) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目12
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects12[indexPath.row - objects11Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 5, rank1: 12, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
        } else if case (1...(dates.count + 1), objects12Count..<objects13Count) = (indexPath.column, indexPath.row) {
            // 1〜列目、2〜行目
            // 残高金額 勘定科目13
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects13[indexPath.row - objects12Count].category,
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = getBalanceAmount(rank0: 5, rank1: 19, left: dataBaseMonthlyTransferEntry.balance_left, right: dataBaseMonthlyTransferEntry.balance_right)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
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
            
        } else if case (1...(dates.count + 1), objects13Count..<bs13Count) = (indexPath.column, indexPath.row) {
            // 資本　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Capital_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.2)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 2, color: .lightGray)
                }
                // アップグレード機能　スタンダードプラン
//                cell.isMasked = indexPath.column == 1 ? false : !UpgradeManager.shared.inAppPurchaseFlag
                return cell
            }
            
        } else if case (1...(dates.count + 1), bs13Count..<big13Count) = (indexPath.column, indexPath.row) {
            // 純資産　合計
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as? ScheduleCell {
                var text = ""
                // 取得 月次貸借対照表　今年度で日付の前方一致
                if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                    yearMonth: "\(dates[indexPath.column - 1].year)" + "/" + "\(String(format: "%02d", dates[indexPath.column - 1].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける　カンマを追加する
                    text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Equity_total)
                }
                if !text.isEmpty {
                    cell.label.text = text
                    cell.label.textColor = text.contains("△") ? .red : .textColor
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
                    cell.borders.top = .none
                    cell.borders.bottom = .solid(width: 3, color: .lightGray)
                } else {
                    cell.label.text = nil
                    cell.backgroundColor = .accentColor.withAlphaComponent(0.3)
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

extension MonthlyTrendsBalanceSheetViewController: SpreadsheetViewDelegate {
    
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
