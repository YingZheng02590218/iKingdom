//
//  SplashModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/05/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

/// GUIアーキテクチャ　MVP
protocol SplashModelInput {
    // 初期化処理
    func initialize(onProgress: @escaping (Int) -> Void, completionHandler: @escaping () -> Void)
    // バージョンチェック
    func appVersionCheck(completionHandler: @escaping (Bool) -> Void)
}

// スプラッシュクラス
class SplashModel: SplashModelInput {
    
    // 初期化処理
    func initialize(onProgress: @escaping (Int) -> Void, completionHandler: @escaping () -> Void) {
        // データベース初期化
        let initial = Initial()
        initial.initialize(
            onProgress: { persentage in
                onProgress(persentage)
            },
            completion: {
                completionHandler()
            }
        )
    }
    
    // バージョンチェック
    func appVersionCheck(completionHandler: @escaping (Bool) -> Void) {
        // https://cpoint-lab.co.jp/article/202206/22919/
        // 端末にインストールされているアプリのバージョンを取得後、App Store から公開済みアプリのバージョンを取得し、それらを比較すると言う処理を行なっています。
        let appVersion = AppVersion.currentVersion
        let identifier = AppVersion.identifier
        guard let url = URL(string: "https://itunes.apple.com/us/lookup?bundleId=\(identifier)") else { return }
        //        // アプリバージョン　< 強制アップデートバージョン（）の場合、強制アップデートダイアログを表示する
        //        let appVersionValue = AppVersion.convertVersionValue(string: AppVersion.currentVersion)
        //        let forcedUpdateVersionValue = AppVersion.convertVersionValue(string: "TODO") // APIから取得する
        //        guard forcedUpdateVersionValue <= appVersionValue else {
        //            // 強制アップデートダイアログを表示する
        //            showForcedUpdateDialog()
        //        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5) // タイムアウトの動作確認をする場合 0.0001 を指定する
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error as NSError? {
                if err.domain == NSURLErrorDomain {
                    // タイムアウトエラー
                    // ネットワーク未接続でも仕訳入力はできるようにするために、バージョンチェックのレスポンスが返らなければスルーする
                    print(err.code)
                    // NSURLErrorDomain Code=-1001 "The request timed out."
                    // NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline."
                    print("Error is time out :", err.code == NSURLErrorTimedOut)
                }
                completionHandler(false)
                return
            }
            
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
                      let storeVersion = result["version"] as? String else {
                    return
                }
                // 端末のアプリバージョンと App Store のアプリバージョンを比較
                // if appVersion < storeVersion { // NOTE: 文字列比較　< の場合、String型で比較しているので、5.10.0 < 5.9.0 がtrueになってしまう（falseが正しい）
                guard let currentVersion = AppVersion(appVersion),
                      let requiredVersion = AppVersion(storeVersion) else {
                    completionHandler(false)
                    return
                }
                print(appVersion, storeVersion, "文字列比較", appVersion < storeVersion, "数値比較", currentVersion < requiredVersion)
                if currentVersion < requiredVersion {
                    print("requiredVersionの方が大きい")
                    // appVersion と storeVersion が異なっている時に実行したい処理
                    completionHandler(true)
                } else {
                    print("currentVersionの方が大きい")
                    completionHandler(false)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
}
