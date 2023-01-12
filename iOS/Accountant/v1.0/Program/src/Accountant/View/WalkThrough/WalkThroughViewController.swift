//
//  WalkThroughViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/17.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EAIntroView

class WalkThroughViewController: UIViewController {

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIntroWithCrossDissolve()
    }

    // MARK: - Setting

    func showIntroWithCrossDissolve() {
        let page = EAIntroPage()
        page.title = "Paciolist"
        page.titleColor = UIColor.textColor
        page.titleFont = UIFont(name: "Futura-Bold", size: 48.0)
        page.titlePositionY = self.view.bounds.size.height / 2
        page.desc = "複式簿記の会計帳簿\n\n紙の帳簿と同じデザインを表現した\n複式簿記で記帳ができるアプリ"
        page.descColor = UIColor.lightGray
        page.descFont = UIFont(name: "HiraMaruProN-W4", size: 18)
        page.descPositionY = self.view.bounds.size.height / 2
        page.bgColor = UIColor.clear
        
        // 各ページはEAIntroPageというクラスがあるので、それで作りましょう。
        let page1 = EAIntroPage()
        // タイトルのテキスト
        page1.title = "仕訳"
        // タイトルの色変更
        page1.titleColor = UIColor.textColor
        // タイトルのフォントの設定
        page1.titleFont = UIFont(name: "Helvetica-Bold", size: 40)
        
        page1.titlePositionY = self.view.bounds.size.height * 0.8
        // ディスクリプションのテキスト
        page1.desc = "日々の取引を仕訳する\nやることはこれだけ\n\nよく使う仕訳のテンプレートを準備しておくと、最速で入力が完了"
        // ディスクリプションの色変更
        page1.descColor = UIColor.lightGray
        // ディスクリプションのフォントの設定
        page1.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        // テキストの位置を変更
        page1.descPositionY = self.view.bounds.size.height * 0.8
        // 背景色変更
        page1.bgColor = UIColor.clear
        // 背景画像
        page1.bgImage = UIImage(named: "bg1")

        let page2 = EAIntroPage()
        page2.title = "主要簿"
        page2.titleColor = UIColor.textColor
        page2.titleFont = UIFont(name: "Helvetica-Bold", size: 40)
        page2.titlePositionY = self.view.bounds.size.height * 0.8
        page2.desc = "仕訳帳と総勘定元帳を確認する\n\n仕訳帳で、仕訳の編集や削除ができる"
        page2.descColor = UIColor.lightGray
        page2.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        page2.descPositionY = self.view.bounds.size.height * 0.8
        page2.bgColor = UIColor.clear
        page2.bgImage = UIImage(named: "bg2")
        
        let page1of2 = EAIntroPage()
        page1of2.title = " "
        page1of2.titleColor = UIColor.textColor
        page1of2.titleFont = UIFont(name: "Helvetica-Bold", size: 40)
        page1of2.titlePositionY = self.view.bounds.size.height * 0.8
        page1of2.desc = "プリンターで印刷や\nPDFファイルを出力することができる"
        page1of2.descColor = UIColor.lightGray
        page1of2.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        page1of2.descPositionY = self.view.bounds.size.height * 0.8
        page1of2.bgColor = UIColor.clear
        page1of2.bgImage = UIImage(named: "bg1of2")
        
        let page3 = EAIntroPage()
        page3.title = "決算"
        page3.titleColor = UIColor.textColor
        page3.titleFont = UIFont(name: "Helvetica-Bold", size: 40)
        page3.titlePositionY = self.view.bounds.size.height * 0.8
        page3.desc = "決算整理仕訳を済ませると\n貸借対照表と損益計算書が完成します"
        page3.descColor = UIColor.lightGray
        page3.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        page3.descPositionY = self.view.bounds.size.height * 0.8
        page3.bgColor = UIColor.clear
        page3.bgImage = UIImage(named: "bg3")

        let page4 = EAIntroPage()
        page4.title = "まず勘定科目を設定しよう"
        page4.titleColor = UIColor.textColor
        page4.titleFont = UIFont(name: "Helvetica-Bold", size: 29)
        page4.titlePositionY = self.view.bounds.size.height * 0.8
        page4.desc = "使用する勘定科目をONにする\n\nオリジナルの勘定科目も登録できる"
        page4.descColor = UIColor.lightGray
        page4.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        page4.descPositionY = self.view.bounds.size.height * 0.8
        page4.bgColor = UIColor.clear
        page4.bgImage = UIImage(named: "bg4")
        
        let page5 = EAIntroPage()
        page5.title = "それでは良い\n複式簿記Lifeを"
        page5.titleColor = UIColor.textColor
        page5.titleFont = UIFont(name: "Helvetica-Bold", size: 29)
        page5.titlePositionY = self.view.bounds.size.height / 2
        page5.desc = ""
        page5.descColor = UIColor.lightGray
        page5.descFont = UIFont(name: "HiraMaruProN-W4", size: 20)
        page5.descPositionY = self.view.bounds.size.height / 2
        page5.bgColor = UIColor.clear
        
        // ここでページを追加
        let introView = EAIntroView(frame: self.view.bounds, andPages: [page, page1, page2, page1of2, page3, page4, page5])
        // スキップボタンのテキスト
        // introView?.skipButton.setTitle("skip", for: UIControl.State.normal)
        // スキップボタンの色変更
        // introView?.skipButton.setTitleColor(UIColor.TextColor, for: UIControl.State.normal)
        
        introView?.skipButton.isHidden = true

        introView?.limitPageIndex = (introView?.pages.count ?? 1) - 1
        // ダークモード対応
        if UITraitCollection.isDarkMode {
        } else {
            introView?.pageControl.pageIndicatorTintColor = .lightGray
        }
        introView?.pageControl.currentPageIndicatorTintColor = .accentBlue

        introView?.pageControlY = self.view.bounds.size.height * 0.9
        
        introView?.delegate = self
        // アニメーション設定
        introView?.show(in: self.view, animateDuration: 0.1)
    }
}

