//
//  SplashViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/03/12.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    // 初期化画面　ロゴ
    @IBOutlet private var logoLabel: UILabel!
    @IBOutlet private var logoImageView: UIView!
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初期化処理
        initialize()
    }

    // MARK: - ロゴとインジゲーターのアニメーション

    func initialize() {
        // インジゲーターを開始
        showActivityIndicatorView()
        // データベース初期化
        let initial = Initial()
        initial.initialize {
            // 半強制アップデートダイアログ表示
            self.appVersionCheck(completionHandler: { moveForward in
                if moveForward {
                    // インジケーターを終了
                    self.finishActivityIndicatorView()
                } else {
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        exit(0)
                    }
                }
            })
        }
    }
    // 半強制アップデートダイアログを表示する アラートを表示し、App Store に誘導する
    func showForcedUpdateDialog(completionHandler: @escaping (Bool) -> Void) {

        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "アップデートのお知らせ",
                message: "最新のアプリをご利用いただけます。",
                preferredStyle: .alert
            )
            let storeAction = UIAlertAction(title: "ストアページへ", style: .default) { _ in
                // guard let self = self else { return }
                // AppStore へのリンクは、Short Linkを指定すると、外部ブラウザを経由して、AppStoreアプリを起動される。
                guard let url = URL(string: Constant.APPSTOREAPPPAGE) else { return }
                UIApplication.shared.open(url, options: [:])
                // self.showForcedUpdateDialog()
                completionHandler(false)

            }
            let laterAction = UIAlertAction(title: "あとで", style: .destructive) { _ in
                // guard let self = self else { return }
                completionHandler(true)
            }
            alert.addAction(storeAction)
            alert.addAction(laterAction)
            self.present(alert, animated: true)
        }
    }
    // https://cpoint-lab.co.jp/article/202206/22919/
    // 端末にインストールされているアプリのバージョンを取得後、App Store から公開済みアプリのバージョンを取得し、それらを比較すると言う処理を行なっています。
    func appVersionCheck(completionHandler: @escaping (Bool) -> Void) {
        let appVersion = AppVersion.currentVersion
        let identifier = AppVersion.identifier
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else { return }
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
                      let storeVersion = result["version"] as? String else { return } // TODO: 4.0.0が返ってくる

                // 端末のアプリバージョンと App Store のアプリバージョンを比較
                if appVersion != storeVersion {
                    // appVersion と storeVersion が異なっている時に実行したい処理
                    // 半強制アップデートダイアログを表示する
                    self.showForcedUpdateDialog(completionHandler: { moveForward in
                        if moveForward {
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    })
                } else {
                    completionHandler(true)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            if let logoImageView = self.logoImageView {
                logoImageView.isHidden = false
                // 表示位置を設定（画面中央）
                self.activityIndicatorView.center = CGPoint(x: logoImageView.center.x, y: logoImageView.center.y + 60)
                // インジケーターのスタイルを指定（白色＆大きいサイズ）
                self.activityIndicatorView.style = UIActivityIndicatorView.Style.large
                // インジケーターを View に追加
                logoImageView.addSubview(self.activityIndicatorView)
                // インジケーターを表示＆アニメーション開始
                self.activityIndicatorView.startAnimating()
            }
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        // 非同期処理などが終了したらメインスレッドでアニメーション終了
        DispatchQueue.main.async {
            // ロゴをアニメーションさせる
            self.showAnimation()
            // 非同期処理などを実行（今回は2秒間待つだけ）
            Thread.sleep(forTimeInterval: 0.5)
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // スプラッシュ画面から、仕訳画面へ遷移させる
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    tabBarController.modalPresentationStyle = .fullScreen
                    tabBarController.modalTransitionStyle = .crossDissolve
                    self.present(tabBarController, animated: true, completion: nil)
                }
            }
        }
    }
    // ロゴをアニメーションさせる
    func showAnimation() {
        // 少し縮小するアニメーション
        if let logoLabel = self.logoLabel {
            UIView.animate(
                withDuration: 0.9,
                delay: 0.2,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: { () in
                    logoLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }, completion: { _ in

                }
            )
            // 拡大させて、消えるアニメーション
            UIView.animate(
                withDuration: 0.4,
                delay: 0.2,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: { () in
                    self.logoLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    self.logoLabel.alpha = 0
                }, completion: { _ in
                    self.logoImageView.removeFromSuperview()
                }
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
