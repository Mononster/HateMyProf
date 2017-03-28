//
//  MainNavigationBar.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class MainNavigatonController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont(name: "ChalkboardSE-Regular", size: 20)!]
        self.navigationBar.tintColor = UIColor.darkGray
    }
    
}
