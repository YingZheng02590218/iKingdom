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
        /*　text-align: right;を指定すると改ページされてしまう　*/
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
        .fontsize40 {
            font-size: 40%;
        }
        .fontsize60 {
            font-size: 40%;
        }
        .fontsize80 {
            font-size: 80%;
        }

        .flex-colum {
            display: flex;
            flex-direction: column;
            margin: 0px;
        }
    /*　サイズ　幅　*/
        .date {
            width: 5.8823529412%;/*　11mm　*/
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
                width: 100%;
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
                    height: auto;/*　1.9455252918% 5mm　*/
                }
    .page{
        width: 210mm;/*　210mm 187mm B5 182mm×257mm　*/
        height: 296mm;/*　297mm 257mm　*/
        box-sizing: border-box;
        padding: 10mm;
        display: block;
        break-after: always;
    }
    @page {
        size: A4 portrait;/*　A4 B5　*/
        margin: auto;
    }
    .page:last-child{
        break-after: auto;
    }
    /* ■ テーブル全体、セルの横幅、高さを%で指定
    width="%"で指定した場合、テーブルの横幅は画面全体100%に対する割合 の長さになります。 テーブルの横幅が50%だと画面全体の2分の1、つまり半分の大きさということ になります。

    テーブルの横幅と高さを指定してある時でセルの横幅、高さを%で指定した場合、 それらの大きさはテーブル全体に対する割合の大きさになります。 */
    </style>
    <body>
    """
    }
    
    func headerstring(title: String, fiscalYear: Int, pageNumber: Int) -> String {
        // let margin = pageNumber % 2 == 0 ? "margin-right" : "margin-left"
        // style="\(margin): 5.8823529412%;"

        return """
        <section class="page">
            <h2 class="center">\(title)</h2>
            <table>
              <thead>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td colspan="6" class="fontsize60 line_single_gray_bottom" style="text-align: start; width: 10%;">No.　\(pageNumber)</td>
                </tr>
                <tr class="line_double_red_top line_single_red_bottom">
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom date" colspan="2">
                    <div class="center">
                      <span class="fontsize60">\(fiscalYear)年</span>
                    </div>
                    <div>
                      <span class="fontsize60"> 月</span>
                      <span class="fontsize60"> 日</span>
                    </div>
                  </td>
                  <td class="smallWritting line_double_red_top line_single_red_bottom line_single_red_left line_single_red_right">
                    <div class="center">
                      <span class="fontsize80 center">摘　</span>
                      <span class="fontsize80 center">　要</span>
                    </div>
                  </td>
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom numberOfAccount">
                    <div class="center flex-colum">
                      <span class="fontsize60">丁</span><span class="fontsize60">数</span>
                    </div>
                  </td>
                  <td class="line_double_red_right line_double_red_top line_single_red_bottom amount">
                    <div class="center">
                      <span class="fontsize80">借　</span><span class="fontsize80">　方</span>
                    </div>
                  </td>
                  <td class="line_double_red_top line_single_red_bottom amount">
                    <div class="center">
                      <span class="fontsize80">貸　</span><span class="fontsize80">　方</span>
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
    
    func getSingleRow(month: String, day: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String) -> String {
        return """
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom fontsize60 center">\(month)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 center">\(day)</td>
                  <td class="smallWritting line_single_blue_bottom line_single_red_right left fontsize60">\(debit_category)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 center">\(99)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60">\(String(debit_amount))</td>
                  <td class="line_single_blue_bottom"></td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom center"></td>
                  <td class="line_double_red_right line_single_blue_bottom center"></td>
                  <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize60">\(credit_category)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 center">\(11)</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom fontsize60">\(String(credit_amount))</td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom"></td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="smallWritting line_single_blue_bottom line_single_red_right left fontsize40">\(smallWritting)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom"></td>
                </tr>
    """
    }

    func getSingleRowEmpty() -> String {
        return """
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize60 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize60 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize60 clearColor"> あ</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom center fontsize60 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom center fontsize60 clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize60 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize60 clearColor"> あ</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize40 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                   <td class="line_single_blue_bottom fontsize60 clearColor"> あ</td>
                 </tr>
    """
    }

    func footerstring(debit_amount: Int64, credit_amount: Int64) -> String {
        return """
                 <tr class="rowHeight">
                    <td class="line_single_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                    <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize40 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> あ</td>
                    <td class="line_single_blue_bottom fontsize60 clearColor"> あ</td>
                  </tr>
              </tbody>
            </table>
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
