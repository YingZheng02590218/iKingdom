//
//  UIColor+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/29.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    class var AccentBlue: UIColor {
        return UIColor(named: "AccentBlue")!
    }

    class var AccentColor: UIColor {
        return UIColor(named: "AccentColor") ?? .white
    }

    class var AccentLight: UIColor {
        return UIColor(named: "AccentLight")!
    }

    class var BaseColor: UIColor {
        return UIColor(named: "BaseColor") ?? .white
    }

    class var CalculatorDisplay: UIColor {
        return UIColor(named: "CalculatorDisplay")!
    }

    class var MainColor: UIColor {
        return UIColor(named: "MainColor") ?? .white
    }

    class var MainColor2: UIColor {
        return UIColor(named: "MainColor2") ?? .white
    }
    
    class var TextColor: UIColor {
        return UIColor(named: "TextColor")!
    }

    static let theme = UIColor(named: "C1D2EB")

}
