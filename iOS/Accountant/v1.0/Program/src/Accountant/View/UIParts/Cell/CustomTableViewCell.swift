//
//  CustomTableViewCell.swift
//  CollectionInTableApp
//
//  Created by Hisashi Ishihara on 2023/07/16.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let customCollectionViewCellName = "CustomCollectionViewCell"
        collectionView.register(UINib(nibName: customCollectionViewCellName, bundle: nil), forCellWithReuseIdentifier: customCollectionViewCellName)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
