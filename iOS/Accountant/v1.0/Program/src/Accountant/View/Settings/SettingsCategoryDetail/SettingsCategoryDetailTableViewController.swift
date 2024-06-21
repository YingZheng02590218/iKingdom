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
class SettingsCategoryDetailTableViewController: UIViewController {
    
    var gADBannerView: GADBannerView!
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var tableView: UITableView!
    // 入力ボタン
    @IBOutlet private var inputButton: EMTNeumorphicButton! // 入力ボタン
    /// モーダル上部に設置されるインジケータ
    private lazy var indicatorView: SemiModalIndicatorView = {
        let indicator = SemiModalIndicatorView()
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorDidTap(_:))))
        return indicator
    }()
    
    // MARK: - var let
    
    var big = "" {
        didSet {
            // 選択した大区分、中区分をテキストフィールドに表示させる
            self.tableView.reloadData()
        }
    }
    var mid = "" {
        didSet {
            // 選択した大区分、中区分をテキストフィールドに表示させる
            self.tableView.reloadData()
        }
    }
    var small = "" // 小区分　使用していない
    var bigNum = ""
    var midNum = ""
    var smallNum = "" // 小区分　使用していない
    var accountname = "" {
        didSet {
            // 選択した大区分、中区分をテキストフィールドに表示させる
            self.tableView.reloadData()
        }
    }
    var taxonomyname = ""
    
    var numberOfAccount: Int = 0 // 勘定科目番号
    
    var addAccount = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue
    // フィードバック
    private let feedbackGeneratorHeavy: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 編集機能
        // editButtonItem.tintColor = .accentColor
        // navigationItem.rightBarButtonItem = editButtonItem
        
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        tableView.separatorColor = .accentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            addBannerViewToView(gADBannerView, constant: -50)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
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
        super.viewDidLayoutSubviews()
        // ボタン作成
        createButtons()
        setupInputButton()
    }
}

