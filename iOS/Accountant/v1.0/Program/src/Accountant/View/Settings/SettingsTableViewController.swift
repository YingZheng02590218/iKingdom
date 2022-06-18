//
//  TableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応
import SafariServices // アプリ内でブラウザ表示
import MessageUI // お問い合わせ機能

// 設定クラス
class SettingsTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.navigationItem.title = "設定"
        //largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        // ナビゲーションを透明にする処理
        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
        }
    }
    
    // 生体認証パスコードロック　設定スイッチ 切り替え
    @objc func switchTriggered(sender: UISwitch){
        // 生体認証かパスコードのいずれかが使用可能かを確認する
        if LocalAuthentication.canEvaluatePolicy() {
            // 認証使用可能時の処理
            DispatchQueue.main.async {
                // 生体認証パスコードロック　設定スイッチ
                UserDefaults.standard.set(sender.isOn, forKey: "biometrics_switch")
                UserDefaults.standard.synchronize()
            }
        }
        else {
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3:
            return "開発者へメールを送ることができます\nメールを受信できるように受信拒否設定は解除してください"
        default:
            return ""
        }
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "アップグレード"
                cell.leftImageView.image = UIImage(named: "icons8-シェブロン-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            default:
                return WithIconTableViewCell()
            }
        }
        else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "事業者名" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                cell.leftImageView.image = UIImage(named: "icons8-会社-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "会計期間"
                cell.leftImageView.image = UIImage(named: "icons8-カレンダー10-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "勘定科目"
                cell.leftImageView.image = UIImage(named: "icons8-スタック組織図-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            default:
                return WithIconTableViewCell()
            }
        }
        else if indexPath.section == 2 {
            switch indexPath.row {
                case 0:
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "パスコードロックを利用する"
                cell.leftImageView.image = UIImage(systemName: "key.fill")?.withRenderingMode(.alwaysTemplate)
                if cell.accessoryView == nil {
                    let switchView = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    // 生体認証パスコードロック　設定スイッチ
                    switchView.isOn = UserDefaults.standard.bool(forKey: "biometrics_switch")
                    switchView.tag = indexPath.row
                    switchView.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
                    cell.accessoryView = switchView
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "仕訳"
                cell.leftImageView.image = UIImage(named: "icons8-ペン-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "仕訳帳"
                cell.leftImageView.image = UIImage(named: "icons8-開いた本-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            default:
                return WithIconTableViewCell()
            }
        }
        else {
            switch indexPath.row {
            case 0:
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "使い方ガイド"
                cell.leftImageView.image = UIImage(named: "icons8-情報-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "評価・レビュー"
                cell.leftImageView.image = UIImage(named: "icons8-いいね-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 2:
                // お問い合わせ機能
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "お問い合わせ(要望・不具合報告)"
                cell.leftImageView.image = UIImage(named: "icons8-コミュニケーション-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            default:
                return WithIconTableViewCell()
            }
        }
    }
    // セルがタップされたとき
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsUpgradeTableViewController", sender: tableView.cellForRow(at: indexPath))
                break
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsInformationTableViewController", sender: tableView.cellForRow(at: indexPath))
                break
            case 1:
                performSegue(withIdentifier: "SettingsPeriodTableViewController", sender: tableView.cellForRow(at: indexPath))
                break
            case 2:
                performSegue(withIdentifier: "SettingsCategoryTableViewController", sender: tableView.cellForRow(at: indexPath))
                break
            default:
                break
            }
        }
        else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                
                break
            case 1:
                performSegue(withIdentifier: "SettingsOperatingJournalEntryViewController", sender: tableView.cellForRow(at: indexPath))
                break
            case 2:
                performSegue(withIdentifier: "SettingsOperatingTableViewController", sender: tableView.cellForRow(at: indexPath))
                break
            default:
                break
            }
        }
        else {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "SettingsHelpViewController", sender: tableView.cellForRow(at: indexPath))
                break
            case 1:
                /// TODO: -  アプリ名変更
                // アプリ内でブラウザを開く
                let url = URL(string:"https://apps.apple.com/jp/app/%E8%A4%87%E5%BC%8F%E7%B0%BF%E8%A8%98%E3%81%AE%E4%BC%9A%E8%A8%88%E5%B8%B3%E7%B0%BF-thereckoning-%E3%82%B6-%E3%83%AC%E3%82%B3%E3%83%8B%E3%83%B3%E3%82%B0/id1535793378?l=ja&ls=1&mt=8&action=write-review")
                if let url = url{
                    let vc = SFSafariViewController(url: url)
                    vc.preferredControlTintColor = .AccentBlue
                    present(vc, animated: true, completion: nil)
                }
                break
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
                }
                else {
                    print("送信できません")
                }
                break
            default:
                break
            }
        }
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
