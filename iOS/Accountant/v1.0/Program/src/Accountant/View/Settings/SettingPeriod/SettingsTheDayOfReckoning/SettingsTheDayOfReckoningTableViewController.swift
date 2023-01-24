//
//  SettingsTheDayOfReckoningTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/17.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 設定決算日
class SettingsTheDayOfReckoningTableViewController: UITableViewController {

    var gADBannerView: GADBannerView!
    
    var month = false // 決算日設定月
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: 30 * -1)
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if month {
            return 12
        } else {
            return 31
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        var date = ""
        if month {
            let dateMonth = theDayOfReckoning[
                theDayOfReckoning.index(
                    theDayOfReckoning.startIndex,
                    offsetBy: 0
                )..<theDayOfReckoning.index(
                    theDayOfReckoning.startIndex,
                    offsetBy: 1
                )
            ] // 日付のx文字目にある月の十の位を抽出
            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                date = String(
                    theDayOfReckoning[
                        theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 1
                        )..<theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 2
                        )
                    ]
                ) // 日付のx文字目にある日の十の位を抽出
            } else {
                date = String(
                    theDayOfReckoning[
                        theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 0
                        )..<theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 2
                        )
                    ]
                ) // 日付のx文字目にある日の十の位を抽出
            }
        } else {
            let dateday = theDayOfReckoning[
                theDayOfReckoning.index(
                    theDayOfReckoning.startIndex,
                    offsetBy: 3
                )..<theDayOfReckoning.index(
                    theDayOfReckoning.startIndex,
                    offsetBy: 4
                )
            ] // 日付のx文字目にある日の十の位を抽出
            if dateday == "0" { // 日の十の位が0の場合は表示しない
                date = String(
                    theDayOfReckoning[
                        theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 4
                        )..<theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 5
                        )
                    ]
                ) // 日付のx文字目にある日の十の位を抽出
            } else {
                date = String(
                    theDayOfReckoning[
                        theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 3
                        )..<theDayOfReckoning.index(
                            theDayOfReckoning.startIndex,
                            offsetBy: 5
                        )
                    ]
                ) // 日付のx文字目にある日の十の位を抽出
            }
            // 月別に日数を調整する
            switch theDayOfReckoning.prefix(2) {
            case "02":
                if "\(indexPath.row + 1)" == "29" || "\(indexPath.row + 1)" == "30" || "\(indexPath.row + 1)" == "31" {
                    cell.textLabel?.textColor = .lightGray
                }
            case "04", "06", "09", "11":
                if "\(indexPath.row + 1)" == "31" {
                    cell.textLabel?.textColor = .lightGray
                }
            default:
                // nothing
                break
            }
        }
        if String(indexPath.row + 1) == date {
            // チェックマークを入れる
            cell.accessoryType = .checkmark
        } else {
            // チェックマークを外す
            cell.accessoryType = .none
        }
        cell.textLabel?.text = "\(indexPath.row + 1)"
        // 月または日　タグ
        cell.tag = indexPath.row + 1
        return cell
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 決算日設定
        if let cell = tableView.cellForRow(at: indexPath) {
            if month { // 月
                // チェックマークを入れる
                cell.accessoryType = .checkmark
                // ここからデータベースを更新する
                pickDate(date: String(cell.tag)) // 決算日　月　日
                // 年度を選択時に会計期間画面を更新する
                tableView.reloadData()
            } else { // 日
                // 月別に日数を調整する
                let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
                // 月別に日数を調整する
                switch theDayOfReckoning.prefix(2) {
                case "02":
                    if "\(indexPath.row + 1)" == "29" || "\(indexPath.row + 1)" == "30" || "\(indexPath.row + 1)" == "31" {
                        // タップ無効化
                    } else {
                        // チェックマークを入れる
                        cell.accessoryType = .checkmark
                        // ここからデータベースを更新する
                        pickDate(date: String(cell.tag)) // 決算日　月　日
                        // 年度を選択時に会計期間画面を更新する
                        tableView.reloadData()
                    }
                case "04", "06", "09", "11":
                    if "\(indexPath.row + 1)" == "31" {
                        // タップ無効化
                    } else {
                        // チェックマークを入れる
                        cell.accessoryType = .checkmark
                        // ここからデータベースを更新する
                        pickDate(date: String(cell.tag)) // 決算日　月　日
                        // 年度を選択時に会計期間画面を更新する
                        tableView.reloadData()
                    }
                default:
                    // チェックマークを入れる
                    cell.accessoryType = .checkmark
                    // ここからデータベースを更新する
                    pickDate(date: String(cell.tag)) // 決算日　月　日
                    // 年度を選択時に会計期間画面を更新する
                    tableView.reloadData()
                }
            }
        }
    }
    // チェックマークの切り替え　データベースを更新
    func pickDate(date: String) {
        // データベース
        DataBaseManagerSettingsPeriod.shared.setTheDayOfReckoning(month: month, date: date)
    }
}
