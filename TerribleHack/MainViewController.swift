//
//  ViewController.swift
//  TerribleHack
//
//  Created by Monster on 2017-03-25.
//  Copyright © 2017 Monster. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var tableView: UITableView!
    
    var courseCode: String?
    
    var courseNum: String?
    
    var indicator: UIActivityIndicatorView!
    
    var searchBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
    }

}

extension MainViewController {
    
    func setupUI() {
        
        self.navigationItem.title = "Find Your Shitty Prof"
        
        setupTableView()
        setupIndicator()
    }
    
    func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        tableView.register(UINib.init(nibName: "SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectionTableViewCell")
        
        tableView.register(UINib.init(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
        
        tableView.backgroundColor = .white
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.keyboardDismissMode = .onDrag
        
        self.view.addSubview(tableView)
    }
    
    func setupIndicator() {
        self.indicator = UIActivityIndicatorView()
    }
}

extension MainViewController: TFResultUpdateDelegate {
    
    func updateSearchKey(key: String, value: String) {
        
        if key == "CourseCode" {
            self.courseCode = value
        }
        
        if key == "CourseNum" {
            self.courseNum = value
        }
    }
}

extension MainViewController {
    
    func searchBtnClicked() {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let key = self.courseCode, let value = self.courseNum {
            
            let spider = RateProfSpider()
            self.indicator.startAnimating()
            searchBtn.setTitle("", for: .normal)
            spider.getProfsGrade(courseName: key, categoryNum: value, completion: { (result) in
                self.indicator.stopAnimating()
                self.searchBtn.setTitle("President Blessed -> GO", for: .normal)
                let profVC = ProfessorViewController()
                var resultProf = Professor()
                
                var score = 5.0
                
                for section in result {
                    if let prof = section.professor {
                        if let profScore = Double(prof.overallGrade) {
                            if profScore < score {
                                score = profScore
                                resultProf = prof
                            }
                        }
                    }
                }
                
                profVC.professor = resultProf
                
                self.navigationController?.pushViewController(profVC, animated: true)
            })
        }
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 270
        }
        
        if indexPath.row == 1 || indexPath.row == 2 {
            return 115
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
        
        searchBtn = UIButton(frame: CGRect(x: 55, y: 40, width: self.view.frame.width - 110, height: 40))
        searchBtn.layer.cornerRadius = 5
        searchBtn.layer.masksToBounds = true
        searchBtn.backgroundColor = UIColor(netHex: 0xFF5647)
        searchBtn.setTitle("President Blessed -> GO", for: .normal)
        searchBtn.setTitleColor(UIColor.white, for: .normal)
        searchBtn.titleLabel?.font = kSelectionTitleFont
        searchBtn.addTarget(self, action: #selector(searchBtnClicked), for: .touchUpInside)
        
        self.indicator.frame = CGRect(x: searchBtn.frame.width / 2 - 10, y: 10, width: 20, height: 20)
        indicator.removeFromSuperview()
        indicator.isHidden = true
        searchBtn.addSubview(indicator)
        container.addSubview(searchBtn)
        
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
            cell.imageForCell.image = #imageLiteral(resourceName: "feridun")
            cell.selectionStyle = .none
            return cell
        }
        
        if indexPath.row == 1 || indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionTableViewCell", for: indexPath) as! SelectionTableViewCell
            
            switch indexPath.row {
            case 1:
                cell.selectionTitle.text = "Enter your course name!"
                cell.key = "CourseCode"
            case 2:
                cell.selectionTitle.text = "Enter your course code!"
                cell.key = "CourseNum"
            default:
                break
            }
            cell.selectionStyle = .none
            cell.resultUpdater = self
            return cell
        }else {
            return UITableViewCell()
        }
    }
}

extension MainViewController: UITableViewDelegate {
    
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

