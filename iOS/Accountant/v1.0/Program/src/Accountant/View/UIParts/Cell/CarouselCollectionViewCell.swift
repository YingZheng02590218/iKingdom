//
//  CarouselCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/28.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // ダークモード　切り替え時に色が更新されない場合の対策
    override func layoutSubviews() {
        super.layoutSubviews()

        createViewDesign()
    }
    
    override var isHighlighted: Bool {
        didSet {
            createViewDesign()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            // セルの選択状態変化に応じて表示を切り替える
            self.onUpdateSelection()
        }
    }
    
    private func onUpdateSelection() {
        // セルの枠線の太さを変える
        contentView.layer.borderWidth = self.isSelected ? 1 : 0
    }
    
    // ビューのデザインを指定する
    private func createViewDesign() {
        // セルの背景色を変える
        contentView.backgroundColor = isHighlighted ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : .mainColor2
        contentView.layer.borderColor = UIColor.gray.cgColor
        // セルを角丸にする
        contentView.layer.cornerRadius = 10
//        // セルに影をつける
//        self.contentView.layer.shadowColor = UIColor.lightGray.cgColor     // 影の色
//        self.contentView.layer.shadowOffset = CGSize(width: 0,height: 0) // 影の位置
//        self.contentView.layer.shadowOpacity = 1                       // 影の透明度
//        self.contentView.layer.shadowRadius = 10                         // 影の広がり
    }
}
