//
//  CountAnimateLabel.swift
//  Paciolist
//
//  Created by Hisashi Ishihara on 2023/07/12.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

final class CountAnimateLabel: UILabel {

    var startTime: CFTimeInterval?
    var fromValue: Int?
    var toValue: Int?
    var duration: TimeInterval?
    
    func animate(from fromValue: Int, to toValue: Int, duration: TimeInterval) {
        text = "Loading... \(fromValue)%"
        
        // 開始時間を保存
        self.startTime = CACurrentMediaTime()
        
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        
        // CADisplayLinkの生成
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.add(to: .current, forMode: .default)
    }
    
    // 描画タイミング毎に呼ばれるメソッド
    @objc
    func updateValue(link: CADisplayLink) {
        if let startTime = startTime,
           let duration = duration,
           let toValue = toValue,
           let fromValue = fromValue {
            
            // 開始からの進捗 0.0 〜 1.0くらい
            let dt = (link.timestamp - startTime) / duration
            // 終了時に最後の値を入れてCADisplayLinkを破棄
            if dt >= 1.0 {
                text = "Loading... \(toValue)%"
                link.invalidate()
                return
            }
            // 最初の値に進捗に応じた値を足して現在の値を計算
            let current = Int(Double(toValue - fromValue) * dt) + fromValue
            text = "Loading... \(current)%"
        }
    }
}
