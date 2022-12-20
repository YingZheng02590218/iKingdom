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
    @IBOutlet var logoLabel: UILabel!
    @IBOutlet var logoImageView: UIView!
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
        initial.initialize()
        // インジケーターを終了
        finishActivityIndicatorView()
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        if let logoImageView = logoImageView {
            logoImageView.isHidden = false
            // 表示位置を設定（画面中央）
            activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y + 60)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            activityIndicatorView.style = UIActivityIndicatorView.Style.large
            // インジケーターを View に追加
            view.addSubview(activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            activityIndicatorView.startAnimating()
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // ロゴをアニメーションさせる
                self.showAnimation()
                // 非同期処理などを実行（今回は2秒間待つだけ）
                Thread.sleep(forTimeInterval: 0.5)
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    // ロゴをアニメーションさせる
    func showAnimation() {
        // 少し縮小するアニメーション
        if let logoLabel = self.logoLabel {
            UIView.animate(withDuration: 0.9,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
                logoLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { _ in

            })
            // 拡大させて、消えるアニメーション
            UIView.animate(withDuration: 0.4,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
                self.logoLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.logoLabel.alpha = 0
            }, completion: { _ in
                self.logoImageView.removeFromSuperview()
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
