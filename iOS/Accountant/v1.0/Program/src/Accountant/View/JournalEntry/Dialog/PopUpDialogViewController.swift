//
//  PopUpViewController.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2022/08/04.
//

import UIKit
import WebKit

// ポップアップ画面
class PopUpDialogViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var bodyView: UIView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var watchAdButton: UIButton!
    @IBOutlet var upgradeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タイトル
        titleLabel.text = "仕訳を入力するために"
        
        // 背景透過
        // 【Xcode/Swift】アラートみたいに画面を透過する方法
        // https://ios-docs.dev/overcurrentcontext/
        // 透過させたいボードに、overCurrentContextを設定します。
        //        PresentationをOver Current Contextに変更
        //        ちなみにPresentationで、もう一つ、Over Full Screenというのが選択できますが、これは、タブバーまで透過するかどうかです。
        // ViewのbackgroundColorを透明な色に変更します。
        //        BackgroundのCustomを選択
        //        色を設定し、Opacityを50%くらいに設定する
        // let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "Next") as! NextViewController
        // nextVC.modalPresentationStyle = .overCurrentContext
        // self.present(nextVC, animated: false)
        
        // UIViewに角丸な枠線(破線/点線)を設定する
        // https://xyk.hatenablog.com/entry/2016/11/28/185521
        baseView.layer.borderColor = UIColor.baseColor.cgColor
        baseView.layer.borderWidth = 0.1
        baseView.layer.cornerRadius = 15
        baseView.layer.masksToBounds = true
        // baseView.clipsToBounds = true // masksToBounds と同じ
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.headerView.addBorder(width: 0.3, color: UIColor.gray, position: .bottom)
        self.footerView.addBorder(width: 0.3, color: UIColor.gray, position: .top)
        // 右上と左下を角丸にする設定
        watchAdButton.layer.borderColor = UIColor.mainColor.cgColor
        watchAdButton.layer.borderWidth = 1.0
        watchAdButton.layer.cornerRadius = watchAdButton.frame.height / 2
        watchAdButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        upgradeButton.layer.borderColor = UIColor.accentColor.cgColor
        upgradeButton.layer.borderWidth = 0.0
        upgradeButton.layer.cornerRadius = upgradeButton.frame.height / 2
        upgradeButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        closeButton.setImage(UIImage(named: "close-close_symbol")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @IBAction func watchAdButtonTapped(_ sender: Any) {
        // 仕訳帳画面・精算表画面からの遷移の場合
        if let navigationController = self.presentingViewController as? UINavigationController,
           let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
            dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                Task {
                    // リワード広告を表示　マネタイズ対応
                    await presentingViewController.showAd()
                }
            })
        }
        // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
        if let presentingViewController = self.presentingViewController as? JournalEntryViewController {
            dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                Task {
                    // リワード広告を表示　マネタイズ対応
                    await presentingViewController.showAd()
                }
            })
        }
        // タブバーの仕訳タブからの遷移の場合
        if let tabBarController = self.presentingViewController as? UITabBarController {
            if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                if let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
                    dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        Task {
                            // リワード広告を表示　マネタイズ対応
                            await presentingViewController.showAd()
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func upgradeButtonTapped(_ sender: Any) {
        // 仕訳帳画面・精算表画面からの遷移の場合
        if let navigationController = self.presentingViewController as? UINavigationController,
           let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
            dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                // アップグレード画面を表示
                presentingViewController.showUpgradeScreen()
            })
        }
        // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
        if let presentingViewController = self.presentingViewController as? JournalEntryViewController {
            dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                // アップグレード画面を表示
                presentingViewController.showUpgradeScreen()
            })
        }
        // タブバーの仕訳タブからの遷移の場合
        if let tabBarController = self.presentingViewController as? UITabBarController {
            if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                if let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
                    dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        // アップグレード画面を表示
                        presentingViewController.showUpgradeScreen()
                    })
                }
            }
        }
    }
    
    @IBAction func closeButtonTpped(_ sender: Any) {
        dismiss(animated: true)
    }
}
