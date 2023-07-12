//
//  SplashPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/05/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

/// GUIアーキテクチャ　MVP
protocol SplashPresenterInput {
    
    func viewDidLoad()
    // アップデートボタン
    func updateButtonTapped()
    // あとでボタン
    func laterButtonTapped()
}

protocol SplashPresenterOutput: AnyObject {
    // インジゲーターを開始
    func showActivityIndicatorView()
    // インジケーターを終了
    func finishActivityIndicatorView()
    // パーセンテージを表示させる
    func showPersentage(persentage: Int)
    // 半強制アップデートダイアログを表示する アラートを表示し、App Store に誘導する
    func showForcedUpdateDialog()
    // AppStore
    func goToAppStore()
}

final class SplashPresenter: SplashPresenterInput {
    
    // MARK: - var let
    
    private weak var view: SplashPresenterOutput!
    private var model: SplashModelInput
    
    init(view: SplashPresenterOutput, model: SplashModelInput) {
        self.view = view
        self.model = model
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        // MARK: - ロゴとインジゲーターのアニメーション
        // インジゲーターを開始
        view.showActivityIndicatorView()
        // 初期化処理
        model.initialize(
            onProgress: { persentage in
                // パーセンテージを表示させる
                self.view.showPersentage(persentage: persentage)
            },
            completionHandler: {
                // バージョンチェック
                self.model.appVersionCheck(completionHandler: { hasNewVersion in
                    if hasNewVersion {
                        // 半強制アップデートダイアログを表示する
                        self.view.showForcedUpdateDialog()
                    } else {
                        // インジケーターを終了
                        self.view.finishActivityIndicatorView()
                    }
                })
            }
        )
    }
    // アップデートボタン
    func updateButtonTapped() {
        // AppStore
        view.goToAppStore()
    }
    // あとでボタン
    func laterButtonTapped() {
        // インジケーターを終了
        self.view.finishActivityIndicatorView()
    }
}
