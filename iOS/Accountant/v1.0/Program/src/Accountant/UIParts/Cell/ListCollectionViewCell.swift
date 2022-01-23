//
//  ListCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView

class ListCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var debitLabel: UILabel!
    @IBOutlet var debitamauntLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var creditamauntLabel: UILabel!
    
    @IBOutlet var backgroundViewForNeumorphism: EMTNeumorphicView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func layoutSubviews() {
        
        createViewDesign()
    }
    
    override var isSelected: Bool {
        didSet {
            // セルの選択状態変化に応じて表示を切り替える
            self.onUpdateSelection()
        }
    }
    
    private func onUpdateSelection() {
        // セルの枠線の太さを変える
        backgroundViewForNeumorphism.neumorphicLayer?.borderWidth = self.isSelected ? 2 : 0
    }
    
    let LIGHTSHADOWOPACITY: Float = 0.3
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 6
    let edged = false
    
    // ビューのデザインを指定する
    private func createViewDesign() {
        backgroundViewForNeumorphism.neumorphicLayer?.borderColor = UIColor.gray.cgColor
        // セルを角丸にする
        self.contentView.layer.cornerRadius = 10
        
        backgroundViewForNeumorphism.neumorphicLayer?.cornerRadius = 10
        backgroundViewForNeumorphism.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        backgroundViewForNeumorphism.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        backgroundViewForNeumorphism.neumorphicLayer?.edged = edged
        backgroundViewForNeumorphism.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        backgroundViewForNeumorphism.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
    }
    
}
