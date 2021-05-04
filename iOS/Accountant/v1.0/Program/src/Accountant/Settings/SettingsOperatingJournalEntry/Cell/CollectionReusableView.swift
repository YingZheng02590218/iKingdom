//
//  CollectionReusableView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/04.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // セルの背景色を変える
        addButton.backgroundColor = .white
        // セルの枠線の太さを変える
        addButton.layer.borderWidth = 0
        addButton.layer.borderColor = UIColor.gray.cgColor
        // セルを角丸にする
        addButton.layer.cornerRadius = 5
//        // セルに影をつける
//        addButton.layer.shadowColor = UIColor.lightGray.cgColor     // 影の色
//        addButton.layer.shadowOffset = CGSize(width: 0,height: 0) // 影の位置
//        addButton.layer.shadowOpacity = 1                       // 影の透明度
//        addButton.layer.shadowRadius = 10                         // 影の広がり
    }
    
}
