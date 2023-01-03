//
//  BalanceSheetViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/01.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import AudioToolbox // 効果音
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import QuickLook
import UIKit

// 貸借対照表　個人事業主
class BalanceSheetViewController: UIViewController {
    
    // MARK: - var let
    
    var gADBannerView: GADBannerView!
    /// 貸借対照表　上部
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var closingDateLabel: UILabel!
    @IBOutlet var closingDatePreviousLabel: UILabel!
    @IBOutlet var closingDateThisYearLabel: UILabel!
    /// 貸借対照表　下部
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.register(
                UINib(nibName: String(describing: BSTableViewHeaderFooterView.self), bundle: nil),
                forHeaderFooterViewReuseIdentifier: String(describing: BSTableViewHeaderFooterView.self)
            )
            tableView.register(
                UINib(nibName: String(describing: BSTableViewCell.self), bundle: nil),
                forCellReuseIdentifier: String(describing: BSTableViewCell.self)
            )
        }
    }
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    fileprivate let refreshControl = UIRefreshControl()
    
    /// GUIアーキテクチャ　MVP
    private var presenter: BalacneSheetPresenterInput!
    func inject(presenter: BalacneSheetPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = BalacneSheetPresenter.init(view: self, model: BalanceSheetModel())
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
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
        }
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Action
    
    @objc private func refreshTable() {
        presenter.refreshTable()
    }
    
    /**
     * 印刷ボタン押下時メソッド
     */
    @objc private func pdfBarButtonItemTapped() {
        presenter.pdfBarButtonItemTapped()
    }
    
}

