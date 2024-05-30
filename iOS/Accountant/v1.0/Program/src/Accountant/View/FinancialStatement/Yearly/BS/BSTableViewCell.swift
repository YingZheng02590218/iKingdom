//
//  BSTableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/29.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit

class BSTableViewCell: UITableViewCell {

    @IBOutlet var labelForPrevious: UILabel!
    @IBOutlet var labelForThisYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.textColor = .paperTextColor
        labelForPrevious.text = ""
        labelForThisYear.text = ""
        
        // selectedBackgroundView を明示的に生成することで、nilになることを防ぐ
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.mainColor
        self.selectedBackgroundView = selectedBackgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
