//
//  HTMLhelperMonthlyBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/10/14.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

struct HTMLhelperMonthlyBS {
    
    // 月別の月末日を取得 12ヶ月分
    let dates = DateManager.shared.getTheDayOfEndingOfMonth()

    // PDFごとに1回コール
    func headerHTMLstring() -> String {
        // htmlヘッダーを生成します。
        // たとえば、ここに店の名前を入力できます
        return """
    <!DOCTYPE html>
        <html>
    
        <style type="text/css" media="all">
    
    <!--     /*　位置　*/ -->
            .center {
                text-align: center;
            }
            .left {
                text-align: left;
    <!--     text-indent: 20px;  -->
            }
            .textIndent1 {
                  text-indent: 20px; }
            .textIndent2 {
                  text-indent: 40px; }
            .textIndent3 {
                  text-indent: 60px; }
            .textIndent4 {
                  text-indent: 80px; }
            .textIndent5 {
                  text-indent: 100px; }
    
            .right {
                margin-right: 5px;
                margin-left: auto;
                width: auto;
                text-align: right; /*　rightを指定すると改ページされてしまう　*/
            }
    <!--     /*　色　*/ -->
            .white {
                color: #FFFFFF;
            }
            .black {
                color: #000000;
            }
            .clearColor {
                color: #FFFFFF;
            }
            .skyBlueBackgroundColor {
                  background-color: #e5f0fa;}
            .yellowBackgroundColor {
                  background-color: #ffff00; }
            .BlueBackgroundColor {
                  background-color: #008080;}
            .accentColor10 {
                  background-color: rgb(65 105 225 / 10%);}
            .accentColor20 {
                  background-color: rgb(65 105 225 / 20%);}
            .accentColor30 {
                  background-color: rgb(65 105 225 / 30%);}
    <!--     /*　罫線　*/ -->
            .line_single_gray_bottom {
                border-bottom: 1px solid #888;
            }
            .line_double_red_top {
                border-top: 3px double #f66;
            }
            .line_double_red_right {
                border-right: 3px double #f66;
            }
            .line_single_red_left {
                border-left: : 1px solid #f66;
            }
            .line_single_red_right {
                border-right: 1px solid #f66;
            }
            .line_single_red_bottom {
                border-bottom: 1px solid #f66;
            }
            .line_single_blue_right {
                border-right: 1px solid #66b3ff;
            }
            .line_single_blue_bottom {
                border-bottom: 1px solid #66b3ff;
            }
            .line_single_black_all {
                border: 1px solid #05203a;
            }
    <!--     /*　サイズ　フォント　*/ -->
            .fontsize60 {
                font-size: 60%;
            }
            .fontsize80 {
                font-size: 80%;
            }
            .fontsize95 {
                font-size: 95%;
            }
    
            .flex-colum {
                display: flex;
                flex-direction: column;
                margin: 0px;
            }
    <!--     /*　サイズ　幅　*/ -->
            .date {
                width: 11.7647058824%;/*　22mm　5.8823529412% 11mm　*/
            }
            .smallWritting {
                width: 41.7112299465%;/*　78mm　*/
            }
            .numberOfAccount {
                width: 5.3475935829%;/*　10mm　*/
            }
            .amount {
                width: 19.7860962567%;/*　37mm　*/
            }
    <!--     /*　サイズ　高さ　*/ -->
            .rowHeight {
                height: auto;/*  2.7237354086% 7mm　*/
            }
    
        html {
        }
        body {
        }
            section {
            }
                h2 {
                    width: 50%;
                }
                table {
                    width: 100%;
                }
                    thead {
    <!--                     height: 5.0583657588%;/*　13mm　*/ -->
                    }
                    tbody {
                    }
                    tfoot {
                        height: 5mm;
    <!--                     height: 10.5058365758%;/*　1.9455252918% 5mm　*/ -->
                    }
        .page{
            width: 297mm;
            height: auto;
            box-sizing: border-box;
            padding: 0mm 10mm;
            display: block;
    <!--         break-after: always; -->
        }
    <!--     /* ■ テーブル全体、セルの横幅、高さを%で指定
        width="%"で指定した場合、テーブルの横幅は画面全体100%に対する割合 の長さになります。 テーブルの横幅が50%だと画面全体の2分の1、つまり半分の大きさということ になります。
    
        テーブルの横幅と高さを指定してある時でセルの横幅、高さを%で指定した場合、 それらの大きさはテーブル全体に対する割合の大きさになります。 */ -->
    
        .richediter {
      line-height: 1.0; }
       .richediter ul, .richediter ol {
        margin: 20px 10px; }
        .richediter ul li, .richediter ol li {
          margin-bottom: 15px; }
      .richediter [class^="col-"] > ul,
      .richediter [class^="col-"] > ol {
        margin: 0 15px; }
      .richediter ul li {
        padding-left: 20px;
        text-indent: -20px; }
        .richediter ul li:before {
          content: '';
          display: inline-block;
          width: 6px;
          height: 6px;
          margin-right: 14px;
          vertical-align: 2px;
          background-color: #384d61; }
      .richediter ol {
        list-style-type: decimal; }
        .richediter ol li {
          margin-left: 2em; }
      .richediter dl {
        margin: 30px 0; }
      .richediter dt {
        font-weight: normal; }
      .richediter dd {
        margin: 12px 0 24px 1em; }
    
        .richediter h2 {
      display: table;
      font-family: "FOT-ロダン Pro DB", sans-serif;
      font-size: 20px;
      text-align: center;
      line-height: 1.28;
      margin: 0 auto;
      padding: 0 0.6em 3px;
      border-bottom: 1px solid; }
    
    .borderTop {
        border-top: 1px solid; }
    .borderBottom {
        border-bottom: 1px solid; }
    
       .richediter th, td {
    <!--   border: 1px solid #05203a; -->
      padding: 5px; }
    
      .l-container {
      margin: auto; }
    
    table {
        border-collapse: collapse;
        border-spacing: 0; }
    
        table{
        margin: 0px 0; }
    
      th, td {
              font-size: 12px;
      border: 1px solid #05203a;
      padding: 2px; }
    
      th {
      width: auto;
      <!--   テーブルレコードの色 -->
      background-color: #e5f0fa;
      }
      td {
        width: 6.5%;
      }
      tfoot td, tfoot th {
          border: 0px solid #05203a;
      }
    
    <!--   body {
        font-size: 13px;
    } -->
      .text-right {
        text-align: right;
    }
    .public-notice td {
        text-align: right;
    }
    .flex{
        display: flex;
    }
     .margin5 {
            margin-top: 5px;}
     .margin10 {
            margin-top: 10px;}
     .margin20 {
            margin-top: 20px;}
     .marginBottomAuto {
            margin-bottom: auto;}
    
    .halfWidth {
        width: 50%;
    }
        </style>
        <body>
    
    """
    }
    // PDFごとに1回コール
    func footerHTMLstring() -> String {
         """
        </body>
    </html>
    """
    }
    
