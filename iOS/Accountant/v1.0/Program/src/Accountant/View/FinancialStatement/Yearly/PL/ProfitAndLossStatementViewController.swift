//
//  ProfitAndLossStatementViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/10.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import QuickLook
import UIKit

// 損益計算書　個人事業主
class ProfitAndLossStatementViewController: UIViewController {
    
    // MARK: - var let
    
    var gADBannerView: GADBannerView!
    /// 損益計算書　上部
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closingDateLabel: UILabel!
    @IBOutlet var closingDatePreviousLabel: UILabel!
    @IBOutlet var closingDateThisYearLabel: UILabel!
    /// 損益計算書　下部
    @IBOutlet private var tableView: UITableView! {
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
    // グラデーションレイヤー　書類系画面
    let gradientLayer = CAGradientLayer()

    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false
    
    fileprivate let refreshControl = UIRefreshControl()
    var account = "" // 勘定名

    /// GUIアーキテクチャ　MVP
    private var presenter: ProfitAndLossStatementPresenterInput!
    func inject(presenter: ProfitAndLossStatementPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ProfitAndLossStatementPresenter.init(view: self, model: ProfitAndLossStatementModel())
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
        tableView.separatorColor = .mainColor2
    }
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
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
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Action
    
    @objc func refreshTable() {
        
        presenter.refreshTable()
    }
    
    /**
     * 印刷ボタン押下時メソッド
     */
    @objc private func pdfBarButtonItemTapped() {
        
        presenter.pdfBarButtonItemTapped()
    }
}

extension ProfitAndLossStatementViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 売上高 売上原価 販売費及び一般管理費...8
        return ProfitAndLossStatement.Block.allCases.count +
        ProfitAndLossStatement.Block.allCases.count + // 合計の分...8
        ProfitAndLossStatement.Benefits.allCases.count // 5つの利益...5
    }
    // セクションヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 35 // 売上高
        case 1:
            return 35 // 売上原価
        case 2:
            return 0 // 売上総利益
        case 3:
            return 35 // 販売費及び一般管理費
        case 4:
            return 0 // 営業利益
        case 5:
            return 35 // 営業外収益
        case 6:
            return 35 // 営業外費用
        case 7:
            return 0 // 経常利益
        case 8:
            return 35 // 特別利益
        case 9:
            return 35 // 特別損失
        case 10:
            return 0 // 税引前当期純利益
        case 11:
            return 35 // 法人税、住民税及び事業税
        case 12:
            return 0 // 当期純利益
        default:
            return 0
        }
        // セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける
    }
    // セクションフッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 35 // 売上高
        case 1:
            return 35 // 売上原価
        case 2:
            return 35 // 売上総利益
        case 3:
            return 35 // 販売費及び一般管理費
        case 4:
            return 35 // 営業利益
        case 5:
            return 35 // 営業外収益
        case 6:
            return 35 // 営業外費用
        case 7:
            return 35 // 経常利益
        case 8:
            return 35 // 特別利益
        case 9:
            return 35 // 特別損失
        case 10:
            return 35 // 税引前当期純利益
        case 11:
            return 35 // 法人税、住民税及び事業税
        case 12:
            return 35 // 当期純利益
        default:
            return 0
        }
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .paperTextColor
            header.textLabel?.textAlignment = .left
            // システムフォントのサイズを設定
            header.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        view.tintColor = UIColor.paperColor
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView = UIView()
            switch section {
            case 0:
                // 売上高
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 1:
                // 売上原価
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 2:
                // 売上総利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
            case 3:
                // 販売費及び一般管理費
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 4:
                // 営業利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
            case 5:
                // 営業外収益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 6:
                // 営業外費用
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 7:
                // 経常利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
            case 8:
                // 特別利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 9:
                // 特別損失
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 10:
                // 税引前当期純利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
            case 11:
                // 法人税、住民税及び事業税
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.2)
            case 12:
                // 当期純利益
                header.backgroundView?.backgroundColor = .bsPlAccentColor.withAlphaComponent(0.3)
            default:
                break
            }
        }
        view.tintColor = UIColor.paperColor
    }
    
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ProfitAndLossStatement.Block.sales.rawValue // 売上高
        case 1:
            return ProfitAndLossStatement.Block.costOfGoodsSold.rawValue // 売上原価
        case 2:
            return nil // 売上総利益
        case 3:
            return ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.rawValue // 販売費及び一般管理費
        case 4:
            return nil // 営業利益
        case 5:
            return ProfitAndLossStatement.Block.nonOperatingIncome.rawValue // 営業外収益
        case 6:
            return ProfitAndLossStatement.Block.nonOperatingExpenses.rawValue // 営業外費用
        case 7:
            return nil // 経常利益
        case 8:
            return ProfitAndLossStatement.Block.extraordinaryProfits.rawValue // 特別利益
        case 9:
            return ProfitAndLossStatement.Block.extraordinaryLoss.rawValue // 特別損失
        case 10:
            return nil // 税引前当期純利益
        case 11:
            return ProfitAndLossStatement.Block.incomeTaxes.rawValue // 法人税、住民税及び事業税
        case 12:
            return nil // 当期純利益
        default:
            return nil
        }
    }
    // セクションフッター
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BSTableViewHeaderFooterView.self))
        if let headerView = view as? BSTableViewHeaderFooterView {
            headerView.labelForThisYear.textColor = .paperTextColor
            headerView.labelForPrevious.textColor = .paperTextColor
            
            var footerLabelText = "" // タイトル
            var textForPrevious = "" // 前年度 前年度の会計帳簿の存在有無を確認
            var textForThisYear = "" // 今年度
            
            switch section {
            case 0:
                footerLabelText = ProfitAndLossStatement.Block.sales.getTotalAmount() // 売上高
                textForPrevious = presenter.getTotalRank0(rank0: 6, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 6, lastYear: false)
            case 1:
                footerLabelText = ProfitAndLossStatement.Block.costOfGoodsSold.getTotalAmount() // 売上原価
                textForPrevious = presenter.getTotalRank0(rank0: 7, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 7, lastYear: false)
            case 2:
                footerLabelText = ProfitAndLossStatement.Benefits.grossProfitOrLoss.rawValue // 売上総利益
                textForPrevious = presenter.getBenefitTotal(benefit: 0, lastYear: true)
                textForThisYear = presenter.getBenefitTotal(benefit: 0, lastYear: false)
            case 3:
                footerLabelText = ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.getTotalAmount() // 販売費及び一般管理費
                textForPrevious = presenter.getTotalRank0(rank0: 8, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 8, lastYear: false)
            case 4:
                footerLabelText = ProfitAndLossStatement.Benefits.otherCapitalSurplusesTotal.rawValue // 営業利益
                textForPrevious = presenter.getBenefitTotal(benefit: 1, lastYear: true)
                textForThisYear = presenter.getBenefitTotal(benefit: 1, lastYear: false)
            case 5:
                footerLabelText = ProfitAndLossStatement.Block.nonOperatingIncome.getTotalAmount() // 営業外収益
                textForPrevious = presenter.getTotalRank1(rank1: 15, lastYear: true)
                textForThisYear = presenter.getTotalRank1(rank1: 15, lastYear: false)
            case 6:
                footerLabelText = ProfitAndLossStatement.Block.nonOperatingExpenses.getTotalAmount() // 営業外費用
                textForPrevious = presenter.getTotalRank1(rank1: 16, lastYear: true)
                textForThisYear = presenter.getTotalRank1(rank1: 16, lastYear: false)
            case 7:
                footerLabelText = ProfitAndLossStatement.Benefits.ordinaryIncomeOrLoss.rawValue // 経常利益
                textForPrevious = presenter.getBenefitTotal(benefit: 2, lastYear: true)
                textForThisYear = presenter.getBenefitTotal(benefit: 2, lastYear: false)
            case 8:
                footerLabelText = ProfitAndLossStatement.Block.extraordinaryProfits.getTotalAmount() // 特別利益
                textForPrevious = presenter.getTotalRank1(rank1: 17, lastYear: true)
                textForThisYear = presenter.getTotalRank1(rank1: 17, lastYear: false)
            case 9:
                footerLabelText = ProfitAndLossStatement.Block.extraordinaryLoss.getTotalAmount() // 特別損失
                textForPrevious = presenter.getTotalRank1(rank1: 18, lastYear: true)
                textForThisYear = presenter.getTotalRank1(rank1: 18, lastYear: false)
            case 10:
                footerLabelText = ProfitAndLossStatement.Benefits.incomeOrLossBeforeIncomeTaxes.rawValue // 税引前当期純利益
                textForPrevious = presenter.getBenefitTotal(benefit: 3, lastYear: true)
                textForThisYear = presenter.getBenefitTotal(benefit: 3, lastYear: false)
            case 11:
                footerLabelText = ProfitAndLossStatement.Block.incomeTaxes.getTotalAmount() // 法人税、住民税及び事業税
                textForPrevious = presenter.getTotalRank0(rank0: 11, lastYear: true)
                textForThisYear = presenter.getTotalRank0(rank0: 11, lastYear: false)
            case 12:
                footerLabelText = ProfitAndLossStatement.Benefits.netIncomeOrLoss.rawValue // 当期純利益
                textForPrevious = presenter.getBenefitTotal(benefit: 4, lastYear: true)
                textForThisYear = presenter.getBenefitTotal(benefit: 4, lastYear: false)
            default:
                break
            }
            
            // タイトル
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 16)
            headerView.textLabel?.minimumScaleFactor = 0.05
            headerView.textLabel?.adjustsFontSizeToFitWidth = true
            headerView.textLabel?.textColor = .paperTextColor
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
        case 0:
            // 売上高
            return presenter.numberOfobjects(rank0: 6, rank1: 0)
        case 1:
            // 売上原価
            return presenter.numberOfobjects(rank0: 7, rank1: 0) +
            presenter.numberOfobjects(rank0: 7, rank1: 1)
        case 2:
            return 0 // 売上総利益
        case 3:
            // 販売費及び一般管理費
            return presenter.numberOfobjects(rank0: 8, rank1: 0)
        case 4:
            return 0 // 営業利益
        case 5:
            // 営業外収益
            return presenter.numberOfobjects(rank0: 9, rank1: 0)
        case 6:
            // 営業外費用
            return presenter.numberOfobjects(rank0: 9, rank1: 1)
        case 7:
            return 0 // 経常利益
        case 8:
            // 特別利益
            return presenter.numberOfobjects(rank0: 10, rank1: 0)
        case 9:
            // 特別損失
            return presenter.numberOfobjects(rank0: 10, rank1: 1)
        case 10:
            return 0 // 税引前当期純利益
        case 11:
            // 法人税、住民税及び事業税
            return presenter.numberOfobjects(rank0: 11, rank1: 0)
        case 12:
            return 0 // 当期純利益
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as? BSTableViewCell else { 
            return UITableViewCell()
        }
        // タイトル
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.minimumScaleFactor = 0.05
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        // 今年度
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForThisYear.text = nil
        cell.labelForThisYear.textAlignment = .right
        // 前年度
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.attributedText = nil
        cell.labelForPrevious.text = nil
        cell.labelForPrevious.textAlignment = .right
        
        switch indexPath.section {
        case 0:
            // 売上高
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 6, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 6, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 6, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 6, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 6, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 1:
            // 売上原価
            switch indexPath.row {
                // 売上原価
            case 0 ..< presenter.numberOfobjects(rank0: 7, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 7, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 7, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 7, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 7, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
                // 製造原価
            case presenter.numberOfobjects(rank0: 7, rank1: 0) ..< presenter.numberOfobjects(rank0: 7, rank1: 0) + presenter.numberOfobjects(rank0: 7, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0)).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0)).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0), lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0), lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 2:
            return cell // 売上総利益
        case 3:
            // 販売費及び一般管理費
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 8, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 8, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 8, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 8, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 8, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 4:
            return cell // 営業利益
        case 5:
            // 営業外収益
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 9, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 9, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 9, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 9, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 9, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 6:
            // 営業外費用
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 9, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 9, rank1: 1, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 9, rank1: 1, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 9, rank1: 1, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 9, rank1: 1, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 7:
            return cell // 経常利益
        case 8:
            // 特別利益
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 10, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 10, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 10, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 10, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 10, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 9:
            // 特別損失
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 10, rank1: 1):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 10, rank1: 1, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 10, rank1: 1, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 10, rank1: 1, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 10, rank1: 1, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 10:
            return cell // 税引前当期純利益
        case 11:
            // 法人税、住民税及び事業税
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 11, rank1: 0):
                // 勘定科目
                cell.textLabel?.text = "    " + presenter.objects(rank0: 11, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 11, rank1: 0, forRow: indexPath.row).category)
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomyAccount(rank0: 11, rank1: 0, forRow: indexPath.row, lastYear: false) // 勘定別の合計
                cell.labelForPrevious.text = presenter.getTotalOfTaxonomyAccount(rank0: 11, rank1: 0, forRow: indexPath.row, lastYear: true) // 勘定別の合計
                return cell
            default:
                return cell
            }
        case 12:
            return cell // 当期純利益
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // 売上高
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 6, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 6, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 6, rank1: 0, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 1:
            // 売上原価
            switch indexPath.row {
                // 売上原価
            case 0 ..< presenter.numberOfobjects(rank0: 7, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 7, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 7, rank1: 0, forRow: indexPath.row).category)
                break
                // 製造原価
            case presenter.numberOfobjects(rank0: 7, rank1: 0) ..< presenter.numberOfobjects(rank0: 7, rank1: 0) + presenter.numberOfobjects(rank0: 7, rank1: 1):
                // 勘定科目
                account = presenter.objects(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0)).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 7, rank1: 1, forRow: indexPath.row - presenter.numberOfobjects(rank0: 7, rank1: 0)).category)
                break
            default:
                break
            }
        case 2:
            break // 売上総利益
        case 3:
            // 販売費及び一般管理費
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 8, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 8, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 8, rank1: 0, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 4:
            break // 営業利益
        case 5:
            // 営業外収益
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 9, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 9, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 9, rank1: 0, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 6:
            // 営業外費用
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 9, rank1: 1):
                // 勘定科目
                account = presenter.objects(rank0: 9, rank1: 1, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 9, rank1: 1, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 7:
            break // 経常利益
        case 8:
            // 特別利益
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 10, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 10, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 10, rank1: 0, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 9:
            // 特別損失
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 10, rank1: 1):
                // 勘定科目
                account = presenter.objects(rank0: 10, rank1: 1, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 10, rank1: 1, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 10:
            break // 税引前当期純利益
        case 11:
            // 法人税、住民税及び事業税
            switch indexPath.row {
            case 0 ..< presenter.numberOfobjects(rank0: 11, rank1: 0):
                // 勘定科目
                account = presenter.objects(rank0: 11, rank1: 0, forRow: indexPath.row).category
                print("PL", indexPath.row, "    " + presenter.objects(rank0: 11, rank1: 0, forRow: indexPath.row).category)
                break
            default:
                break
            }
        case 12:
            break // 当期純利益
        default:
            break
        }
        
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: "GeneralLedgerAccountViewController",
                bundle: nil
            ).instantiateViewController(
                withIdentifier: "GeneralLedgerAccountViewController"
            ) as? GeneralLedgerAccountViewController {
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                // 遷移先のコントローラに値を渡す
                viewController.account = self.account // セルに表示した勘定名を取得
                self.present(navigation, animated: true, completion: nil)
            }
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfitAndLossStatementViewController: ProfitAndLossStatementPresenterOutput {
    
    func reloadData() {
        // 更新処理
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
        self.navigationController?.navigationBar.tintColor = .accentColor
        self.navigationItem.title = "財務諸表"
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
        titleLabel.text = "損益計算書"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
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

extension ProfitAndLossStatementViewController: QLPreviewControllerDataSource {
    
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