// MARK: - EAIntroDelegate

extension WalkThroughViewController: EAIntroDelegate {

    func intro(_ introView: EAIntroView!, pageAppeared page: EAIntroPage!, with pageIndex: UInt) {
        // 最終ページまで到達した場合
        if introView.limitPageIndex == pageIndex {
            // 非表示とする
            introView.pageControl.isHidden = true
        }
    }
    
    func intro(_ introView: EAIntroView!, pageStartScrolling page: EAIntroPage!, with pageIndex: UInt) {
        // 最終ページまで到達した場合
        if introView.limitPageIndex == pageIndex {
            // 非表示とする
            introView.pageControl.isHidden = true
        }
    }
    
    func intro(_ introView: EAIntroView!, pageEndScrolling page: EAIntroPage!, with pageIndex: UInt) {
        // 5ページ目の場合
        if pageIndex == 5 {
            // ①UIAlertControllerクラスのインスタンスを生成する
            // titleにタイトル, messegeにメッセージ, prefereedStyleにスタイルを指定する
            // preferredStyleにUIAlertControllerStyle.actionSheetを指定してアクションシートを表示する
            let actionSheet = UIAlertController(
                title: "勘定科目体系の選択",
                message: nil,
                preferredStyle: UIAlertController.Style.actionSheet
            )
            // ②選択肢の作成と追加
            actionSheet.addAction(
                UIAlertAction(
                    title: "法人",
                    style: .default,
                    handler: { (action: UIAlertAction) -> Void in
                        print(action)
                        // 法人/個人フラグ　法人:true, 個人:false
                        let userDefaults = UserDefaults.standard
                        let firstLunchKey = "corporation_switch"
                        userDefaults.set(true, forKey: firstLunchKey)
                        userDefaults.synchronize()
                    }
                )
            )
            // ②選択肢の作成と追加
            actionSheet.addAction(
                UIAlertAction(
                    title: "個人事業主",
                    style: .default,
                    handler: { (action: UIAlertAction) -> Void in
                        print(action)
                        // 法人/個人フラグ　法人:true, 個人:false
                        let userDefaults = UserDefaults.standard
                        let firstLunchKey = "corporation_switch"
                        userDefaults.set(false, forKey: firstLunchKey)
                        userDefaults.synchronize()
                    }
                )
            )
            // iPad の場合のみ、ActionSheetを表示するための必要な設定
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                actionSheet.popoverPresentationController?.sourceRect = CGRect(
                    x: screenSize.size.width / 2,
                    y: screenSize.size.height,
                    width: 0,
                    height: 0
                )
                // iPadの場合、アクションシートの背後の画面をタップできる
            } else {
                // ③表示するViewと表示位置を指定する
                actionSheet.popoverPresentationController?.sourceView = view
                actionSheet.popoverPresentationController?.sourceRect = (page as AnyObject).frame
            }
            // ④アクションシートを表示
            present(actionSheet, animated: true, completion: nil)
        }
        // 最終ページまで到達した場合
        if introView.limitPageIndex == pageIndex {
            // 2秒間待つだけ
            Thread.sleep(forTimeInterval: 1.5)
            // 画面を閉じる
            introView.hide(withFadeOutDuration: 0.8)
            // チュートリアル対応 ウォークスルー型　初回起動時
            let userDefaults = UserDefaults.standard
            let firstLunchKey = "firstLunch_WalkThrough"
            userDefaults.set(false, forKey: firstLunchKey)
            userDefaults.synchronize()
        }
    }
    
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        if let tabBarController = self.presentingViewController as? UITabBarController,
           let navigationController = tabBarController.viewControllers?[0] as? UINavigationController,
           let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
            self.dismiss(
                animated: true,
                completion: { [presentingViewController] () -> Void in
                    // ViewController(ウォークスルー画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                    // チュートリアル対応 コーチマーク型
                    presentingViewController.showAnnotation()
                }
            )
        }
    }
}
