//
//  PopUpViewController.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2022/08/04.
//

import UIKit
import WebKit

// ポップアップ画面
class PopUpViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var bodyView: UIView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var button: UIButton!
    
    var webView: WKWebView?
    // 利用規約フラグ
    var termsOrPrivacyPolicy: TermsAndPrivacyPolicy = .terms
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タイトル
        titleLabel.text = termsOrPrivacyPolicy.description

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
    
    override func loadView() {
        super.loadView() // 重要
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        guard let webView = webView else {
            return
        }
        webView.translatesAutoresizingMaskIntoConstraints = false
        // 背景色が白くなるので透明にする
        webView.isOpaque = false
        webView.backgroundColor = .cellBackground
        webView.scrollView.backgroundColor = .clear
        // バウンスを禁止する
        webView.scrollView.bounces = false
        webView.navigationDelegate = self

        bodyView.addSubview(webView)
        bodyView.bringSubviewToFront(webView)

        // 親Viewを覆うように制約をつける
        webView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 5).isActive = true
        webView.topAnchor.constraint(equalTo: bodyView.topAnchor, constant: 5).isActive = true
        webView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -5).isActive = true
        webView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: -5).isActive = true
        webView.layoutIfNeeded()
        
        // HTML を読み込む
        if let url = Bundle.main.url(forResource: termsOrPrivacyPolicy.fileName, withExtension: "html") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.headerView.addBorder(width: 0.3, color: UIColor.gray, position: .bottom)
        self.footerView.addBorder(width: 0.3, color: UIColor.gray, position: .top)
        // 右上と左下を角丸にする設定
        button.layer.borderColor = UIColor.accentColor.cgColor
        button.layer.borderWidth = 0.1
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        // ダークモード対応 HTML上の文字色を変更する
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView?.evaluateJavaScript(
                "changeFontColor('\(UITraitCollection.isDarkMode ? "#F2F2F2" : "#0C0C0C")')",
                completionHandler: { _, _ in
                    print("Completed Javascript evaluation.")
                }
            )
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension PopUpViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 長押しによる選択、コールアウト表示を禁止する
        webView.prohibitTouchCalloutAndUserSelect()
    }
}

extension NSAttributedString {
    // 文字列を別の文字列に置換する
    func replace(pattern: String, replacement: String) -> NSMutableAttributedString {
        let mutableAttributedString = self.mutableCopy() as! NSMutableAttributedString
        let mutableString = mutableAttributedString.mutableString
        while mutableString.contains(pattern) {
            let range = mutableString.range(of: pattern)
            mutableAttributedString.replaceCharacters(in: range, with: replacement)
        }
        return mutableAttributedString
    }
}

// 【Swift】枠線を任意の場所につける
// https://qiita.com/kojimetal666/items/d3c674244e5312ce8cfe

enum BorderPosition {
    case top
    case left
    case right
    case bottom
}

extension UIView {
    /// 特定の場所にborderをつける
    ///
    /// - Parameters:
    ///   - width: 線の幅
    ///   - color: 線の色
    ///   - position: 上下左右どこにborderをつけるか
    func addBorder(width: CGFloat, color: UIColor, position: BorderPosition) {
        
        let border = CALayer()
        
        switch position {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .right:
            print(self.frame.width)
            
            border.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        }
    }
}
enum TermsAndPrivacyPolicy: CustomStringConvertible {
    // 利用規約
    case terms
    // プライバシーポリシー
    case privacyPolicy
    
    var description: String {
        switch self {
        case .terms:
            return "利用規約"
        case .privacyPolicy:
            return "プライバシーポリシー"
        }
    }
    var fileName: String {
        switch self {
        case .terms:
            return "terms"
        case .privacyPolicy:
            return "privacy_policy"
        }
    }
}
