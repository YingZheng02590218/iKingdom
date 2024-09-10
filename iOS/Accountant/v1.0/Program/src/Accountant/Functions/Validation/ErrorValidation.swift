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
    // バリデーションチェック　小書き
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
    func validateEmpty(text: String?, amount: Int?, editableType: EditableType) -> ErrorValidationState {
        // 必須　金額
        if editableType == .amount {
            guard  let amount = amount, 0 != amount else {
                return .failure(
                    message: ErrorValidationType.required(
                        name: editableType.rawValue
                    ).errorText
                )
            }
        } else {
            // 必須
            guard let text = text, !text.isEmpty else {
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
    // バリデーション 勘定科目 重複　複合仕訳
    func validateDuplicated(debit: AccountTitleAmount, debitElements: [AccountTitleAmount], credit: AccountTitleAmount, creditElements: [AccountTitleAmount]) -> ErrorValidationState {
        // 存在確認　同じ勘定科目名が存在するかどうかを確認する
        let allDebitElements: [AccountTitleAmount] = [debit] + debitElements
        print("借方", allDebitElements)
        // 存在確認　同じ勘定科目名が存在するかどうかを確認する
        let allCreditElements: [AccountTitleAmount] = [credit] + creditElements
        print("貸方", allCreditElements)
        
        // 借方
        guard !(allDebitElements.filter({ $0.title == debit.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debit.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allDebitElements.filter({ $0.title == debitElements[safe: 0]?.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debitElements[safe: 0]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allDebitElements.filter({ $0.title == debitElements[safe: 1]?.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debitElements[safe: 1]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allDebitElements.filter({ $0.title == debitElements[safe: 2]?.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debitElements[safe: 2]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allDebitElements.filter({ $0.title == debitElements[safe: 3]?.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debitElements[safe: 3]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        
        // 貸方
        guard !(allCreditElements.filter({ $0.title == credit.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == credit.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allCreditElements.filter({ $0.title == creditElements[safe: 0]?.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == creditElements[safe: 0]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allCreditElements.filter({ $0.title == creditElements[safe: 1]?.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == creditElements[safe: 1]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        guard !(allCreditElements.filter({ $0.title == creditElements[safe: 2]?.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == creditElements[safe: 2]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }
        // 通らない
        guard !(allCreditElements.filter({ $0.title == creditElements[safe: 3]?.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == creditElements[safe: 3]?.title }).isEmpty) else {
            return .failure(
                message: ErrorValidationType.requiredDifferentCategories.errorText
            )
        }

        return .success
    }
    // バリデーション 金額　貸借一致
    func validate(creditAmount: Int?, debitAmount: Int?) -> ErrorValidationState {
        // 貸方と同じ勘定科目の場合
        guard creditAmount == debitAmount else {
            return .failure(
                message: ErrorValidationType.requiredDifferentAmount.errorText
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
