//
//  TableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import AudioToolbox
import GoogleMobileAds // マネタイズ対応
import MessageUI // お問い合わせ機能
import MXParallaxHeader
import SafariServices // アプリ内でブラウザ表示
import UIKit
import WidgetKit

// 設定クラス
class SettingsTableViewController: UIViewController {
    
    @IBOutlet var logoLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var scrollView: UIScrollView!
    // 【Xcode11】いつもスクロールしなかったUIScrollView + AutoLayoutをやっと攻略できた
    // https://swallow-incubate.com/archives/blog/20200805
    //    手順
    //    UIScrollViewを設置する
    //    UIScrollViewとViewに制約を設定する
    //    UIScrollViewにUIView（ContentView）を配置する
    //    UIScrollViewとContentViewに制約を設定する
    //    ContentViewに高さを設定する
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var headerView: UIView!
    var posX: CGFloat = 0
    // 通知設定 設定アプリ　Allow Notifications
    var isOn = false {
        didSet {
            // 記帳の時刻を通知する のセルをリロードする
            self.reloadRow(section: 3, row: 4)
        }
    }
    // フィードバック
    private let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
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
    // フィードバック
    private let feedbackGeneratorNotification: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorColor = .accentColor
        tableView.register(
            UINib(nibName: String(describing: NewsTableViewHeaderFooterView.self), bundle: nil),
            forHeaderFooterViewReuseIdentifier: String(describing: NewsTableViewHeaderFooterView.self)
        )
        
        self.navigationItem.title = "設定"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = self.view.frame.height * 0.15
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.minimumHeight = 0
        scrollView.contentSize = contentView.frame.size
        scrollView.flashScrollIndicators()
        
        versionLabel.text = "Version \(AppVersion.currentVersion)"
        
        // Push通知の権限ダイアログを表示させる
        showDialogForPushNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 通知設定
        pushPermissionState(completion: { isOn in
            self.isOn = isOn
        })
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // 会計期間のセルをリロードする
        reloadRow(section: 2, row: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ロゴに影をつける
        logoLabel.clipsToBounds = false
        logoLabel.layer.shadowColor = UIColor.textShadowColor.cgColor // 影の色
        logoLabel.layer.shadowOffset = CGSize(width: 1.0, height: 1.5) // 影の位置
        logoLabel.layer.shadowOpacity = 1.0 // 影の透明度
        logoLabel.layer.shadowRadius = 5.0 // 影の広がり
    }
    
