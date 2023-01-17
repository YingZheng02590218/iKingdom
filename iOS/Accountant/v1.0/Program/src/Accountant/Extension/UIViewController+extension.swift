//
//  UIViewController+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/03.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import GoogleMobileAds // マネタイズ対応
import UIKit

extension UIViewController {

    // MARK: - アップグレード機能　スタンダードプラン

    // 広告を表示
    func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: bannerView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: bottomLayoutGuide,
                    attribute: .top,
                    multiplier: 1,
                    constant: constant
                ),
                NSLayoutConstraint(
                    item: bannerView,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerX,
                    multiplier: 1,
                    constant: 0
                )
            ]
        )
    }
    // 広告を非表示
    func removeBannerViewToView(_ bannerView: GADBannerView) {

        bannerView.removeFromSuperview()
    }
}
