//
//  ListCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

protocol DeleteDataCollectionProtocol {
    func deleteData(number: Int)
}

class ListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var debitLabel: UILabel!
    @IBOutlet var debitamauntLabel: UILabel!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var creditamauntLabel: UILabel!
    @IBOutlet var backgroundViewForNeumorphism: EMTNeumorphicView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var checkmarkImageView: UIImageView!
    
    var isEditing = false {
        didSet {
            deleteButton.isHidden = !isEditing
        }
    }
    // よく使う仕訳の連番
    var number: Int?
    /// コールバック
    var switchValueChangedCompletion: ((Bool, Int) -> Void)?
    
    var delegate: DeleteDataCollectionProtocol?
    
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
        backgroundViewForNeumorphism.neumorphicLayer?.borderWidth = self.isSelected ? 1 : 0
        // チェックマーク
        checkmarkImageView.isHidden = !(isEditing && isSelected)

        if let number = number {
            // タップ時の選択状態とよく使う仕訳自身の連番を返す
            switchValueChangedCompletion?(isSelected, number)
        }
    }
    
    // ビューのデザインを指定する
    private func createViewDesign() {
        // セルを角丸にする
        self.contentView.layer.cornerRadius = 10
        
        backgroundViewForNeumorphism.neumorphicLayer?.cornerRadius = 10
        backgroundViewForNeumorphism.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        backgroundViewForNeumorphism.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        backgroundViewForNeumorphism.neumorphicLayer?.edged = Constant.edged
        backgroundViewForNeumorphism.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        backgroundViewForNeumorphism.neumorphicLayer?.elementBackgroundColor = isHighlighted ? UIColor.gray.cgColor : UIColor.mainColor2.cgColor
        backgroundViewForNeumorphism.neumorphicLayer?.borderColor = UIColor.gray.cgColor
        // 削除ボタン
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        deleteButton.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: config), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.backgroundColor = .white
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 12.5
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        // チェックマーク
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill") ?? UIImage()
        checkmarkImageView.tintColor = .accentBlue
        checkmarkImageView.backgroundColor = .white
        checkmarkImageView.layer.masksToBounds = true
        checkmarkImageView.layer.cornerRadius = 12.5
        checkmarkImageView.isHidden = !(isEditing && isSelected)
    }
    
    @objc private func deleteButtonAction() {
        if let number = number {
            delegate?.deleteData(number: number)
        }
    }
}
