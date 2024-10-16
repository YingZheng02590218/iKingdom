//
//  ErrorValidationType.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/03/09.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

// エラーバリデーション種別
enum ErrorValidationType {
    case required(name: String)
    case requiredSomething
    case maxLength(name: String, max: Int)
    case requiredDifferentCategory
    case requiredDifferentCategories
    case requiredDifferentAmount

    var errorText: String {
        switch self {
        case let .required(name):
            return "\(name)は必須です。"
        case .requiredSomething:
            return "なにも入力されていません"
        case let .maxLength(name, max):
            return "\(name)は\(max)文字以内でご入力ください。"
        case .requiredDifferentCategory:
            return "借方と貸方が同じ勘定科目となっています。"
        case .requiredDifferentCategories:
            return "勘定科目が重複しています。"
        case .requiredDifferentAmount:
            return "借方と貸方の金額が不一致となっています。"
        }
    }
}
