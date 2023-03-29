//
//  EditableType.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/03/10.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

// テキストフィールドで編集可能な項目
enum EditableType: String {
    case smallWriting = "小書き"
    case nickname = "仕訳の概要"

    // 最大長
    var maxLength: Int {
        switch self {
        case .smallWriting:
            return 50
        case .nickname:
            return 25
        }
    }
}