    // Push通知の権限ダイアログを表示させる
    func showDialogForPushNotifications() {
        // Push通知 Firebase
        UserNotificationUtility.shared.initialize()
        UserNotificationUtility.shared.showPushPermit { result in
            switch result {
            case .success(let isGranted):
                if isGranted {
                    DispatchQueue.main.async {
                        // APNs への登録
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    // セルをリロードする
    func reloadRow(section: Int, row: Int) {
        let indexPath = IndexPath(row: row, section: section)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    // 生体認証パスコードロック　設定スイッチ 切り替え
    @objc
    func switchTriggered(sender: UISwitch) {
        // システムサウンドを鳴らす
        if sender.isOn {
            AudioServicesPlaySystemSound(1_484) // UISwitch_On_Haptic.caf
        } else {
            AudioServicesPlaySystemSound(1_485) // UISwitch_Off_Haptic.caf
        }
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 生体認証かパスコードのいずれかが使用可能かを確認する
        if LocalAuthentication.canEvaluatePolicy() {
            // 認証使用可能時の処理
            DispatchQueue.main.async {
                // 生体認証パスコードロック　設定スイッチ
                UserDefaults.standard.set(sender.isOn, forKey: "biometrics_switch")
                UserDefaults.standard.synchronize()
            }
        } else {
            // フィードバック
            if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                generator.notificationOccurred(.error)
            }
            // 認証使用可能時の処理
            DispatchQueue.main.async {
                // スイッチを元に戻す
                sender.isOn = !sender.isOn
                // アラート画面を表示する
                let alert = UIAlertController(title: "エラー", message: "パスコードを利用できるよう設定してください", preferredStyle: .alert)
                
                self.present(alert, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    // iOS の設定を開く　ボタン
    @objc
    func iosSettingsButtonTapped(sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // OSの通知設定画面へ遷移
        linkToSettingsScreen()
    }
    // AppStoreを開く　ボタン
    @objc
    func appStoreButtonTapped(sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // AppStoreへ遷移
        jumpToAppStore()
    }
    // ローカル通知　設定スイッチ 切り替え
    @objc
    func localNotificationSettingSwitchTriggered(sender: UISwitch) {
        // システムサウンドを鳴らす
        if sender.isOn {
            AudioServicesPlaySystemSound(1_484) // UISwitch_On_Haptic.caf
        } else {
            AudioServicesPlaySystemSound(1_485) // UISwitch_Off_Haptic.caf
        }
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        pushPermissionState(completion: { isOn in
            DispatchQueue.main.async {
                if isOn {
                    DispatchQueue.main.async {
                        // ローカル通知　設定スイッチ
                        UserDefaults.standard.set(sender.isOn, forKey: "local_notification_switch")
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    // OSの設定　がOFFの場合
                    // フィードバック
                    if #available(iOS 10.0, *), let generator = self.feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                        generator.notificationOccurred(.error)
                    }
                    // 認証使用可能時の処理
                    DispatchQueue.main.async {
                        // スイッチを元に戻す
                        sender.isOn = !sender.isOn
                        // アラート画面を表示する
                        let alert = UIAlertController(title: "エラー", message: "ローカル通知を利用できるように\n通知をオンに設定してください", preferredStyle: .alert)
                        
                        self.present(alert, animated: true) { () -> Void in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.dismiss(animated: true, completion: {
                                    // OSの通知設定画面へ遷移
                                    self.linkToSettingsScreen()
                                })
                            }
                        }
                    }
                }
            }
        })
    }
    // 指定時刻
    @objc
    func datePickerTriggered(sender: UIDatePicker) {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ja_JP")
        df.timeZone = .current
        
        df.dateStyle = .none
        df.timeStyle = .short
        let time = df.string(from: sender.date) // String "21:00"
        UserDefaults.standard.set(time, forKey: "localNotificationEvereyDay")
        UserDefaults.standard.synchronize()
    }
    
    // 通知設定状況を取得
    func pushPermissionState(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Allow notification")
                completion(true)
            case .denied:
                print("Denied notification")
                completion(false)
            case .notDetermined:
                print("Not settings")
                completion(false)
            case .provisional:
                print("provisional")
                completion(false)
            case .ephemeral:
                print("ephemeral")
                completion(false)
            @unknown default:
                print("default")
                completion(false)
            }
        }
    }
    // OSの通知設定画面へ遷移
    func linkToSettingsScreen() {
        DispatchQueue.main.async {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // ウィジェット 単位　設定 切り替え
    @objc
    func onSegment(sender: UISegmentedControl) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // セグメントコントロール　0: 千円, 1:円
        let segStatus = sender.selectedSegmentIndex == 0 ? true : false
        print("Segment \(segStatus)")
        // ウィジェット 単位を変更
        change(isThousand: segStatus)
    }
    // ウィジェット 単位を変更
    func change(isThousand: Bool) {
        // ウィジェット 単位　設定
        let userDefault = UserDefaults(suiteName: AppGroups.appGroupsId)
        userDefault?.set(isThousand, forKey: "isThousand" )
        
        if #available(iOS 14.0, *) {
            // アプリ側からWidgetを更新する
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    // 追加機能　画面遷移の準備　仕訳画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
           let controller = navigationController.topViewController as? SettingsUpgradeViewController {
            if segue.identifier == "SettingsUpgradeViewController" {
                controller.screenType = .push
            }
        }
    }
}

extension SettingsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 4
        case 3:
            return 7
        case 4:
            return 3
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "バックアップ"
        case 2:
            return "帳簿情報"
        case 3:
            return "環境設定"
        case 4:
            return "サポート"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        default:
            return nil
        }
    }
    // セクションフッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 35
        default:
            return 0
        }
    }
    // セクションフッター
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: NewsTableViewHeaderFooterView.self))
            if let headerView = view as? NewsTableViewHeaderFooterView {
                headerView.textLabel?.text = nil
                let message = [
                    "このアプリが少しでも役に立ったなと思ったら、サブスク登録、高評価をお願いいたします。",
                ]
                headerView.setup(message: message)
                return headerView
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else {
            return 50
        }
    }
    //　セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithIconTableViewCell else { return UITableViewCell() }
        cell.centerLabelHeighCenterY.priority = .defaultLow
        cell.centerLabelMiddleCenterY.priority = .defaultHigh
        cell.lowerLabel.text = nil
        cell.lowerLabel.isHidden = true
        
        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView
        // ラベル
        cell.centerLabel.font = UIFont.systemFont(ofSize: 19.0)
        cell.centerLabel.textColor = .textColor
        // 右側のラベル
        cell.subLabel.text = ""
        // アイコン画像の色を指定する
        cell.leftImageView.tintColor = .textColor
        // 背景色
        cell.backgroundColor = .mainColor2
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                // Accessory Color
                disclosureView.tintColor = UIColor.mainColor2
                // ラベル
                cell.centerLabel.text = "アップグレード"
                cell.centerLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
                cell.centerLabel.textColor = .mainColor2
                cell.leftImageView.image = UIImage(named: "baseline_workspace_premium_black_36pt")?.withRenderingMode(.alwaysTemplate)
                // アイコン画像の色を指定する
                cell.leftImageView.tintColor = .baseColor
                // 背景色
                cell.backgroundColor = .accentColor
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            default:
                break
            }
        } else if indexPath.section == 1 {
            cell.centerLabel.text = "データのバックアップ・復元"
            cell.leftImageView.image = UIImage(named: "baseline_cloud_upload_black_36pt")?.withRenderingMode(.alwaysTemplate)
            // セルの選択を可にする
            cell.selectionStyle = .gray
            
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "事業者名" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                cell.leftImageView.image = UIImage(named: "domain-domain_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 1:
                cell.centerLabel.text = "会計期間"
                // 期首
                let beginningOfYearDate = DateManager.shared.getBeginningOfYearDate()
                // 期末
                let endingOfYearDate = DateManager.shared.getEndingOfYearDate()
                cell.subLabel.text = "\(beginningOfYearDate)〜\(endingOfYearDate)"
                cell.leftImageView.image = UIImage(named: "edit_calendar-edit_calendar_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 2:
                cell.centerLabel.text = "勘定科目体系"
                cell.leftImageView.image = UIImage(named: "account_tree-account_tree_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 3:
                cell.centerLabel.text = "開始残高"
                cell.centerLabelHeighCenterY.priority = .defaultHigh
                cell.centerLabelMiddleCenterY.priority = .defaultLow
                cell.lowerLabel.text = "前期の決算書を参照しながらご入力ください。"
                cell.lowerLabel.isHidden = false
                cell.leftImageView.image = UIImage(named: "edit_document-edit_document_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            default:
                break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "よく使う仕訳"
                cell.leftImageView.image = UIImage(named: "border_color-border_color_grad200_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 1:
                cell.centerLabel.text = "主要簿"
                cell.leftImageView.image = UIImage(named: "import_contacts-import_contacts_grad200_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 2:
                cell.centerLabel.text = "iOS の設定を開く"
                // ボタン
                let button = UIButton(frame: CGRect(x: 0, y: cell.frame.size.height / 2, width: 25, height: 25))
                // iOS の設定を開く　設定スイッチ
                button.tintColor = .accentColor
                let picture = UIImage(named: "baseline_open_in_new_black_36pt")?.withRenderingMode(.alwaysTemplate)
                button.setImage(picture, for: .normal)
                button.imageView?.tintColor = .accentColor
                cell.leftImageView.image = UIImage(named: "settings-settings_symbol")?.withRenderingMode(.alwaysTemplate)
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(iosSettingsButtonTapped), for: .touchUpInside)
                cell.accessoryView = button
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 3:
                cell.centerLabel.text = "生体認証・パスコード"
                // 生体認証かパスコードのいずれかが使用可能かを確認する
                if LocalAuthentication.canEvaluatePolicy() {
                    cell.leftImageView.image = UIImage(named: "lock-lock_symbol")?.withRenderingMode(.alwaysTemplate)
                } else {
                    cell.leftImageView.image = UIImage(named: "baseline_lock_open_black_36pt")?.withRenderingMode(.alwaysTemplate)
                }
                let switchView = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                // 生体認証パスコードロック　設定スイッチ
                switchView.onTintColor = .accentBlue
                switchView.isOn = UserDefaults.standard.bool(forKey: "biometrics_switch")
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
                cell.accessoryView = switchView
                // セルの選択不可にする
                cell.selectionStyle = .none
                
                return cell
            case 4:
                cell.centerLabel.text = "記帳の時刻を通知する"
                // 通知設定
                if isOn {
                    cell.leftImageView.image = UIImage(named: "baseline_alarm_black_36pt")?.withRenderingMode(.alwaysTemplate)
                } else {
                    // OSの設定　がOFFの場合
                    cell.leftImageView.image = UIImage(named: "baseline_alarm_off_black_36pt")?.withRenderingMode(.alwaysTemplate)
                }
                let switchView = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                // ローカル通知　設定スイッチ
                switchView.onTintColor = .accentBlue
                switchView.isOn = UserDefaults.standard.bool(forKey: "local_notification_switch")
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(localNotificationSettingSwitchTriggered), for: .valueChanged)
                cell.accessoryView = switchView
                // セルの選択不可にする
                cell.selectionStyle = .none
                
            case 5:
                cell.centerLabel.text = "指定時刻"
                cell.leftImageView.image = nil
                
                let picker = UIDatePicker()
                picker.tintColor = .accentColor
                picker.locale = Locale(identifier: "ja_JP") // Locale(identifier: "en_US_POSIX")
                picker.timeZone = .current
                picker.calendar = Calendar(identifier: .gregorian)
                // デバイスの設定(暦法)を無視して表示させる
                
                if #available(iOS 13.4, *) {
                    picker.preferredDatePickerStyle = .compact
                } else {
                    // Fallback on earlier versions
                }
                // 時間のみにする
                picker.datePickerMode = .time
                // Let it size itself to its preferred size
                picker.sizeToFit()
                // Set the frame without changing the size
                picker.frame = .init(x: 0, y: 0, width: 90, height: 35)
                // systemLayoutSizeFittingとはUIViewのメソッドで、引数に合うSizeを返してくれます。
                // 引数に自身のViewのWidthを入れ、横の優先順位を上げる(defaultHighをセットする)ことで横幅いっぱいの時用のサイズを取得できます。
                let targetSize = CGSize(width: picker.frame.width, height: 0)
                let size = picker.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
                picker.frame.size = size
                // 初期値
                picker.date = UserNotificationUtility.shared.time
                picker.addTarget(self, action: #selector(datePickerTriggered), for: .valueChanged)
                cell.accessoryView = picker
                // セルの選択不可にする
                cell.selectionStyle = .none
                
            case 6:
                // ウィジェット 単位　設定
                cell.centerLabel.text = "Widget"
                cell.centerLabelHeighCenterY.priority = .defaultHigh
                cell.centerLabelMiddleCenterY.priority = .defaultLow
                cell.subLabel.text = "金額の単位"
                cell.lowerLabel.text = "ウィジェットに表示させる金額の単位を指定します。"
                cell.lowerLabel.isHidden = false
                
                cell.leftImageView.image = UIImage(named: "baseline_widgets_black_36pt")?.withRenderingMode(.alwaysTemplate)
                // ウィジェット 単位　設定 セグメントコントロール
                let segment = UISegmentedControl(items: ["千円", "円"])
                // ウィジェット 単位　設定
                let userDefault = UserDefaults(suiteName: AppGroups.appGroupsId)
                segment.selectedSegmentIndex = userDefault?.bool(forKey: "isThousand") ?? true ? 0 : 1
                segment.addTarget(self, action: #selector(onSegment), for: .valueChanged)
                cell.accessoryView = UIView(frame: segment.frame)
                cell.accessoryView?.addSubview(segment)
                // セルの選択不可にする
                cell.selectionStyle = .none
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "使い方ガイド"
                cell.leftImageView.image = UIImage(named: "help-help_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 1:
                cell.centerLabel.text = "評価・レビュー"
                // ボタン
                let button = UIButton(frame: CGRect(x: 0, y: cell.frame.size.height / 2, width: 25, height: 25))
                // iOS の設定を開く　設定スイッチ
                button.tintColor = .accentColor
                let picture = UIImage(named: "baseline_open_in_new_black_36pt")?.withRenderingMode(.alwaysTemplate)
                button.setImage(picture, for: .normal)
                button.imageView?.tintColor = .accentColor
                cell.leftImageView.image = UIImage(named: "thumb_up-thumb_up_symbol")?.withRenderingMode(.alwaysTemplate)
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(appStoreButtonTapped), for: .touchUpInside)
                cell.accessoryView = button
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            case 2:
                // お問い合わせ機能
                cell.centerLabel.text = "お問い合わせ"
                cell.centerLabelHeighCenterY.priority = .defaultHigh
                cell.centerLabelMiddleCenterY.priority = .defaultLow
                cell.subLabel.text = "要望・不具合報告"
                cell.lowerLabel.text = "メールを受信できるように受信拒否設定は解除してください。"
                cell.lowerLabel.isHidden = false
                cell.leftImageView.image = UIImage(named: "mail-mail_symbol")?.withRenderingMode(.alwaysTemplate)
                // セルの選択を可にする
                cell.selectionStyle = .gray
                
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 3:
            switch indexPath.row {
            case 0:
                return indexPath
            case 1:
                return indexPath
            case 2:
                return indexPath
            default:
                return nil
            }
        case 4:
            switch indexPath.row {
            default:
                return indexPath
            }
        default:
            return indexPath
        }
    }
    // セルがタップされたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsUpgradeViewController", sender: tableView.cellForRow(at: indexPath))
            default:
                break
            }
        } else if indexPath.section == 1 {
            
            performSegue(withIdentifier: "BackupViewController", sender: tableView.cellForRow(at: indexPath))
            
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsInformationTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 1:
                performSegue(withIdentifier: "SettingsPeriodTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 2:
                performSegue(withIdentifier: "SettingsCategoryTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 3:
                performSegue(withIdentifier: "OpeningBalanceViewController", sender: tableView.cellForRow(at: indexPath))
            default:
                break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsOperatingJournalEntryViewController", sender: tableView.cellForRow(at: indexPath))
            case 1:
                performSegue(withIdentifier: "SettingsOperatingTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 2:
                // OSの通知設定画面へ遷移
                linkToSettingsScreen()
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsHelpViewController", sender: tableView.cellForRow(at: indexPath))
            case 1:
                // AppStoreへ遷移
                jumpToAppStore()
            case 2:
                // お問い合わせ機能
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    // 宛先アドレス
                    mail.setToRecipients(["paciolist@gmail.com"])
                    // 件名
                    mail.setSubject("お問い合わせ")
                    // 本文　末尾に、iPhoneのモデルとOSとバージョンを表示
                    mail.setMessageBody("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n---------------------------\n\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\n Version: \(AppVersion.currentVersion) Buld: \(AppVersion.currentBuildVersion)", isHTML: false)
                    present(mail, animated: true, completion: nil)
                } else {
                    print("送信できません")
                    let alert = UIAlertController(title: "メール作成できません", message: "メールアドレスが設定されていないため", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    // AppStoreへ遷移
    func jumpToAppStore() {
        // TODO: アプリ名を変更
        // 中間ブラウザ　アプリ内でブラウザを開く
        let url = URL(
            string:  "https://apps.apple.com/jp/app/%E8%A4%87%E5%BC%8F%E7%B0%BF%E8%A8%98%E3%81%AE%E4%BC%9A%E8%A8%88%E5%B8%B3%E7%B0%BF-thereckoning-%E3%82%B6-%E3%83%AC%E3%82%B3%E3%83%8B%E3%83%B3%E3%82%B0/id1535793378?l=ja&ls=1&mt=8&action=write-review"
        )
        if let url = url {
            let vc = SFSafariViewController(url: url)
            vc.preferredControlTintColor = .accentBlue
            present(vc, animated: true, completion: nil)
        }
    }
}

extension SettingsTableViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        posX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = posX
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    // お問い合わせ機能
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
