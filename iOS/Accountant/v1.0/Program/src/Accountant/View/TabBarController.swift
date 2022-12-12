//
//  TabBarController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/07.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 生体認証パスコードロック アプリ起動完了時のパスコード画面表示の通知監視
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayPasscodeLockScreenIfNeeded), name: UIApplication.didFinishLaunchingNotification, object: nil)

        self.navigationController?.navigationBar.tintColor = .accentColor
    }

    // MARK: - 生体認証パスコードロック

    // 生体認証パスコードロック アプリを一旦閉じた状態から再度アプリを起動させる場合
    @objc private func displayPasscodeLockScreenIfNeeded() {
        // パスコードロックを設定していない場合は何もしない
        if !UserDefaults.standard.bool(forKey: "biometrics_switch") {
            return
        }

        let firstLunchKey = "biometrics"
        if UserDefaults.standard.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    // 生体認証パスコードロック
                    let viewController = UIStoryboard(name: "PassCodeLockViewController", bundle: nil)
                        .instantiateViewController(withIdentifier: "PassCodeLockViewController") as! PassCodeLockViewController
                    let nav = UINavigationController(rootViewController: viewController)
                    nav.modalPresentationStyle = .overFullScreen
                    nav.modalTransitionStyle   = .crossDissolve
                    self.present(nav, animated: false, completion: nil)
                }
            }
        }
    }
    
}
