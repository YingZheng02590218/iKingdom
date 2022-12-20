//
//  PassCodeLockViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/06/03.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit

class PassCodeLockViewController: UIViewController {

    // MARK: - var let

    @IBOutlet var label: UILabel!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 文言を指定
        let type = LocalAuthentication.getDeviceOwnerLocalAuthenticationType()
        label.text = type.getDescriptionTitle() + "を使って\n認証して下さい"
        // 生体認証パスコードロック　認証処理
        authrizePassCode()
    }
    
    // MARK: - Action

    // 認証をするボタンがタップ
    @IBAction func buttonTapped(_ sender: Any) {
        // 生体認証パスコードロック　認証処理
        authrizePassCode()
    }
    
    // MARK: - Function

    // 生体認証パスコードロック　認証処理
    func authrizePassCode() {
        // TouchID/FaceIDによる認証を実行し、成功した場合にはパスコードロックを解除する
        LocalAuthentication.auth(
            successHandler: {
                // 認証成功時の処理
                // 生体認証パスコードロック
                let ud = UserDefaults.standard
                let firstLunchKey = "biometrics"
                ud.set(false, forKey: firstLunchKey)
                ud.synchronize()
                // 生体認証パスコードロック画面を閉じる ロック解除
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            },
            errorHandler: { errorReason in
                // 認証失敗時の処理
                DispatchQueue.main.async {
                    // アラート画面を表示する
                    // Paciolistの設定画面でパスコードロックをONにしている状態で、iPhoneの設定画面でパスコードをオフにした場合
                    if !errorReason.isEmpty {
                        let alert = UIAlertController(title: "エラー", message: errorReason, preferredStyle: .alert)
                        self.present(alert, animated: true) { () -> Void in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        )
    }
    
}
