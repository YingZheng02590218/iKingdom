//
//  CollectionReusableView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/04.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

class CollectionReusableView: UICollectionReusableView {

    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet private var addButton: EMTNeumorphicButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 日付　ボタン作成
    }
    
    override func layoutSubviews() {
        
    }
    
    
}
