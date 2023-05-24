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

    var errorText: String {
        switch self {
        case let .required(name):
            return "\(name)は必須です。"
        case .requiredSomething:
            return "なにも入力されていません"
        case let .maxLength(name, max):
            return "\(name)は\(max)文字以内でご入力ください。"
        }
    }
}
