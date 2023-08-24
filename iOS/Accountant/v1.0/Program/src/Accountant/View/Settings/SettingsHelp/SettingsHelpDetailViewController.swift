//
//  SettingsHelpDetailViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit
import WebKit

class SettingsHelpDetailViewController: UIViewController {
    
    var gADBannerView: GADBannerView!
    
    @IBOutlet private var setUpAccountEditTextView: UITextView!
    @IBOutlet private var configurationTextView: UITextView!
    @IBOutlet private var journalEntryTextView: UITextView!
    @IBOutlet private var journalEntryEditTextView: UITextView!
    @IBOutlet private var journalEntryDeleteTextView: UITextView!
    @IBOutlet private var journalsTextView: UITextView!
    @IBOutlet var baseView: UIView!
    
    var webView: WKWebView?
    
    var textViewSwitchNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch textViewSwitchNumber {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3: // 初期設定の手順
            break
        case 4: // 基本情報の登録をしよう
            break
        case 5: // 勘定科目を設定しよう
            break
        case 6: // 勘定科目の編集しよう
            setUpAccountEditTextView.isHidden = false
            if let baseString = setUpAccountEditTextView.text {
                let attributedString = NSMutableAttributedString(string: setUpAccountEditTextView.text)
                // 勘定科目体系の登録 修正をする ①
                let textAttachment00 = NSTextAttachment()
                textAttachment00.image = UIImage(named: "Text View set Up1.png")!
                var oldWidth = textAttachment00.image!.size.width
                var scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment00.image = UIImage.init(cgImage: textAttachment00.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                var attrStringWithImage = NSAttributedString(attachment: textAttachment00)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location-7, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 修正をする ②
                let textAttachment000 = NSTextAttachment()
                textAttachment000.image = UIImage(named: "Text View set Up2.png")!
                oldWidth = textAttachment000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment000.image = UIImage.init(cgImage: textAttachment000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location-6, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 修正をする ③
                let textAttachment0000 = NSTextAttachment()
                textAttachment0000.image = UIImage(named: "TableViewControllerCategoryList1.png")!
                oldWidth = textAttachment0000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment0000.image = UIImage.init(cgImage: textAttachment0000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment0000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location-5, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 修正をする ④
                let textAttachment00000 = NSTextAttachment()
                textAttachment00000.image = UIImage(named: "TableViewControllerCategoryList2.png")!
                oldWidth = textAttachment00000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment00000.image = UIImage.init(cgImage: textAttachment00000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment00000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location-4, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 修正をする ⑤
                let textAttachment000000 = NSTextAttachment()
                textAttachment000000.image = UIImage(named: "TableViewControllerCategoryList3.png")!
                oldWidth = textAttachment000000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment000000.image = UIImage.init(cgImage: textAttachment000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment000000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location - 3, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 修正をする ⑥
                let textAttachment0000000 = NSTextAttachment()
                textAttachment0000000.image = UIImage(named: "TableViewControllerCategoryList4.png")!
                oldWidth = textAttachment0000000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment0000000.image = UIImage.init(cgImage: textAttachment0000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment0000000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "表示科目名のみ変更").location - 2, 1), with: attrStringWithImage)
                
                // 勘定科目体系の登録 削除をする ①
                let textAttachment00000000 = NSTextAttachment()
                textAttachment00000000.image = UIImage(named: "Text View set Up1.png")!
                oldWidth = textAttachment00000000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment00000000.image = UIImage.init(cgImage: textAttachment00000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment00000000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location - 8, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ②
                let textAttachment000000000 = NSTextAttachment()
                textAttachment000000000.image = UIImage(named: "Text View set Up2.png")!
                oldWidth = textAttachment000000000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment000000000.image = UIImage.init(cgImage: textAttachment000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment000000000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location - 7, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ③
                let textAttachment0000000000 = NSTextAttachment()
                textAttachment0000000000.image = UIImage(named: "Text View set Up3.png")!
                oldWidth = textAttachment0000000000.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment0000000000.image = UIImage.init(cgImage: textAttachment0000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment0000000000)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location - 6, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ④
                let textAttachment444 = NSTextAttachment()
                textAttachment444.image = UIImage(named: "TableViewControllerCategoryList_delete1.png")!
                oldWidth = textAttachment444.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment444.image = UIImage.init(cgImage: textAttachment444.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment444)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location - 5, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ⑤
                let textAttachment555 = NSTextAttachment()
                textAttachment555.image = UIImage(named: "TableViewControllerCategoryList_delete2.png")!
                oldWidth = textAttachment555.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment555.image = UIImage.init(cgImage: textAttachment555.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment555)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location-4, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ⑥
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "TableViewControllerCategoryList_delete3.png")!
                oldWidth = textAttachment666.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location - 3, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ⑦
                let textAttachment777 = NSTextAttachment()
                textAttachment777.image = UIImage(named: "TableViewControllerCategoryList_delete4.png")!
                oldWidth = textAttachment777.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "新規で追加した勘定科目").location-2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "4. 勘定科目の編集しよう"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "* 修正をする"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "* 削除をする"))
                setUpAccountEditTextView.attributedText = attributedString
                setUpAccountEditTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                setUpAccountEditTextView.setContentOffset(
                    CGPoint(x: 0, y: -setUpAccountEditTextView.contentInset.top),
                    animated: false
                )
            }
        case 7: // 環境設定を確認・変更しよう
            configurationTextView.isHidden = false
            if let baseString = configurationTextView.text {
                let attributedString = NSMutableAttributedString(string: configurationTextView.text)
                // 勘定科目体系の登録 削除をする ⑥
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals.png")!
                var oldWidth = textAttachment666.image!.size.width
                var scaleFactor = oldWidth / (configurationTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(configurationTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "損益振替仕訳と資本振替仕訳の表示").location - 3, 1), with: attrStringWithImage)
                // 勘定科目体系の登録 削除をする ⑦
                let textAttachment777 = NSTextAttachment()
                textAttachment777.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals1.png")!
                oldWidth = textAttachment777.image!.size.width
                scaleFactor = oldWidth / (configurationTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
                print(configurationTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "損益振替仕訳と資本振替仕訳の表示").location - 2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "5. 環境設定を確認・変更しよう"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "* 仕訳帳画面"))
                configurationTextView.attributedText = attributedString
                configurationTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                configurationTextView.setContentOffset(
                    CGPoint(x: 0, y: -configurationTextView.contentInset.top),
                    animated: false
                )
            }
        case 8: // 仕訳を入力する
            journalEntryTextView.isHidden = false
            if let baseString = journalEntryTextView.text {
                let attributedString = NSMutableAttributedString(string: journalEntryTextView.text)
                // 勘定科目体系の登録 削除をする ⑥
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "ViewControllerJournalEntry.png")!
                let oldWidth = textAttachment666.image!.size.width
                let scaleFactor = oldWidth / (journalEntryTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                let attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(journalEntryTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 日付の入力").location-2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "4. 帳簿に記帳する"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "1. 仕訳を入力する"))
                journalEntryTextView.attributedText = attributedString
                journalEntryTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                journalEntryTextView.setContentOffset(
                    CGPoint(x: 0, y: -journalEntryTextView.contentInset.top),
                    animated: false
                )
            }
        case 9: // 仕訳を修正する
            journalEntryEditTextView.isHidden = false
            if let baseString = journalEntryEditTextView.text {
                let attributedString = NSMutableAttributedString(string: journalEntryEditTextView.text)
                // 4. 帳簿に記帳する 2. 仕訳を修正する ①
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
                var oldWidth = textAttachment666.image!.size.width
                var scaleFactor = oldWidth / (journalEntryEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(journalEntryEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 任意の仕訳を長押し").location - 3, 1), with: attrStringWithImage)
                // 4. 帳簿に記帳する 2. 仕訳を修正する　②
                let textAttachment777 = NSTextAttachment()
                textAttachment777.image = UIImage(named: "TableViewControllerJournals1.png")!
                oldWidth = textAttachment777.image!.size.width
                scaleFactor = oldWidth / (setUpAccountEditTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
                print(setUpAccountEditTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 任意の仕訳を長押し").location - 2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "4. 帳簿に記帳する"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "2. 仕訳を修正する"))
                journalEntryEditTextView.attributedText = attributedString
                journalEntryEditTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                journalEntryEditTextView.setContentOffset(
                    CGPoint(x: 0, y: -journalEntryEditTextView.contentInset.top),
                    animated: false
                )
            }
        case 10: // 仕訳を削除する
            journalEntryDeleteTextView.isHidden = false
            if let baseString = journalEntryDeleteTextView.text {
                let attributedString = NSMutableAttributedString(string: journalEntryDeleteTextView.text)
                // 4. 帳簿に記帳する 2. 仕訳を修正する ①
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
                var oldWidth = textAttachment666.image!.size.width
                var scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(journalEntryDeleteTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 任意の仕訳を右から左へスワイプ").location - 4, 1), with: attrStringWithImage)
                // 4. 帳簿に記帳する 2. 仕訳を修正する　②
                let textAttachment777 = NSTextAttachment()
                textAttachment777.image = UIImage(named: "TableViewControllerJournals2.png")!
                oldWidth = textAttachment777.image!.size.width
                scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
                print(journalEntryDeleteTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 任意の仕訳を右から左へスワイプ").location - 3, 1), with: attrStringWithImage)
                // 4. 帳簿に記帳する 2. 仕訳を修正する　③
                let textAttachment888 = NSTextAttachment()
                textAttachment888.image = UIImage(named: "TableViewControllerJournals3.png")!
                oldWidth = textAttachment888.image!.size.width
                scaleFactor = oldWidth / (journalEntryDeleteTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment888)
                print(journalEntryDeleteTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "① 任意の仕訳を右から左へスワイプ").location - 2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "4. 帳簿に記帳する"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "3. 仕訳を削除する"))
                journalEntryDeleteTextView.attributedText = attributedString
                journalEntryDeleteTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                journalEntryDeleteTextView.setContentOffset(
                    CGPoint(x: 0, y: -journalEntryDeleteTextView.contentInset.top),
                    animated: false
                )
            }
        case 11: // 入力した取引を確認しよう
            journalsTextView.isHidden = false
            if let baseString = journalsTextView.text {
                let attributedString = NSMutableAttributedString(string: journalsTextView.text)
                // 仕訳帳 ①
                let textAttachment666 = NSTextAttachment()
                textAttachment666.image = UIImage(named: "TableViewControllerJournals4.png")!
                var oldWidth = textAttachment666.image!.size.width
                var scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
                print(journalsTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "* 総勘定元帳").location-3, 1), with: attrStringWithImage)
                // 総勘定元帳　①
                let textAttachment777 = NSTextAttachment()
                textAttachment777.image = UIImage(named: "TableViewControllerGeneralLedger.png")!
                oldWidth = textAttachment777.image!.size.width
                scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
                print(journalsTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "② 任意の勘定").location - 3, 1), with: attrStringWithImage)
                // 総勘定元帳　②
                let textAttachment888 = NSTextAttachment()
                textAttachment888.image = UIImage(named: "TableViewControllerGeneralLedger1.png")!
                oldWidth = textAttachment888.image!.size.width
                scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
                textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
                attrStringWithImage = NSAttributedString(attachment: textAttachment888)
                print(journalsTextView.text.unicodeScalars.count)
                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "② 任意の勘定").location - 2, 1), with: attrStringWithImage)
                // 複数の属性を一気に指定します.
                // 全体の文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 19)
                ], range: NSString(string: baseString).range(of: baseString))
                // カテゴリタイトルの文字サイズを指定
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ], range: NSString(string: baseString).range(of: "4. 帳簿に記帳する"))
                attributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ], range: NSString(string: baseString).range(of: "4. 入力した取引を確認しよう"))
                journalsTextView.attributedText = attributedString
                journalsTextView.textColor = .textColor
                self.view.layoutIfNeeded()    // 追加
                journalsTextView.setContentOffset(
                    CGPoint(x: 0, y: -journalsTextView.contentInset.top),
                    animated: false
                )
            }
        default:
            break
        }
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
        
        baseView.addSubview(webView)
        baseView.bringSubviewToFront(webView)
        
        // 親Viewを覆うように制約をつける
        webView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 0).isActive = true
        webView.layoutIfNeeded()
        
        var fileName = ""
        switch textViewSwitchNumber {
        case 0:
            fileName = "About_This_App"
        case 1:
            fileName = "Thought"
        case 2:
            fileName = "Basic_Of_Bookkeeping"
        case 4:
            fileName = "Set_Up_Basic_Info"
        case 41:
            fileName = "Set_Up_Basic_Info2"
        case 42:
            fileName = "Set_Up_Basic_Info3"
        case 5:
            fileName = "Set_Up_Account"
        case 51:
            fileName = "Set_Up_Account2"
        case 52:
            fileName = "Set_Up_Account3"
        case 53:
            fileName = "Set_Up_Account4"
        default:
            break
        }
        // HTML を読み込む
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ダークモード対応 HTML上の文字色を変更する
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView?.evaluateJavaScript(
                "changeFontColor('\(UITraitCollection.isDarkMode ? "#F2F2F2" : "#0C0C0C")')",
                completionHandler: { _, _ in
                    print("Completed Javascript evaluation.")
                }
            )
            // HTML上の画像を指定する
            self.updateHtmlImage()
        }
    }
    
    // HTML上の画像を指定する
    func updateHtmlImage() {
        switch self.textViewSwitchNumber {
        case 0:
            break
        case 1:
            break
        case 2:
            // 画像を表示させる
            if let path = Bundle.main.url(forResource: "簿記一巡", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 基本情報の登録をしよう
        case 4:
            // 基本情報の登録　事業者名を設定しよう 設定画面
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_user", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 基本情報の登録 事業者名を設定しよう 帳簿情報画面
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsInformation", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSecond('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
        case 41:
            // 基本情報の登録 決算日を設定しよう ①
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_term", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 基本情報の登録 決算日を設定しよう ②
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info2", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSecond('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
        case 42:
            // 基本情報の登録 会計帳簿を作成しよう
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_term", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 基本情報の登録 会計帳簿を作成しよう ③
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info3", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSecond('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 基本情報の登録 会計帳簿を作成しよう ④
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info4", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageThird('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
        case 5:
            break
        case 51:
            // 勘定科目体系の登録 勘定科目を一覧で表示 ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSecond('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ③
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageThird('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            
            // 勘定科目体系の登録 表示科目別に勘定科目を表示 ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageForth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ②
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsCategory_categoriesBSandPL", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageFifth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ③
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsTaxonomyAccountByTaxonomyList", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSixth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
        case 52:
            break
        case 53:
            // 勘定科目体系の登録　新規に追加登録する ①設定画面
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImage('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　新規に追加登録する ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSecond('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　新規に追加登録する ③
            if let path = Bundle.main.url(forResource: "Text View set Up3", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageThird('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            
            // 勘定科目体系の登録　新規に追加登録する ④
            if let path = Bundle.main.url(forResource: "Text View set Up4", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageForth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　新規に追加登録する ⑤
            if let path = Bundle.main.url(forResource: "Text View set Up5", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageFifth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
            // 勘定科目体系の登録　新規に追加登録する ⑥
            if let path = Bundle.main.url(forResource: "Text View set Up6", withExtension: "png") {
                print(path)
                self.webView?.evaluateJavaScript(
                    "changeImageSixth('\(path)')",
                    completionHandler: { _, _ in
                        print("Completed Javascript evaluation.")
                    }
                )
            }
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
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
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

extension SettingsHelpDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 長押しによる選択、コールアウト表示を禁止する
        webView.prohibitTouchCalloutAndUserSelect()
    }
}
