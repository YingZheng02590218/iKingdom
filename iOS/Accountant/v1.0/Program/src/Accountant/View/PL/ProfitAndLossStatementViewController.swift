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

    let LIGHTSHADOWOPACITY: Float = 0.5
    //    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    //    let edged = false

    fileprivate let refreshControl = UIRefreshControl()

    /// GUIアーキテクチャ　MVP
    private var presenter: PLPresenterInput!
    func inject(presenter: PLPresenterInput) {
        self.presenter = presenter
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PLPresenter.init(view: self, model: PLModel())
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
            backgroundView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
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

        return 5 + // 合計の分
        ProfitAndLossStatement.Block.allCases.count + // 売上高 売上原価 販売費及び一般管理費...
        ProfitAndLossStatement.Benefits.allCases.count // 5つの利益
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 5:五大利益(+2 非支配株主に帰属する当期純利益,親会社株主に帰属する当期純利益)　8:小分類のタイトル　5:小分類の合計
        return 5 + 8 + 5 +
        presenter.numberOfmidCategory10 +
        presenter.numberOfobjects9 +
        presenter.numberOfmidCategory6 +
        presenter.numberOfmidCategory11 +
        presenter.numberOfmidCategory7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as? BSTableViewCell else { return UITableViewCell() }
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForPrevious.attributedText = nil
        // TODO: Model へ移動
        let han =           3 + presenter.numberOfobjects9 + 1 // 販売費及び一般管理費合計
        let ei =            3 + presenter.numberOfobjects9 + 2 // 営業利益
        let eigai =         3 + presenter.numberOfobjects9 + 3 // 営業外収益10
        let eigaiTotal =    3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + 4 // 営業外収益合計
        let eigaih =        3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + 5 // 営業外費用6
        let eigaihTotal =   3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + 6 // 営業外費用合計
        let kei =           3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + 7 // 経常利益
        let toku =          3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + 8 // 特別利益11
        let tokuTotal =     3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + 9 // 特別利益合計
        let tokus =         3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + 10 // 特別損失7
        let tokusTotal =    3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 11 // 特別損失合計
        let zei =           3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 12 // 税金等調整前当期純利益
        let zeikin =        3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 13 // 法人税等8
        let touki =         3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 14 // 当期純利益
        //        let htouki =        3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 15 // 非支配株主に帰属する当期純利益
        //        let otouki =        3 + presenter.numberOfobjects9 + presenter.numberOfmidCategory10 + presenter.numberOfmidCategory6 + presenter.numberOfmidCategory11 + presenter.numberOfmidCategory7 + 16 // 親会社株主に帰属する当期純利益

        switch indexPath.row {
        case 0: // 売上高10
            cell.textLabel?.text = "売上高"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            cell.labelForThisYear.text = presenter.getTotalRank0(big5: 4, rank0: 6, lastYear: false)
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = presenter.getTotalRank0(big5: 4, rank0: 6, lastYear: true)
            } else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case 1: // 売上原価8
            cell.textLabel?.text = "売上原価"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            cell.labelForThisYear.text = presenter.getTotalRank0(big5: 3, rank0: 7, lastYear: false)
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = presenter.getTotalRank0(big5: 3, rank0: 7, lastYear: true)
            } else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case 2: // 売上総利益
            cell.textLabel?.text = "売上総利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getBenefitTotal(benefit: 0, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 0, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        case 3: // 販売費及び一般管理費9
            cell.textLabel?.text = "販売費及び一般管理費"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case han: // 販売費及び一般管理費合計
            cell.textLabel?.text = "販売費及び一般管理費合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank0(big5: 3, rank0: 8, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank0(big5: 3, rank0: 8, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case ei: // 営業利益
            cell.textLabel?.text = "営業利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getBenefitTotal(benefit: 1, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 1, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        case eigai: // 営業外収益10
            cell.textLabel?.text = "営業外収益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case eigaiTotal: // 営業外収益合計
            cell.textLabel?.text = "営業外収益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank1(big5: 4, rank1: 15, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 4, rank1: 15, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case eigaih: // 営業外費用6
            cell.textLabel?.text = "営業外費用"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case eigaihTotal: // 営業外費用合計
            cell.textLabel?.text = "営業外費用合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank1(big5: 3, rank1: 16, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 3, rank1: 16, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case kei: // 経常利益
            cell.textLabel?.text = "経常利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getBenefitTotal(benefit: 2, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 2, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        case toku: // 特別利益11
            cell.textLabel?.text = "特別利益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case tokuTotal: // 特別利益合計
            cell.textLabel?.text = "特別利益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank1(big5: 4, rank1: 17, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 4, rank1: 17, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case tokus: // 特別損失7
            cell.textLabel?.text = "特別損失"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case tokusTotal: // 特別損失合計
            cell.textLabel?.text = "特別損失合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank1(big5: 3, rank1: 18, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 3, rank1: 18, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case zei: // 税金等調整前当期純利益
            cell.textLabel?.text = "税金等調整前当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getBenefitTotal(benefit: 3, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 3, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        case zeikin: // 税等8
            cell.textLabel?.text = "法人税等"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getTotalRank0(big5: 3, rank0: 11, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank0(big5: 3, rank0: 11, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case touki: // 当期純利益
            cell.textLabel?.text = "当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            // ラベルを置いて金額を表示する
            let text: String = presenter.getBenefitTotal(benefit: 4, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            var textt: String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 4, lastYear: true)
            } else {
                textt = "-"
            }
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeTextt = NSMutableAttributedString(string: textt)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeTextt.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, textt.count)
            )
            cell.labelForPrevious.attributedText = attributeTextt
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
            //        case htouki: //非支配株主に帰属する当期純利益
            //            cell.textLabel?.text = "非支配株主に帰属する当期純利益"
            //            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //            // ラベルを置いて金額を表示する
            //            cell.labelForThisYear.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            //            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            //            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            //                cell.labelForPrevious.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            //            } else {
            //                cell.labelForPrevious.text = "-"
            //            }
            //            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            //            return cell
            //        case otouki: //親会社株主に帰属する当期純利益
            //            cell.textLabel?.text = "親会社株主に帰属する当期純利益"
            //            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //            // ラベルを置いて金額を表示する
            //            cell.labelForThisYear.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            //            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            //            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
            //                cell.labelForPrevious.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            //            } else {
            //                cell.labelForPrevious.text = "-"
            //            }
            //            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            //            return cell
        default:
            // 勘定科目
            if       indexPath.row > 3 &&                // 販売費及び一般管理費9
                        indexPath.row < han {                // 販売費及び一般管理費合計　タイトルより下の行から、合計の行より上
                cell.textLabel?.text = "    " + presenter.objects9(forRow: indexPath.row - (3 + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                // ラベルを置いて金額を表示する
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(
                    numberOfSettingsTaxonomy: presenter.objects9(
                        forRow: indexPath.row - (3 + 1)
                    ).number,
                    lastYear: false
                ) // BSAndPL_category を number に変更する 2020/09/17
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects9(forRow: indexPath.row - (3 + 1)).number, lastYear: true)
                } else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            } else if indexPath.row > eigai &&             // 営業外収益10
                        indexPath.row < eigaiTotal {          // 営業外収益合計
                cell.textLabel?.text = "    " + presenter.midCategory10(forRow: indexPath.row - (eigai + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                // ラベルを置いて金額を表示する
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.midCategory10(forRow: indexPath.row - (eigai + 1)).number, lastYear: false) // 収益:4
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.midCategory10(forRow: indexPath.row - (eigai + 1)).number, lastYear: true) // 収益:4
                } else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            } else if indexPath.row > eigaih &&          // 営業外費用
                        indexPath.row < eigaihTotal {      // 営業外費用合計
                cell.textLabel?.text = "    " + presenter.midCategory6(forRow: indexPath.row - (eigaih + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                // ラベルを置いて金額を表示する
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.midCategory6(forRow: indexPath.row - (eigaih + 1)).number, lastYear: false)
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.midCategory6(forRow: indexPath.row - (eigaih + 1)).number, lastYear: true)
                } else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            } else if indexPath.row > toku &&                       // 特別利益
                        indexPath.row < tokuTotal {                   // 特別利益合計
                cell.textLabel?.text = "    " + presenter.mid_category11(forRow: indexPath.row - (toku + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                // ラベルを置いて金額を表示する
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category11(forRow: indexPath.row - (toku + 1)).number, lastYear: false) // 収益:4
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category11(forRow: indexPath.row - (toku + 1)).number, lastYear: true) // 収益:4
                } else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            } else if indexPath.row > tokus &&                   // 特別損失
                        indexPath.row < tokusTotal {               // 特別損失合計
                cell.textLabel?.text = "    " + presenter.mid_category7(forRow: indexPath.row - (tokus + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                // ラベルを置いて金額を表示する
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category7(forRow: indexPath.row - (tokus + 1)).number, lastYear: false)
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category7(forRow: indexPath.row - (tokus + 1)).number, lastYear: true)
                } else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
                // 税金　勘定科目を表示する必要はない
                // 法人税、住民税及び事業税
                // 法人税等調整額
            } else {
                return cell
            }
        }
    }
}

extension ProfitAndLossStatementViewController: PLPresenterOutput {

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
        self.navigationItem.title = "損益計算書"
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
            print(tableView.rowHeight)
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
