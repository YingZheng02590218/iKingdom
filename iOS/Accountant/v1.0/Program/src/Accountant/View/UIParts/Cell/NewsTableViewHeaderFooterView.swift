//
//  NewsTableViewHeaderFooterView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/19.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

class NewsTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var label: UILabel!
    
    var messages = [String]()
    var msgId = 0
    var offsetX: CGFloat = 0
    var changeFlg = true
    // タイマー　オブジェクトを保持する
    var timer: Timer?

    func setup(message: [String]) {
        // 表示する文言
        messages = message
        
        if let timer = self.timer {
            print(timer.timeInterval)
        } else {
            self.timer = Timer.scheduledTimer(
                timeInterval: 0.05,
                target: self,
                selector: #selector(scrollTicker),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    @objc
    func scrollTicker() {
        if changeFlg == true {
            var offset = scrollView.contentOffset
            offset.x = -self.frame.size.width
            scrollView.contentOffset = offset
            
            label.text = messages[msgId]
            msgId += 1
            if msgId >= messages.count {
                msgId = 0
            }
            
            self.label.sizeToFit()
            offsetX = self.label.frame.size.width
            
            changeFlg = false
        } else {
            var offset = scrollView.contentOffset
            offset.x += 3.0
            if offsetX < offset.x {
                changeFlg = true
            }
            scrollView.contentOffset = offset
        }
    }
    
}
