//
//  String+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/14.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

extension StringProtocol where Self: RangeReplaceableCollection {
    
    // 文字列中の全ての空白や改行を削除する
    var removeWhitespacesAndNewlines: Self {
        filter { !$0.isNewline && !$0.isWhitespace }
    }
}

extension String {

    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    // 全角かどうか
    public var isFullwidth: Bool {
        // 全角＼、全角｜、絵文字　が含まれる場合は、エラー
        guard !self.contains("＼") else { return false }
        guard !self.contains("｜") else { return false }
        guard !self.contains("　") else { return false }
        // 絵文字チェック
        let isContainedAppleColorEmoji = self.unicodeScalars.filter {
            $0.properties.isEmojiPresentation || $0.properties.isEmojiModifier || $0.properties.isEmojiModifierBase
        }.isEmpty
        guard isContainedAppleColorEmoji else { return false }
        
        // 全角に変換した文字列と比較することで判定
        return self == self.applyingTransform(.fullwidthToHalfwidth, reverse: true)
    }
}
