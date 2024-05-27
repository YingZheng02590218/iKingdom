//
//  SemiModalIndicatorView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/05/16.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import UIKit

/// セミモーダル　インジケータ
final class SemiModalIndicatorView: UIView {

    // MARK: Initializer

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}

// MARK: Private Functions
extension SemiModalIndicatorView {

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 2.5
        backgroundColor = UIColor.darkGray
    }
}
