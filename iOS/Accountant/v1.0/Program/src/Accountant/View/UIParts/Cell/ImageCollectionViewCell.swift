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
    
    lazy var spinner = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        commonInit()
    }
    
    private func commonInit() {
        // セルに影をつける
        imageView.clipsToBounds = false
        imageView.layer.shadowColor = UIColor.gray.cgColor // 影の色
        imageView.layer.shadowOffset = CGSize(width: 0.5, height: 1.5) // 影の位置
        imageView.layer.shadowOpacity = 1.0 // 影の透明度
        imageView.layer.shadowRadius = 4.0 // 影の広がり
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        // spinner.color = .white
        contentView.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
}
