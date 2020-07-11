//
//  TableViewControllerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 損益計算書クラス
class TableViewControllerPL: UITableViewController, UIPrintInteractionControllerDelegate {

    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 損益計算書　計算
        dataBaseManagerPL.initializeBenefits()
        
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.culculatAmountOfAllAccount()
        // 月末、年度末などの決算日をラベルに表示する
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf() //データベースマネジャー
        let company = dataBaseManagerAccountingBooksShelf.getCompany()
        label_company_name.text = company // 社名
//        label_closingDate.text = "令和xx年3月31日"
        let dataBaseManagerPeriod = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_closingDate.text = fiscalYear.description + "年3月31日" // 決算日を表示する
        label_title.text = "損益計算書"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//              損益計算書　計18行　+ 勘定科目
        //営業収益9    売上高10
        //営業費用5    売上原価8
//        売上総利益
        //            販売費及び一般管理費9 ＊販管費はひとまとめにする
//        営業利益
        //営業外収益10                    ＊ひとまとめにせずに勘定科目を列挙する
        //...
        //合計
        //営業外費用6                     ＊ひとまとめにせずに勘定科目を列挙する
        //...
        //合計
//        経常利益
        //特別利益11                      ＊ひとまとめにせずに勘定科目を列挙する
        //...
        //合計
        //特別損失7                       ＊ひとまとめにせずに勘定科目を列挙する
        //...
        //合計
//        税金等調整前当期純利益
        //税等8                           ＊ひとまとめにしない？
        //...
//        当期純利益
        //親会社株主に帰属する当期純利益

        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        let objects = databaseManagerSettings.getMiddleCategory(mid_category: 10)  //営業外収益10
        let objectss = databaseManagerSettings.getMiddleCategory(mid_category: 6)  //営業外費用6
        let objectsss = databaseManagerSettings.getMiddleCategory(mid_category: 11)//特別利益11
        let objectssss = databaseManagerSettings.getMiddleCategory(mid_category: 7)//特別損失7
        return 14 + objects.count + objectss.count + objectsss.count + objectssss.count + 4    //4は合計欄の分
    }

    let dataBaseManagerPL = DataBaseManagerPL()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // 中分類　中分類ごとの数を取得
        let mid_category10 = databaseManagerSettings.getMiddleCategory(mid_category: 10)
        let mid_category6 = databaseManagerSettings.getMiddleCategory(mid_category: 6)
        let mid_category11 = databaseManagerSettings.getMiddleCategory(mid_category: 11)
        let mid_category7 = databaseManagerSettings.getMiddleCategory(mid_category: 7)

        switch indexPath.row {
        case 0: //売上高10
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上高"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する 
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 4, small_category: 10)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case 1: //売上原価8
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上原価"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 3, small_category: 8)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case 2: //売上総利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上総利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 0)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case 3: //販売費及び一般管理費9
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "販売費及び一般管理費"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 3, small_category: 9)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case 4: //営業利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 1)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case 5: //営業外収益10
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外収益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case mid_category10.count + 6: //営業外収益合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外収益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 4, mid_category: 10)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case mid_category10.count + 7: //営業外費用6
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外費用"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case mid_category10.count + mid_category6.count + 8: //営業外費用合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外費用合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 6)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + 9: //経常利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "経常利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 2)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + 10: //特別利益11
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別利益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + 11: //特別利益合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別利益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 4, mid_category: 11)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + 12: //特別損失7
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別損失"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 13: //特別損失合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別損失合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 7)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 14: //税金等調整前当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "税金等調整前当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 3)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 15: //税等8
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "法人税等合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 8)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 16: //当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 4)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 17: //親会社株主に帰属する当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "親会社株主に帰属する当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 4)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        default:
            // 勘定科目
            if       indexPath.row >= 6 &&                              // 営業外収益
                     indexPath.row < mid_category10.count + 6 {         // 営業外収益のタイトルより下の行から、営業外収益合計の行より上
                let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category10[indexPath.row - 6].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerPL.getAccountTotal(big_category: 4, account: mid_category10[indexPath.row - 6].category) //収益:4
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row >= mid_category10.count + 8 &&       // 営業外費用
                     indexPath.row <  mid_category10.count + mid_category6.count + 8 { // 営業外費用のタイトルより下の行から、営業外費用合計の行より上
                let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category6[indexPath.row - (mid_category10.count + 8)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerPL.getAccountTotal(big_category: 3, account: mid_category6[indexPath.row - (mid_category10.count + 8)].category)
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row >= mid_category10.count + mid_category6.count + 11 &&                       // 特別利益
                     indexPath.row <  mid_category10.count + mid_category6.count + mid_category11.count + 11 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category11[indexPath.row - (mid_category10.count + mid_category6.count + 11)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerPL.getAccountTotal(big_category: 4, account: mid_category11[indexPath.row - (mid_category10.count+mid_category6.count+11)].category) //収益:4
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row >= mid_category10.count + mid_category6.count + mid_category11.count + 13 && // 特別損失
                     indexPath.row <  mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 13 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category7[indexPath.row - (mid_category10.count + mid_category6.count + mid_category11.count + 13)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerPL.getAccountTotal(big_category: 3, account: mid_category7[indexPath.row - (mid_category10.count+mid_category6.count+mid_category11.count+13)].category)
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
    //ToDo 税金　勘定科目を表示する
            }else{
                    return tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            }
        }
    }
    
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
        // disable sticky section header
        override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if printing {
                print("scrollView.contentOffset.y   : \(scrollView.contentOffset.y)")
                if scrollView.contentOffset.y <= tableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 { // スクロールがセクション高さ以上かつ0以上
                    scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
                    print("tableView.sectionHeaderHeight:: \(tableView.sectionHeaderHeight)")
                }else if scrollView.contentOffset.y > tableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 { // セクションの重複を防ぐ
                    scrollView.contentInset = UIEdgeInsets(top: (tableView.sectionHeaderHeight+scrollView.contentOffset.y) * -1, left: 0, bottom: 0, right: 0)
                }else if scrollView.contentOffset.y >= tableView.sectionHeaderHeight {
        //            scrollView.contentInset = UIEdgeInsets(top: (tableView.sectionHeaderHeight+scrollView.contentOffset.y) * -1, left: 0, bottom: 0, right: 0)
                    scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
                }
            }else{
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    
        var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet weak var button_print: UIButton!
        /**
         * 印刷ボタン押下時メソッド
         */
        @IBAction func button_print(_ sender: UIButton) {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
            // 第三の方法
            //余計なUIをキャプチャしないように隠す
            tableView.showsVerticalScrollIndicator = false
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
            pageSize = CGSize(width: tableView.contentSize.width / 25.4 * 72, height: tableView.contentSize.height / 25.4 * 72)
            //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
    //        var rect = self.view.bounds
            //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
            //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
            UIGraphicsBeginImageContextWithOptions(pageSize, true, 0.0)
                //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
    //        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
                //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
            //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
    //        let newImage = UIGraphicsGetImageFromCurrentImageContext()
            printing = true
            let newImage = self.tableView.captureImagee()
            //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
            UIGraphicsEndImageContext()
            printing = false
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
            /*
            ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
             CGBitmapContextCreate関数を使用して、コンテキストを作成し、
             それに画像コンテンツを描画します。
             描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
             Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
             完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
            */
            let myImageView = UIImageView(image: newImage)
            myImageView.layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
            
    //PDF
            //p-49 リスト 4-2 ページ単位のコンテンツの描画
                let framePath = NSMutableData()
            //p-45 「PDFコンテキストの作成と設定」
                // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
                //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
                //  UIGraphicsBeginPDFContextToData関数の場合、
                //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
                UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
            print(" myImageView.bounds : \(myImageView.bounds)")
            //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
                UIGraphicsBeginPDFPage()
             /* PDFページの描画
               UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
               UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
            */
            //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
                // グラフィックスコンテキストを取得する
                guard let currentContext = UIGraphicsGetCurrentContext() else { return }
                myImageView.layer.render(in: currentContext)
                //描画が終了したら、UIGraphicsEndPDFContextを呼び出して、PDFグラフィックスコンテキストを閉じます。
                UIGraphicsEndPDFContext()
                
    //ここからプリントです
            //p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
            let pic = UIPrintInteractionController.shared
            if UIPrintInteractionController.canPrint(framePath as Data) {
                //pic.delegate = self;
                pic.delegate = self
                
                let printInfo = UIPrintInfo.printInfo()
                printInfo.outputType = .general
                printInfo.jobName = "Profit And Loss Statement"
                printInfo.duplex = .none
                pic.printInfo = printInfo
                //'showsPageRange' was deprecated in iOS 10.0: Pages can be removed from the print preview, so page range is always shown.
                pic.printingItem = framePath
        
                let completionHandler: (UIPrintInteractionController, Bool, NSError) -> Void = { (pic: UIPrintInteractionController, completed: Bool, error: Error?) in
                    
                    if !completed && (error != nil) {
                        print("FAILED! due to error in domain %@ with error code %u \(String(describing: error))")
                    }
                }
                //p-79 印刷インタラクションコントローラを使って印刷オプションを提示
                //UIPrintInteractionControllerには、ユーザに印刷オプションを表示するために次の3つのメソッ ドが宣言されており、それぞれアニメーションが付属しています。
                if UIDevice.current.userInterfaceIdiom == .pad {
                    //これらのうちの2つは、iPadデバイス上で呼び出されることを想定しています。
                    //・presentFromBarButtonItem:animated:completionHandler:は、ナビゲーションバーまたは ツールバーのボタン(通常は印刷ボタン)からアニメーションでPopover Viewを表示します。
    //                print("通過・printButton.frame -> \(button_print.frame)")
    //                print("通過・printButton.bounds -> \(button_print.bounds)")
                    //UIBarButtonItemの場合
                    //pic.present(from: printUIButton, animated: true, completionHandler: nil)
                    //・presentFromRect:inView:animated:completionHandler:は、アプリケーションのビューの任意の矩形からアニメーションでPopover Viewを表示します。
                    pic.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: nil)
                    print("iPadです")
                } else {
                    //モーダル表示
                    //・presentAnimated:completionHandler:は、画面の下端からスライドアップするページをアニ メーション化します。これはiPhoneおよびiPod touchデバイス上で呼び出されることを想定しています。
                    pic.present(animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                    print("iPhoneです")
                }
            }
            //余計なUIをキャプチャしないように隠したのを戻す
            tableView.showsVerticalScrollIndicator = true
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

        }
        
        // MARK: - UIImageWriteToSavedPhotosAlbum
        
        @objc func didFinishWriteImage(_ image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer) {
            if let error = error {
            print("Image write error: \(error)")
            }
        }

        func printInteractionController ( _ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
            print("printInteractionController")
            for i in 0..<paperList.count {
                let paper: UIPrintPaper = paperList[i]
            print(" paperListのビクセル is \(paper.paperSize.width) \(paper.paperSize.height)")
            }
            //ピクセル
            print(" pageSizeピクセル    -> \(pageSize)")
            let bestPaper = UIPrintPaper.bestPaper(forPageSize: pageSize, withPapersFrom: paperList)
            //mmで用紙サイズと印刷可能範囲を表示
            print(" paperSizeミリ      -> \(bestPaper.paperSize.width / 72.0 * 25.4), \(bestPaper.paperSize.height / 72.0 * 25.4)")
            print(" bestPaper         -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4), \(bestPaper.printableRect.origin.y / 72.0 * 25.4), \(bestPaper.printableRect.size.width / 72.0 * 25.4), \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
            return bestPaper
        }
    
}
