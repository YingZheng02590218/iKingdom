//
//  Biometrics.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/06/02.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import LocalAuthentication

// 生体認証パスコードロック
enum LocalAuthentication {
    
    // 生体認証を行う
    static func auth(successHandler: (() -> ())? = nil,
                     errorHandler: ((String) -> Void)? = nil) {

        let context = LAContext()
        let localizedReason = "ロックを解除するために利用します。"
        var errorReason = ""

        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: localizedReason,
                               reply: { success, error in
            
            if let error = error {
                switch LAError(_nsError: error as NSError).code {
                case .appCancel:
                    // システムによるキャンセル① アプリのコード
                    errorReason = "システムによるキャンセル① アプリのコード"
                    break
                case .systemCancel:
                    // システムによるキャンセル② システム
                    errorReason = "システムによるキャンセル② システム"
                    break
                case .userCancel:
                    // ユーザーによってキャンセルされた場合
                    errorReason = "ユーザーによってキャンセルされた場合"
                    break
                case .biometryLockout:
                    // 生体認証エラー① 失敗制限に達した際のロック
                    errorReason = "生体認証エラー① 失敗制限に達した際のロック"
                    break
                case .biometryNotAvailable:
                    // 生体認証エラー② 許可していない
                    errorReason = "生体認証エラー② 許可していない"
                    break
                case .biometryNotEnrolled:
                    // 生体認証エラー③ 生体認証IDが１つもない
                    errorReason = "生体認証エラー③ 生体認証IDが１つもない"
                    break
                case .authenticationFailed:
                    // 認証に失敗してエラー
                    errorReason = "認証に失敗してエラー"
                    break
                case .invalidContext:
                    // システムによるエラー① すでに無効化済み
                    errorReason = "システムによるエラー① すでに無効化済み"
                    break
                case .notInteractive:
                    // システムによるエラー② 非表示になっている
                    errorReason = "システムによるエラー② 非表示になっている"
                    break
                case .passcodeNotSet:
                    // パスコード認証エラー① パスコードを設定していない
                    errorReason = "パスコード認証エラー① パスコードを設定していない"
                    break
                case .userFallback:
                    // パスコード認証エラー② LAPolicyによって無効化
                    errorReason = "パスコード認証エラー② LAPolicyによって無効化"
                    break
                default:
                    // そのほかの未対応エラー
                    errorReason = "そのほかの未対応エラー"
                    break
                }
                errorHandler?(errorReason)
                print("認証失敗:", errorReason)
            }
            else if success {
                // 認証成功時の処理
                successHandler?()
                print("認証成功:")
            }
            else {
                // 予期せぬエラーの場合
                print("Authenticate Cancel: " + (error?.localizedDescription ?? "Unknown Error"))
            }
        })
    }
    
    // MARK: - Static Function
    
    static func getDeviceOwnerLocalAuthenticationType() -> LocalAuthenticationType {
        
        let localAuthenticationContext = LAContext()
        // iOS11以上の場合: FaceID/TouchID/パスコードの3種類
        if #available(iOS 11.0, *) {

            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                switch localAuthenticationContext.biometryType {
                case .faceID: return .authWithFaceID
                case .touchID: return .authWithTouchID
                default: return .authWithManual
                }
            }
        }
        // iOS10以下の場合: TouchID/パスコードの2種類
        else {

            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return .authWithTouchID
            }
            else {
                return .authWithManual
            }
        }
        return .authWithManual
    }
    
}

enum LocalAuthenticationType {
    case authWithFaceID  // FaceIDでのロック解除
    case authWithTouchID // TouchIDでのロック解除
    case authWithManual  // 手動入力でのロック解除

    // MARK: - Function

    func getDescriptionTitle() -> String {
        switch self {
        case .authWithFaceID: return "FaceID"
        case .authWithTouchID: return "TouchID"
        case .authWithManual: return "パスコード"
        }
    }

    func getLocalizedReason() -> String {
        switch self {
        case .authWithFaceID, .authWithTouchID, .authWithManual:
            return "\(self.getDescriptionTitle())を利用して画面ロックを解除します。"
        }
    }
}
