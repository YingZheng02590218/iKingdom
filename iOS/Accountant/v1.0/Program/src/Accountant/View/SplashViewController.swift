//
//  SplashViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/03/12.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import StoreKit
import UIKit

class SplashViewController: UIViewController {
    // 初期化画面　ロゴ
    @IBOutlet private var logoLabel: UILabel!

    @IBOutlet private var whatIsDoingLabel: CountAnimateLabel!
    @IBOutlet private var logoImageView: UIView!
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    var time = 0
    var timer = Timer()

    /// GUIアーキテクチャ　MVP
    private var presenter: SplashPresenterInput!
    
    func inject(presenter: SplashPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SplashPresenter.init(view: self, model: SplashModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    // ロゴをアニメーションさせる
    func showAnimation() {
        // 少し縮小するアニメーション
        if let logoLabel = self.logoLabel {
            UIView.animate(
                withDuration: 0.9,
                delay: 0.0,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: { () in
                    logoLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }, completion: { _ in
                    
                }
            )
            // 拡大させて、消えるアニメーション
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
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
}

extension SplashViewController: SplashPresenterOutput {
    
    // 半強制アップデートダイアログを表示する アラートを表示し、App Store に誘導する
    func showForcedUpdateDialog() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "アップデートのお知らせ",
                message: "最新のアプリをご利用いただけます。",
                preferredStyle: .alert
            )
            let storeAction = UIAlertAction(
                title: "ストアページへ",
                style: .default
            ) { _ in
                // アップデートボタン
                self.presenter.updateButtonTapped()
            }
            let laterAction = UIAlertAction(
                title: "あとで",
                style: .destructive
            ) { _ in
                // あとでボタン
                self.presenter.laterButtonTapped()
            }
            alert.addAction(storeAction)
            alert.addAction(laterAction)
            self.present(alert, animated: true)
        }
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            if let logoImageView = self.logoImageView {
                logoImageView.isHidden = false
                // 表示位置を設定（画面中央）
                self.activityIndicatorView.center = CGPoint(x: logoImageView.center.x, y: logoImageView.center.y + 0)
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
    // パーセンテージを表示させる
    func showPersentage(persentage: Int) {
        DispatchQueue.main.async {
            if let whatIsDoingLabel = self.whatIsDoingLabel {
                whatIsDoingLabel.isHidden = false
                self.whatIsDoingLabel.animate(from: self.time, to: persentage, duration: TimeInterval((persentage - self.time) / 10))
                self.time = persentage
            }
        }
    }

    // パーセンテージを非表示させる
    func hidePersentage() {
        DispatchQueue.main.async {
            if let whatIsDoingLabel = self.whatIsDoingLabel {
                whatIsDoingLabel.isHidden = true
            }
        }
    }
    
    // AppStore
    func goToAppStore() {
        // AppStore へのリンクは、Short Linkを指定すると、外部ブラウザを経由して、AppStoreアプリを起動される。
        guard let url = URL(string: Constant.APPSTOREAPPPAGE) else { return }
        UIApplication.shared.open(url, options: [:])
        
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            exit(0)
        }
    }
    
    // MARK: - レビュー催促機能

    // レビュー催促機能
    func showRequestReview() {
        // レビューリクエスト画面は、３６５日で最大３回までしか表示されないルールがあるようです。
        let key = "startUpCount"
        let count = UserDefaults.standard.integer(forKey: key)
        if count == 10 { // 起動が5回目にレビューを催促する
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
        if count < 11 {
            // 永遠にインクリメントするのを防ぐ
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: key) + 1, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
