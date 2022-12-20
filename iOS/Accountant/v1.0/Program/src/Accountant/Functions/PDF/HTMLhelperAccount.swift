//
//  HTMLhelperAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/15.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

struct HTMLhelperAccount {
    
    func headerHTMLstring() -> String {
        // htmlヘッダーを生成します。
        // たとえば、ここに店の名前を入力できます
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
                width: 80%;
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
            .line_double_gray_bottom {
                border-bottom: 4px double #888;
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
            .titleUnderLine {
                width: 50%;
                margin-left: auto;
                margin-right: auto;
            }
            .date {
                width: 11.7647058824%;/*　22mm　5.8823529412% 11mm　*/
            }
            .smallWritting {
                width: 22.9946524064%;/*　43mm　*/
            }
            .numberOfAccount { /*　丁数、借又貸　*/
                width: 4.2780748663%;/*　8mm　*/
            }
            .amount {
                width: 16.577540107%;/*　31mm　*/
            }
            .balanceAmount {
                width: 18.1818181818%;/*　34mm　*/
            }
        /*　サイズ　高さ　*/
            .rowHeight {
                height: 7mm;/*  2.7237354086% 7mm　*/
            }

        html {
        }
        body {
        }
            section {
            }
                h2 {
                    width: 100%;
                height: 12mm;/*  8.560311284% 22mm　*/
                }
                table {
                    width: 100%;
                height: 235mm;/*  91.439688716% 235mm　*/
                }
                    thead {
                    height: 13mm;/*　5.0583657588% 13mm　*/
                    }
                    tbody {
                    height: 217mm;/* 84.4357976654%　217mm　*/
                    }
                    tfoot {
                    height: 5mm;/*　10.5058365758% 1.9455252918% 5mm　*/
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
      line-height: 1.1; }
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
        """
            <section class="page">
                <div class="richediter l-container">

                <p class="text-right">\(DateManager.shared.getDate())</p>

                <h2 class="center">
                    <div class="center titleUnderLine line_double_gray_bottom">\(title)</div>
                </h2>
                <table>
                  <thead>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td colspan="8" class="fontsize95 line_single_gray_bottom" style="font-size: 17px; text-align: start; width: 10%;">No.　　　\(pageNumber)</td>
                    </tr>
                    <tr class="line_double_red_top line_single_red_bottom">
                      <td class="line_double_red_right line_double_red_top line_single_red_bottom date" colspan="2">
                <div class="right">
                          <span class="fontsize95">\(fiscalYear)年</span>
                        </div>
                <div class="right">
                          <p class="fontsize95">月  　日</p>
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
                      <td class="line_double_red_right line_double_red_top line_single_red_bottom amount">
                        <div class="center">
                          <span class="fontsize95">貸　</span><span class="fontsize95">　方</span>
                        </div>
                      </td>
                      <td class="line_double_red_right line_double_red_top line_single_red_bottom numberOfAccount">
                        <div class="center flex-colum">
                          <span class="fontsize60">借</span><span class="fontsize60">又</span><span class="fontsize60">貸</span>
                        </div>
                      </td>
                      <td class="line_double_red_top line_single_red_bottom balanceAmount">
                        <div class="center">
                          <span class="fontsize95">差引残高</span>
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
                            <td colspan="3" class="fontsize80"><p class="right">©複式簿記の会計帳簿 Paciolist</p></td>
                        </tr>
                    </tfoot>
                  <tbody>
    """
    }
    
    func getSingleRow(month: String,
                      day: String,
                      debitCategory: String,
                      debitAmount: Int64,
                      creditCategory: String,
                      creditAmount: Int64,
                      correspondingAccounts: String,
                      numberOfAccount: Int,
                      balanceAmount: Int64,
                      balanceDebitOrCredit: String) -> String {
        // 摘要は勘定科目を右寄せか左よせを分岐する
        if correspondingAccounts == debitCategory {
            return """
            　<tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom fontsize95 center">\(month)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(day)</td>
                  <td class="smallWritting line_single_blue_bottom line_double_red_right left fontsize95">\(debitCategory)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(numberOfAccount == 0 ? "" : String(numberOfAccount))</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95"></td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95"><p class="right">\(String(creditAmount))</p></td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(balanceDebitOrCredit)</td>
                  <td class="line_single_blue_bottom fontsize95"><p class="right">\(String(balanceAmount))</p></td>
                </tr>
    """
        } else {
            return """
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom fontsize95 center">\(month)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(day)</td>
                  <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95">\(creditCategory)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(numberOfAccount == 0 ? "" : String(numberOfAccount))</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95"><p class="right">\(String(debitAmount))</p></td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95"></td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize95 center">\(balanceDebitOrCredit)</td>
                  <td class="line_single_blue_bottom fontsize95"><p class="right">\(String(balanceAmount))</p></td>
                </tr>
    """
        }
    }

    func getSingleRowEmpty() -> String {
        """
                                   <tr class="rowHeight">
                                     <td class="line_single_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                                     <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                                     <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                                     <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                                     <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                     <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                     <td class="line_double_red_right line_single_blue_bottom fontsize95 center clearColor"> あ</td>
                                     <td class="line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                   </tr>
    """
    }

    func footerstring(debitAmount: Int64, creditAmount: Int64) -> String {
        """
                                   <tr class="rowHeight">
                                      <td class="line_single_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                      <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                      <td class="smallWritting line_single_blue_bottom line_double_red_right fontsize95 clearColor"> あ</td>
                                      <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
                                      <td class="line_double_red_right line_single_blue_bottom fontsize95 clearColor"> あ</td>
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
        """
        </body>
    </html>
    """
    }
}