// MARK: - Table view data source
extension SettingsCategoryDetailTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 大区分
            // 中区分
            // 勘定科目名
            return 3
        case 1:
            if addAccount { // 勘定科目追加の場合
                return 3
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if addAccount { // 勘定科目追加の場合
                return nil
            } else {
                return "勘定科目"
            }
        case 1:
            if addAccount { // 勘定科目追加の場合
                return "勘定科目"
            } else {
                return tableView.isEditing ? "勘定科目 変更" : nil // 編集モードの場合
            }
        default:
            return nil
        }
    }
    // セクションフッターのテキスト決める
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if addAccount { // 勘定科目追加の場合
                return 0
            } else {
                return 44
            }
        case 1:
            if addAccount { // 勘定科目追加の場合
                return 44
            } else {
                return tableView.isEditing ? 44 : 0 // 編集モードの場合
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? SettingAccountDetailTableViewCell else {
            return UITableViewCell()
        }
        // 大区分　中区分
        if let accountDetailBigTextField = cell.accountDetailBigTextField {
            accountDetailBigTextField.isHidden = true
            accountDetailBigTextField.isEnabled = false
        }
        // 勘定科目名
        if let accountDetailAccountTextField = cell.accountDetailAccountTextField {
            accountDetailAccountTextField.isHidden = true
            accountDetailAccountTextField.isEnabled = false
        }
        cell.accessoryType = .none
        // セルの選択
        cell.selectionStyle = .none
        cell.label.text = ""
        cell.label.textColor = .textColor
        cell.accessoryView = nil
        
        if indexPath.section == 0 { // 勘定科目
            // 新規追加　以外
            cell.label.isHidden = false
            cell.label.isEnabled = true
            // 勘定科目の連番から勘定科目を取得
            if let object = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: numberOfAccount) { // 勘定科目
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "大区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object.Rank0 {
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
                    switch object.Rank1 {
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
                    case "19": cell.label.text = "非支配株主持分"
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
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目
                    if object.category != "" {
                        cell.label.text = object.category
                    } else {
                        cell.label.text = ""
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                default:
                    break
                }
            }
        } else if indexPath.section == 1 {
            // 勘定科目 変更
            switch indexPath.row {
            case 0:
                // 編集モードの場合
                if tableView.isEditing {
                    cell.accountDetailAccountTextField.isHidden = false
                    cell.accountDetailAccountTextField.isEnabled = true
                    cell.delegate = self
                    cell.accountDetailAccountTextField.text = accountname
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
                    if DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: accountname) {
                        // テキストフィールドの枠線を赤色とする。
                        cell.accountDetailAccountTextField.layer.borderColor = UIColor.red.cgColor
                        cell.accountDetailAccountTextField.layer.borderWidth = 1.0
                        cell.accountDetailAccountTextField.layer.cornerRadius = 5
                    } else {
                        // テキストフィールドの枠線を非表示とする。
                        cell.accountDetailAccountTextField.layer.borderColor = UIColor.lightGray.cgColor
                        cell.accountDetailAccountTextField.layer.borderWidth = 0.0
                    }
                } else {
                    cell.accountDetailBigTextField.isHidden = false
                    cell.accountDetailBigTextField.isEnabled = true
                    cell.accountDetailBigTextField.setup(identifier: "identifier_category_big")
                    cell.delegate = self
                    cell.accountDetailBigTextField.text = big
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                }
            case 1:
                cell.accountDetailBigTextField.isHidden = false
                cell.accountDetailBigTextField.isEnabled = true
                cell.accountDetailBigTextField.setup(identifier: "identifier_category") // switch文でdefaultケースに通すため
                cell.delegate = self
                cell.accountDetailBigTextField.text = mid
                cell.accessoryType = .none
                // セルの選択
                cell.selectionStyle = .none
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                cell.textLabel?.font = .systemFont(ofSize: 14)
                cell.textLabel?.text = "中区分"
            case 2:
                cell.accountDetailAccountTextField.isHidden = false
                cell.accountDetailAccountTextField.isEnabled = true
                cell.delegate = self
                cell.accountDetailAccountTextField.text = accountname
                cell.accessoryType = .none
                // セルの選択
                cell.selectionStyle = .none
                cell.textLabel?.font = .systemFont(ofSize: 14)
                cell.textLabel?.text = "勘定科目名"
                cell.textLabel?.textColor = .lightGray
                // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
                if DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: accountname) {
                    // テキストフィールドの枠線を赤色とする。
                    cell.accountDetailAccountTextField.layer.borderColor = UIColor.red.cgColor
                    cell.accountDetailAccountTextField.layer.borderWidth = 1.0
                    cell.accountDetailAccountTextField.layer.cornerRadius = 5
                } else {
                    // テキストフィールドの枠線を非表示とする。
                    cell.accountDetailAccountTextField.layer.borderColor = UIColor.lightGray.cgColor
                    cell.accountDetailAccountTextField.layer.borderWidth = 0.0
                }
            default:
                break
            }
        }
        return cell
    }
    
    // 編集機能
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    // インデント
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    // MARK: setup
    
    // ボタンのデザインを指定する
    private func createButtons() {
        // 編集モードの場合
        if tableView.isEditing {
            inputButton.setTitle("変　更", for: .normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        } else {
            inputButton.setTitle("登　録", for: .normal)
        }
        inputButton.setTitleColor(.accentColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.accentColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = Constant.edged
        inputButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        
        // タイプ判定
        if addAccount {
            if let backgroundView = backgroundView {
                // 中央上部に配置する
                indicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 5)
                backgroundView.addSubview(indicatorView)
                indicatorView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    indicatorView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                    indicatorView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5),
                    indicatorView.widthAnchor.constraint(equalToConstant: indicatorView.frame.width),
                    indicatorView.heightAnchor.constraint(equalToConstant: indicatorView.frame.height)
                ])
            }
        }
    }
    
    func setupInputButton() {
        // 登録ボタンの　表示　非表示
        if addAccount {
            inputButton.isHidden = false
            inputButton.isEnabled = true
        } else {
            inputButton.isHidden = tableView.isEditing ? false : true // 編集モードの場合
            inputButton.isEnabled = tableView.isEditing ? true : false // 編集モードの場合
        }
    }
    
    // MARK: action
    
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableView.reloadData()
        }
        setupInputButton()
    }
    
    @IBAction func inputButtonTapped(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        inputButton.isSelected = false
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        // 勘定科目　追加か編集か
        var newnumber = 0
        // 入力チェック
        if textInputCheck() {
            if addAccount { // 勘定科目追加の場合
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                        newnumber = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                                            rank0: self.bigNum,
                                            rank1: self.midNum,
                                            rank2: self.smallNum,
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                        newnumber = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                                            rank0: self.bigNum,
                                            rank1: self.midNum,
                                            rank2: self.smallNum,
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
                } else {
                    // 勘定科目 編集の場合
                    print(topViewController(controller: self))
                    // TODO: インジゲーターをつける
                    // TODO: 仕訳入力がされていない場合のみ、更新できるようにする？
                    // TODO: 影響がある仕訳、勘定などを更新する
                    // TODO: 勘定科目名を変更する前に、影響がある仕訳、決算整理仕訳、損益振替仕訳、残高振替仕訳、資本振替仕訳、勘定などを更新する必要がある。
                    //                    // 更新　勘定科目名を変更
                    //                    let number = DatabaseManagerSettingsTaxonomyAccount.shared.updateAccountNameOfSettingsTaxonomyAccount(
                    //                        number: numberOfAccount,
                    //                        accountName: self.accountname
                    //                    )
                }
            }
        }
    }
    
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool {
        // 編集モードの場合
        if tableView.isEditing {
            // バリデーションをおこなわない
        } else {
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
        }
        guard accountname != "入力してください" && accountname != "" else {
            let alert = UIAlertController(title: "勘定科目名", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
        guard !(DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: accountname)) else {
            // アラートを表示する
            let alert = UIAlertController(title: "勘定科目名", message: "同じ名称がすでに存在しています", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return false // NG
        }
        
        return true // OK
    }
    
    // インジケータ タップ
    @objc
    private func indicatorDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: navigation
    
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false // false:画面遷移させない
    }
}
extension SettingsCategoryDetailTableViewController: TableViewCellDelegate {
    
    func selectedRankAction(big: String, mid: String, bigNum: String, midNum: String) {
        self.big = big
        self.mid = mid
        self.bigNum = bigNum
        self.midNum = midNum
    }
    
    func selectedAccountAction(accountname: String?) {
        if let str = accountname {
            if str != "" {
                // 文字列中の全ての空白や改行を削除する
                let removeWhitesSpacesString = str.removeWhitespacesAndNewlines
                print("##", "「" + removeWhitesSpacesString + "」")
                
                // 存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
                if DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: removeWhitesSpacesString) {
                    // アラートを表示する
                    let alert = UIAlertController(title: "勘定科目名", message: "同じ名称がすでに存在しています", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                self.accountname = removeWhitesSpacesString
            }
        }
    }
}
