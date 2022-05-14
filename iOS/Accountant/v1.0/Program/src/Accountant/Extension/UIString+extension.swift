//
//  UIString+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/14.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation

extension StringProtocol where Self: RangeReplaceableCollection {
    // 文字列中の全ての空白や改行を削除する
    var removeWhitespacesAndNewlines: Self {
        filter { !$0.isNewline && !$0.isWhitespace }
    }
}
