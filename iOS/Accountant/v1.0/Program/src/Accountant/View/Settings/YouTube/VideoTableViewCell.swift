//
//  VideoTableViewCell.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2022/08/08.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet var thumbnailsImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var publishedAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
