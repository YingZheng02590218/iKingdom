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
    static func auth(
        successHandler: (() -> ())? = nil,
        errorHandler: ((String) -> Void)? = nil) {

            let context = LAContext()
            // Mac のシミュレータでTouchIDの入力画面のポップアップの文言が、「"" is trying to」となるのでローカライズする
            let localizedReason = Locale.preferredLanguages.first == "ja-JP" ? "ロックを解除するために利用します。" : "Log in to your account"
            var errorReason = ""

            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: localizedReason,
                reply: { success, error in

                    if let error = error {
                        switch LAError(_nsError: error as NSError).code {
                        case .appCancel:
                            // システムによるキャンセル① アプリのコード
                            break
                        case .systemCancel:
                            // システムによるキャンセル② システム　アプリを閉じるなどをした場合
                            break
                        case .userCancel:
                            // ユーザーによってキャンセルされた場合
                            break
                        case .biometryLockout:
                            // 生体認証エラー① 失敗制限に達した際のロック
                            break
                        case .biometryNotAvailable:
                            // 生体認証エラー② 許可していない　呼ばれないようだ
                            break
                        case .biometryNotEnrolled:
                            // 生体認証エラー③ 生体認証IDが１つもない　呼ばれないようだ
                            break
                        case .authenticationFailed:
                            // 認証に失敗してエラー　呼ばれないようだ
                            break
                        case .invalidContext:
                            // システムによるエラー① すでに無効化済み
                            break
                        case .notInteractive:
                            // システムによるエラー② 非表示になっている
                            break
                        case .passcodeNotSet:
                            // パスコード認証エラー① パスコードを設定していない
                            errorReason = "パスコードを設定してください"
                        case .userFallback:
                            // パスコード認証エラー② LAPolicyによって無効化
                            break
                        default:
                            // そのほかの未対応エラー
                            break
                        }
                        errorHandler?(errorReason)
                        print("認証失敗: ", errorReason)
                    } else if success {
                        // 認証成功時の処理
                        successHandler?()
                        print("認証成功: ")
                    } else {
                        // 予期せぬエラーの場合
                        print("Authenticate Cancel: " + (error?.localizedDescription ?? "Unknown Error"))
                    }
                }
            )
        }
    
    // MARK: - Static Function
    
    static func getDeviceOwnerLocalAuthenticationType() -> LocalAuthenticationType {
        
        let localAuthenticationContext = LAContext()
        // iOS11以上の場合: FaceID/TouchID/パスコードの3種類
        if #available(iOS 11.0, *) {
            // 生体認証が利用できるか
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
            // 生体認証が利用できるか
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return .authWithTouchID
            } else {
                return .authWithManual
            }
        }
        return .authWithManual
    }
    
    /// 生体認証かパスコードのいずれかが使用可能かを確認する
    /// False: 「パスコードをオフにする」と設定している場合
    /// True : 下記のみの場合、かつ「パスコードをオンにする」と設定している場合
    /// 「アクセス許可　Face ID」がOFFの場合
    /// 「FACE IDを使用: Phoneのロックを解除」がOFFの場合
    /// FaceID、TouchIDが登録されていない場合
    static func canEvaluatePolicy() -> Bool {
        
        let localAuthenticationContext = LAContext()
        // 生体認証かパスコードのいずれかが利用できるか
        return localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
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
