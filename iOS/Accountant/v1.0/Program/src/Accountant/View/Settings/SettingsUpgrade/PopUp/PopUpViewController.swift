//
//  PopUpViewController.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2022/08/04.
//

import UIKit

// ポップアップ画面
class PopUpViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var bodyView: UIView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var button: UIButton!
    // 利用規約フラグ
    var termsOrPrivacyPolicy: TermsAndPrivacyPolicy = .terms
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "利用規約/プライバシーポリシー"
        textView.text = termsOrPrivacyPolicy.description
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
        button.layer.borderColor = UIColor.accentColor.cgColor
        button.layer.borderWidth = 0.1
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
            return """
                    利用規約
                    
                    第1条（目的）
                    この「複式簿記の会計帳簿 Paciolist パチョーリ主義」利用規約（以下「本利用規約」といいます）は、iKingdom（以下「当社」といいます）が提供するiOS向けアプリケーション・ソフトウェア「複式簿記の会計帳簿 Paciolist パチョーリ主義」（以下「本アプリ」といいます）の利用条件を定めるものであり、本アプリをご利用になるすべての方（以下「お客様」といいます) と当社との間に適用されます。また、本利用規約は、本アプリがアップデートされた場合の当該アップデート版に対しても適用されます。
                    
                    第2条（お客様の同意）
                    1．当社は、お客様が、お客様が保有または管理するiPhone端末およびiPad端末（以下、「iOS端末」といいます）に本アプリをダウンロードしてそのアイコンをタップすることその他の方法により本アプリを利用されたことによって、お客様が本利用規約に同意されたものとみなします。
                    2．当社は、本規約を変更する場合、第10条に定める方法により変更を掲載します。当社は、お客様が、当社による本規約変更の掲載後、本アプリを利用されたことによって、お客様が当該変更に同意されたものとみなします。なお、掲載後一定の周知期間を経た後に変更する場合、変更の効力発生日以降に利用されたことによって、お客様が当該変更に同意されたものとみなします。
                    3．当社は、本規約に定めるほか、本アプリにおいて表示する方法により利用条件等を通知します。当社は、お客様が、利用条件等を通知された後、本アプリを利用されることによって、お客様が当該利用条件等に同意されたものとみなします。 
                    第3条（利用許諾）
                    当社は、お客様に対し、お客様ご本人が、本アプリをiOS端末において、本利用規約および当社が定める利用条件等（別途定めるプライバシーポリシーを含みます）に従って利用する、非独占的かつ譲渡不能な権利を付与します。
                    
                    第4条（利用条件）
                    1.お客様は､本アプリのダウンロード、インストールおよびアンインストール並びに本アプリの利用にあたっては､諸法令を遵守し、お客様ご自身の責任においてこれらの行為を行うことを承諾していただきます。
                    2.本アプリの利用にあたり、お客様は、自己の責任と費用負担において、本アプリをiOS端末にダウンロードしインストールするものとします。当社は、本アプリがすべてのiOS端末に対応することを保証するものではありません。
                    3.お客様が未成年者である場合は、親権者など法定代理人の同意（本規約への同意を含みます）を得たうえで本サービスをを利用するものとします。また、本サービスにユーザー登録した時点で未成年者であったお客様が、成年に達した後に本サービスを利用した場合、未成年者であった間の利用行為を追認したものとみなします。
                    4.本アプリの利用に関しては、お客様の責任と費用負担において、本アプリの利用に必要な環境の整備・維持管理を行うとともに、別途携帯電話会社所定の通信料を支払うものとします。
                    5.当社は、以下の各号に定める場合、事前にお客様に通知することなく、本アプリの配信の全部または一部を停止する場合があります。     (1) 本アプリの配信・運営等に必要な設備等の、定期的または緊急的な、保守、工事または障害の対策等が必要な場合     (2) 事故、天災、不可抗力、電気通信事業者による電気通信役務の提供の中止等、当社の責によらない事由により本アプリの配信が不可能となった場合     (3) 運用上・技術上停止することがやむを得ない場合     (4) その他当社において停止すべきと判断した場合
                    6.お客様は、建物内、ビル陰およびネットワーク接続エリア対象外の場所などにおいて、通信環境の悪化により一時的に本アプリを利用できなくなる場合があります。
                    
                    第5条（禁止事項）
                    1.当社は､本アプリ上で明示的に許諾されている場合を除き、お客様が本アプリの全部または一部について、転載、複写、複製、転送、抽出、加工、改変、送信可能化その他一切の二次利用をすることを禁止するともに、本アプリを貸与、販売、再配布、公衆送信、再利用許諾等を行うこと､および第三者に利用させることを禁止します｡
                    2.お客様は、本アプリを、逆アセンブル、逆コンパイル、リバースエンジニアリング等によりソースコード、構造、アイデア等を解析することはできず、改変し、または他のソフトウェアと結合することはできません。
                    3.お客様は、本アプリに関する当社または第三者の権利を侵害する行為、当社または第三者に不利益や損害を与える行為、本アプリの配信・運営等を妨害する行為、およびこれらのおそれのある一切の行為を行ってはならないものとします。
                    4.お客様は、本アプリを営利目的または商業目的に利用してはならないものとします。
                    5.お客様は、前各項に定める他、当社が不適当と判断した本アプリ利用に関する行為を行ってはならないものとします。
                    
                    第6条（権利帰属）
                    1.本アプリに関する著作権、商標権等の知的財産権は、当社または当社に権利を許諾した第三者に帰属します。     2.本利用規約は、お客様に対し、本アプリの著作権その他のいかなる権利をも移転することを許諾するものではありません。
                    
                    第7条（不保証）
                    1.当社は、明示または黙示を問わず、本アプリが第三者の知的財産権を侵害していないことにつき一切の保証をしないものとします。     2.当社は、本アプリの瑕疵担保責任を負わず、本アプリの機能、動作性、正確性、信頼性その他一切の事項につき保証を行いません。
                    
                    第8条（個人情報の取扱）
                    1.お客様が本アプリのダウンロードおよび利用にあたり、Appleの運営するダウンロードサイト「AppStore」（以下「AppStore」といいます）において入力した個人情報は、Appleによって管理されます。当該個人情報に係る疑義または争いが発生した場合、当該疑義または争いについてはお客様とAppleとの間で解決するものとし、お客様は当社に対して何らの請求または苦情の申立ても行わないものとします。また、Appleが当該個人情報を第三者に開示または提供したことによりお客様が損害を被ったとしても、当社は賠償等一切の責を負わないものとします。
                    2.お客様は、自己の責任において本アプリに個人情報その他の情報を入力するものとし、当該入力および入力内容に関してお客様が何らかの損害を被った場合であっても、当社は賠償等一切の責を負わないものとします。
                    
                    第9条（本アプリの変更・中止）
                    1.当社は、何らの予告なく当社の裁量により、本アプリの内容（配信方法を含みます）の全部または一部を、機能改良、追加、中止、中断、変更、削除またはアクセス不能とすることができるものとし、当該機能改良、追加、中止、中断、変更、削除またはアクセス不能によってお客様が損害を被った場合であっても、当社は賠償等一切の責を負わないものとします。
                    2.当社は、お客様が本利用規約に違反しまたは違反する恐れのある場合は、何ら通知または催告なしに、お客様に対する本アプリの提供を停止し、または本利用規約の適用を解除することができるものとします。
                    
                    第10条（本利用規約の変更）
                    当社は、本利用規約の内容をお客様の承諾なしに変更することができるものとします。この場合、当社は、AppStore内の本アプリ掲載画面上に掲載する方法により、当該変更の旨をお客様に通知するものとします。ただし、重要な変更については、アプリ上に表示する等の方法により、お客様への周知の徹底を図るものとします。
                    
                    第11条（譲渡禁止）
                    お客様は、本アプリおよび本利用規約に係るいかなる権利または義務も、第三者に移転または譲渡することはできません。
                    
                    第12条（免責）
                    当社は、お客様が本アプリの利用（利用できないことを含みます）に関して損害（データの消失、営業上の利益の逸失による損害を含み、これらに限られません）を被った場合であっても、理由の如何を問わず、損害賠償等一切の責を負いません。これは，当社が当該事項の発生の可能性を予見し、または予見しえた場合であっても同様です。
                    
                    第13条（準拠法・裁判管轄）
                    本利用規約は日本法を準拠法とし、本アプリまたは本利用規約に関し、お客様と当社との間で疑義または争いが生じた場合には、誠意を持って協議し解決することとしますが、それでもなお解決しない場合には、当社の本社を管轄する地方裁判所または簡易裁判所を第一審の専属的合意管轄裁判所とします。
                    
                    第14条（存続条項）
                    上記各条の他本利用規約に定めのない事項については、別途当社の定めるところに従うものとします。本利用規約のいずれかの規定が管轄権のある裁判所により無効である旨判断された場合には、かかる規定は、法律が許容する限りで、本来の規定の趣旨を最大限実現するように変更または解釈されるものとし、また、本利用規約のその他の規定の効力には何らの影響を与えないものとします。
                    """
        case .privacyPolicy:
            return """
                    プライバシーポリシー
                    
                    第三者に個人を特定できる情報を提供することはありません。個人情報の管理には細心の注意を払い、以下に掲げた通りに扱います。
                    アプリの設定画面にはメールでご意見・ご要望、不具合報告が送れる機能があります。
                    問題解決に役立たせるため、OSのバージョン、モバイルかタブレットかなどのモデル、アプリのバージョンなどのデバイス情報が送信されます。
                    また、アプリの利便性向上のため、匿名で、個人を特定できない範囲に細心の注意を払い、アクセス解析をしております。
                    例えば、アプリがクラッシュした時、どの部分でクラッシュしたかを匿名で送信し、バグの素早い修正に役立たせております。
                    また、デバイスやアプリバージョンの使用率、特定の機能の使用率などを解析し、アプリの改善に役立てています。
                    (例えば、より使われている機能の改善を優先的の行うなど)
                    ※ご不明な点があれば、お気軽にお問い合わせください。
                    """
        }
    }
}