    // ページごとに1回コール
    func headerstring(company: String, fiscalYear: Int, theDayOfReckoning: String, pageNumber: Int) -> String {
         """
        <section class="page">
            <div class="richediter public-notice l-container">
    
                <p class="text-right">\(DateManager.shared.getDate())</p>
                <h2>貸借対照表</h2>
                <div class="flex">
                    <span class="halfWidth">\(company)</span>
                    <span class="halfWidth"><p class="right"> (\(theDayOfReckoning == "12/31" ? fiscalYear : fiscalYear + 1)/\(theDayOfReckoning) 現在)<br> (単位:円)<br><br>No.　　　\(pageNumber)</p></span>
                </div>
    
                <div>
    """
    }
    // ページごとに1回コール
    func footerstring() -> String {
         """
                </div>
            </div>
        </section>
        """
    }
    
    // テーブル　トップ
    func tableTopString(monthes: [String: String]) -> String {
         """
    <table>
        <thead>
            <tr class="accentColor10">
                <th></th>
                <td>\(String(describing: monthes["\(dates[0].year)" + "-" + "\(String(format: "%02d", dates[0].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[1].year)" + "-" + "\(String(format: "%02d", dates[1].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[2].year)" + "-" + "\(String(format: "%02d", dates[2].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[3].year)" + "-" + "\(String(format: "%02d", dates[3].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[4].year)" + "-" + "\(String(format: "%02d", dates[4].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[5].year)" + "-" + "\(String(format: "%02d", dates[5].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[6].year)" + "-" + "\(String(format: "%02d", dates[6].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[7].year)" + "-" + "\(String(format: "%02d", dates[7].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[8].year)" + "-" + "\(String(format: "%02d", dates[8].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[9].year)" + "-" + "\(String(format: "%02d", dates[9].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[10].year)" + "-" + "\(String(format: "%02d", dates[10].month))"] ?? ""))</td>
                <td>\(String(describing: monthes["\(dates[11].year)" + "-" + "\(String(format: "%02d", dates[11].month))"] ?? ""))</td>
                <td>\(dates.count == 13 ? String(describing: monthes["\(dates[12].year)" + "-" + "\(String(format: "%02d", dates[12].month))"] ?? "") : "")</td>
            </tr>
            <tr class="accentColor10">
                <th>勘定科目</th>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
        </thead>
        <tbody>
    """
    }
    // テーブル　エンド
    func tableEndString() -> String {
         """
        </tbody>
        <tfoot>
            <tr>
                <th id="asset-1" class="left"></th>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td colspan="4" class="fontsize80"><p class="right">©複式簿記の会計帳簿 Paciolist</p></td>
            </tr>
        </tfoot>
    </table>
    """
    }
    
