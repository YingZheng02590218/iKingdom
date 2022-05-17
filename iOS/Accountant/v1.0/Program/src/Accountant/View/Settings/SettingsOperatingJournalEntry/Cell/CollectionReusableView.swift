//
//  CollectionReusableView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/04.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView

class CollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet var addButton: EMTNeumorphicButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 日付　ボタン作成
        createButtons()
    }
    
    override func layoutSubviews() {
        
        createButtons()
    }
    
    let LIGHTSHADOWOPACITY: Float = 0.3
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 6
    let edged = false
    // ボタンのデザインを指定する
    private func createButtons() {
        addButton.setTitleColor(.ButtonTextColor, for: .normal)
        addButton.neumorphicLayer?.cornerRadius = 10
        addButton.setTitleColor(.ButtonTextColor, for: .selected)
        addButton.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        addButton.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        addButton.neumorphicLayer?.edged = edged
        addButton.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        addButton.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
    }
    
}
