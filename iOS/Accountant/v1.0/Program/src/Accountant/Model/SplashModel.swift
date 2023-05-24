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
    func initialize(completionHandler: @escaping () -> Void)
    // バージョンチェック
    func appVersionCheck(completionHandler: @escaping (Bool) -> Void)
}

// スプラッシュクラス
class SplashModel: SplashModelInput {
    
    // 初期化処理
    func initialize(completionHandler: @escaping () -> Void) {
        // データベース初期化
        let initial = Initial()
        initial.initialize {
            completionHandler()
        }
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
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
                      let storeVersion = result["version"] as? String else {
                    return
                }
                // 端末のアプリバージョンと App Store のアプリバージョンを比較
                print(appVersion, storeVersion, appVersion < storeVersion)
                if appVersion < storeVersion {
                    // appVersion と storeVersion が異なっている時に実行したい処理
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
}
