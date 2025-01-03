//
//  SpatialInference.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 24.11.2024.
//

import Foundation

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
        } else if operation.starts(with: "sort(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 5)
            sort(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "slice(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 6)
            slice(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "produce(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 8)
            produce(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "calc(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 5)
            calc(String(operation[startIdx..<endIdx]))
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
    
    func produce(_ terms: String) {
        print(terms)
    }
    
    func map(_ assignments: String) {
        print(assignments)
    }
    
    
    func calc(_ assignments: String) {
        print(assignments)
    }
    
    func slice(_ range: String) {
        print("slice \(range)")
        let str = range.replacingOccurrences(of: "..", with: ".")
        let list = str.split(separator: ".").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        var lower = 0
        var upper = 0
        if list.count > 0 {
            lower = Int(list[0]) ?? 1
            if lower >= input.count {
                lower = input.count
            }
            if lower < 0 {
                lower = input.count + lower
            } else {
                lower = lower - 1
            }
        }
        if list.count > 1 {
            upper = Int(list[1]) ?? 1
            if upper >= input.count {
                upper = input.count
            }
            if upper < 0 {
                upper = input.count + upper
            } else {
                upper = upper - 1
            }
        } else {
            upper = lower
        }
        if lower > upper {
            let temp = lower
            lower = upper
            upper = temp
        }
        let idxRange = ClosedRange<Int>(uncheckedBounds: (lower: lower, upper: upper))
        print(idxRange)
        output = Array(input[idxRange])
        succeeded = !output.isEmpty
    }
    
    func sort(_ attribute: String) {
        if attribute.contains(".") {
            sortByRelation(attribute)
            return
        }
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
            case "baseradius": sortedObjects = inputObjects.sorted { $0.baseradius < $1.baseradius }
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
            case "baseradius": sortedObjects = inputObjects.sorted { $0.baseradius > $1.baseradius }
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
    
    func sortByRelation(_ attribute: String) {
        var ascending = false
        var inputObjects: [SpatialObject] = []
        let preIndices = fact.backtrace()
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
            sortedObjects = inputObjects.sorted { $0.relationValue(attribute, pre: preIndices) < $1.relationValue(attribute, pre: preIndices) }
        } else {
            sortedObjects = inputObjects.sorted { $0.relationValue(attribute, pre: preIndices) > $1.relationValue(attribute, pre: preIndices) }
        }
        for object in sortedObjects {
            if let idx = fact.objects.firstIndex(where: {$0 === object}) {
                add(index: idx)
            }
        }
        succeeded = !output.isEmpty
    }
    
    func hasFailed() -> Bool {
        return !error.isEmpty
    }
    
    func isManipulating() -> Bool {
        if operation.starts(with: "filter") {
            return true
        }
        if operation.starts(with: "pick") {
            return true
        }
        if operation.starts(with: "select") {
            return true
        }
        if operation.starts(with: "produce") {
            return true
        }
        if operation.starts(with: "slice") {
            return true
        }
        return false
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
        var cond = condition.trimmingCharacters(in: CharacterSet.whitespaces)
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
