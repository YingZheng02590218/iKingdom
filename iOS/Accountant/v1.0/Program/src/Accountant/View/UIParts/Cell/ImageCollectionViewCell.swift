//
//  ImageCollectionViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/05/04.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    lazy var spinner = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        contentView.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // セルに影をつける
        self.imageView.clipsToBounds = false
        self.imageView.layer.shadowColor = UIColor.gray.cgColor // 影の色
        self.imageView.layer.shadowOffset = CGSize(width: 0.5, height: 1.5) // 影の位置
        self.imageView.layer.shadowOpacity = 1.0 // 影の透明度
        self.imageView.layer.shadowRadius = 4.0 // 影の広がり
    }
}
