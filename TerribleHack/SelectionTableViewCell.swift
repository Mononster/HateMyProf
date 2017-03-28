//
//  SelectionTableViewCell.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

let kSelectionTitleFont = UIFont(name: "ChalkboardSE-Regular", size: 20)

protocol TFResultUpdateDelegate: class {
    func updateSearchKey(key: String, value: String)
}

class SelectionTableViewCell: UITableViewCell {
    
    var result = ""
    
    var key = ""
    
    weak var resultUpdater: TFResultUpdateDelegate?
    
    @IBOutlet weak var selectionInput: UITextField! {
        didSet {
            selectionInput.delegate = self
            selectionInput.font = kSelectionTitleFont
            selectionInput.textColor = UIColor.darkGray
        }
    }

    @IBOutlet weak var selectionTitle: UILabel! {
        didSet {
            selectionTitle.font = kSelectionTitleFont
            selectionTitle.textColor = UIColor.darkGray
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

extension SelectionTableViewCell: UITextFieldDelegate {
    
    // change text format occording to the input type.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let value = textField.text {
            result = value.uppercased()
            
            resultUpdater?.updateSearchKey(key: key, value: result)
        }
    }
}
