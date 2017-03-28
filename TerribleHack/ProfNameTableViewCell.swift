//
//  ProfNameTableViewCell.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class ProfNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var congrat: UILabel! {
        didSet {
            congrat.font = kSelectionTitleFont
            congrat.textColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var profName: UILabel! {
        
        didSet {
            profName.font = UIFont(name: "ChalkboardSE-Bold", size: 50)
            profName.textColor = UIColor.init(netHex: 0xFF5647)
            profName.adjustsFontSizeToFitWidth = true
        }
        
    }
    
    @IBOutlet weak var enjoyStudy: UILabel! {
        didSet {
            enjoyStudy.font = kSelectionTitleFont
            enjoyStudy.textColor = UIColor.darkGray
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
