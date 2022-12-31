//
//  SettingsCategoryDetailTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 勘定科目詳細クラス
class SettingsCategoryDetailTableViewController: UITableViewController {
    
    // 入力ボタン
    @IBOutlet private var inputButton: EMTNeumorphicButton! // 入力ボタン
    
    var gADBannerView: GADBannerView!
    
    // MARK: - var let
    
    var big = ""
    var mid = ""
    var small = ""
    var accountname = ""
    var taxonomyname = ""
    var bigNum = ""
    var midNum = ""
    var smallNum = ""
    
    var numberOfAccount: Int = 0 // 勘定科目番号
    var numberOfTaxonomy: Int = 0 // 表示科目番号
    
    var addAccount = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue
    // 画面遷移の準備　表示科目一覧画面へ
    var tappedIndexPath: IndexPath?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .accentColor
        
        // 登録ボタンの　表示　非表示
        if addAccount {
            inputButton.isHidden = false
            inputButton.isEnabled = true
        } else {
            inputButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 表示科目を変更後に勘定科目詳細画面を更新する
        tableView.reloadData()
        // テキストフィールドを初期化
        if addAccount { // 勘定科目追加の場合
            createTextFieldForCategory()
        }
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
            addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count - 1].frame.height * -1)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        // ボタン作成
        createButtons()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 大区分
            // 中区分
            // 小区分 コメントアウト
            // 勘定科目名
            return 3 // 4
        } else {
            // 表示科目
            return 1
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "勘定科目"
        case 1:
            return "表示科目"
        default:
            return ""
        }
    }
    // セクションフッターのテキスト決める
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "勘定科目を、決算書上に表記される表示科目に紐付けてください。"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? SettingAccountDetailTaxonomyTableViewCell else { return UITableViewCell() }
        cell.accessoryType = .none
        cell.label.text = "-"
        // セルの選択不可にする
        cell.selectionStyle = .none
        // 新規で設定勘定科目を追加する場合　addButtonを押下
        if addAccount { // 新規追加
            if indexPath.section == 0 { // 勘定科目
                switch indexPath.row {
                case 0:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as? SettingAccountDetailTableViewCell else { return UITableViewCell() }
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                    return cell
                case 1:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as? SettingAccountDetailTableViewCell else { return UITableViewCell() }
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "中区分"
                    return cell
                case 2:
                    //                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category", for: indexPath) as? SettingAccountDetailTableViewCell else { return UITableViewCell() }
                    //                    // セルの選択
                    //                    cell.selectionStyle = .none
                    //                    cell.textLabel?.textColor = .darkGray
                    //                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    //                    cell.textLabel?.text = "小区分"
                    //                    return cell
                    //                case 3:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_Account", for: indexPath) as? SettingAccountDetailAccountTableViewCell else { return UITableViewCell() }
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    return cell
                default:
                    return cell
                }
            } else { // タクソノミ　表示科目
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? SettingAccountDetailTaxonomyTableViewCell else { return UITableViewCell() }
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目名
                //                let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SettingAccountDetailTaxonomyTableViewCell else { return UITableViewCell() }
                if self.numberOfTaxonomy != 0 {
                    //                    taxonomyname = cell_taxonomy.label.text!
                    //                    cell.label.text = taxonomyname
                    let object = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
                    cell.label.text! = "\(object!.number), \(object!.category)"
                } else {
                    cell.label.text = "表示科目を選択してください"
                    cell.label.textColor = .lightGray
                }
                // Accessory Color
                let disclosureImage = UIImage(named: "navigate_next")!.withRenderingMode(.alwaysTemplate)
                let disclosureView = UIImageView(image: disclosureImage)
                disclosureView.tintColor = UIColor.accentColor
                cell.accessoryView = disclosureView
                
                return cell
            }
        } else { // 新規追加　以外
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? SettingAccountDetailTaxonomyTableViewCell else { return UITableViewCell() }
            cell.accessoryType = .none
            // セルの選択
            cell.selectionStyle = .none
            // 勘定科目の連番から勘定科目を取得　紐づけた表示科目の連番を知るため
            let object = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: numberOfAccount) // 勘定科目
            cell.label.text = "-"
            if indexPath.section == 0 { // 勘定科目
                switch indexPath.row {
                case 0:
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object?.Rank0 {
                    case "0": cell.label.text = "流動資産"
                    case "1": cell.label.text = "固定資産"
                    case "2": cell.label.text = "繰延資産"
                    case "3": cell.label.text = "流動負債"
                    case "4": cell.label.text = "固定負債"
                    case "5": cell.label.text = "資本"
                    case "6": cell.label.text = "売上"
                    case "7": cell.label.text = "売上原価"
                    case "8": cell.label.text = "販売費及び一般管理費"
                    case "9": cell.label.text = "営業外損益"
                    case "10": cell.label.text = "特別損益"
                    case "11": cell.label.text = "税金"
                    default: cell.label.text = "-"
                    }
                case 1:
                    cell.textLabel?.text = "中区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object?.Rank1 {
                    case "0": cell.label.text = "当座資産"
                    case "1": cell.label.text = "棚卸資産"
                    case "2": cell.label.text = "その他の流動資産"
                    case "3": cell.label.text = "有形固定資産"
                    case "4": cell.label.text = "無形固定資産"
                    case "5": cell.label.text = "投資その他の資産"
                    case "6": cell.label.text = "繰延資産"
                    case "7": cell.label.text = "仕入債務"
                    case "8": cell.label.text = "その他の流動負債"
                    case "9": cell.label.text = "長期債務"
                    case "10": cell.label.text = "株主資本"
                    case "11": cell.label.text = "評価・換算差額等"
                    case "12": cell.label.text = "新株予約権"
                    case "13": cell.label.text = "売上原価"
                    case "14": cell.label.text = "製造原価"
                    case "15": cell.label.text = "営業外収益"
                    case "16": cell.label.text = "営業外費用"
                    case "17": cell.label.text = "特別利益"
                    case "18": cell.label.text = "特別損失"
                    default: cell.label.text = "-"
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                case 2:
                    //                    cell.textLabel?.text = "小区分"
                    //                    cell.textLabel?.textColor = .darkGray
                    //                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    //                    cell.label.textAlignment = NSTextAlignment.center
                    //                    break
                    //                case 3: // 勘定科目
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目
                    if object!.category != "" {
                        cell.label.text = object!.category
                    } else {
                        cell.label.text = ""
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                default:
                    break
                }
            } else { // タクソノミ　表示科目
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目の連番から表示科目を取得　勘定科目の詳細情報を得るため
                if object?.numberOfTaxonomy != "" {
                    let objectt = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: Int(object!.numberOfTaxonomy)!) // 表示科目
                    cell.label.text = "\(objectt!.number), \(objectt!.category)"
                } else {
                    cell.label.text = ""
                }
                cell.label.textAlignment = NSTextAlignment.center
            }
            return cell
        }
    }
    
    // ボタンのデザインを指定する
    private func createButtons() {
        inputButton.setTitleColor(.textColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.textColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = Constant.edged
        inputButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
    }
    
    // TextField作成
    func createTextFieldForCategory() {
        // 大区分
        guard let bigCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingAccountDetailTableViewCell else { return }
        bigCell.accountDetailBigTextField.setup(identifier: "identifier_category_big")
        // 中区分
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SettingAccountDetailTableViewCell else { return }
        cell.accountDetailBigTextField.setup(identifier: "identifier_category")// switch文でdefaultケースに通すため
        //        // 小区分
        //        let cell_small = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SettingAccountDetailTableViewCell else { return UITableViewCell() }
        //        cell_small.textField_AccountDetail.setup(identifier: "identifier_category_small", component0: 0)
        // 勘定科目名
        guard let categoryCell = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as? SettingAccountDetailAccountTableViewCell else { return }
        
        // TextFieldに入力された値に反応
        // 入力開始
        // cell_big.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidBegin),for: UIControl.Event.editingDidBegin)
        // 入力終了
        bigCell.accountDetailBigTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
        cell.accountDetailBigTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
        // cell_small.textField_AccountDetail.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
        categoryCell.accountDetailAccountTextField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: UIControl.Event.editingDidEnd)
    }
    // テキストフィールへの入力が終了したとき
    @objc func textFieldEditingDidEnd(_ textField: UITextField) {
        // 取得　TextField 入力テキスト
        
        // 勘定科目区分選択　の場合
        if textField is AccountDetailPickerTextField {
            // 大区分
            guard let bigCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingAccountDetailTableViewCell else { return }
            // 中区分
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SettingAccountDetailTableViewCell else { return }
            if textField.tag == 0 {
                // // String型の番号に変換してあげる
                // big = cell_big.accountDetailBigTextField.text!
                // cell_big.accountDetailBigTextField.textColor = UIColor.black // 文字色をブラックとする
                // // String型の番号に変換してあげる tagに大区分の番号を保持しておいたものを取得
                // bigNum = String(cell_big.accountDetailBigTextField.tag)
                big = bigCell.accountDetailBigTextField.accountDetailBig
                bigNum = bigCell.accountDetailBigTextField.selectedRank0
                mid = bigCell.accountDetailBigTextField.accountDetail
                midNum = bigCell.accountDetailBigTextField.selectedRank1
            } else if textField.tag == 1 {
                big = cell.accountDetailBigTextField.accountDetailBig
                bigNum = cell.accountDetailBigTextField.selectedRank0
                mid = cell.accountDetailBigTextField.accountDetail
                midNum = cell.accountDetailBigTextField.selectedRank1
            }
            print(big)
            bigCell.accountDetailBigTextField.text = big
            print(mid)
            cell.accountDetailBigTextField.text = mid
        }
        // 勘定科目名
        guard let categoryCell = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as? SettingAccountDetailAccountTableViewCell else { return }
        if let str = categoryCell.accountDetailAccountTextField?.text {
            if str != "" {
                // 文字列中の全ての空白や改行を削除する
                let removeWhitesSpacesString = str.removeWhitespacesAndNewlines
                print("##", "「" + removeWhitesSpacesString + "」")
                categoryCell.accountDetailAccountTextField!.text = removeWhitesSpacesString
                
                // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
                if DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: removeWhitesSpacesString) {
                    // テキストフィールドの枠線を赤色とする。
                    categoryCell.accountDetailAccountTextField.layer.borderColor = UIColor.red.cgColor
                    categoryCell.accountDetailAccountTextField.layer.borderWidth = 1.0
                    
                    accountname = ""
                    // アラートを表示する
                    let alert = UIAlertController(title: "勘定科目名", message: "同名が既に存在しています", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    // テキストフィールドの枠線を非表示とする。
                    categoryCell.accountDetailAccountTextField.layer.borderColor = UIColor.lightGray.cgColor
                    categoryCell.accountDetailAccountTextField.layer.borderWidth = 0.0
                    
                    accountname = categoryCell.accountDetailAccountTextField.text!
                }
            }
        }
        // 表示科目名
        guard let taxonomyCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SettingAccountDetailTaxonomyTableViewCell else { return }
        if taxonomyCell.label!.text != "表示科目を選択してください" {
            taxonomyname = taxonomyCell.label.text!
        }
        print(
            "AccountDetailPickerTextField",
            big,
            mid,
            small,
            accountname,
            taxonomyname
        )
        print(
            "AccountDetailPickerTextField",
            bigNum,
            midNum,
            smallNum
        )
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if let indexPath: IndexPath = self.tableView.indexPathForSelectedRow {
            if IndexPath(row: 0, section: 1) != indexPath { // 表示科目名以外は遷移しない
                return false // false:画面遷移させない
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        if let indexPath: IndexPath = self.tableView.indexPathForSelectedRow { // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
            // セルの選択を解除
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch segue.identifier {
            // 設定勘定科目
        case "segue_TaxonomyList": // “セグウェイにつけた名称”:
            // segue.destinationの型はUIViewController
            if let viewControllerGenearlLedgerAccount = segue.destination as? SettingsTaxonomyListTableViewController {
                viewControllerGenearlLedgerAccount.howToUse = true // 勘定科目　詳細　設定画面からの遷移の場合はtrue
                if addAccount { // 新規で設定勘定科目を追加する場合　addButtonを押下
                    viewControllerGenearlLedgerAccount.addAccount = true // 新規で設定勘定科目を追加する場合　addButtonを押下
                } else {
                    // 勘定科目を編集する場合　勘定科目の連番から勘定科目を取得　大区分を知るため
                    if let dataBaseSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: numberOfAccount) {
                        bigNum = dataBaseSettingsTaxonomyAccount.Rank0 // 大区分
                    }
                }
                // 遷移先のコントローラに値を渡す
                viewControllerGenearlLedgerAccount.numberOfTaxonomyAccount = numberOfAccount // 設定勘定科目連番　を渡す
                switch bigNum { // object?.rank0 {
                case "0", "1", "2", "3", "4", "5":
                    viewControllerGenearlLedgerAccount.segmentedControl.selectedSegmentIndex = 0 // セグメントスイッチにBSを設定
                    // 遷移先のコントローラー.条件用の属性 = “条件”
                case "6", "7", "8", "9", "10", "11":
                    viewControllerGenearlLedgerAccount.segmentedControl.selectedSegmentIndex = 1 // セグメントスイッチにPLを設定
                default:
                    break
                }
            }
        default:
            break
        }
    }
    // 勘定科目に紐づけられた表示科目を変更する　設定勘定科目連番、表示科目連番
    func changeTaxonomyOfTaxonomyAccount(number: Int, numberOfTaxonomy: Int) -> Int {
        var newnumber = 0
        // 変更
        DatabaseManagerSettingsTaxonomyAccount.shared.updateTaxonomyOfSettingsTaxonomyAccount(number: number, numberOfTaxonomy: String(numberOfTaxonomy))
        newnumber = number
        return newnumber
    }
    
    func showNumberOfTaxonomy() {
        // 表示科目名
        if self.numberOfTaxonomy != 0 { // 表示科目が選択されて、表示科目番号が詳細画面に戻ってきた場合
            guard let taxonomyCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SettingAccountDetailTaxonomyTableViewCell else { return }
            let object = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
            taxonomyCell.label.text! = "\(object!.number), \(object!.category)"
            taxonomyCell.label.textColor = .textColor
            taxonomyname = taxonomyCell.label.text!
        }
    }
    
    @IBAction func inputButtonTapped(_ sender: Any) {
        // 勘定科目　追加か編集か
        var newnumber = 0
        // 入力チェック
        if textInputCheck() {
            
            if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
               let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
               let navigationController = splitViewController.viewControllers[0] as? UINavigationController { // スプリットコントローラから、現在選択されているコントローラを取得する
                let navigationController2: UINavigationController
                // iPadとiPhoneで動きが変わるので分岐する
                if UIDevice.current.userInterfaceIdiom == .pad { // iPad
                    //        if UIDevice.current.orientation == .portrait { // ポートレート 上下逆さまだとポートレートとはならない
                    print(splitViewController.viewControllers.count)
                    if let navigationController0 = splitViewController.viewControllers[0] as? UINavigationController, // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                       let navigationController1 = navigationController0.viewControllers[1] as? UINavigationController {
                        navigationController2 = navigationController1
                        print(navigationController0.viewControllers.count)
                        print(navigationController0.viewControllers[1])
                        print(navigationController2.viewControllers.count)
                        print(navigationController2.viewControllers[0])
                        print("iPad ビューコントローラーの階層")
                        //            print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                        //            print("splitViewController[1]      : ", splitViewController.viewControllers[1] )    // UINavigationController
                        //            print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                        //            print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // SettingsCategoryTableViewController
                        print("    navigationController2[1]: ", navigationController2.viewControllers[1])   // CategoryListCarouselAndPageViewController
                        if let categoryListCarouselAndPageViewController = navigationController2.viewControllers[1] as? CategoryListCarouselAndPageViewController,
                           let presentingViewController = categoryListCarouselAndPageViewController.pageViewController.viewControllers?.first as? CategoryListTableViewController {
                            // viewWillAppearを呼び出す　更新のため
                            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                newnumber = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                                    rank0: self.bigNum,
                                    rank1: self.midNum,
                                    rank2: self.smallNum,
                                    numberOfTaxonomy: String(self.numberOfTaxonomy),
                                    category: self.accountname,
                                    switching: true
                                )
                                // 新規追加　を終了するためにフラグを倒す
                                if newnumber != 0 {
                                    self.addAccount = false
                                    // presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
                                    // TableViewをリロードする処理がある
                                    presentingViewController.reloadDataAferAdding()
                                }
                            })
                        }
                    }
                } else { // iPhone
                    print(splitViewController.viewControllers.count)
                    if let navigationController1 = navigationController.viewControllers[1] as? UINavigationController {
                        navigationController2 = navigationController1
                        //             navigationController2 = navigationController.viewControllers[0] as! UINavigationController // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                        print("iPhone ビューコントローラーの階層")
                        print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                        print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                        print("  navigationController[1]   : ", navigationController.viewControllers[1])    // UINavigationController
                        print("    navigationController2.count: ", navigationController2.viewControllers.count)   //
                        print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // SettingsCategoryTableViewController
                        print("    navigationController2[1]: ", navigationController2.viewControllers[1])   // CategoryListCarouselAndPageViewController
                        if let categoryListCarouselAndPageViewController = navigationController2.viewControllers[1] as? CategoryListCarouselAndPageViewController,
                           let presentingViewController = categoryListCarouselAndPageViewController.pageViewController.viewControllers?.first as? CategoryListTableViewController {
                            // viewWillAppearを呼び出す　更新のため
                            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                newnumber = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                                    rank0: self.bigNum,
                                    rank1: self.midNum,
                                    rank2: self.smallNum,
                                    numberOfTaxonomy: String(self.numberOfTaxonomy),
                                    category: self.accountname,
                                    switching: true
                                )
                                // 新規追加　を終了するためにフラグを倒す
                                if newnumber != 0 {
                                    self.addAccount = false
                                    // presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
                                    // TableViewをリロードする処理がある
                                    presentingViewController.reloadDataAferAdding()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool {
        guard big != "選択してください" && big != "" else {
            let alert = UIAlertController(title: "大区分", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        
        guard mid != "選択してください" && mid != "" else {
            let alert = UIAlertController(title: "中区分", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        //                if small != "選択してください" && small != ""{
        guard accountname != "入力してください" && accountname != "" else {
            let alert = UIAlertController(title: "勘定科目名", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        guard taxonomyname != "表示科目を選択してください" && taxonomyname != "" else {
            let alert = UIAlertController(title: "表示科目名", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        return true // OK
    }
}
