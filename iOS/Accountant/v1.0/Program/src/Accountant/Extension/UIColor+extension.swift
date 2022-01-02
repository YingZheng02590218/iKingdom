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
    /// AccentOrange RGB:#xxxx
    class var AccentOrange: UIColor {
        return UIColor(named: "AccentOrange")!
    }
    
    class var TextColor: UIColor {
        return UIColor(named: "TextColor")!
    }
    
    class var Background: UIColor {
        return UIColor(named: "Background")!
    }
    
    class var ButtonTextColor: UIColor {
        return UIColor(named: "ButtonTextColor")!
    }
    
    class var Background_light: UIColor {
        return UIColor(named: "Background_light")!
    }
    
    class var Background_dark: UIColor {
        return UIColor(named: "Background_dark")!
    }

    static let theme = UIColor(named: "C1D2EB")

}
