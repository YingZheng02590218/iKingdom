//
//  BSViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/28.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import QuickLook
import GoogleMobileAds // マネタイズ対応
import AudioToolbox // 効果音

class BSViewController: UIViewController {

    // MARK: - var let

    @IBOutlet var gADBannerView: GADBannerView!
    /// 貸借対照表　上部
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var label_closingDate_previous: UILabel!
    @IBOutlet var label_closingDate_thisYear: UILabel!
    /// 貸借対照表　下部
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
//    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
//    let edged = false

    fileprivate let refreshControl = UIRefreshControl()
    
    /// GUIアーキテクチャ　MVP
    private var presenter: BSPresenterInput!
    func inject(presenter: BSPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = BSPresenter.init(view: self, model: BSModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        tableView.register(UINib(nibName: "BSTableViewCell", bundle: nil), forCellReuseIdentifier: "BSTableViewCell")
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
    
    var printing: Bool = false { // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
        didSet(oldValue){
            if !(oldValue) {
//                if self.overrideUserInterfaceStyle != .light  {
//                    // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
//                    tableView.overrideUserInterfaceStyle = .light
//                }
//            }else {
//                // ダークモード回避を解除
//                tableView.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    /**
     * 印刷ボタン押下時メソッド
     */
    @objc private func pdfBarButtonItemTapped() {
        
        presenter.pdfBarButtonItemTapped()
    }

}

extension BSViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、純資産の部
        return 3
    }
    // セクションヘッダーの高さを決める
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .textColor
        header.textLabel?.textAlignment = .left
        // システムフォントのサイズを設定
        header.textLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            // 大分類のタイトルはセクションヘッダーに表示する
        case 0://資産の部
            print("資産の部", 1 + 6 + 3 +
                  presenter.numberOfobjects0100 +
                  presenter.numberOfobjects0102 +
                  presenter.numberOfobjects010142 +
                  presenter.numberOfobjects010143 +
                  presenter.numberOfobjects010144 )
            return 1 + 6 + 3 +
            presenter.numberOfobjects0100 +
            presenter.numberOfobjects0102 +
            presenter.numberOfobjects010142 +
            presenter.numberOfobjects010143 +
            presenter.numberOfobjects010144 // 大分類合計1・中分類(タイトル、合計)6・小分類(タイトル、合計)6・表示科目の数
        case 1://負債の部
            print("負債の部", 1 + 4 +
                  presenter.numberOfobjects0114 +
                  presenter.numberOfobjects0115 )
            return 1 + 4 +
            presenter.numberOfobjects0114 +
            presenter.numberOfobjects0115
        case 2://純資産の部
            print("純資産の部", 1 + 4 + 0 +
                  presenter.numberOfobjects0129 +
                  presenter.numberOfobjects01210 +
                  presenter.numberOfobjects01211 +
                  presenter.numberOfobjects01213 + 1)
            return 1 + 4 + 0 +
            presenter.numberOfobjects0129 +
            presenter.numberOfobjects01210 +
            presenter.numberOfobjects01211 +
            presenter.numberOfobjects01213 + 1 //+1は、負債純資産合計　の分
        default:
            print("default")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as! BSTableViewCell
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForPrevious.attributedText = nil
        
        switch indexPath.section { // 大区分
        case 0: // MARK: - 資産の部
            
            switch indexPath.row { // 中区分
            case 0:
                // MARK: - "  流動資産"
                cell.textLabel?.text = "  流動資産" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                print("BS", indexPath.row, "  流動資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1: // 中区分タイトルの分を1行追加　流動資産に属する勘定科目の数
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    流動資産合計"
                cell.textLabel?.text = "    流動資産合計"
                print("BS", indexPath.row, "    流動資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: true)
                }else {
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
                return cell
            case presenter.numberOfobjects0100 + 1 + 1:
                // MARK: - "  固定資産"
                cell.textLabel?.text = "  固定資産"
                print("BS", indexPath.row, "  固定資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
// 小区分
                // MARK: - 有形固定資産3
            case presenter.numberOfobjects0100 + 1 + 1 + 1: // 112
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 3)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 3)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
                // MARK: - 無形固定資産
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1:
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 4)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 4)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
                // MARK: - 投資その他資産　投資その他の資産
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1:
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 5)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 5)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1: //最後の行の前
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    固定資産合計"
                cell.textLabel?.text = "    固定資産合計"
                print("BS", indexPath.row, "    固定資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: true)
                }else {
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
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1:
                // MARK: - "  繰越資産"
                cell.textLabel?.text = "  繰越資産"
                print("BS", indexPath.row, "  繰越資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1 + presenter.numberOfobjects0102 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    繰越資産合計"
                cell.textLabel?.text = "    繰越資産合計"
                print("BS", indexPath.row, "    繰越資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: true)
                }else {
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
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1 + presenter.numberOfobjects0102 + 1 + 1: //最後の行
                // MARK: - "資産合計"
                cell.textLabel?.text = "資産合計"
                print("BS", indexPath.row, "資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 0, lastYear: false)
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
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 0, lastYear: true)
                }else {
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
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if presenter.getTotalBig5(big5: 0, lastYear: false) != presenter.getTotalBig5(big5: 3, lastYear: false) {
                    cell.labelForThisYear.textColor = .red
                }else {
                    
                }
                return cell
            default:
// 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                           // 流動資産タイトルの1行下 中区分タイトルより下の行から、中区分合計の行より上
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 {   // 流動資産合計　　　　中区分タイトル + 流動資産 + 合計
                    cell.textLabel?.text = "        "+presenter.objects0100(forRow: indexPath.row-(1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0100(forRow: indexPath.row-(1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0100(forRow: indexPath.row-(1 )).number, lastYear: false) // 勘定別の合計　計算
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0100(forRow: indexPath.row-(1 )).number, lastYear: true) // 勘定別の合計　計算
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + 1 &&  // 有形固定資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 { // 無形固定資産
                    cell.textLabel?.text = "        "+presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1 && // 無形固定資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 { // 投資その他資産
                    cell.textLabel?.text = "        "+presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1 && // 投資その他資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 { // 固定資産合計
                    cell.textLabel?.text = "        "+presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1 && // 繰延資産タイトルの1行下
                            indexPath.row < presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + presenter.numberOfobjects0102 + 1 { // 繰延資産合計
                    cell.textLabel?.text = "        "+presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else {
                    cell.textLabel?.text = "default"
                    print("BS", indexPath.row, "default")
                    cell.labelForThisYear.text = "default"
                    cell.labelForThisYear.textAlignment = .right
                }
                return cell
            }
        case 1: // MARK: - 負債の部
            switch indexPath.row {
            case 0:
                // MARK: - "  流動負債"
                cell.textLabel?.text = "  流動負債"
                print("BS", indexPath.row, "  流動負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0114 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    流動負債合計"
                cell.textLabel?.text = "    流動負債合計"
                print("BS", indexPath.row, "    流動負債合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: true)
                }else {
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
                return cell
            case presenter.numberOfobjects0114 + 1 + 1: // 中分類名の分を1行追加 合計の行を追加
                // MARK: - "  固定負債"
                cell.textLabel?.text = "  固定負債"
                print("BS", indexPath.row, "  固定負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1: //最後の行の前 22
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    固定負債合計"
                cell.textLabel?.text = "    固定負債合計"
                print("BS", indexPath.row, "    固定負債合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: true)
                }else {
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
                return cell
            case presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1 + 1: //最後の行
                // MARK: - "負債合計"
                cell.textLabel?.text = "負債合計"
                print("BS", indexPath.row, "負債合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 1, lastYear: false)
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
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 1, lastYear: true)
                }else {
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
            default:
                // 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                     // 流動負債タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0114 + 1 {  // 流動負債合計 中区分のタイトルより下の行から、中区分合計の行より上
                    cell.textLabel?.text = "        "+presenter.objects0114(forRow: indexPath.row-(1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0114(forRow: indexPath.row-(1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0114(forRow: indexPath.row-(1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0114(forRow: indexPath.row-(1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0114 + 1 + 1 + 1 && // 固定負債タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1 { // 固定負債合計
                    cell.textLabel?.text = "        "+presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).category
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else {
                    cell.textLabel?.text = "default"
                    print("BS", indexPath.row, "default")
                    cell.labelForThisYear.text = "default"
                    cell.labelForThisYear.textAlignment = .right
                }
                return cell
            }
        case 2: // MARK: - 純資産の部
// 中区分
            switch indexPath.row {
            case 0:
                // MARK: - "  株主資本"
                cell.textLabel?.text = "  株主資本"
                print("BS", indexPath.row, "  株主資本"+"★")
                //                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0129 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    株主資本合計"
                cell.textLabel?.text = "    株主資本合計"
                print("BS", indexPath.row, "    株主資本合計"+"★")
                let text:String = presenter.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: true) // 中区分の合計を取得
                }else {
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
                return cell
            case presenter.numberOfobjects0129 + 2: // 中分類名の分を1行追加 合計の行を追加
                // MARK: - "  その他の包括利益累計額"
                cell.textLabel?.text = "  その他の包括利益累計額"
                print("BS", indexPath.row, "  その他の包括利益累計額"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    その他の包括利益累計額合計"
                cell.textLabel?.text = "    その他の包括利益累計額合計"
                print("BS", indexPath.row, "    その他の包括利益累計額合計"+"★")
                let text:String = presenter.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: true) // 中区分の合計を取得
                }else {
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
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1: //新株予約権16
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < presenter.numberOfobjects01211 else { //新株予約権16 が0件の場合
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    cell.textLabel?.minimumScaleFactor = 0.05
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    
                    // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/08/03
                    guard 0 < presenter.numberOfobjects01213 else { //非支配株主持分22 が0件の場合
                        // MARK: - "純資産合計"
                        cell.textLabel?.text = "純資産合計"
                        print("BS", indexPath.row, "純資産合計"+"★")
                        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                        let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
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
                        var textt:String = ""
                        if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                        }else {
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
                    } // 1. array.count（要素数）を利用する
                    
                    cell.textLabel?.text = "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category
                    print("BS", indexPath.row, "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category)

                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    return cell
                }
                cell.textLabel?.text = "  "+presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).category
                print("BS", indexPath.row, "  "+presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).category)

                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).number, lastYear: false)
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForThisYear.textAlignment = .right
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211: //非支配株主持分22
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < presenter.numberOfobjects01213 else {
                    // MARK: - "純資産合計"
                    cell.textLabel?.text = "純資産合計"
                    print("BS", indexPath.row, "純資産合計"+"★")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                    let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
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
                    var textt:String = ""
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                    }else {
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
                } // 1. array.count（要素数）を利用する
                cell.textLabel?.text = "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category
                print("BS", indexPath.row, "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category)
                
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: false)
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForThisYear.textAlignment = .right
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211 + presenter.numberOfobjects01213: //最後の行
                // MARK: - "純資産合計"
                cell.textLabel?.text = "純資産合計"
                print("BS", indexPath.row, "純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
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
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                }else {
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
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211 + presenter.numberOfobjects01213 + 1: //最後の行の下
                // MARK: - "負債純資産合計"
                cell.textLabel?.text = "負債純資産合計"
                print("BS", indexPath.row, "負債純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 3, lastYear: false)
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
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 3, lastYear: true)
                }else {
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
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if presenter.getTotalBig5(big5: 0, lastYear: false) != presenter.getTotalBig5(big5: 3, lastYear: false) {
                    cell.labelForThisYear.textColor = .red
                }else {
                    
                }
                return cell
            default:
                // 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                       // 株主資本
                            indexPath.row <  presenter.numberOfobjects0129 + 1 {      // 株主資本合計
                    cell.textLabel?.text = "        "+presenter.objects0129(forRow: indexPath.row-1).category
                    print("BS", indexPath.row, "        "+presenter.objects0129(forRow: indexPath.row-1).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0129(forRow: indexPath.row-1).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0129(forRow: indexPath.row-1).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }else if indexPath.row >= presenter.numberOfobjects0129 + 2 + 1 &&                     //その他の包括利益累計額
                            indexPath.row <   presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 {    //その他の包括利益累計額合計
                    cell.textLabel?.text = "        "+presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }else {
                    print("??")
                    let soundIdRing: SystemSoundID = 1000 //鐘
                    AudioServicesPlaySystemSound(soundIdRing)
                }
                return cell
            }
        default:
            return cell
        }
    }

    private func translateSmallCategory(small_category: Int) -> String {
        var small_category_name: String
        switch small_category {
        case 0:
            small_category_name = " 当座資産"
            break
        case 1:
            small_category_name = " 棚卸資産"
            break
        case 2:
            small_category_name = " その他流動資産"
            break
            
            
            
        case 3:
            small_category_name = " 有形固定資産"
            break
        case 4:
            small_category_name = " 無形固定資産"
            break
        case 5:
            small_category_name = " 投資その他資産"
            break
            
            
            
        case 6:
            small_category_name = " 仕入負債" // 仕入債務
            break
        case 7:
            small_category_name = " その他流動負債" // 短期借入金
            break
            
            
            
        case 8:
            small_category_name = " 売上原価"
            break
        case 9:
            small_category_name = " 販売費及び一般管理費"
            break
        case 10:
            small_category_name = " 売上高"
            break
        default:
            small_category_name = " 小分類なし"
            break
        }
        return small_category_name
    }
}

extension BSViewController: BSPresenterOutput {
    
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
        let printoutButton = UIBarButtonItem(image: UIImage(named: "picture_as_pdf-picture_as_pdf_symbol")!.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(pdfBarButtonItemTapped))
        printoutButton.tintColor = .accentColor
        //ナビゲーションに定義したボタンを置く
        self.navigationItem.rightBarButtonItem = printoutButton
        self.navigationItem.title = "貸借対照表"
    }
    
    func setupViewForViewWillAppear() {
        // 月末、年度末などの決算日をラベルに表示する
        label_company_name.text = presenter.company() // 社名
        
        let theDayOfReckoning = presenter.theDayOfReckoning()
        let fiscalYear = presenter.fiscalYear()
        if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
            label_closingDate.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
            label_closingDate_previous.text = "前年度\n(" + String(fiscalYear-1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
            label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
        }
        else {
            label_closingDate.text = String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
            label_closingDate_previous.text = "前年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
            label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
        }
        label_title.text = "貸借対照表"
        label_title.font = UIFont.boldSystemFont(ofSize: 21)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            if gADBannerView == nil {
                gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
                // GADBannerView プロパティを設定する
                gADBannerView.adUnitID = Constant.ADMOB_ID
                
                gADBannerView.rootViewController = self
                // 広告を読み込む
                gADBannerView.load(GADRequest())
                print("rowHeight", tableView.rowHeight)
                // GADBannerView を作成する
                addBannerViewToView(gADBannerView, constant: tableView.rowHeight * -1)
            }
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
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

 extension BSViewController: QLPreviewControllerDataSource {
     
     func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
         
         if let PDFpath = presenter.PDFpath {
             return PDFpath.count
         }
         else {
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
