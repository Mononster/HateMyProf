//
//  RatingTableViewCell.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var rating: UILabel! {
        didSet {
            rating.textColor = UIColor.init(netHex: 0xFF5647)
            rating.font = UIFont(name: "ChalkboardSE-Bold", size: 150)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
