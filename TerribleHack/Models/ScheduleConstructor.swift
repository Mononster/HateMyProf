//
//
//  ScheduleConstructor.swift
//  RateMyProfSpider
//
//  Created by Monster on 2017-03-19.
//  Copyright © 2017 Monster. All rights reserved.
//

class ScheduleConstructor {
    
    var courses = [[ClassSection]]()
    
    var sectionSequences = [[ScheduleNode]]()
    
    var resultSequences = [[ScheduleNode]]()
    
    var ifPop = false
    
    var maxDepth = 0
    
    init(courses: [[ClassSection]]) {
        self.courses = courses
    }
    
    func construct(isLowest: Bool = false, completion: @escaping ([ClassSection]) -> ()) {
        buildTree(isLowest) { nodes in
            var sections = [ClassSection]()
            for node in nodes {
                
                guard let section = node.section else {
                    print("Error: cannot decode section")
                    continue
                }
                sections.append(section)
            }
            
            completion(sections)
        }
    }
    
    func buildTree(_ isLowest: Bool, completion: @escaping ([ScheduleNode]) -> ()) {
        
        var allNodes = [ScheduleNode]()
        var index = 1
        for course in courses {
            
            var restCourses = courses
            restCourses.removeSubrange(0..<index)
            
            // each sections represent a list of ClassSections
            for section in course {
                
                let scheduleNode = ScheduleNode(section: section)
                allNodes.append(scheduleNode)
                
                for linkCourse in restCourses {
                    
                    for linkSection in linkCourse {
                        
                        if !checkIfOverlap(sectionA: section, sectionB: linkSection) {
                            // two sections do not overlap
                            // link them up
                            // NOTICE: for our scheduling problem, we can simply use
                            // one direction link to solve it.
                            // first check if the node has already existed in our graph
                            var isFound = false
                            for index in 0..<allNodes.count {
                                if allNodes[index].section == linkSection {
                                    scheduleNode.addNeighbour(node: allNodes[index])
                                    isFound = true
                                    break
                                }
                            }
                            if !isFound {
                                let linkNode = ScheduleNode(section: linkSection)
                                scheduleNode.addNeighbour(node: linkNode)
                            }
                        }
                    }
                }
            }
            
            index += 1
        }
        
        // now link the whole tree up
        let sequences = linkTree(nodes: allNodes)
        // sequences are all possible combination of sections (they do not overlap)
        
        var maxScore = 0.0
        
        if isLowest {
            maxScore = 999
        }
        
        var maxSequence = [ScheduleNode]()
        
        for sequence in sequences {
            
            var sequenceScore = 0.0
            for node in sequence {
                //node.printNode()
                guard let prof = node.section?.professor else {
                    print("Error: Professor does not exist!")
                    continue
                }
                let grade = prof.overallGrade
                
                if grade == kRatingDNE {
                    sequenceScore += 2.5
                    // add 2.5 point if grade does not exist.
                }else {
                    sequenceScore += Double(grade)!
                }
            }
            
            if isLowest {
                if sequenceScore <= maxScore {
                    maxScore = sequenceScore
                    maxSequence = sequence
                }
            }else {
                if sequenceScore >= maxScore {
                    maxScore = sequenceScore
                    maxSequence = sequence
                }
            }
        }
        
//        print("Begin printing max sequence info...")
//        for node in maxSequence {
//            node.printNode()
//            node.section!.professor!.printInfo()
//        }
//        
        completion(maxSequence)
    }
    
    func linkTree(nodes: [ScheduleNode]) -> [[ScheduleNode]] {
        var result = nodes
        // Notice: bottom-up building would be a better approach
        // since nodes are passed by value
        for index in 0..<result.count {
            ifPop = false
            linkNode(node: &result[index], nodes: nodes, sequence: [result[index]])
        }
        
        var index = 0
        for _ in 0..<sectionSequences.count {
            
            if checkIfOverlapOccurInSequence(sequence: sectionSequences[index]) {
                // Overlap -> remove it
                sectionSequences.remove(at: index)
                index -= 1
            }
            
            index += 1
        }
        
        return sectionSequences
    }
    
    func linkNode(node: inout ScheduleNode, nodes: [ScheduleNode], sequence: [ScheduleNode]) {
        
        // HOLY F**K 
        // I wrote this function pretty late at night
        // I was intended to write a dfs function to parse
        // all the section sequnces, which would be a mess
        // then I dont know what happened and suddenly I found this trick :3
        // solving this problem
        
        var newSequence = sequence
        
        for neighbourIndex in 0..<node.neighbours.count {
            //neighbour.printNode()
    
            guard let neighbourSection = node.neighbours[neighbourIndex].section else {
                print("Error: section does not exist!")
                continue
            }
            
            if let findNode = findNodeInCollection(sectionName: neighbourSection.courseName,
                                                   sectionNum: neighbourSection.section,
                                                   sectionCategory: neighbourSection.courseCategoryNum,
                                                   nodes: nodes) {
                node.neighbours[neighbourIndex] = findNode

                if ifPop {
                    newSequence.removeLast()
                    ifPop = false
                }
                
                newSequence.append(findNode)
                
                linkNode(node: &node.neighbours[neighbourIndex], nodes: nodes, sequence: newSequence)
            }
        }
        
        if !ifPop {
            
            if newSequence.count >= maxDepth {
                maxDepth = newSequence.count
                sectionSequences.append(newSequence)
            }
            
            ifPop = true
        }
    }
    
    func findNodeInCollection(sectionName: String?,
                              sectionNum: String?,
                              sectionCategory: String?,
                              nodes: [ScheduleNode]) -> ScheduleNode? {
        
        for node in nodes {
            
            guard let section = node.section else {
                print("Error: section does not exist!")
                continue
            }
            
            if section.section == sectionNum &&
                section.courseName == sectionName &&
                section.courseCategoryNum == sectionCategory {
                return node
            }
        }
        
        return nil
    }
    
    func checkIfOverlapOccurInSequence(sequence: [ScheduleNode]) -> Bool {
        
        for i in 0..<sequence.count {
            
            for j in i + 1..<sequence.count {
                
                if checkIfOverlap(sectionA: sequence[i].section!, sectionB: sequence[j].section!) {
                   return true
                }
            }
        }
        
        return false
    }
    
}

extension ScheduleConstructor {
    
    func checkIfOverlap(sectionA: ClassSection, sectionB: ClassSection) -> Bool {
        
        for daysA in sectionA.weekdays {
            for daysB in sectionB.weekdays {
                
                if daysA == daysB {
                    // now two section will be held on the same day
                    
                    guard let startTimeA = sectionA.startTimeInDate,
                        let startTimeB = sectionB.startTimeInDate,
                        let endTimeA = sectionA.endTimeInDate,
                        let endTimeB = sectionB.endTimeInDate else {
                        // if a section does not have starting time or end time
                        // that means it is an online class, -> will never overlap
                        continue
                    }
                    
                    // http://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
                    // gives a strong/simple proof for this.
                    if startTimeA <= endTimeB && endTimeA >= startTimeB {
                        // Overlap!
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
}

