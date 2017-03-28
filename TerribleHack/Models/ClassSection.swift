//
//
//  CourseScheduleInfo
//  RateMyProfSpider
//
//  Created by Monster on 2017-03-14.
//  Copyright © 2017 Monster. All rights reserved.
//

import Foundation

enum Weekdays: Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
}

class ClassSection {
    
    var professor: Professor?
    
    var courseName: String?
    
    var courseCategoryNum: String?
    
    var courseCode: String?
    
    var section: String?
    
    var startTime: String?
    
    var startTimeInDate: Date?
    
    var endTime: String?
    
    var endTimeInDate: Date?
    
    var duration: String?
    
    var building: String?
    
    var room: String?
    
    var weekdays = [Weekdays]()
    
    var isOnlineCourse = false
    
    var json: JSON?
    
    init(json: JSON) {
        
        self.json = json
        
        let classes = json["classes"][0]
        let dates = classes["date"]
        let location = classes["location"]
        
        if let title = json["title"].string {
            self.courseName = title
        }
        
        if let section = json["section"].string {
            self.section = section
        }
        
        if let subject = json["subject"].string {
            self.courseCode = subject
        }
        
        if let categoryNum = json["catalog_number"].string {
            self.courseCategoryNum = categoryNum
        }
        
        if let weekdays = dates["weekdays"].string {
            self.weekdays = parseWeekDays(weekdays: weekdays)
        }
        
        if let building = location["building"].string {
            self.building = building
        }
        
        if let room = location["room"].string {
            self.room = room
        }
        
        let professor = json["professor"]
        
        if let profFullName = professor["fullName"].string,
            let profGrade = professor["grade"].string {
            let prof = Professor(fullName: profFullName, grade: profGrade)
            self.professor = prof
        }
    }
    
    func generateEncodeJson() -> JSON{
        
        var data = json!.object!
        
        if let prof = self.professor {
            var profInfo = [String : String]()
            profInfo["fullName"] = prof.fullName!
            profInfo["grade"] = prof.overallGrade
            
            let profJson = JSON(profInfo)
            
            data["professor"] = profJson
        }
        
        return JSON(data)
    }
    
    
    
    func parseWeekDays(weekdays: String) -> [Weekdays] {
        
        var result = [Weekdays]()
        
        var index = 0
        for character in weekdays.characters {
            
            if character == "T" {
                if index + 1 < weekdays.characters.count {
                    
                    let nextChar = weekdays[index + 1]
                    if nextChar == "h" {
                        // Thursday detected
                        result.append(Weekdays.Thursday)
                    }else {
                        result.append(Weekdays.Tuesday)
                    }
                }else {
                    result.append(Weekdays.Tuesday)
                }
            }
            
            if character == "M" {
                result.append(Weekdays.Monday)
            }
            
            if character == "W" {
                result.append(Weekdays.Wednesday)
            }
            
            if character == "F" {
                result.append(Weekdays.Friday)
            }
            
            index += 1
        }
        
        return result
    }
    
    func printInfo() {
        
        print("CourseName: \(courseName)")
        print("StartTime: \(startTime)")
        print("EndTime: \(endTime)")
        for weekday in weekdays {
            print(weekday.rawValue)
        }
        print("Location: \(building) \(room)")
    }
}

extension ClassSection: Equatable {
    static func ==(lhs: ClassSection, rhs: ClassSection) -> Bool {
        return lhs.section == rhs.section &&
            lhs.courseCategoryNum == rhs.courseCategoryNum &&
            lhs.courseName == rhs.courseName
    }
}
