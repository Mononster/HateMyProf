//
//
//  Professor.swift
//  RateMyProfSpider
//
//  Created by Monster on 2017-03-14.
//  Copyright © 2017 Monster. All rights reserved.
//

let kRatingDNE = "No rating yet."

class Professor {
    
    var id: String?
    
    var fullName: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var overallGrade = kRatingDNE
    
    var levelOfDifficulty: String?
    
    var studentComments = [String]()
    
    init(){
    
    }
    
    init(fullName: String, grade: String) {
        
        self.fullName = fullName
        self.overallGrade = grade
    }
    
    func printInfo() {
        
        print("\(fullName!) : \(overallGrade)")
    }
}
