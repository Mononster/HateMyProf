//
//
//  RateProfSpider.swift
//  RateMyProfSpider
//
//  Created by Monster on 2017-03-14.
//  Copyright © 2017 Monster. All rights reserved.
//

import Kanna
import Alamofire

class RateProfSpider {
    
    fileprivate var profArray = [Professor]()
    
    
    func getProfsGrade(courseName: String,
                       categoryNum: String,
                       completion: @escaping ([ClassSection]) -> ()) {
        
        getSchedule(courseName, categoryNum, completion: completion)
    }

    func getSchedule(_ name: String,
                     _ num: String,
                     completion: @escaping ([ClassSection]) -> ()) {
        
        let courses = Courses()
        
        var classes = [ClassSection]()
        
//        courses.schedule(subject: "CS", catalogNumber: "348") { (
//            meda, data) in
//            print(data)
//        }
        courses.schedule(subject: name, catalogNumber: num) { meta, data in
            
            //print(data)
            
            for indiClass in data.array! {
                
                if let section = indiClass["section"].string {
                    let whitespace = " "
                    let result = section.components(separatedBy: whitespace)[0]
                    
                    if result == "LEC" || result == "STU" {

                        let schedule = ClassSection(json: indiClass)
                        
                        if schedule.isOnlineCourse == true {
                            // kick out all of the online courses
                            continue
                        }
                        
                        if let profName = indiClass["classes"][0]["instructors"][0].string {
                            //print(profName)
                            
                            let prof = Professor()
                            prof.fullName = profName

                            let parsedName = self.parseProfName(name: profName)
                            
                            prof.firstName = parsedName[0]
                            prof.lastName = parsedName[1]
                            
                            self.profArray.append(prof)
                            schedule.professor = prof
                            classes.append(schedule)
                        }
                    }
                }
            }
            
            // remove duplicate profs
            var newArray = [Professor]()
            for prof in self.profArray {
                
                var ifAppend = true
                for newProf in newArray {
                    if prof.fullName == newProf.fullName {
                        ifAppend = false
                        break
                    }
                }
                
                if ifAppend {
                    newArray.append(prof)
                }
            }
            
            var result = [Professor]()
            let tasks = DispatchGroup()
            // scrape each single one of the professors
            for prof in newArray {
                tasks.enter()
                self.scrape(prof: prof) { prof in
                    result.append(prof)
                    tasks.leave()
                }
            }
            tasks.notify(queue: DispatchQueue.main, execute: {
                
                for singleClass in classes {
                    for prof in result {
                        if singleClass.professor?.fullName == prof.fullName {
                            singleClass.professor = prof
                        }
                    }
                }
                
                completion(classes)
            })
            
        }
    }
    
    func parseProfName(name: String) -> [String] {
        let delimiter = ","
        let whitespace = " "
        var result = name.components(separatedBy: delimiter)
        
        // cut middle name out
        // i.e Pretti,John-Paul C
        // cut c out
        result[1] = result[1].components(separatedBy: whitespace)[0]
        
        return result
    }
    
    // Grabs the HTML http://www.ratemyprofessors.com for parsing.
    func scrape(prof: Professor,
                completion: @escaping (Professor) -> ()) -> Void {
        
        if let lastName = prof.lastName,
            let firstName = prof.firstName {
            let search = "http://www.ratemyprofessors.com/search.jsp?query=\(lastName)+\(firstName)"
            Alamofire.request(search).responseString { response in
                //print("\(response.result.isSuccess)")
                if let html = response.result.value {
                    //print(html)
                    self.parseHTML(html: html, prof: prof) {
                        prof in
                        completion(prof)
                    }
                }else {
                    completion(prof)
                }
            }
        }
    }
    
    func parseHTML(html: String,
                   prof: Professor,
                   completion: @escaping (Professor) -> ()) -> Void {
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            // Search for nodes by CSS selector
            //li class="listing PROFESSOR
            let nodes = doc.css("a[href^=/ShowRatings.jsp?tid=]")
            
            //print(nodes.count)
            
            var isMatched = false
            
            for show in nodes {
                
                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //print(showString)
                
                // if there are multiple matches,
                // we use regular expression to fetch
                // the one with university of waterloo.
                
                // FIXME : potentailly two professor can share the same name within the same university.
                
                if nodes.count > 1{
                    
                    let regex = try! NSRegularExpression(pattern: "University of Waterloo", options: [.caseInsensitive])
                    
                    if regex.firstMatch(in: showString, options: [], range: NSMakeRange(0, showString.characters.count)) != nil {
                        //print("\(showString)\n")
                        getProfessorInfo(css: show, prof: prof) { prof in
                            completion(prof)
                        }
                        isMatched = true
                        break
                    }
                }else {
                    isMatched = true
                    getProfessorInfo(css: show, prof: prof) { prof in
                        completion(prof)
                    }
                }
            }
            
            if nodes.count == 0 || !isMatched{
                completion(prof)
            }
            
        }
    }
    
    func getProfessorInfo(css: XMLElement,
                          prof: Professor,
                          completion: @escaping (Professor) -> ()) {
        
        let searchString = "ShowRatings.jsp?tid="
        let resultProf = prof
        if let ref = css["href"] {
            let id = ref.substring(from: searchString.characters.count + 1)
            
            // now we have obtained prof's id
            //print(id)
            
            //http://www.ratemyprofessors.com/ShowRatings.jsp?tid=1848250
            
            parseProfessorPage(id: id, prof: prof) { prof in
                prof.id = id
                completion(prof)
                //print("Professor: \(lastName), \(firstName) -> \(grade)")
            }
        }else {
            completion(resultProf)
            //print("Professor: \(lastName), \(firstName) -> No rating yet.")
        }
        
    }
    
    func parseProfessorPage(id: String,
                            prof: Professor,
                            completion: @escaping (Professor) -> ()){
        
        let page = "http://www.ratemyprofessors.com/ShowRatings.jsp?tid=" + id
        let resultProf = prof
        Alamofire.request(page).responseString { response in
            //print("\(response.result.isSuccess)")
            if let html = response.result.value {
                //print(html)
                
                if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                    
                    for show in doc.css("div[class^=breakdown-container quality]") {
                        
                        let grade = show.css("div[class^=grade]")
                        
                        resultProf.overallGrade = grade.first!.text!
                        
                        //print(grade.first!.text!)
                    }
                    
                    for show in doc.css("div[class^=breakdown-section difficulty]") {
                        
                        let levelOfDifficulty = show.css("div[class^=grade]")
                        
                        resultProf.levelOfDifficulty = levelOfDifficulty.first!.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    for show in doc.css("div[class^=rating-filter togglable]") {
                        
                        let comments = show.css("p[class^=commentsParagraph]")
                        
                        for comment in comments {
                            
                            //print(comment.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                            
                            resultProf.studentComments.append(comment.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                            
                        }
                        
                        
                    }
                }
            }
            completion(resultProf)
        }
        
    }
    
}

extension RateProfSpider {
    
    func parseAllUWProfessors() {
        
        let ref = "http://www.ratemyprofessors.com/search.jsp?queryBy=schoolId&schoolName=University+of+Waterloo&schoolID=1490&queryoption=TEACHER"
        
        Alamofire.request(ref).responseString { response in
            
            if let html = response.result.value {
                
                if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                    

                    for show in doc.css("div[class^=left-panel]") {
                        
                        //print(show.text!)
                        
                        let profs = show.css("div[class^=result-list]")
                        
                        for prof in profs {
                            print(prof.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                            //print(grade.first!.text!)
                        }
                    }
                    
                }
            }
            
        }
    }
}

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
}
