//
//  SettingsCategoryDetailTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応

// 勘定科目詳細クラス
class SettingsCategoryDetailTableViewController: UITableViewController, UITextFieldDelegate {


    @IBOutlet var gADBannerView: GADBannerView!
    
    var big = ""
    var mid = ""
    var small = ""
    var accountname = ""
    var taxonomyname = ""
    var big_num = ""
    var mid_num = ""
    var small_num = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 登録ボタンの　表示　非表示
        if addAccount {
            Button_input.isHidden = false
            Button_input.isEnabled = true
        }else {
            Button_input.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 表示科目を変更後に勘定科目詳細画面を更新する
        tableView.reloadData()
        // テキストフィールドを初期化
        if addAccount { // 勘定科目追加の場合
            createTextFieldForCategory()
        }
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOB_ID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count-1].frame.height * -1)
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
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
            return 3//4
        }else {
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
    var numberOfAccount :Int = 0 // 勘定科目番号
    var numberOfTaxonomy :Int = 0 // 表示科目番号
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SettingAccountDetailTaxonomyTableViewCell
        cell.accessoryType = .none
        cell.label.text = "-"
        // セルの選択不可にする
        cell.selectionStyle = .none
        // 新規で設定勘定科目を追加する場合　addButtonを押下
        if addAccount { // 新規追加
            if indexPath.section == 0 { // 勘定科目
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as! SettingAccountDetailTableViewCell
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    print(cell.textLabel?.font.pointSize)// = .systemFont(ofSize: 15))
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as! SettingAccountDetailTableViewCell
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "中区分"
                    return cell
                case 2:
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category", for: indexPath) as! SettingAccountDetailTableViewCell
//                    // セルの選択
//                    cell.selectionStyle = .none
//                    cell.textLabel?.textColor = .darkGray
//                    cell.textLabel?.textAlignment = NSTextAlignment.left
//                    cell.textLabel?.text = "小区分"
//                    return cell
//                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_Account", for: indexPath) as! SettingAccountDetailAccountTableViewCell
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
            }else { // タクソノミ　表示科目
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SettingAccountDetailTaxonomyTableViewCell
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目名
//                let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingAccountDetailTaxonomyTableViewCell
                if self.numberOfTaxonomy != 0 {
//                    taxonomyname = cell_taxonomy.label.text!
//                    cell.label.text = taxonomyname
                    let object = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
                    cell.label.text! = "\(object!.number), \(object!.category)"
                }else {
                    cell.label.text = "表示科目を選択してください"
                    cell.label.textColor = .lightGray
                }
                return cell
            }
        }else { // 新規追加　以外
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SettingAccountDetailTaxonomyTableViewCell
            cell.accessoryType = .none
            // セルの選択
            cell.selectionStyle = .none
            // 勘定科目の連番から勘定科目を取得　紐づけた表示科目の連番を知るため
            let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
            let object = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: numberOfAccount) // 勘定科目
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
                    case "0": cell.label.text =   "流動資産"
                        break
                    case "1": cell.label.text =   "固定資産"
                        break
                    case "2": cell.label.text =   "繰延資産"
                        break
                    case "3": cell.label.text =   "流動負債"
                        break
                    case "4": cell.label.text =   "固定負債"
                        break
                    case "5": cell.label.text =   "資本"
                        break
                    case "6": cell.label.text =   "売上"
                        break
                    case "7": cell.label.text =   "売上原価"
                        break
                    case "8": cell.label.text =   "販売費及び一般管理費"
                        break
                    case "9": cell.label.text =   "営業外損益"
                        break
                    case "10": cell.label.text =   "特別損益"
                        break
                    case "11": cell.label.text =   "税金"
                        break
                    default:
                        cell.label.text = "-"
                        break
                    }
                    break
                case 1:
                    cell.textLabel?.text = "中区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object?.Rank1 {
                    case "0": cell.label.text =   "当座資産"
                        break
                    case "1": cell.label.text =   "棚卸資産"
                        break
                    case "2": cell.label.text =   "その他の流動資産"
                        break
                    case "3": cell.label.text =   "有形固定資産"
                        break
                    case "4": cell.label.text =   "無形固定資産"
                        break
                    case "5": cell.label.text =   "投資その他の資産"
                        break
                    case "6": cell.label.text =   "繰延資産"
                        break
                    case "7": cell.label.text =   "仕入債務"
                        break
                    case "8": cell.label.text =   "その他の流動負債"
                        break
                    case "9": cell.label.text =   "長期債務"
                        break
                    case "10": cell.label.text =   "株主資本"
                        break
                    case "11": cell.label.text =   "評価・換算差額等"
                        break
                    case "12": cell.label.text =   "新株予約権"
                        break
                    case "13": cell.label.text =   "売上原価"
                        break
                    case "14": cell.label.text =   "製造原価"
                        break
                    case "15": cell.label.text =   "営業外収益"
                        break
                    case "16": cell.label.text =   "営業外費用"
                        break
                    case "17": cell.label.text =   "特別利益"
                        break
                    case "18": cell.label.text =   "特別損失"
                        break
                    default:
                        cell.label.text = "-"
                        break
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                    break
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
                    //勘定科目
                    if object!.category != "" {
                        cell.label.text = object!.category
                    }else {
                        cell.label.text = ""
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                    break
                default:
                    //
                    break
                }
            }else { // タクソノミ　表示科目
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目の連番から表示科目を取得　勘定科目の詳細情報を得るため
                if "" != object?.numberOfTaxonomy {
                    let objectt = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: Int(object!.numberOfTaxonomy)!) // 表示科目
                    cell.label.text = "\(objectt!.number), \(objectt!.category)"
                }else {
                    cell.label.text = ""
                }
                cell.label.textAlignment = NSTextAlignment.center
            }
            return cell
        }
    }
    
    // ボタンのデザインを指定する
    private func createButtons() {
        Button_input.setTitleColor(.TextColor, for: .normal)
        Button_input.neumorphicLayer?.cornerRadius = 15
        Button_input.setTitleColor(.TextColor, for: .selected)
        Button_input.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        Button_input.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        Button_input.neumorphicLayer?.edged = Constant.edged
        Button_input.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        Button_input.neumorphicLayer?.elementBackgroundColor = UIColor.BaseColor.cgColor
    }
    
    // TextField作成
    func createTextFieldForCategory() {
        // 大区分
        let cell_big = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SettingAccountDetailTableViewCell
            cell_big.textField_AccountDetail_big.setup(identifier: "identifier_category_big")
        // 中区分
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SettingAccountDetailTableViewCell
            cell.textField_AccountDetail_big.setup(identifier: "identifier_category")// switch文でdefaultケースに通すため
//        // 小区分
//        let cell_small = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingAccountDetailTableViewCell
//        cell_small.textField_AccountDetail.setup(identifier: "identifier_category_small", component0: 0)
        // 勘定科目名
        let cell_category = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as! SettingAccountDetailAccountTableViewCell
        
        // TextFieldに入力された値に反応
        // 入力開始
//        cell_big.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidBegin),for: UIControl.Event.editingDidBegin)
        // 入力終了
        cell_big.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
        cell.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
//        cell_small.textField_AccountDetail.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
        cell_category.textField_AccountDetail_Account.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
    }
    // テキストフィールへの入力が終了したとき
    @objc func textFieldEditingDidEnd(_ textField: UITextField) {
        // 取得　TextField 入力テキスト
        
        // 勘定科目区分選択　の場合
        if textField is AccountDetailPickerTextField {
            // 大区分
            let cell_big = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SettingAccountDetailTableViewCell
            // 中区分
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SettingAccountDetailTableViewCell
            if textField.tag == 0 {
//            // String型の番号に変換してあげる
//            big = cell_big.textField_AccountDetail_big.text!
//            cell_big.textField_AccountDetail_big.textColor = UIColor.black // 文字色をブラックとする
//            // String型の番号に変換してあげる tagに大区分の番号を保持しておいたものを取得
//            big_num = String(cell_big.textField_AccountDetail_big.tag)
                big = cell_big.textField_AccountDetail_big.AccountDetail_big
                big_num = cell_big.textField_AccountDetail_big.selectedRank0
                mid = cell_big.textField_AccountDetail_big.AccountDetail
                mid_num = cell_big.textField_AccountDetail_big.selectedRank1
            }else if textField.tag == 1 {
                big = cell.textField_AccountDetail_big.AccountDetail_big
                big_num = cell.textField_AccountDetail_big.selectedRank0
                mid = cell.textField_AccountDetail_big.AccountDetail
                mid_num = cell.textField_AccountDetail_big.selectedRank1
            }
//            print(big)
            cell_big.textField_AccountDetail_big.text = big
//            print(mid)
            cell.textField_AccountDetail_big.text = mid
        }
        // 勘定科目名
        let cell_category = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as! SettingAccountDetailAccountTableViewCell
        if let str = cell_category.textField_AccountDetail_Account!.text {
            if str != "" {
                // 文字列中の全ての空白や改行を削除する
                let removeWhitesSpacesString = str.removeWhitespacesAndNewlines
                print("##", "「" + removeWhitesSpacesString + "」")
                cell_category.textField_AccountDetail_Account!.text = removeWhitesSpacesString
                
                // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
                let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
                if databaseManagerSettingsTaxonomyAccount.isExistSettingsTaxonomyAccount(category: removeWhitesSpacesString) {
                    // テキストフィールドの枠線を赤色とする。
                    cell_category.textField_AccountDetail_Account.layer.borderColor = UIColor.red.cgColor
                    cell_category.textField_AccountDetail_Account.layer.borderWidth = 1.0
                    
                    accountname = ""
                    // アラートを表示する
                    let alert = UIAlertController(title: "勘定科目名", message: "同名が既に存在しています", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else {
                    // テキストフィールドの枠線を非表示とする。
                    cell_category.textField_AccountDetail_Account.layer.borderColor = UIColor.lightGray.cgColor
                    cell_category.textField_AccountDetail_Account.layer.borderWidth = 0.0

                    accountname = cell_category.textField_AccountDetail_Account.text!
                }
            }
        }
        // 表示科目名
        let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingAccountDetailTaxonomyTableViewCell
        if cell_taxonomy.label!.text != "表示科目を選択してください" {
            taxonomyname = cell_taxonomy.label.text!
        }
        print("AccountDetailPickerTextField", big ,
              mid ,
              small ,
              accountname ,
              taxonomyname )
        print("AccountDetailPickerTextField", big_num ,
              mid_num ,
              small_num )
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 0, section: 1) != self.tableView.indexPathForSelectedRow! { // 表示科目名以外は遷移しない
            return false //false:画面遷移させない
        }
        return true
    }
    var addAccount: Bool = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue
    // 画面遷移の準備　表示科目一覧画面へ
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        switch segue.identifier {
        // 設定勘定科目
        case "segue_TaxonomyList": //“セグウェイにつけた名称”:
            // segue.destinationの型はUIViewController
            let viewControllerGenearlLedgerAccount = segue.destination as! SettingsTaxonomyListTableViewController
            // 遷移先のコントローラに値を渡す
            viewControllerGenearlLedgerAccount.numberOfTaxonomyAccount = numberOfAccount // 設定勘定科目連番　を渡す
            switch big_num { //object?.Rank0 {
            case "0","1","2","3","4","5":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 0 // セグメントスイッチにBSを設定
                // 遷移先のコントローラー.条件用の属性 = “条件”
                break
            case "6","7","8","9","10","11":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 1 // セグメントスイッチにPLを設定
                break
            default:
                //
                break
            }
            viewControllerGenearlLedgerAccount.howToUse = true // 勘定科目　詳細　設定画面からの遷移の場合はtrue
            if addAccount { // 新規で設定勘定科目を追加する場合　addButtonを押下
                viewControllerGenearlLedgerAccount.addAccount = true // 新規で設定勘定科目を追加する場合　addButtonを押下
            }
            break
        default:
            //
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // 勘定科目に紐づけられた表示科目を変更する　設定勘定科目連番、表示科目連番
    func changeTaxonomyOfTaxonomyAccount(number: Int, numberOfTaxonomy: Int) -> Int {
        var newnumber = 0
        // 変更
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        databaseManagerSettingsTaxonomyAccount.updateTaxonomyOfSettingsTaxonomyAccount(number: number, numberOfTaxonomy: String(numberOfTaxonomy))
        newnumber = number
        return newnumber
    }
    
    func showNumberOfTaxonomy() {
        // 表示科目名
        if self.numberOfTaxonomy != 0 { // 表示科目が選択されて、表示科目番号が詳細画面に戻ってきた場合
            let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingAccountDetailTaxonomyTableViewCell
            let object = DataBaseManagerSettingsTaxonomy.shared.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
            cell_taxonomy.label.text! = "\(object!.number), \(object!.category)"
            cell_taxonomy.label.textColor = .TextColor
            taxonomyname = cell_taxonomy.label.text!
        }
    }
    // 入力ボタン
    @IBOutlet var Button_input: EMTNeumorphicButton!// 入力ボタン
    @IBAction func Button_Input(_ sender: Any) {
        // 勘定科目　追加か編集か
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        var newnumber = 0
        // 入力チェック
        if textInputCheck() {
            // TableViewControllerのviewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: {
                [presentingViewController] () -> Void in
                newnumber = databaseManagerSettingsTaxonomyAccount.addSettingsTaxonomyAccount(Rank0: self.big_num, Rank1: self.mid_num, Rank2: self.small_num, numberOfTaxonomy: String(self.numberOfTaxonomy), category: self.accountname, switching: true)
                // 新規追加　を終了するためにフラグを倒す
                if newnumber != 0 {
                    self.addAccount = false
                    //                                presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
                    presentingViewController!.viewWillAppear(true) // TableViewをリロードする処理がある
                }
            })
        }
    }
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool {
        if big != "選択してください" && big != "" {
            if mid != "選択してください" && mid != "" {
//                if small != "選択してください" && small != ""{
                if accountname != "入力してください" && accountname != "" {
                    if taxonomyname != "表示科目を選択してください" && taxonomyname != "" {
                        return true // OK
                    }
                    else {
                        let alert = UIAlertController(title: "表示科目名", message: "入力してください", preferredStyle: .alert)
                        self.present(alert, animated: true) { () -> Void in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        return false // NG
                    }
                }
                else {
                    let alert = UIAlertController(title: "勘定科目名", message: "入力してください", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    return false // NG
                }
            }
            else {
                let alert = UIAlertController(title: "中区分", message: "入力してください", preferredStyle: .alert)
                self.present(alert, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return false // NG
            }
        }
        else {
            let alert = UIAlertController(title: "大区分", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
    }
}

