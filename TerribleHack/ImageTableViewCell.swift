//
//  ImageTableViewCell.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageForCell: UIImageView! {
        didSet {
            imageForCell.layer.cornerRadius = 5
            imageForCell.layer.masksToBounds = true
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