extension BalanceSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、資本の部...負債純資産合計
        // 流動資産,固定資産,繰延資産...
        return 3 +
        BalanceSheet.Block.allCases.count + // 資産合計、負債合計、純資産合計の分
        BalanceSheet.Assets.allCases.count +
        BalanceSheet.Liabilities.allCases.count +
        BalanceSheet.Capital.allCases.count
    }
    // セクションヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 35 // 資産の部
        case 1:
            return 0 // 流動資産
        case 2:
            return 0 // 固定資産
        case 3:
            return 0 // 繰延資産
        case 4:
            return 0 // 資産合計
        case 5: return 35 // 負債の部
        case 6:
            return 0 // 流動負債
        case 7:
            return 0 // 固定負債
        case 8:
            return 0 // 負債合計
        case 9: return 35 // 資本の部
        case 10:
            return 0 // 元入金
        case 11:
            return 0 // 純資産合計
        case 12:
            return 0 // 負債純資産合計
        default:
            return 35
        }
        // セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける
    }
    // セクションフッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0 // 資産の部
        case 1:
            return 35 // 流動資産
        case 2:
            return 35 // 固定資産
        case 3:
            return 35 // 繰延資産
        case 4:
            return 35 // 資産合計
        case 5: return 0 // 負債の部
        case 6:
            return 35 // 流動負債
        case 7:
            return 35 // 固定負債
        case 8:
            return 35 // 負債合計
        case 9: return 0 // 資本の部
        case 10:
            return 0 // 元入金合計
        case 11:
            return 35 // 純資産合計
        case 12:
            return 35 // 負債純資産合計
        default:
            return 0
        }
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            //            header.backgroundColor = .orange
            
            header.textLabel?.textColor = .textColor
            header.textLabel?.textAlignment = .left
            // システムフォントのサイズを設定
            header.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return BalanceSheet.Block.assets.rawValue // 資産の部
        case 1:
            return "  " + BalanceSheet.Assets.currentAssets.rawValue // 流動資産
        case 2:
            return "  " + BalanceSheet.Assets.nonCurrentAssets.rawValue // 固定資産
        case 3:
            return "  " + BalanceSheet.Assets.deferredAssets.rawValue // 繰延資産
        case 4: // 資産合計
            return nil
        case 5:
            return BalanceSheet.Block.liabilities.rawValue // 負債の部
        case 6:
            return "  " + BalanceSheet.Liabilities.currentLiabilities.rawValue // 流動負債
        case 7:
            return "  " + BalanceSheet.Liabilities.fixedLiabilities.rawValue // 固定負債
        case 8: // 負債合計
            return nil
        case 9:
            return BalanceSheet.Block.netAssets.rawValue // 資本の部
        case 10:
            return nil // 元入金
        case 11: // 純資産合計
            return nil
        case 12: // 負債純資産合計
            return nil
        default:
            return nil
        }
    }
    
    // セクションフッター
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BSTableViewHeaderFooterView.self))
        if let headerView = view as? BSTableViewHeaderFooterView {

            var footerLabelText = "" // タイトル
            var textForPrevious = "" // 前年度 前年度の会計帳簿の存在有無を確認
            var textForThisYear = "" // 今年度
            
            switch section {
                //　case 0: // 資産の部
            case 1: // MARK: - "    流動資産合計"
                footerLabelText = BalanceSheet.Assets.currentAssets.getTotalAmount() // 流動資産
                textForPrevious = presenter.getTotalRank0(rank0: 0, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 0, lastYear: false)
            case 2: // MARK: - "    固定資産合計"
                footerLabelText = BalanceSheet.Assets.nonCurrentAssets.getTotalAmount() // 固定資産
                textForPrevious = presenter.getTotalRank0(rank0: 1, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 1, lastYear: false)
            case 3: // MARK: - "    繰越資産合計"
                footerLabelText = BalanceSheet.Assets.deferredAssets.getTotalAmount() // 繰延資産
                textForPrevious = presenter.getTotalRank0(rank0: 2, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 2, lastYear: false)
            case 4: // MARK: - "資産合計"
                footerLabelText = BalanceSheet.Block.assets.getTotalAmount() // 資産の部
                textForPrevious = presenter.getTotalBig5(big5: 0, lastYear: true)
                textForThisYear = presenter.getTotalBig5(big5: 0, lastYear: false)
                //　case 5: // 負債の部
            case 6: // MARK: - "    流動負債合計"
                footerLabelText = BalanceSheet.Liabilities.currentLiabilities.getTotalAmount() // 流動負債
                textForPrevious = presenter.getTotalRank0(rank0: 3, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 3, lastYear: false)
            case 7: // MARK: - "    固定負債合計"
                footerLabelText = BalanceSheet.Liabilities.fixedLiabilities.getTotalAmount() // 固定負債
                textForPrevious = presenter.getTotalRank0(rank0: 4, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 4, lastYear: false)
            case 8: // MARK: - "負債合計"
                footerLabelText = BalanceSheet.Block.liabilities.getTotalAmount() // 負債の部
                textForPrevious = presenter.getTotalBig5(big5: 1, lastYear: true)
                textForThisYear = presenter.getTotalBig5(big5: 1, lastYear: false)
                //　case 9: // 資本の部
            case 10: // MARK: - "    元入金合計"
                // TODO: 株主資本、評価・換算差額等　なども表示させる
                break
            case 11: // MARK: - "純資産合計"
                footerLabelText = BalanceSheet.Block.netAssets.getTotalAmount() // 資本の部
                textForPrevious = presenter.getTotalBig5(big5: 2, lastYear: true)
                textForThisYear = presenter.getTotalBig5(big5: 2, lastYear: false)
            case 12: // MARK: - "負債純資産合計"
                footerLabelText = BalanceSheet.Block.liabilityAndEquity.getTotalAmount() // 負債純資産の部
                textForPrevious = presenter.getTotalBig5(big5: 3, lastYear: true)
                textForThisYear = presenter.getTotalBig5(big5: 3, lastYear: false)
            default:
                break
            }
            // タイトル
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 16)
            headerView.textLabel?.minimumScaleFactor = 0.05
            headerView.textLabel?.adjustsFontSizeToFitWidth = true
            headerView.textLabel?.textColor = .textColor
            headerView.textLabel?.text = "    \(footerLabelText)"
            // 今年度
            let attributeTextForThisYear = NSMutableAttributedString(string: textForThisYear)
            attributeTextForThisYear.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textForThisYear.count)
            )
            headerView.labelForThisYear.attributedText = attributeTextForThisYear
            headerView.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            // 前年度
            let attributeTextForPrevious = NSMutableAttributedString(string: textForPrevious)
            attributeTextForPrevious.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textForPrevious.count)
            )
            headerView.labelForPrevious.attributedText = attributeTextForPrevious
            headerView.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)

            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        22
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 資産の部
            print("資産の部")
            return 0
        case 1: // 流動資産
            print(
                "流動資産",
                presenter.numberOfobjects(rank0: 0, rank1: 0) +
                presenter.numberOfobjects(rank0: 0, rank1: 1) +
                presenter.numberOfobjects(rank0: 0, rank1: 2)
            )
            return presenter.numberOfobjects(rank0: 0, rank1: 0) +
            presenter.numberOfobjects(rank0: 0, rank1: 1) +
            presenter.numberOfobjects(rank0: 0, rank1: 2)
        case 2: // 固定資産
            print(
                "固定資産",
                presenter.numberOfobjects(rank0: 1, rank1: 0) +
                presenter.numberOfobjects(rank0: 1, rank1: 1) +
                presenter.numberOfobjects(rank0: 1, rank1: 2)
            )
            return presenter.numberOfobjects(rank0: 1, rank1: 0) +
            presenter.numberOfobjects(rank0: 1, rank1: 1) +
            presenter.numberOfobjects(rank0: 1, rank1: 2)
        case 3: // 繰延資産
            print(
                "繰延資産",
                presenter.numberOfobjects(rank0: 2, rank1: 0)
            )
            return presenter.numberOfobjects(rank0: 2, rank1: 0)
        case 4: // 資産合計
            return 0
        case 5: // 負債の部
            print("負債の部")
            return 0
        case 6: // 流動負債
            print(
                "流動負債",
                presenter.numberOfobjects(rank0: 3, rank1: 0) +
                presenter.numberOfobjects(rank0: 3, rank1: 1)
            )
            return presenter.numberOfobjects(rank0: 3, rank1: 0) +
            presenter.numberOfobjects(rank0: 3, rank1: 1)
        case 7: // 固定負債
            print(
                "固定負債",
                presenter.numberOfobjects(rank0: 4, rank1: 0)
            )
            return presenter.numberOfobjects(rank0: 4, rank1: 0)
        case 8: // 負債合計
            return 0
        case 9: // 資本の部
            print("資本の部")
            return 0
        case 10: // 資本
            print(
                "資本",
                presenter.numberOfobjects(rank0: 5, rank1: 4)
            )
            return presenter.numberOfobjects(rank0: 5, rank1: 4)
        case 11: // 純資産合計
            return 0
        case 12: // 負債純資産合計
            return 0
            
        default:
            print("default")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as? BSTableViewCell else { return UITableViewCell() }
        // タイトル
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.minimumScaleFactor = 0.05
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        // 前年度
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForThisYear.text = nil
        cell.labelForThisYear.textAlignment = .right
        
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.attributedText = nil
        cell.labelForPrevious.text = nil
        cell.labelForPrevious.textAlignment = .right
        
        switch indexPath.section { // 5大区分、大区分
        case 0: // MARK: - 資産の部
            return cell
            
        case 1: // MARK: - "  流動資産"
            switch indexPath.row {
                // MARK: - "  当座資産"
            case 0 ..< presenter.numberOfobjects(rank0: 0, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 0, rank1: 0, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 0, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
                // MARK: - "  棚卸資産"
            case presenter.numberOfobjects(rank0: 0, rank1: 0) ..< presenter.numberOfobjects(rank0: 0, rank1: 0) + presenter.numberOfobjects(rank0: 0, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 0, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0)).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 0, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0), lastYear: true) // 勘定別の合計
                return cell
                // MARK: - "  その他の流動資産"
            case presenter.numberOfobjects(rank0: 0, rank1: 0) + presenter.numberOfobjects(rank0: 0, rank1: 1) ..< presenter.numberOfobjects(rank0: 0, rank1: 0) + presenter.numberOfobjects(rank0: 0, rank1: 1) + presenter.numberOfobjects(rank0: 0, rank1: 2):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 0, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0) - presenter.numberOfobjects(rank0: 0, rank1: 1)).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 0, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0) - presenter.numberOfobjects(rank0: 0, rank1: 1)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0) - presenter.numberOfobjects(rank0: 0, rank1: 1), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 0, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 0, rank1: 0) - presenter.numberOfobjects(rank0: 0, rank1: 1), lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
            
        case 2: // MARK: - "  固定資産"
            switch indexPath.row {
                // MARK: - 有形固定資産3
            case 0 ..< presenter.numberOfobjects(rank0: 1, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 1, rank1: 0, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 1, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
                // MARK: - 無形固定資産
            case presenter.numberOfobjects(rank0: 1, rank1: 0) ..< presenter.numberOfobjects(rank0: 1, rank1: 0) + presenter.numberOfobjects(rank0: 1, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 1, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0)).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 1, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0), lastYear: true) // 勘定別の合計
                return cell
                // MARK: - 投資その他資産　投資その他の資産
            case presenter.numberOfobjects(rank0: 1, rank1: 0) + presenter.numberOfobjects(rank0: 1, rank1: 1) ..< presenter.numberOfobjects(rank0: 1, rank1: 0) + presenter.numberOfobjects(rank0: 1, rank1: 1) + presenter.numberOfobjects(rank0: 1, rank1: 2):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 1, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0) - presenter.numberOfobjects(rank0: 1, rank1: 1)).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 1, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0) - presenter.numberOfobjects(rank0: 1, rank1: 1)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0) - presenter.numberOfobjects(rank0: 1, rank1: 1), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 1, rank1: 2, forRow: indexPath.row - presenter.numberOfobjects(rank0: 1, rank1: 0) - presenter.numberOfobjects(rank0: 1, rank1: 1), lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
            
        case 3: // MARK: - "  繰越資産"
            switch indexPath.row {
                // MARK: - "  繰越資産"
            case 0 ..< presenter.numberOfobjects(rank0: 2, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 2, rank1: 0, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 2, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 2, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 2, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
            
        case 4: // 資産合計
            return cell
            
        case 5: // MARK: - 負債の部
            return cell
            
        case 6: // MARK: - "  流動負債"
            
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 3, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 3, rank1: 0, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 3, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 3, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 3, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
                
            case presenter.numberOfobjects(rank0: 3, rank1: 0) ..< presenter.numberOfobjects(rank0: 3, rank1: 0) + presenter.numberOfobjects(rank0: 3, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 3, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 3, rank1: 0)).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 3, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 3, rank1: 0)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 3, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 3, rank1: 0), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 3, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 3, rank1: 0), lastYear: true) // 勘定別の合計
                return cell
                
            default:
                return cell
            }
            
        case 7: // MARK: - "  固定負債"
            switch indexPath.row {
                // MARK: - "  長期債務"
            case 0 ..< presenter.numberOfobjects(rank0: 4, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 4, rank1: 0, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 4, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 4, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 4, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
            
        case 8: // 負債合計
            return cell
            
        case 9: // MARK: - 資本の部
            return cell
            
        case 10: // MARK: - "  元入金"
            switch indexPath.row {
                // TODO: 株主資本、評価・換算差額等　なども表示させる
                // MARK: - "  元入金"
            case 0 ..< presenter.numberOfobjects(rank0: 5, rank1: 4):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 5, rank1: 4, forRow: indexPath.row).category
                print("BS", indexPath.row, "    " + presenter.objects(rank0: 5, rank1: 4, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 5, rank1: 4, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 5, rank1: 4, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
            
        case 11: // 純資産合計
            return cell
            
        case 12: // 負債純資産合計
            return cell
            
        default:
            return cell
        }
    }
    
    private func translateSmallCategory(smallCategory: Int) -> String {
        var smallCategoryName: String
        switch smallCategory {
        case 0:
            smallCategoryName = " 当座資産"
        case 1:
            smallCategoryName = " 棚卸資産"
        case 2:
            smallCategoryName = " その他流動資産"
            
        case 3:
            smallCategoryName = " 有形固定資産"
        case 4:
            smallCategoryName = " 無形固定資産"
        case 5:
            smallCategoryName = " 投資その他資産"
            
        case 6:
            smallCategoryName = " 仕入負債" // 仕入債務
        case 7:
            smallCategoryName = " その他流動負債" // 短期借入金
            
        case 8:
            smallCategoryName = " 売上原価"
        case 9:
            smallCategoryName = " 販売費及び一般管理費"
        case 10:
            smallCategoryName = " 売上高"
        default:
            smallCategoryName = " 小分類なし"
        }
        return smallCategoryName
    }
}

extension BalanceSheetViewController: BalacneSheetPresenterOutput {
    
    func reloadData() {
        tableView.reloadData()
        // クルクルを止める
        refreshControl.endRefreshing()
    }
    
    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        setRefreshControl()
        // 印刷機能
        let printoutButton = UIBarButtonItem(
            image: UIImage(named: "picture_as_pdf-picture_as_pdf_symbol")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(pdfBarButtonItemTapped)
        )
        printoutButton.tintColor = .accentColor
        // ナビゲーションに定義したボタンを置く
        self.navigationItem.rightBarButtonItem = printoutButton
        self.navigationItem.title = "貸借対照表"
    }
    
    func setupViewForViewWillAppear() {
        // 月末、年度末などの決算日をラベルに表示する
        companyNameLabel.text = presenter.company() // 社名
        
        let theDayOfReckoning = presenter.theDayOfReckoning()
        let fiscalYear = presenter.fiscalYear()
        if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
            closingDateLabel.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
            closingDatePreviousLabel.text = "前年度\n(" + String(fiscalYear - 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
            closingDateThisYearLabel.text = "今年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
        } else {
            closingDateLabel.text = String(fiscalYear + 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
            closingDatePreviousLabel.text = "前年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
            closingDateThisYearLabel.text = "今年度\n(" + String(fiscalYear + 1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
        }
        titleLabel.text = "貸借対照表"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            if gADBannerView == nil {
                gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
                // GADBannerView プロパティを設定する
                gADBannerView.adUnitID = Constant.ADMOBID
                gADBannerView.rootViewController = self
                // 広告を読み込む
                gADBannerView.load(GADRequest())
                print("rowHeight", tableView.rowHeight)
                // GADBannerView を作成する
                addBannerViewToView(gADBannerView, constant: tableView.rowHeight * -1)
            }
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

extension BalanceSheetViewController: QLPreviewControllerDataSource {
    
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
