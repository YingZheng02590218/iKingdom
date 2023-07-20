//
//  CarouselTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/19.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CarouselTableViewCell: UITableViewCell {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // setup
        createList()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 画面の回転に合わせてCellのサイズを変更する
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    // MARK: - Create View
    
    // setup
    func createList() {
        // xib読み込み
        let nib = UINib(nibName: "CarouselCollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }

    func configure(gropName: String) {
        titleLabel.text = gropName
    }
}
