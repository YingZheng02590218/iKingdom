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
    /*　位置　*/
    .center {
      text-align: center;
    }
    .left {
      text-align: left;
    }
    .right {
      text-align: right;
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
    .line_double_red_top {
      border-top: 1px double #f66;
    }
    .line_double_red_right {
      border-right: 1px double #f66;
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
      width: 22mm;
    }
    .smallWritting {
      width: 78mm;
    }
    .numberOfAccount {
      width: 10mm;
    }
    .amount {
      width: 37mm;
    }
    /*　サイズ　高さ　*/
    .rowHeight {
      height: 4mm;
    }

    html {
      margin: auto;
    }
    body {
      margin: auto;
    }
    section {
    }
    h2 {
      margin: auto;
      height: 22mm;
    }
    table {
      margin: auto;
      height: 235mm;
    }
    thead {
      margin: auto;
      height: 13mm;
    }
    tbody {
      margin: auto;
      height: 217mm;
    }
    .height3 {
      margin: auto;
      height: 5mm;
    }
    .page{
      margin: auto;
      width: 187mm;
      height: 257mm;
      box-sizing: border-box;
      padding: 0mm;
      break-after: always;
    }
    .page:last-child{
      break-after: auto;
    }
    @page {
      size: B5 portrait;
    }
    </style>
    <body>
    """
    }
    
    func headerstring(title: String, fiscalYear: Int) -> String {

        return """
    <section class="page">
      <div class="center">
        <div class="center">
          <h2 class="center">\(title)</h2>
        </div>
        <table>
          <thead>
            <tr class="line_double_red_top line_single_red_bottom">
              <td class="date line_double_red_right line_double_red_top line_single_red_bottom" colspan="2">
                <div class="center">
                  <span class="fontsize60">\(fiscalYear)年</span>
                </div>
                <div>
                  <span class="fontsize60"> 月</span>
                  <span class="fontsize60 right"> 日</span>
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
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 right">\(String(debit_amount))</td>
                  <td class="line_single_blue_bottom right"></td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom center"></td>
                  <td class="line_double_red_right line_single_blue_bottom center"></td>
                  <td class="smallWritting line_single_blue_bottom line_single_red_right right fontsize60">\(credit_category)</td>
                  <td class="line_double_red_right line_single_blue_bottom fontsize60 center">\(11)</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom fontsize60 right">\(String(credit_amount))</td>
                </tr>
                <tr class="rowHeight">
                  <td class="line_single_red_right line_single_blue_bottom"></td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="smallWritting line_single_blue_bottom line_single_red_right left fontsize40">\(smallWritting)</td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_double_red_right line_single_blue_bottom"></td>
                  <td class="line_single_blue_bottom right"></td>
                </tr>
    """
    }

    func getSingleRowEmpty() -> String {
        return """
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize60 center clearColor">a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor">a</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize60 clearColor">a </td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 right clearColor"> a</td>
                   <td class="line_single_blue_bottom right fontsize60 clearColor"> a</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom center fontsize60 clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom center fontsize60 clearColor"> a</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right right fontsize60 clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 center clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                   <td class="line_single_blue_bottom fontsize60 right clearColor"> a</td>
                 </tr>
                 <tr class="rowHeight">
                   <td class="line_single_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                   <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize40 clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                   <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                   <td class="line_single_blue_bottom right fontsize60 clearColor"> a</td>
                 </tr>

    """
    }

    func footerstring(debit_amount: Int64, credit_amount: Int64) -> String {
        return """
                  <tr class="rowHeight">
                    <td class="line_single_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                    <td class="smallWritting line_single_blue_bottom line_single_red_right fontsize40 clearColor"> a</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                    <td class="line_double_red_right line_single_blue_bottom fontsize60 clearColor"> a</td>
                    <td class="line_single_blue_bottom right fontsize60 clearColor"> a</td>
                  </tr>
                  </tbody>
                  <tfoot>
                    <tr class="height3">
                      <td colspan="6" class="right fontsize60">©複式簿記の会計帳簿 Paciolist パチョーリ主義</td>
                    </tr>
                  </tfoot>
                  </table>
                  </div>
                  </section>
                  </body>
        """
    }

    func footerHTMLstring() -> String {
        return """
    </html>
    """
    }
}
