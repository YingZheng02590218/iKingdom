//
//  MapTableViewCell.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2022/08/08.
//

import UIKit

class MapTableViewCell: UITableViewCell {


    @IBOutlet var thumbnailsImageView: UIImageView!

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var openingHoursLabel: UILabel!

    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var starRatingStakView: UIView!
    @IBOutlet var user_ratings_totalLabel: UILabel!
    
    @IBOutlet var type: UILabel!
    @IBOutlet var publishedAtLabel: UILabel!


    @IBOutlet var htmlTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 星を表示させる
    func setRating(rating: Double) {
        DispatchQueue.main.async {
//            let starRatingView = StarRatingView(frame: CGRect(origin: .zero, size: CGSize(width: self.starRatingStakView.bounds.width*0.9, height: self.starRatingStakView.bounds.height*0.9)),
//                                                rating: Float(rating),
//                                                color: UIColor.systemOrange,
//                                                starRounding: .floorToHalfStar)
//            self.starRatingStakView.addSubview(starRatingView)
//            starRatingView.centerXAnchor.constraint(equalTo: self.starRatingStakView.centerXAnchor).isActive = true
//            starRatingView.centerYAnchor.constraint(equalTo: self.starRatingStakView.centerYAnchor).isActive = true
        }
    }
}
