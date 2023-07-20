//
//  ErrorValidation.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/03/09.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

// バリエーション状態
enum ErrorValidationState: Hashable {
    // 未バリデーション
    case unvalidated
    // 失敗
    case failure(message: String?)
    // 成功
    case success
    
    var errorText: String? {
        switch self {
        case.failure(let errorText):
            return errorText
        case .success, .unvalidated:
            return nil
        }
    }
}

// バリデーションチェック　バリデーション状態を返却する
struct ErrorValidation {
    
    func validateSmallWriting(text: String) -> ErrorValidationState {
        let editableType = EditableType.smallWriting
        // 最大長
        guard text.count <= editableType.maxLength else {
            return .failure(
                message: ErrorValidationType.maxLength(
                    name: editableType.rawValue,
                    max: editableType.maxLength
                ).errorText
            )
        }
        return .success
    }
    
    func validateNickname(text: String) -> ErrorValidationState {
        let editableType = EditableType.nickname
        // 最大長
        guard text.count <= editableType.maxLength else {
            return .failure(
                message: ErrorValidationType.maxLength(
                    name: editableType.rawValue,
                    max: editableType.maxLength
                ).errorText
            )
        }
        return .success
    }
    // バリデーション　グループ名
    func validateSettingsJournalEntryGroup(text: String?) -> ErrorValidationState {
        let editableType = EditableType.group
        // 必須
        guard let text = text, !text.isEmpty else {
            return .failure(
                message: ErrorValidationType.required(
                    name: editableType.rawValue
                ).errorText
            )
        }
        // 最大長
        guard text.count <= editableType.maxLength else {
            return .failure(
                message: ErrorValidationType.maxLength(
                    name: editableType.rawValue,
                    max: editableType.maxLength
                ).errorText
            )
        }
        return .success
    }
    // バリデーション 勘定科目、金額
    func validateEmpty(text: String?, editableType: EditableType) -> ErrorValidationState {
        // 必須
        guard let text = text, !text.isEmpty else {
            return .failure(
                message: ErrorValidationType.required(
                    name: editableType.rawValue
                ).errorText
            )
        }
        // 必須　金額
        if editableType == .amount {
            guard "0" != text else {
                return .failure(
                    message: ErrorValidationType.required(
                        name: editableType.rawValue
                    ).errorText
                )
            }
        }
        return .success
    }
    // バリデーション 勘定科目
    func validate(creditText: String?, debitText: String?) -> ErrorValidationState {
        // 貸方と同じ勘定科目の場合
        guard creditText != debitText else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategory.errorText
            )
        }
        return .success
    }
    // バリデーション 仕訳一括編集 日付、勘定科目、金額、小書き
    func validateEmptyAll(journalEntryData: JournalEntryData) -> ErrorValidationState {
        // 必須 ひとつでも変更されているか
        guard !journalEntryData.checkPropertyIsNil() else {
            return .failure(
                message: ErrorValidationType.requiredSomething.errorText
            )
        }
        return .success
    }
}
