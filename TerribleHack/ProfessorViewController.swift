//
//  ProfessorViewController.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class ProfessorViewController: UIViewController {
    
    var tableView: UITableView!
    var professor: Professor!
    
    override func viewDidLoad() {
        setupUI()
    }
}

extension ProfessorViewController {
    
    func setupUI() {
        
        self.navigationItem.title = "Your Shitty Prof Has Been Found"
        setupTableView()
    }
    
    func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        tableView.register(UINib.init(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingTableViewCell")
        
        tableView.register(UINib.init(nibName: "ProfNameTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfNameTableViewCell")
        
        tableView.register(UINib.init(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
        
        tableView.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.keyboardDismissMode = .onDrag
        
        self.view.addSubview(tableView)
    }
}

extension ProfessorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        
        if indexPath.row == 1 {
            return 160
        }
        
        if indexPath.row == 2 {
            return 270
        }
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
            cell.rating.text = professor.overallGrade
            cell.selectionStyle = .none
            return cell
        }
        
        if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfNameTableViewCell", for: indexPath) as! ProfNameTableViewCell
            
            if let firstName = professor.firstName, let lastName = professor.lastName {
                cell.profName.text = firstName + ", " + lastName
            }else {
                cell.profName.text = professor.fullName
            }
            cell.selectionStyle = .none
            return cell
            
        }
        
        if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
            cell.imageForCell.image = #imageLiteral(resourceName: "goose")
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
}

extension ProfessorViewController: UITableViewDelegate {
    
}

