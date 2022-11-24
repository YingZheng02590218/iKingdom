//
//  HTMLhelper.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

struct HTMLhelper {
    
    func headerHTMLstring() -> String {
        //htmlヘッダーを生成します。
        //たとえば、ここに店の名前を入力できます
        return """
    <!DOCTYPE html>
    <html>

    <style type="text/css" media="all">
        * {
            margin: 0px;
            padding: 0px;
        }
    /*　位置　*/
        .center {
            text-align: center;
        }
        .left {
            text-align: left;
        }
        .right {
            margin-right: 5px;
            margin-left: auto;
            width: 50%;
            text-align: right; /*　rightを指定すると改ページされてしまう　*/
        }
    /*　色　*/
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
    /*　罫線　*/
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
    /*　サイズ　フォント　*/
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
    /*　サイズ　幅　*/
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
    /*　サイズ　高さ　*/
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
                height: 8.560311284%;/*   22mm　*/
            }
            table {
                width: 100%;
                height: 91.439688716%;/*   235mm　*/
            }
                thead {
                    height: 5.0583657588%;/*　13mm　*/
                }
                tbody {
                    height: 84.4357976654%;/*　217mm　*/
                }
                tfoot {
                    height: 10.5058365758%;/*　1.9455252918% 5mm　*/
                }
    .page{
        width: 210mm;
        height: 296mm;
        box-sizing: border-box;
        padding: 0mm 10mm;
        display: block;
        break-after: always;
    }
    /* ■ テーブル全体、セルの横幅、高さを%で指定
    width="%"で指定した場合、テーブルの横幅は画面全体100%に対する割合 の長さになります。 テーブルの横幅が50%だと画面全体の2分の1、つまり半分の大きさということ になります。

    テーブルの横幅と高さを指定してある時でセルの横幅、高さを%で指定した場合、 それらの大きさはテーブル全体に対する割合の大きさになります。 */

        .richediter {
      line-height: 1.4; }
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
          padding: 0 0.6em 10px; }

    .borderTop {
        border-top: 1px solid; }
    .borderBottom {
        border-bottom: 1px solid; }

        .richediter th, td {
    <!--   border: 1px solid #05203a; -->
        padding: 5px; }

      .l-container {
      margin: auto; }

        table{
        margin: 0px 0; }

      th, td {
              font-size: 15px;
      border: 0px solid #05203a;
      padding: 5px; }

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
    
    func headerstring(title: String, fiscalYear: Int, pageNumber: Int) -> String {
        // let margin = pageNumber % 2 == 0 ? "margin-right" : "margin-left"
        // style="\(margin): 5.8823529412%;"

        return """
        <section class="page">
            <div class="richediter l-container">

            <p class="text-right margin5">\(DateManager.shared.getDate())</p>
            <h2 class="center">\(title)</h2>
            <table>
              <thead>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td colspan="6" class="fontsize95 line_single_gray_bottom" style="font-size: 18px; text-align: start; width: 10%;">No.　　　\(pageNumber)</td>
                </tr>
                <tr class="line_double_red_top line_single_red_bottom">
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom date" colspan="2">
                    <div class="center">
                      <span class="fontsize95">\(fiscalYear)年</span>
                    </div>
                    <div class="center">
                      <p class="fontsize95 center">　月  　日</p>
                    </div>
                  </td>
                  <td class="smallWritting line_double_red_top line_single_red_bottom line_single_red_left line_double_red_right">
                    <div class="center">
                      <span class="fontsize95 center">摘　</span>
                      <span class="fontsize95 center">　要</span>
                    </div>
                  </td>
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom numberOfAccount">
                    <div class="center flex-colum">
                      <span class="fontsize60">丁</span><span class="fontsize60">数</span>
                    </div>
                  </td>
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom amount">
                    <div class="center">
                      <span class="fontsize95">借　</span><span class="fontsize95">　方</span>
                    </div>
                  </td>
                  <td class="line_double_red_top line_single_red_bottom amount">
                    <div class="center">
                      <span class="fontsize95">貸　</span><span class="fontsize95">　方</span>
                    </div>
                  </td>
                </tr>
              </thead>
                <tfoot>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td colspan="6" class="fontsize60">©複式簿記の会計帳簿 Paciolist</td>
                    </tr>
                </tfoot>
              <tbody>
    """
    }
    
    func getSingleRow(month: String, day: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, numberOfAccountCredit: Int, numberOfAccountDebit: Int) -> String {
        return """
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom fontsize95 center">\(month)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(day)</td>
                  <td class="smallWritting line_single_blue_bottom line_double_red_right left fontsize95">\(debit_category)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(numberOfAccountDebit == 0 ? "" : String(numberOfAccountDebit))</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95"><p class="right">\(String(debit_amount))</p></td>
                  <td class="line_single_blue_bottom"></td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom center"></td>
                  <td class="line_double_red_right line_single_blue_bottom center"></td>
                  <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95"><p class="right">\(credit_category)</p></td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(numberOfAccountCredit == 0 ? "" : String(numberOfAccountCredit))</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom fontsize95"><p class="right">\(String(credit_amount))</p></td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom"></td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="smallWritting line_single_blue_bottom line_double_red_right left fontsize80">\(smallWritting)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom"></td>
                </tr>
    """
    }

    func getSingleRowEmpty() -> String {
        return """
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize95 clearColor"> あ</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom center fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom center fontsize95 clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize95 clearColor"> あ</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize95 clearColor"> あ</td>
                 </tr>
    """
    }

    func footerstring(debit_amount: Int64, credit_amount: Int64) -> String {
        return """
                 <tr class="rowHeight">
                    <td class="line_single_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                    <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                    <td class="line_single_blue_bottom fontsize95 clearColor"> あ</td>
                  </tr>
              </tbody>
            </table>
                        </div>
        </section>
        """
    }

    func footerHTMLstring() -> String {
        return """
        </body>
    </html>
    """
    }
}
