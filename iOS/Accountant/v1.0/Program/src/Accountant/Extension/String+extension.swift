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
}
