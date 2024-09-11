//
//  Array+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/09/05.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        //　MARK: 配列の要素以上を指定していたらnilを返すようにする
        // indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        indices.contains(index) ? self[index] : nil
    }
}
