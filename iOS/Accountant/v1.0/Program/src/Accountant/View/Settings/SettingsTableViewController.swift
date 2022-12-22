//
//  TableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import MessageUI // お問い合わせ機能
import MXParallaxHeader
import SafariServices // アプリ内でブラウザ表示
import UIKit

// 設定クラス
class SettingsTableViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorColor = .accentColor

        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = 160
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.minimumHeight = 0
        scrollView.contentSize = contentView.frame.size
        scrollView.flashScrollIndicators()

        self.navigationItem.title = "設定"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
    }

    // 生体認証パスコードロック　設定スイッチ 切り替え
    @objc func switchTriggered(sender: UISwitch) {
        // 生体認証かパスコードのいずれかが使用可能かを確認する
        if LocalAuthentication.canEvaluatePolicy() {
            // 認証使用可能時の処理
            DispatchQueue.main.async {
                // 生体認証パスコードロック　設定スイッチ
                UserDefaults.standard.set(sender.isOn, forKey: "biometrics_switch")
                UserDefaults.standard.synchronize()
            }
        } else {
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

}

extension SettingsTableViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
         4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 3
        case 3:
            return 3
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "アップグレード"
        case 1:
            return "帳簿情報"
        case 2:
            return "環境設定"
        case 3:
            return "サポート"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3:
            return "開発者へメールを送ることができます\nメールを受信できるように受信拒否設定は解除してください"
        default:
            return ""
        }
    }
    //　セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithIconTableViewCell else { return UITableViewCell() }

        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "アップグレード"
                cell.leftImageView.image = UIImage(named: "military_tech-military_tech_symbol")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "事業者名" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                cell.leftImageView.image = UIImage(named: "domain-domain_symbol")?.withRenderingMode(.alwaysTemplate)
            case 1:
                cell.centerLabel.text = "会計期間"
                cell.leftImageView.image = UIImage(named: "edit_calendar-edit_calendar_symbol")?.withRenderingMode(.alwaysTemplate)
            case 2:
                cell.centerLabel.text = "勘定科目"
                cell.leftImageView.image = UIImage(named: "account_tree-account_tree_symbol")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithIconTableViewCell else { return UITableViewCell() }
                cell.centerLabel.text = "パスコードロックを利用する"
                cell.leftImageView.image = UIImage(named: "lock-lock_symbol")?.withRenderingMode(.alwaysTemplate)
                if cell.accessoryView == nil {
                    let switchView = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    // 生体認証パスコードロック　設定スイッチ
                    switchView.onTintColor = .accentColor
                    switchView.isOn = UserDefaults.standard.bool(forKey: "biometrics_switch")
                    switchView.tag = indexPath.row
                    switchView.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
                    cell.accessoryView = switchView
                }
                return cell
            case 1:
                cell.centerLabel.text = "仕訳"
                cell.leftImageView.image = UIImage(named: "border_color-border_color_grad200_symbol")?.withRenderingMode(.alwaysTemplate)
            case 2:
                cell.centerLabel.text = "仕訳帳"
                cell.leftImageView.image = UIImage(named: "import_contacts-import_contacts_grad200_symbol")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.centerLabel.text = "使い方ガイド"
                cell.leftImageView.image = UIImage(named: "help-help_symbol")?.withRenderingMode(.alwaysTemplate)
            case 1:
                cell.centerLabel.text = "評価・レビュー"
                cell.leftImageView.image = UIImage(named: "thumb_up-thumb_up_symbol")?.withRenderingMode(.alwaysTemplate)
            case 2:
                // お問い合わせ機能
                cell.centerLabel.text = "お問い合わせ(要望・不具合報告)"
                cell.leftImageView.image = UIImage(named: "forum-forum_symbol")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 2:
            switch indexPath.row {
            case 0:
                return nil
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
                performSegue(withIdentifier: "SettingsUpgradeTableViewController", sender: tableView.cellForRow(at: indexPath))
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsInformationTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 1:
                performSegue(withIdentifier: "SettingsPeriodTableViewController", sender: tableView.cellForRow(at: indexPath))
            case 2:
                performSegue(withIdentifier: "SettingsCategoryTableViewController", sender: tableView.cellForRow(at: indexPath))
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                break
            case 1:
                performSegue(withIdentifier: "SettingsOperatingJournalEntryViewController", sender: tableView.cellForRow(at: indexPath))
            case 2:
                performSegue(withIdentifier: "SettingsOperatingTableViewController", sender: tableView.cellForRow(at: indexPath))
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsHelpViewController", sender: tableView.cellForRow(at: indexPath))
            case 1:
                /// TODO: -  アプリ名変更
                // アプリ内でブラウザを開く
                let url = URL(string:  "https://apps.apple.com/jp/app/%E8%A4%87%E5%BC%8F%E7%B0%BF%E8%A8%98%E3%81%AE%E4%BC%9A%E8%A8%88%E5%B8%B3%E7%B0%BF-thereckoning-%E3%82%B6-%E3%83%AC%E3%82%B3%E3%83%8B%E3%83%B3%E3%82%B0/id1535793378?l=ja&ls=1&mt=8&action=write-review")
                if let url = url {
                    let vc = SFSafariViewController(url: url)
                    vc.preferredControlTintColor = .accentBlue
                    present(vc, animated: true, completion: nil)
                }
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
                    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                       let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                        mail.setMessageBody("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n---------------------------\n\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\n Version: \(version) Buld: \(build)", isHTML: false)
                    }
                    present(mail, animated: true, completion: nil)
                } else {
                    print("送信できません")
                }
            default:
                break
            }
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
