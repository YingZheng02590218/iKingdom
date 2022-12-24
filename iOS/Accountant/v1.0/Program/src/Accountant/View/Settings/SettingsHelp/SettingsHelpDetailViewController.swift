//
//  SettingsHelpDetailViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

class SettingsHelpDetailViewController: UIViewController {

   var gADBannerView: GADBannerView!
    
    @IBOutlet private var aboutThisAppTextView: UITextView!
    @IBOutlet private var thoughtTextView: UITextView!
    @IBOutlet private var basicOfBookkeepingTextView: UITextView!
    @IBOutlet private var setUpTextView: UITextView!
    @IBOutlet private var setUpBasicInfoTextView: UITextView!
    @IBOutlet private var setUpAccountTextView: UITextView!
    @IBOutlet private var setUpAccountEditTextView: UITextView!
    @IBOutlet private var configurationTextView: UITextView!
    @IBOutlet private var journalEntryTextView: UITextView!
    @IBOutlet private var journalEntryEditTextView: UITextView!
    @IBOutlet private var journalEntryDeleteTextView: UITextView!
    @IBOutlet private var journalsTextView: UITextView!
    
    var textViewSwitchNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        switch textViewSwitchNumber {
        case 0:
            aboutThisAppTextView.isHidden = false
            let baseString = aboutThisAppTextView.text
            let attributedString = NSMutableAttributedString(string: baseString!)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "このアプリについて"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "アプリ名："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "概要："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "想定ユーザー："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "コンセプト："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "作成書類："))
            aboutThisAppTextView.attributedText = attributedString
            aboutThisAppTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            aboutThisAppTextView.setContentOffset(
                CGPoint(x: 0, y: -aboutThisAppTextView.contentInset.top),
                animated: false
            )
        case 1:
            thoughtTextView.isHidden = false
