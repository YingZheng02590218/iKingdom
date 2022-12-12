//
//  CarouselTabCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/16.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CarouselTabCollectionViewCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var view: UIView! // 洗濯中のマーク
    @IBOutlet var coverEfect: UIView! // 選択中以外にエフェクトをかける
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // セルの背景色を変える
        self.contentView.backgroundColor = .white
        // セルの枠線の太さを変える
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        // セルを角丸にする
        self.contentView.layer.cornerRadius = 10
    }
    
    
    override var isSelected: Bool {
        didSet {
            self.view.backgroundColor = self.isSelected ? .accentBlue : .clear
        }
    }

}