    // 中区分 合計
    func middleRowEnd(title: String, monthes: [String: String]) -> String {
         """
        <tr class="accentColor20">
            <th id="asset-1" class="right">\(title)</th>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[0].year)" + "-" + "\(String(format: "%02d", dates[0].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[1].year)" + "-" + "\(String(format: "%02d", dates[1].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[2].year)" + "-" + "\(String(format: "%02d", dates[2].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[3].year)" + "-" + "\(String(format: "%02d", dates[3].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[4].year)" + "-" + "\(String(format: "%02d", dates[4].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[5].year)" + "-" + "\(String(format: "%02d", dates[5].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[6].year)" + "-" + "\(String(format: "%02d", dates[6].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[7].year)" + "-" + "\(String(format: "%02d", dates[7].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[8].year)" + "-" + "\(String(format: "%02d", dates[8].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[9].year)" + "-" + "\(String(format: "%02d", dates[9].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[10].year)" + "-" + "\(String(format: "%02d", dates[10].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(String(describing: monthes["\(dates[11].year)" + "-" + "\(String(format: "%02d", dates[11].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderBottom">\(dates.count == 13 ? String(describing: monthes["\(dates[12].year)" + "-" + "\(String(format: "%02d", dates[12].month))"] ?? "") : "")</td>
        </tr>
    """
    }

    // レコードごとに1回コール
    func getSingleRow(title: String, monthes: [String: String]) -> String {
         """
        <tr>
            <th id="asset-1" class="left">\(title)</th>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[0].year)" + "-" + "\(String(format: "%02d", dates[0].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[1].year)" + "-" + "\(String(format: "%02d", dates[1].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[2].year)" + "-" + "\(String(format: "%02d", dates[2].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[3].year)" + "-" + "\(String(format: "%02d", dates[3].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[4].year)" + "-" + "\(String(format: "%02d", dates[4].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[5].year)" + "-" + "\(String(format: "%02d", dates[5].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[6].year)" + "-" + "\(String(format: "%02d", dates[6].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[7].year)" + "-" + "\(String(format: "%02d", dates[7].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[8].year)" + "-" + "\(String(format: "%02d", dates[8].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[9].year)" + "-" + "\(String(format: "%02d", dates[9].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[10].year)" + "-" + "\(String(format: "%02d", dates[10].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(String(describing: monthes["\(dates[11].year)" + "-" + "\(String(format: "%02d", dates[11].month))"] ?? ""))</td>
            <td headers="assets asset-1">\(dates.count == 13 ? String(describing: monthes["\(dates[12].year)" + "-" + "\(String(format: "%02d", dates[12].month))"] ?? "") : "")</td>
        </tr>
    """
    }
    
    // レコードごとに1回コール 段落0 五つの利益
    func getSingleRowForBenefits(title: String, monthes: [String: String]) -> String {
         """
        <tr class="accentColor30">
            <th id="asset-1" class="right">\(title)</th>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[0].year)" + "-" + "\(String(format: "%02d", dates[0].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[1].year)" + "-" + "\(String(format: "%02d", dates[1].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[2].year)" + "-" + "\(String(format: "%02d", dates[2].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[3].year)" + "-" + "\(String(format: "%02d", dates[3].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[4].year)" + "-" + "\(String(format: "%02d", dates[4].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[5].year)" + "-" + "\(String(format: "%02d", dates[5].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[6].year)" + "-" + "\(String(format: "%02d", dates[6].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[7].year)" + "-" + "\(String(format: "%02d", dates[7].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[8].year)" + "-" + "\(String(format: "%02d", dates[8].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[9].year)" + "-" + "\(String(format: "%02d", dates[9].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[10].year)" + "-" + "\(String(format: "%02d", dates[10].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(String(describing: monthes["\(dates[11].year)" + "-" + "\(String(format: "%02d", dates[11].month))"] ?? ""))</td>
            <td headers="assets asset-1" class="borderTop borderBottom">\(dates.count == 13 ? String(describing: monthes["\(dates[12].year)" + "-" + "\(String(format: "%02d", dates[12].month))"] ?? "") : "")</td>
        </tr>
    """
    }
}
