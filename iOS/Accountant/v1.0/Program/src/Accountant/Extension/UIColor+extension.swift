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

    class var accentBlue: UIColor {
        UIColor(named: "AccentBlue") ?? .white
    }

    class var accentColor: UIColor {
        UIColor(named: "AccentColor") ?? .white
    }

    class var accentDark: UIColor {
        UIColor(named: "AccentDark") ?? .white
    }
    
    class var accentLight: UIColor {
        UIColor(named: "AccentLight") ?? .white
    }

    class var baseColor: UIColor {
        UIColor(named: "BaseColor") ?? .white
    }

    class var borderBlueColor: UIColor {
        UIColor(named: "BorderBlueColor") ?? .white
    }

    class var borderRedColor: UIColor {
        UIColor(named: "BorderRedColor") ?? .white
    }
    
    class var calculatorDisplay: UIColor {
        UIColor(named: "CalculatorDisplay") ?? .white
    }

    class var mainColor: UIColor {
        UIColor(named: "MainColor") ?? .white
    }

    class var mainColor2: UIColor {
        UIColor(named: "MainColor2") ?? .white
    }

    class var cellBackground: UIColor {
        UIColor(named: "CellBackground") ?? .white
    }
    
    class var cellBackgroundGradationStart: UIColor {
        UIColor(named: "CellBackgroundGradationStart") ?? .white
    }
    
    class var cellBackgroundGradationEnd: UIColor {
        UIColor(named: "CellBackgroundGradationEnd") ?? .white
    }
    
    class var textColor: UIColor {
        UIColor(named: "TextColor") ?? .white
    }

    static let theme = UIColor(named: "C1D2EB")
}
