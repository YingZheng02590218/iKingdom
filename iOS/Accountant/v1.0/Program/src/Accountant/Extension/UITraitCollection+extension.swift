//
//  UITraitCollection+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/24.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

extension UITraitCollection {

    // ダークモード判定
    public static var isDarkMode: Bool {
        if #available(iOS 13, *), current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }

}
