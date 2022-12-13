//
//  SettingsTheDayOfReckoningTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/17.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 設定決算日
class SettingsTheDayOfReckoningTableViewController: UITableViewController {

    
    @IBOutlet var gADBannerView: GADBannerView!
    
    var month: Bool = false // 決算日設定月
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: 30 * -1)
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
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
        }else {
            return 31
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let object = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        var date = ""
        let d = object
        if month {
            let dateMonth = d[d.index(d.startIndex, offsetBy: 0)..<d.index(d.startIndex, offsetBy: 1)] // 日付のx文字目にある月の十の位を抽出
            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                date = String(d[d.index(d.startIndex, offsetBy: 1)..<d.index(d.startIndex, offsetBy: 2)]) // 日付のx文字目にある日の十の位を抽出
            }else {
                date = String(d[d.index(d.startIndex, offsetBy: 0)..<d.index(d.startIndex, offsetBy: 2)]) // 日付のx文字目にある日の十の位を抽出
            }
        }else {
            let dateday = d[d.index(d.startIndex, offsetBy: 3)..<d.index(d.startIndex, offsetBy: 4)] // 日付のx文字目にある日の十の位を抽出
            if dateday == "0" { // 日の十の位が0の場合は表示しない
                date = String(d[d.index(d.startIndex, offsetBy: 4)..<d.index(d.startIndex, offsetBy: 5)]) // 日付のx文字目にある日の十の位を抽出
            }else {
                date = String(d[d.index(d.startIndex, offsetBy: 3)..<d.index(d.startIndex, offsetBy: 5)]) // 日付のx文字目にある日の十の位を抽出
            }
            // 月別に日数を調整する
            switch d.prefix(2) {
            case "02":
                if "\(indexPath.row+1)" == "29" || "\(indexPath.row+1)" == "30" || "\(indexPath.row+1)" == "31" {
                    cell.textLabel?.textColor = .lightGray
                }
                break
            case "04","06","09","11":
                if "\(indexPath.row+1)" == "31" {
                    cell.textLabel?.textColor = .lightGray
                }
                break
            default:
                break
            }
        }
        if String(indexPath.row + 1) == date {
            // チェックマークを入れる
            cell.accessoryType = .checkmark
        }else {
            // チェックマークを外す
            cell.accessoryType = .none
        }
        cell.textLabel?.text = "\(indexPath.row+1)"
        // 月または日　タグ
        cell.tag = indexPath.row + 1
        return cell
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 決算日設定
        let cell = tableView.cellForRow(at:indexPath)
        if month { // 月
            // チェックマークを入れる
            cell?.accessoryType = .checkmark
            // ここからデータベースを更新する
            pickDate(date: String(cell!.tag)) // 決算日　月　日
            // 年度を選択時に会計期間画面を更新する
            tableView.reloadData()
        }else { // 日
            // 月別に日数を調整する
            let object = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var date = ""
            let d = object
            // 月別に日数を調整する
            switch d.prefix(2) {
            case "02":
                if "\(indexPath.row+1)" == "29" || "\(indexPath.row+1)" == "30" || "\(indexPath.row+1)" == "31" {
                    // タップ無効化
                }else {
                    // チェックマークを入れる
                    cell?.accessoryType = .checkmark
                    // ここからデータベースを更新する
                    pickDate(date: String(cell!.tag)) // 決算日　月　日
                    // 年度を選択時に会計期間画面を更新する
                    tableView.reloadData()
                }
                break
            case "04","06","09","11":
                if "\(indexPath.row+1)" == "31" {
                    // タップ無効化
                }else {
                    // チェックマークを入れる
                    cell?.accessoryType = .checkmark
                    // ここからデータベースを更新する
                    pickDate(date: String(cell!.tag)) // 決算日　月　日
                    // 年度を選択時に会計期間画面を更新する
                    tableView.reloadData()
                }
                break
            default:
                // チェックマークを入れる
                cell?.accessoryType = .checkmark
                // ここからデータベースを更新する
                pickDate(date: String(cell!.tag)) // 決算日　月　日
                // 年度を選択時に会計期間画面を更新する
                tableView.reloadData()
                break
            }
        }
    }
    // チェックマークの切り替え　データベースを更新
    func pickDate(date: String) {
        // データベース
        DataBaseManagerSettingsPeriod.shared.setTheDayOfReckoning(month: month, date: date)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
