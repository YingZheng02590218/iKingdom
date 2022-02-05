//
//  HTMLhelper.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

func headerHTMLstring(title: String, fiscalYear: Int) -> String {
    //htmlヘッダーを生成します。
    //たとえば、ここに店の名前を入力できます
    return """
    <!DOCTYPE html>
    <html>
        <head>
                <title>レシート</title>
        <style>
            table, th, td {
              border: 1px solid black;
              border-collapse: collapse;
            }
            h2 {
              border-bottom: 6px double #000;
              width: 50p%;
            }
            .center {
              text-align: center;
            }
            .right {
              text-align: right;
            }
        </style>
        <body>
            <h2 class="center">\(title)</h2>
            <table style="width:100%">
                <tr>
                    <th>\(String(fiscalYear))年月日</th>
                    <th>摘要</th>
                    <th>丁数</th>
                    <th>借方</th>
                    <th>貸方</th>
                </tr>
    """
}
//, balance_left: Int64, balance_right: Int64)
//        <td>\(String(balance_left))</td>
//<td>\(String(balance_right))</td>
func getSingleRow(date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String) -> String {
    return """
    <tr>
        <td>\(date)</td>
        <td>\(debit_category)</td>
        <td>\(99)</td>
        <td>\(String(debit_amount))</td>
        <td></td>
    </tr>
    <tr>
        <td></td>
        <td class="right">\(credit_category)</td>
        <td>\(11)</td>
        <td></td>
        <td>\(String(credit_amount))</td>
    </tr>
    <tr>
        <td></td>
        <td>\(smallWritting)</td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
    """
}

func footerHTMLstring() -> String {
    return """
        </table>

        </body>
    </html>
    """
}
