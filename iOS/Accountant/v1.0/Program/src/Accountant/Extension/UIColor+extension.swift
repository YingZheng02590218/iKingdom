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

    // MARK: Accent
    
    class var accentColor: UIColor {
        UIColor(named: "AccentColor") ?? .white
    }

    // MARK: Base

    class var baseColor: UIColor {
        UIColor(named: "BaseColor") ?? .white
    }
    
    // MARK: Main

    class var mainColor2: UIColor {
        UIColor(named: "MainColor2") ?? .white
    }
    
    // MARK: Other

    class var accentBlue: UIColor {
        UIColor(named: "AccentBlue") ?? .white
    }

    class var accentDark: UIColor {
        UIColor(named: "AccentDark") ?? .white
    }
    
    class var accentLight: UIColor {
        UIColor(named: "AccentLight") ?? .white
    }
    
    class var calculatorDisplay: UIColor {
        UIColor(named: "CalculatorDisplay") ?? .white
    }

    class var mainColor: UIColor {
        UIColor(named: "MainColor") ?? .white
    }
    
    // MARK: Paper

    class var accentRedColor: UIColor {
        UIColor(named: "AccentRedColor") ?? .white
    }
    
    class var borderBlueColor: UIColor {
        UIColor(named: "BorderBlueColor") ?? .white
    }

    class var borderRedColor: UIColor {
        UIColor(named: "BorderRedColor") ?? .white
    }
    
    class var bsPlAccentColor: UIColor {
        UIColor(named: "BsPlAccentColor") ?? .white
    }
    
    class var paperColor: UIColor {
        UIColor(named: "PaperColor") ?? .white
    }

    class var paperGradationEnd: UIColor {
        UIColor(named: "PaperGradationEnd") ?? .white
    }

    class var paperGradationStart: UIColor {
        UIColor(named: "PaperGradationStart") ?? .white
    }
    
    class var paperTextColor: UIColor {
        UIColor(named: "PaperTextColor") ?? .white
    }
    
    class var textColor: UIColor {
        UIColor(named: "TextColor") ?? .white
    }

}
