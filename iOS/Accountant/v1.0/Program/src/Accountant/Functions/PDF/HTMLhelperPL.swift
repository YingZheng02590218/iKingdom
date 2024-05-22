//
//  HTMLhelperPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/22.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

struct HTMLhelperPL {
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
                width: 70%;
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
    <!--                     height: 10.5058365758%;/*　1.9455252918% 5mm　*/ -->
                    }
        .page{
            width: 210mm;
            height: 294mm;
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
            border: 1px solid #05203a;
      border-collapse: collapse;
      border-spacing: 0; }
    
        table{
        margin: 0px 0; }
    
      th, td {
              font-size: 12px;
      border: 0px solid #05203a;
      padding: 2px; }
    
      th {
      width: 70%;
      <!--   テーブルレコードの色 -->
      background-color: #e5f0fa;
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
    func headerstring(company: String, fiscalYear: Int, theDayOfReckoning: String) -> String {
         """
        <section class="page">
            <div class="richediter public-notice l-container">
    
                <p class="text-right">\(DateManager.shared.getDate())</p>
                <h2>損益計算書</h2>
                <div class="flex">
                    <span class="halfWidth">\(company)</span>
                    <span class="halfWidth"><p class="right"> (\(theDayOfReckoning == "12/31" ? fiscalYear : fiscalYear + 1)/\(theDayOfReckoning) 現在)<br> (単位:円)</p></span>
                </div>
    
            <div>
    """
    }
    // ページごとに1回コール
    func footerstring() -> String {
         """
                </div>
        <p class="fontsize95 right margin5">©複式簿記の会計帳簿 Paciolist</p>
        </div>
        </section>
        """
    }
    
    // テーブル　トップ
    func tableTopString() -> String {
         """
    <table>
                <tbody>
    """
    }
    // テーブル　エンド
    func tableEndString() -> String {
         """
    </tbody>
    </table>
    """
    }
    
    // 中区分 合計 売上高、売上原価
    func middleRowEndIndent0space(title: String, amount: String) -> String {
         """
                <tr>
                <th id="asset-1" class="left">\(title)</th>
                <td headers="assets asset-1">\(amount)</td>
                </tr>
    """
    }
    // 中区分 段落0　販売費及び一般管理費
    func middleRowTop(title: String) -> String {
         """
                <tr>
                <th id="asset-1" class="left">\(title)</th>
                <td headers="assets asset-1"></td>
                </tr>
    """
    }
    // 中区分 合計 段落1
    func middleRowEnd(title: String, amount: String) -> String {
         """
    <tr  class="skyBlueBackgroundColor">
                <th id="asset-1" class="left textIndent1">\(title)</th>
                <td headers="assets asset-1" class="borderBottom">\(amount)</td>
                </tr>
    """
    }
    
    // レコードごとに1回コール 段落1
    func getSingleRow(title: String, amount: String) -> String {
         """
    <tr>
                <th id="asset-1" class="left textIndent1">\(title)</th>
                <td headers="assets asset-1">\(amount)</td>
                </tr>
    """
    }
    
    // レコードごとに1回コール 段落0 五つの利益
    func getSingleRowForBenefits(title: String, amount: String) -> String {
         """
    <tr  class="skyBlueBackgroundColor">
                <th id="asset-1" class="left">\(title)</th>
                <td headers="assets asset-1" class="borderTop borderBottom">\(amount)</td>
                </tr>
    """
    }
}
