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
    
//    // マネタイズ対応
//    // 広告ユニットID
//    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
//    // テスト用広告ユニットID
//    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
//    #if DEBUG
//    let AdMobTest:Bool = true    // true:テスト
//    #else
//    let AdMobTest:Bool = false
//    #endif
//    @IBOutlet var gADBannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
//        // アップグレード機能　スタンダードプラン
//        if !inAppPurchaseFlag {
//            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
//    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
//            // GADBannerView を作成する
//            gADBannerView = GADBannerView(adSize:kGADAdSizeMediumRectangle)
//            // GADBannerView プロパティを設定する
//            if AdMobTest {
//                gADBannerView.adUnitID = TEST_ID
//            }
//            else{
//                gADBannerView.adUnitID = AdMobID
//            }
//            gADBannerView.rootViewController = self
//            // 広告を読み込む
//            gADBannerView.load(GADRequest())
//            // GADBannerView を作成する
//            addBannerViewToView(gADBannerView, constant:  self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1) // 一番したから3行分のスペースを空ける
//        }
        // ナビゲーションを透明にする処理
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
//    func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
//      bannerView.translatesAutoresizingMaskIntoConstraints = false
//      view.addSubview(bannerView)
//      view.addConstraints(
//        [NSLayoutConstraint(item: bannerView,
//                            attribute: .bottom,
//                            relatedBy: .equal,
//                            toItem: bottomLayoutGuide,
//                            attribute: .top,
//                            multiplier: 1,
//                            constant: constant),
//         NSLayoutConstraint(item: bannerView,
//                            attribute: .centerX,
//                            relatedBy: .equal,
//                            toItem: view,
//                            attribute: .centerX,
//                            multiplier: 1,
//                            constant: 0)
//        ])
//     }


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
            return 2
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
            return "開発者へメールを送信することができます。"
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
                cell.centerLabel.text = "仕訳"
                cell.leftImageView.image = UIImage(named: "icons8-ペン-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell
                cell.centerLabel.text = "仕訳帳"
                cell.leftImageView.image = UIImage(named: "icons8-開いた本-25")?.withRenderingMode(.alwaysTemplate)
                return cell
            default:
                return WithIconTableViewCell()
            }
        }else {
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
                cell.centerLabel.text = "問い合わせ(要望・不具合報告など)"
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
                performSegue(withIdentifier: "SettingsOperatingJournalEntryViewController", sender: tableView.cellForRow(at: indexPath))
                break
            case 1:
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
                    mail.setToRecipients(["paciolist@gmail.com"])   // 宛先アドレス
                    mail.setSubject("問い合わせ")                          // 件名
                    mail.setMessageBody("", isHTML: false)             // 本文
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
