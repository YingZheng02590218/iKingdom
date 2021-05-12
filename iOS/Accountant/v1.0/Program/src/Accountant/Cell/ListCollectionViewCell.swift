//
//  ListCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var debitLabel: UILabel!
    @IBOutlet var debitamauntLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var creditamauntLabel: UILabel!
    
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
            // セルの選択状態変化に応じて表示を切り替える
            self.onUpdateSelection()
        }
    }
    
    private func onUpdateSelection() {
        self.contentView.layer.borderWidth = self.isSelected ? 2 : 0
    }
    
}
