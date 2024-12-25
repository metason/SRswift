//
//  SpatialInference.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 24.11.2024.
//

import Foundation

// infer, query, parse, transform, execute spatial query, process

class SpatialInference {
        
    var input:[Int] = [] // index to fact.base.objects
    var output:[Int] = [] // index to fact.base.objects
    var operation = ""
    var succeeded = false
    var error = ""
    var fact:SpatialReasoner
    
    init(input: [Int], operation: String, in fact: SpatialReasoner) {
        self.input = input
        self.operation = operation
        self.fact = fact
        let endIdx = operation.index(operation.endIndex, offsetBy: -1)
        if operation.starts(with: "filter(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 7)
            filter(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "pick(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 5)
            pick(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "select(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 7)
            select(String(operation[startIdx..<endIdx]))
        }else if operation.starts(with: "sort(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 5)
            sort(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "analyse(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 8)
            analyse(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "validate(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 9)
            validate(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "map(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 4)
            map(String(operation[startIdx..<endIdx]))
        }
    }
    
    private func add(index:Int) {
        if !output.contains(index) {
            output.append(index)
        }
    }
    
    func filter(_ condition: String) {
        let predicate = SpatialInference.attributePredicate(condition)
        let baseObjects = fact.base["objects"] as! [Any]
        for i in input {
            let result = predicate!.evaluate(with: baseObjects[i])
            if result {
                add(index: i)
            }
        }
        succeeded = true
    }
    
    func pick(_ relations: String) {
        let predicates = relations.keywords()
        for i in input {
            for j in 0..<fact.objects.count {
                var cond = relations
                if i != j {
                    for predicate in predicates {
                        if fact.does(subject: fact.objects[j], have: predicate, with: i) {
                            cond = cond.replacingOccurrences(of: predicate, with: "TRUEPREDICATE")
                        } else {
                            cond = cond.replacingOccurrences(of: predicate, with: "FALSEPREDICATE")
                        }
                    }
                    let result = NSPredicate(format: cond).evaluate(with: nil)
                    if result {
                        add(index: j)
                    }
                }
            }
        }
        succeeded = !output.isEmpty
    }
    
    func select(_ terms: String) {
        let list = terms.split(separator: "?").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.count != 2 {
            error = "Invalid select query"
            return
        }
        let conditions = list[1]
        let relations = list[0]
        let predicates = relations.keywords()
        let baseObjects = fact.base["objects"] as! [Any]
        for i in input {
            for j in 0..<fact.objects.count {
                var cond = relations
                if i != j {
                    for predicate in predicates {
                        if fact.does(subject: fact.objects[j], have: predicate, with: i) {
                            cond = cond.replacingOccurrences(of: predicate, with: "TRUEPREDICATE")
                        } else {
                            cond = cond.replacingOccurrences(of: predicate, with: "FALSEPREDICATE")
                        }
                    }
                    let result = NSPredicate(format: cond).evaluate(with: nil)
                    if result {
                        let attrPredicate = SpatialInference.attributePredicate(conditions)
                        let result2 = attrPredicate!.evaluate(with: baseObjects[j])
                        if result2 {
                            add(index: i)
                        }
                    }
                }
            }
        }
        succeeded = !output.isEmpty
    }
    
    func analyse(_ assignments: String) {
        print(assignments)
    }
    
    func map(_ assignments: String) {
        print(assignments)
    }
    
    func sort(_ attribute: String) {
        var ascending = false
        var inputObjects: [SpatialObject] = []
        var sortedObjects: [SpatialObject]
        for i in input {
            inputObjects.append(fact.objects[i])
        }
        let list = attribute.split(separator: " ").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.count > 1 {
            if list[1] == "<" {
                ascending = true
            }
        }
        if ascending {
            switch list[0] {
            case "width": sortedObjects = inputObjects.sorted { $0.width < $1.width }
            case "height": sortedObjects = inputObjects.sorted { $0.height < $1.height }
            case "depth": sortedObjects = inputObjects.sorted { $0.depth < $1.depth }
            case "length": sortedObjects = inputObjects.sorted { $0.length < $1.length }
            case "angle": sortedObjects = inputObjects.sorted { $0.angle < $1.angle }
            case "yaw": sortedObjects = inputObjects.sorted { $0.yaw < $1.yaw }
            case "footprint": sortedObjects = inputObjects.sorted { $0.footprint < $1.footprint }
            case "frontface": sortedObjects = inputObjects.sorted { $0.frontface < $1.frontface }
            case "sideface": sortedObjects = inputObjects.sorted { $0.sideface < $1.sideface }
            case "surface": sortedObjects = inputObjects.sorted { $0.surface < $1.surface }
            case "volume": sortedObjects = inputObjects.sorted { $0.volume < $1.volume }
            case "perimeter": sortedObjects = inputObjects.sorted { $0.perimeter < $1.perimeter }
            case "groundradius": sortedObjects = inputObjects.sorted { $0.groundradius < $1.groundradius }
            case "radius": sortedObjects = inputObjects.sorted { $0.radius < $1.radius }
            case "speed": sortedObjects = inputObjects.sorted { $0.speed < $1.speed }
            case "confidence": sortedObjects = inputObjects.sorted { $0.confidence.value < $1.confidence.value }
            case "lifespan": sortedObjects = inputObjects.sorted { $0.lifespan < $1.lifespan }
            default: sortedObjects = inputObjects
            }
        } else {
            switch list[0] {
            case "width": sortedObjects = inputObjects.sorted { $0.width > $1.width }
            case "height": sortedObjects = inputObjects.sorted { $0.height > $1.height }
            case "depth": sortedObjects = inputObjects.sorted { $0.depth > $1.depth }
            case "length": sortedObjects = inputObjects.sorted { $0.length > $1.length }
            case "angle": sortedObjects = inputObjects.sorted { $0.angle > $1.angle }
            case "yaw": sortedObjects = inputObjects.sorted { $0.yaw > $1.yaw }
            case "footprint": sortedObjects = inputObjects.sorted { $0.footprint > $1.footprint }
            case "frontface": sortedObjects = inputObjects.sorted { $0.frontface > $1.frontface }
            case "sideface": sortedObjects = inputObjects.sorted { $0.sideface > $1.sideface }
            case "surface": sortedObjects = inputObjects.sorted { $0.surface > $1.surface }
            case "volume": sortedObjects = inputObjects.sorted { $0.volume > $1.volume }
            case "perimeter": sortedObjects = inputObjects.sorted { $0.perimeter > $1.perimeter }
            case "groundradius": sortedObjects = inputObjects.sorted { $0.groundradius > $1.groundradius }
            case "radius": sortedObjects = inputObjects.sorted { $0.radius > $1.radius }
            case "speed": sortedObjects = inputObjects.sorted { $0.speed > $1.speed }
            case "confidence": sortedObjects = inputObjects.sorted { $0.confidence.value > $1.confidence.value }
            case "lifespan": sortedObjects = inputObjects.sorted { $0.lifespan > $1.lifespan }
            default: sortedObjects = inputObjects
            }
        }
        for object in sortedObjects {
            if let idx = fact.objects.firstIndex(where: {$0 === object}) {
                add(index: idx)
            }
        }
        succeeded = !output.isEmpty
    }
    
    func validate(_ condition: String) {
        print(condition)
    }
    
    func hasFailed() -> Bool {
        return !error.isEmpty
    }
    
    public func asDict() -> Dictionary<String, Any>? {
        let output = [
            "operation": operation,
            "input": input,
            "output": output,
            "error": error,
            "succeeded": succeeded
        ] as [String : Any]
        return output
    }
    
    static func attributePredicate(_ condition: String) -> NSPredicate? {
        var cond = condition
        /// for boolean attributes: add comparison (e.g., == TRUE) if missing
        for word in SpatialObject.booleanAttributes {
            var searchRange = cond.startIndex..<cond.endIndex
            while let range = cond.range(of: word, range: searchRange) {
                if range.upperBound < cond.endIndex {
                    let ahead = cond[range.upperBound..<cond.index(range.upperBound, offsetBy: 5)]
                    if !ahead.contains("=") && !ahead.contains("<") && !ahead.contains(">") {
                        cond.replaceSubrange(range, with: word + " == TRUE")
                    }
                } else {
                    cond.replaceSubrange(range, with: word + " == TRUE")
                }
                searchRange = range.upperBound..<cond.endIndex
            }
        }
        return NSPredicate(format: cond)
    }

}

extension String {
    
    func keywords() -> [String] {
        let scanner = Scanner(string: self)
        var keywords: [String] = [String]()
        while !scanner.isAtEnd {
            let result = scanner.scanCharacters(from: CharacterSet.lowercaseLetters)
            if result != nil {
                if !keywords.contains(result! as String) {
                    keywords.append(result! as String)
                }
            }
            _ = scanner.scanUpToCharacters(from: CharacterSet.lowercaseLetters)
        }
        return keywords
    }
    
}
