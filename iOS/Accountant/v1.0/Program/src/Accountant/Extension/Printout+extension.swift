//
//  Printout+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/29.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // オフスクリーン画像を作成
    func captureImage() -> UIImage? {
        print("captureImage")
        // ①オフスクリーンを作成
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        print(" bounds.size: \(bounds.size)")
        // 設定されているCGContextを取り出す
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return nil
        }

        self.layer.render(in: context)
        // オフスクリーンを画像として取り出す
        let capturedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return capturedImage
    }
}

extension UITextView {

    var contentBottom: CGFloat {
        contentSize.height - bounds.height
    }
    // オフスクリーン画像を作成
    func captureImageTextView() -> UIImage? {
            // オフスクリーン保持用のプロパティ
            let images = captureImages()

            // Concatenate images

            print(" contentSize: \(contentSize)\n")
            UIGraphicsBeginImageContext(contentSize)

            // ①画像を描画
            // ②スケーリングさせないUIImageの描画
            var y: CGFloat = 0
            for image in images {
                print("images.count: \(images.count)")
                image.draw(at: CGPoint(x: 0, y: y))
                print(" y : \(y)")
                y = min(y + bounds.height, contentBottom) // calculate layer diff
                print(" y + bounds.height, contentBottom :  \(y) + \(bounds.height), \(contentBottom)")
            }
            let concatImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            return concatImage
    }

    func captureImages() -> [UIImage] {
        print("captureImages")
        // オフスクリーン保持用のプロパティ
        var images: [UIImage?] = []

        while true {

            images.append(superview?.captureImage()) // not work in self.view

            if contentOffset.y < (contentBottom - bounds.height) { // スクロール高さ<コンテント高さー座標高さー座標高さ
                // iPadを横向きで実行するとこのパスを通る
                print("if contentOffset.y < (contentBottom - bounds.height)")
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                contentOffset.y += bounds.height
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
            } else {
                // contentBottomの座標からセクションの高さを引く?　※セクションは残ったままとなる
                contentOffset.y = contentBottom
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
                images.append(superview?.captureImage()) // not work in self.view
                break
            }
        }
        return images.compactMap { $0 } // exclude nil
    }
}

extension UITableView {

    var contentBottom: CGFloat {
        contentSize.height - bounds.height
    }

    func captureImagee() -> UIImage? {
        print("captureImagee")
        // オフスクリーン保持用のプロパティ
        let images = captureImages()

        // Concatenate images

        print(" contentSize: \(contentSize)\n")
        UIGraphicsBeginImageContext(contentSize)

        // ①画像を描画
        // ②スケーリングさせないUIImageの描画
        var y: CGFloat = 0
        for image in images {
            print("images.count: \(images.count)")
            image.draw(at: CGPoint(x: 0, y: y))
            print(" y : \(y)")
            y = min(y + bounds.height, contentBottom) // calculate layer diff
            print(" y + bounds.height, contentBottom :  \(y) + \(bounds.height), \(contentBottom)")
        }
        let concatImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return concatImage
    }

    func captureImages() -> [UIImage] {
        print("captureImages")
        // オフスクリーン保持用のプロパティ
        var images: [UIImage?] = []

        while true {

            images.append(superview?.captureImage()) // not work in self.view

            if contentOffset.y < (contentBottom - bounds.height) { // スクロール高さ<コンテント高さー座標高さー座標高さ
                // iPadを横向きで実行するとこのパスを通る
                print("if contentOffset.y < (contentBottom - bounds.height)")
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                contentOffset.y += bounds.height
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
            } else {
                // contentBottomの座標からセクションの高さを引く?　※セクションは残ったままとなる
                contentOffset.y = contentBottom
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
                images.append(superview?.captureImage()) // not work in self.view
                break
            }
        }
        return images.compactMap { $0 } // exclude nil
    }
}

extension UIScrollView {

    func getContentImage(captureSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(captureSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // 元の frame.size を記憶
        let originalSize = self.frame.size
        // frame.size を一時的に変更
        self.frame.size = self.contentSize
        self.layer.render(in: context)
        // 元に戻す
        self.frame.size = originalSize

        let capturedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return capturedImage
    }
}

extension NSAttributedString {

    static func parseHTML2Text(sourceText text: String) -> NSAttributedString? {
        let encodeData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        var attributedString: NSAttributedString?
        if let encodeData = encodeData {
            do {
                attributedString = try NSAttributedString(
                    data: encodeData,
                    options: attributedOptions,
                    documentAttributes: nil
                )
            } catch _ {
                print("エラーが発生しました")
            }
        }
        return attributedString
    }
}
