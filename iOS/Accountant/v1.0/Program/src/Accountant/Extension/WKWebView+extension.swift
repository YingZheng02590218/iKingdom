//
//  WKWebView+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/08/19.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import WebKit

extension WKWebView {
    
    /// 長押しによる選択、コールアウト表示を禁止する
    func prohibitTouchCalloutAndUserSelect() {
        let script = """
        var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}';
        var head = document.head || document.getElementsByTagName('head')[0];
        var style = document.createElement('style');
        style.type = 'text/css';
        style.appendChild(document.createTextNode(css));
        head.appendChild(style);
        """
        evaluateJavaScript(script, completionHandler: nil)
    }
}
