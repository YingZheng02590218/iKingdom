//
//  UIView+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/29.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    // MARK: Utility
    
    /// 枠線の色
    @IBInspectable var borderColor: UIColor? {
        get {
            layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 枠線のWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 角丸の大きさ
    @IBInspectable var cornerRound: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// 影の色
    @IBInspectable var shadowColor: UIColor? {
        get {
            layer.shadowColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.shadowColor = newValue?.cgColor
            layer.masksToBounds = false
        }
    }
    
    /// 影の透明度
    @IBInspectable var shadowAlpha: Float {
        get {
            layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// 影のオフセット
    @IBInspectable var shadowOffset: CGSize {
        get {
            layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// 影のぼかし量
    @IBInspectable var shadowRadius: CGFloat {
        get {
            layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    // MARK: アニメーション
    
    // マイクロインタラクション アニメーション　ボタン
    func animateView() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.3,
                initialSpringVelocity: 10,
                options: .curveEaseOut,
                animations: {
                    self.transform = .identity
                }, completion: nil
            )
        }
    }
    
    // マイクロインタラクション アニメーション　セル
    func animateViewSmaller() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 10,
                options: .curveEaseOut,
                animations: {
                    self.transform = .identity
                }, completion: nil
            )
        }
    }
    
    // マイクロインタラクション アニメーション　セル 編集中
    func animateViewWobble(isActive: Bool) {
        if isActive {
            // Create wobble animation
            let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
            wobble.values = [0.0, -0.02, 0.0, 0.02, 0.0]
            wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            wobble.duration = 0.75
            wobble.isAdditive = true
            wobble.repeatCount = Float.greatestFiniteMagnitude
            
            self.layer.add(wobble, forKey: "wobble")
        } else {
            self.layer.removeAllAnimations()
        }
    }
    
    // フェードイン・アウトメソッド
    func animateViewFadeOut() {
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseIn) {
            self.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut) {
                self.alpha = 0
            }
        }
    }
}

extension UIView {
    // TableViewのスワイプアクションの擬似的なアニメーション
    class func animateRevealHideActionForRow(cell: UITableViewCell, completion: (() -> Void)? = nil) {
        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "trash.fill")
            imageView.backgroundColor = .systemRed
            imageView.tintColor = .white
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        let swipeLabelWidth = 80.0
        let swipeLabelFrame = CGRect(x: cell.bounds.size.width - swipeLabelWidth, y: cell.frame.origin.y, width: swipeLabelWidth, height: cell.bounds.size.height)
        
        var swipeLabel: UILabel? = .init(frame: swipeLabelFrame)
        if let swipeLabel = swipeLabel {
            swipeLabel.backgroundColor = .systemRed
            swipeLabel.textColor = .white
            // セルに背景色をつける。削除ボタンを隠すため
            cell.backgroundColor = UIColor.mainColor2
            // TableViewを取得
            if let superview = cell.superview {
                superview.addSubview(swipeLabel)
                NSLayoutConstraint.activate([
                    swipeLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
                ])
                // セルを削除ボタンの前面に移動させる
                superview.bringSubviewToFront(cell)
            }
            
            swipeLabel.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalTo: swipeLabel.heightAnchor, multiplier: 0.45),
                imageView.centerXAnchor.constraint(equalTo: swipeLabel.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor)
            ])
        }
        
        UIView.animate(
            withDuration: 1.5,
            animations: {
                cell.frame = .init(
                    x: cell.frame.origin.x - swipeLabelWidth,
                    y: cell.frame.origin.y,
                    width: cell.bounds.size.width,
                    height: cell.bounds.size.height
                )
            }
        ) { _ in
            UIView.animate(
                withDuration: 1.5,
                animations: {
                    cell.frame = .init(
                        x: cell.frame.origin.x + swipeLabelWidth,
                        y: cell.frame.origin.y,
                        width: cell.bounds.size.width,
                        height: cell.bounds.size.height
                    )
                }, completion: { _ in
                    swipeLabel?.removeFromSuperview()
                    swipeLabel = nil
                    // セルに背景色をつける。削除ボタンを隠すため
                    cell.backgroundColor = .clear
                    
                    completion?()
                }
            )
        }
    }
    
    // TableViewのドラッグアクションの擬似的なアニメーション
    class func animateRevealHideActionForTable(tableView: UITableView, completion: (() -> Void)? = nil) {
        let swipeLabelHeight = 80.0
        
        UIView.animate(
            withDuration: 1.5,
            animations: {
                tableView.frame = .init(
                    x: tableView.frame.origin.x,
                    y: tableView.frame.origin.y + swipeLabelHeight,
                    width: tableView.bounds.size.width,
                    height: tableView.bounds.size.height
                )
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    tableView.frame = .init(
                        x: tableView.frame.origin.x,
                        y: tableView.frame.origin.y - swipeLabelHeight,
                        width: tableView.bounds.size.width,
                        height: tableView.bounds.size.height
                    )
                }, completion: { _ in
                    
                    completion?()
                }
            )
        }
    }
}