//            textView_thought.font = .systemFont(ofSize: 19)
            let baseString = thoughtTextView.text
            let attributedString = NSMutableAttributedString(string: baseString!)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "当アプリで採用した会計概念"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　簿記の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　帳簿会計の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　会計帳簿の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　仕訳の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　帳簿決算（帳簿の締め切り）方法"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　経済活動の種類による分類"))
            thoughtTextView.attributedText = attributedString
            thoughtTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            thoughtTextView.setContentOffset(
                CGPoint(x: 0, y: -thoughtTextView.contentInset.top),
                animated: false
            )
        case 2:
            basicOfBookkeepingTextView.isHidden = false
            let baseString = basicOfBookkeepingTextView.text
            let attributedString = NSMutableAttributedString(string: basicOfBookkeepingTextView.text)
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "簿記一巡.png")!
            let oldWidth = textAttachment.image!.size.width;
            print(textAttachment.image!.size.width)
            print(basicOfBookkeepingTextView.frame.size.width)
            print((UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!)
            let scaleFactor = oldWidth / (basicOfBookkeepingTextView.frame.size.width - 20)*1; //for the padding inside the textView
            print(scaleFactor)
            textAttachment.image = UIImage.init(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            print(basicOfBookkeepingTextView.text.unicodeScalars.count)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "1. 簿記の基礎"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "1. 取引の発生から財務諸表までの流れ"))
            attributedString.replaceCharacters(in: NSMakeRange(150, 1), with: attrStringWithImage)
            basicOfBookkeepingTextView.attributedText = attributedString
            basicOfBookkeepingTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            basicOfBookkeepingTextView.setContentOffset(
                CGPoint(x: 0, y: -basicOfBookkeepingTextView.contentInset.top),
                animated: false
            )
        case 3: // 初期設定の手順
            setUpTextView.isHidden = false
            let baseString = setUpTextView.text
            let attributedString = NSMutableAttributedString(string: setUpTextView.text)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "1. 初期設定の手順"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "    1. 基本情報の登録 "))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "    2. 勘定科目体系の登録 "))
            setUpTextView.attributedText = attributedString
            setUpTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            setUpTextView.setContentOffset(
                CGPoint(x: 0, y: -setUpTextView.contentInset.top),
                animated: false
            )
        case 4: // 基本情報の登録をしよう
            setUpBasicInfoTextView.isHidden = false
            let baseString = setUpBasicInfoTextView.text
            let attributedString = NSMutableAttributedString(string: setUpBasicInfoTextView.text)
            // 基本情報の登録　事業者名を設定しよう 設定画面
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "TableViewControllerSettings_cell_user.png")!
            var oldWidth = textAttachment.image!.size.width
            print(textAttachment.image!.size.width)
            print(setUpBasicInfoTextView.frame.size.width)
            var scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20)*3; // -20 for the padding inside the textView, *3 textViewの幅の三分の1のサイズにするため
            textAttachment.image = UIImage.init(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            print(NSString(string: baseString!).range(of: "こちらで設定した事業者名は"))
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した事業者名は").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 事業者名を設定しよう 帳簿情報画面
            let textAttachmentt = NSTextAttachment()
            textAttachmentt.image = UIImage(named: "TableViewControllerSettingsInformation.png")!
            oldWidth = textAttachmentt.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachmentt.image = UIImage.init(cgImage: textAttachmentt.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachmentt)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した事業者名は").location-2, 1), with: attrStringWithImage)
            // 基本情報の登録 決算日を設定しよう ①
            let textAttachment1 = NSTextAttachment()
            textAttachment1.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_term.png")!
            oldWidth = textAttachment1.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment1.image = UIImage.init(cgImage: textAttachment1.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment1)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した決算日は").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 決算日を設定しよう ②
            let textAttachment2 = NSTextAttachment()
            textAttachment2.image = UIImage(named: "Text View set Up basic Info2.png")!
            oldWidth = textAttachment2.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment2.image = UIImage.init(cgImage: textAttachment2.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment2)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した決算日は").location-2, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう
            let textAttachment0 = NSTextAttachment()
            textAttachment0.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_term.png")!
            oldWidth = textAttachment0.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0.image = UIImage.init(cgImage: textAttachment0.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-4, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう ③
            let textAttachment3 = NSTextAttachment()
            textAttachment3.image = UIImage(named: "Text View set Up basic Info3.png")!
            oldWidth = textAttachment3.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment3.image = UIImage.init(cgImage: textAttachment3.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment3)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう ④
            let textAttachment4 = NSTextAttachment()
            textAttachment4.image = UIImage(named: "Text View set Up basic Info4.png")!
            oldWidth = textAttachment4.image!.size.width
            scaleFactor = oldWidth / (setUpBasicInfoTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment4.image = UIImage.init(cgImage: textAttachment4.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment4)
            print(setUpBasicInfoTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "2. 基本情報の登録をしよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 事業者名を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 決算日を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 会計帳簿を作成しよう"))
            setUpBasicInfoTextView.attributedText = attributedString
            setUpBasicInfoTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            setUpBasicInfoTextView.setContentOffset(
                CGPoint(x: 0, y: -setUpBasicInfoTextView.contentInset.top),
                animated: false
            )
        case 5: // 勘定科目を設定しよう
            setUpAccountTextView.isHidden = false
            let baseString = setUpAccountTextView.text
            let attributedString = NSMutableAttributedString(string: setUpAccountTextView.text)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ①
            let textAttachment00 = NSTextAttachment()
            textAttachment00.image = UIImage(named: "Text View set Up1.png")!
            var oldWidth = textAttachment00.image!.size.width
            var scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment00.image = UIImage.init(cgImage: textAttachment00.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment00)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ②
            let textAttachment000 = NSTextAttachment()
            textAttachment000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment000.image = UIImage.init(cgImage: textAttachment000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ③
            let textAttachment0000 = NSTextAttachment()
            textAttachment0000.image = UIImage(named: "TableViewControllerCategoryList.png")!
            oldWidth = textAttachment0000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0000.image = UIImage.init(cgImage: textAttachment0000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-2, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 表示科目別に勘定科目を表示 ①
            let textAttachment0 = NSTextAttachment()
            textAttachment0.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachment0.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0.image = UIImage.init(cgImage: textAttachment0.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ②
            let textAttachment1 = NSTextAttachment()
            textAttachment1.image = UIImage(named: "TableViewControllerSettingsCategory_categoriesBSandPL.png")!
            oldWidth = textAttachment1.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment1.image = UIImage.init(cgImage: textAttachment1.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment1)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ③
            let textAttachment11 = NSTextAttachment()
            textAttachment11.image = UIImage(named: "TableViewControllerSettingsTaxonomyAccountByTaxonomyList.png")!
            oldWidth = textAttachment11.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment11.image = UIImage.init(cgImage: textAttachment11.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment11)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-2, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ①設定画面
            let textAttachmentttt = NSTextAttachment()
            textAttachmentttt.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachmentttt.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachmentttt.image = UIImage.init(cgImage: textAttachmentttt.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachmentttt)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ②
            let textAttachment2 = NSTextAttachment()
            textAttachment2.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment2.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment2.image = UIImage.init(cgImage: textAttachment2.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment2)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ③
            let textAttachment3 = NSTextAttachment()
            textAttachment3.image = UIImage(named: "Text View set Up3.png")!
            oldWidth = textAttachment3.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment3.image = UIImage.init(cgImage: textAttachment3.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment3)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ④
            let textAttachment4 = NSTextAttachment()
            textAttachment4.image = UIImage(named: "Text View set Up4.png")!
            oldWidth = textAttachment4.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment4.image = UIImage.init(cgImage: textAttachment4.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment4)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ⑤
            let textAttachment5 = NSTextAttachment()
            textAttachment5.image = UIImage(named: "Text View set Up5.png")!
            oldWidth = textAttachment5.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment5.image = UIImage.init(cgImage: textAttachment5.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment5)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ⑥
            let textAttachment6 = NSTextAttachment()
            textAttachment6.image = UIImage(named: "Text View set Up6.png")!
            oldWidth = textAttachment6.image!.size.width
            scaleFactor = oldWidth / (setUpAccountTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment6.image = UIImage.init(cgImage: textAttachment6.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment6)
            print(setUpAccountTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "3. 勘定科目を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 準備資料"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 勘定科目の確認"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 勘定科目体系の図"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 新規に追加登録する"))
            setUpAccountTextView.attributedText = attributedString
            setUpAccountTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            setUpAccountTextView.setContentOffset(
                CGPoint(x: 0, y: -setUpAccountTextView.contentInset.top),
                animated: false
            )
        case 6: // 勘定科目の編集しよう
            setUpAccountEditTextView.isHidden = false
            let baseString = setUpAccountEditTextView.text
            let attributedString = NSMutableAttributedString(string: setUpAccountEditTextView.text)
            // 勘定科目体系の登録 修正をする ①
            let textAttachment00 = NSTextAttachment()
            textAttachment00.image = UIImage(named: "Text View set Up1.png")!
            var oldWidth = textAttachment00.image!.size.width
            var scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment00.image = UIImage.init(cgImage: textAttachment00.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment00)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ②
            let textAttachment000 = NSTextAttachment()
            textAttachment000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment000.image = UIImage.init(cgImage: textAttachment000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ③
            let textAttachment0000 = NSTextAttachment()
            textAttachment0000.image = UIImage(named: "TableViewControllerCategoryList1.png")!
            oldWidth = textAttachment0000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0000.image = UIImage.init(cgImage: textAttachment0000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ④
            let textAttachment00000 = NSTextAttachment()
            textAttachment00000.image = UIImage(named: "TableViewControllerCategoryList2.png")!
            oldWidth = textAttachment00000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment00000.image = UIImage.init(cgImage: textAttachment00000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment00000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ⑤
            let textAttachment000000 = NSTextAttachment()
            textAttachment000000.image = UIImage(named: "TableViewControllerCategoryList3.png")!
            oldWidth = textAttachment000000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment000000.image = UIImage.init(cgImage: textAttachment000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ⑥
            let textAttachment0000000 = NSTextAttachment()
            textAttachment0000000.image = UIImage(named: "TableViewControllerCategoryList4.png")!
            oldWidth = textAttachment0000000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0000000.image = UIImage.init(cgImage: textAttachment0000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-2, 1), with: attrStringWithImage)
            
            // 勘定科目体系の登録 削除をする ①
            let textAttachment00000000 = NSTextAttachment()
            textAttachment00000000.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachment00000000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment00000000.image = UIImage.init(cgImage: textAttachment00000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment00000000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-8, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ②
            let textAttachment000000000 = NSTextAttachment()
            textAttachment000000000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000000000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment000000000.image = UIImage.init(cgImage: textAttachment000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000000000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ③
            let textAttachment0000000000 = NSTextAttachment()
            textAttachment0000000000.image = UIImage(named: "Text View set Up3.png")!
            oldWidth = textAttachment0000000000.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment0000000000.image = UIImage.init(cgImage: textAttachment0000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000000000)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ④
            let textAttachment444 = NSTextAttachment()
            textAttachment444.image = UIImage(named: "TableViewControllerCategoryList_delete1.png")!
            oldWidth = textAttachment444.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment444.image = UIImage.init(cgImage: textAttachment444.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment444)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑤
            let textAttachment555 = NSTextAttachment()
            textAttachment555.image = UIImage(named: "TableViewControllerCategoryList_delete2.png")!
            oldWidth = textAttachment555.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment555.image = UIImage.init(cgImage: textAttachment555.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment555)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerCategoryList_delete3.png")!
            oldWidth = textAttachment666.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑦
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerCategoryList_delete4.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 勘定科目の編集しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 修正をする"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 削除をする"))
            setUpAccountEditTextView.attributedText = attributedString
            setUpAccountEditTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            setUpAccountEditTextView.setContentOffset(
                CGPoint(x: 0, y: -setUpAccountEditTextView.contentInset.top),
                animated: false
            )
        case 7: // 環境設定を確認・変更しよう
            configurationTextView.isHidden = false
            let baseString = configurationTextView.text
            let attributedString = NSMutableAttributedString(string: configurationTextView.text)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (configurationTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(configurationTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "損益振替仕訳と資本振替仕訳の表示").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑦
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals1.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (configurationTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(configurationTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "損益振替仕訳と資本振替仕訳の表示").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "5. 環境設定を確認・変更しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 仕訳帳画面"))
            configurationTextView.attributedText = attributedString
            configurationTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            configurationTextView.setContentOffset(
                CGPoint(x: 0, y: -configurationTextView.contentInset.top),
                animated: false
            )
        case 8: // 仕訳を入力する
            journalEntryTextView.isHidden = false
            let baseString = journalEntryTextView.text
            let attributedString = NSMutableAttributedString(string: journalEntryTextView.text)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "ViewControllerJournalEntry.png")!
            let oldWidth = textAttachment666.image!.size.width
            let scaleFactor = oldWidth / (journalEntryTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(journalEntryTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 日付の入力").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "1. 仕訳を入力する"))
            journalEntryTextView.attributedText = attributedString
            journalEntryTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            journalEntryTextView.setContentOffset(
                CGPoint(x: 0, y: -journalEntryTextView.contentInset.top),
                animated: false
            )
        case 9: // 仕訳を修正する
            journalEntryEditTextView.isHidden = false
            let baseString = journalEntryEditTextView.text
            let attributedString = NSMutableAttributedString(string: journalEntryEditTextView.text)
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (journalEntryEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(journalEntryEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を長押し").location-3, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerJournals1.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(setUpAccountEditTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を長押し").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "2. 仕訳を修正する"))
            journalEntryEditTextView.attributedText = attributedString
            journalEntryEditTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            journalEntryEditTextView.setContentOffset(
                CGPoint(x: 0, y: -journalEntryEditTextView.contentInset.top),
                animated: false
            )
        case 10: // 仕訳を削除する
            journalEntryDeleteTextView.isHidden = false
            let baseString = journalEntryDeleteTextView.text
            let attributedString = NSMutableAttributedString(string: journalEntryDeleteTextView.text)
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(journalEntryDeleteTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-4, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerJournals2.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(journalEntryDeleteTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-3, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　③
            let textAttachment888 = NSTextAttachment()
            textAttachment888.image = UIImage(named: "TableViewControllerJournals3.png")!
            oldWidth = textAttachment888.image!.size.width
            scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment888)
            print(journalEntryDeleteTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "3. 仕訳を削除する"))
            journalEntryDeleteTextView.attributedText = attributedString
            journalEntryDeleteTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            journalEntryDeleteTextView.setContentOffset(
                CGPoint(x: 0, y: -journalEntryDeleteTextView.contentInset.top),
                animated: false
            )
        case 11: // 入力した取引を確認しよう
            journalsTextView.isHidden = false
            let baseString = journalsTextView.text
            let attributedString = NSMutableAttributedString(string: journalsTextView.text)
            // 仕訳帳 ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals4.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(journalsTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "* 総勘定元帳").location-3, 1), with: attrStringWithImage)
            // 総勘定元帳　①
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerGeneralLedger.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(journalsTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "② 任意の勘定").location-3, 1), with: attrStringWithImage)
            // 総勘定元帳　②
            let textAttachment888 = NSTextAttachment()
            textAttachment888.image = UIImage(named: "TableViewControllerGeneralLedger1.png")!
            oldWidth = textAttachment888.image!.size.width
            scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
            textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment888)
            print(journalsTextView.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "② 任意の勘定").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "4. 入力した取引を確認しよう"))
            journalsTextView.attributedText = attributedString
            journalsTextView.textColor = .textColor
            self.view.layoutIfNeeded()    // 追加
            journalsTextView.setContentOffset(
                CGPoint(x: 0, y: -journalsTextView.contentInset.top),
                animated: false
            )
        default:
            break
        }
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: 50 * -1)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
