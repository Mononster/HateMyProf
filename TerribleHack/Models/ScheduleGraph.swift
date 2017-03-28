//
//
//  ScheduleGraph.swift
//  RateMyProfSpider
//
//  Created by Monster on 2017-03-19.
//  Copyright © 2017 Monster. All rights reserved.
//

class ScheduleNode {
    // each node represents a class section
    var section: ClassSection?
    
    // for traverse
    var neighbours = [ScheduleNode]()
    var isVisited = false
    
    init(section: ClassSection) {
        self.section = section
    }
    
    func addNeighbour(node: ScheduleNode) {
        self.neighbours.append(node)
    }
    
    func traverseNode() {
        
        print("NeighboursCount: \(self.neighbours.count)")
        for node in self.neighbours {
            node.printNode()
            node.traverseNode()
        }
        
        
    }
    
    func printNode() {
        
        guard let section = self.section else {
            print("Error: section does not exist!")
            return
        }
        
        guard section.startTime != nil && section.endTime != nil else {
            print("\(section.courseCode!)\(section.courseCategoryNum!)\(section.section!)")
            return
        }
        
        print("\(section.courseCode!)\(section.courseCategoryNum!)\(section.section!) \(section.startTime!) -> \(section.endTime!)")
        
//        if !section.isOnlineCourse {
//            print("Starting at: ")
//        }
//        
        var displayString = ""
        for day in section.weekdays {
            displayString += String(day.rawValue)
        }
        
        print("Held at: " + displayString)
        
    }
    
}
