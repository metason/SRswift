//
//  SpatialInference.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 24.11.2024.
//

import Foundation
import SceneKit

public class SpatialInference : Hashable, Identifiable {
    
    public var input:[Int] = [] // indices to fact.base.objects
    public var output:[Int] = [] // indices to fact.base.objects
    public var operation = ""
    public var succeeded = false
    public var error = ""
    private var fact:SpatialReasoner
    
    public init(input: [Int], operation: String, in fact: SpatialReasoner) {
        self.input = input
        self.operation = operation
        self.fact = fact
        let endIdx = operation.index(operation.endIndex, offsetBy: -1)
        if operation.starts(with: "filter(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 7)
            filter(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "isa(") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 4)
            isa(String(operation[startIdx..<endIdx]))
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
        } else if operation.starts(with: "backtrac") {
            let startIdx = operation.index(operation.startIndex, offsetBy: 10)
            backtrace(String(operation[startIdx..<endIdx]))
        } else if operation.starts(with: "reload(") {
            reload()
        } else  {
            error = "Unknown inference operation: \(operation)"
        }
    }
    
    private func add(index: Int) {
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
        succeeded = !output.isEmpty
    }
    
    func isa(_ type: String) {
        var str = type.lowercased().replacingOccurrences(of: " || ", with: " or ")
        str = str.replacingOccurrences(of: " or ", with: " | ")
        let list = str.split(separator: "|")
        
        let baseObjects = fact.base["objects"] as! [Dictionary<String, Any>]
        for i in input {
            var doAdd = false
            for term in list {
                if !doAdd {
                    let targetType = term.trimmingCharacters(in: CharacterSet(charactersIn: "' "))
                    var baseConcept:SpatialObjectConcept? = nil
                    var baseType = baseObjects[i]["type"] as? String
                    if baseType != nil && !baseType!.isEmpty {
                        baseConcept = SpatialTaxonomy.getConcept(label: baseType!)
                    }
                    if baseConcept == nil {
                        baseType = baseObjects[i]["label"] as? String
                        baseConcept = SpatialTaxonomy.getConcept(label: baseType!)
                    }
                    if baseConcept != nil {
                        let result = baseConcept!.isa(type: targetType)
                        doAdd = result != nil
                    }
                }
            }            
            if doAdd {
                add(index: i)
            }
        }
        succeeded = !output.isEmpty
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
        var relations:String
        var conditions:String = ""
        if list.count == 1 {
            relations = list[0]
        } else if list.count == 2 {
            relations = list[0]
            conditions = list[1]
        } else {
            error = "Invalid select query"
            return
        }
        if relations.lowercased().contains("any ") {
            relations = relations.replacingOccurrences(of: "ANY ", with: "").replacingOccurrences(of: "any ", with: "")
        }
        var inclusive = false
        if relations.lowercased().contains("all ") {
            inclusive = true
            relations = relations.replacingOccurrences(of: "ALL ", with: "").replacingOccurrences(of: "all ", with: "")
        }
        var exclude = false
        if relations.lowercased().contains("not ") || relations.lowercased().contains("!"){
            exclude = true
            inclusive = true
            relations = relations.replacingOccurrences(of: "NOT ", with: "").replacingOccurrences(of: "not ", with: "").replacingOccurrences(of: "!", with: "")
        }
        let predicates = relations.keywords()
        let baseObjects = fact.base["objects"] as! [Any]
        for i in input {
            var limit = fact.objects.count - 1
            if i == limit {
                limit = limit - 1
            }
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
                    let resultRel = NSPredicate(format: cond).evaluate(with: nil)
                    var resultAttr = true
                    if conditions != "" {
                        let attrPredicate = SpatialInference.attributePredicate(conditions)
                        resultAttr = attrPredicate!.evaluate(with: baseObjects[j])
                    }
                    let result = resultRel && resultAttr
                    if result {
                        if inclusive {
                            if exclude {
                                break
                            }
                            if j == limit {
                                add(index: i)
                            }
                        } else {
                            add(index: i)
                        }
                    } else {
                        if inclusive {
                            if !exclude && resultAttr {
                                break
                            }
                            if j == limit {
                                add(index: i)
                            }
                        }
                    }
                }
            }
        }
        succeeded = !output.isEmpty
    }
    
    func map(_ assignments: String) {
        assign(assignments, indices: input)
        fact.load()
        output = input
        succeeded = !output.isEmpty
    }
    
    func assign(_ assignments: String, indices:[Int]) {
        //print(assignments)
        let list = assignments.split(separator: ";").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        let baseObjects = fact.base["objects"] as! [Any]
        for i in indices {
            var dict = Dictionary<String, Any>()
            if fact.base["data"] != nil {
                dict.merge(fact.base["data"] as! Dictionary<String, Any> ) { (_, new) in new } // replacing current
            }
            for assignment in list {
                let kv = assignment.components(separatedBy: "=")
                if kv.count == 2 {
                    let key = kv[0].trimmingCharacters(in: [" "])
                    let expr = kv[1].trimmingCharacters(in: [" "])
                    let expression = NSExpression(format: expr)
                    let value = expression.expressionValue(with: baseObjects[i], context: nil)
                    if value != nil {
                        let oldValue = dict[key]
                        dict[key] = value
                        if oldValue as? AnyHashable != dict[key] as? AnyHashable {
                            fact.changes.insert(i)
                        }
                    }
                }
            }
            fact.objects[i].fromAny(dict)
        }
    }
    
    func calc(_ assignments: String) {
        let list = assignments.split(separator: ";").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        for assignment in list {
            let kv = assignment.components(separatedBy: "=")
            if kv.count == 2 {
                let key = kv[0].trimmingCharacters(in: [" "])
                let expr = kv[1].trimmingCharacters(in: [" "])
                let expression = NSExpression(format: expr)
                let value = expression.expressionValue(with: fact.base, context: nil)
                if value != nil {
                    fact.setData(key: key, value: value!)
                }
            }
        }
        output = input
        succeeded = !output.isEmpty
    }
    
    func slice(_ range: String) {
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
            case "azimuth": sortedObjects = inputObjects.sorted { $0.azimuth < $1.azimuth }
            case "footprint": sortedObjects = inputObjects.sorted { $0.footprint < $1.footprint }
            case "frontface": sortedObjects = inputObjects.sorted { $0.frontface < $1.frontface }
            case "sideface": sortedObjects = inputObjects.sorted { $0.sideface < $1.sideface }
            case "surface": sortedObjects = inputObjects.sorted { $0.surface < $1.surface }
            case "volume": sortedObjects = inputObjects.sorted { $0.volume < $1.volume }
            case "perimeter": sortedObjects = inputObjects.sorted { $0.perimeter < $1.perimeter }
            case "baseradius": sortedObjects = inputObjects.sorted { $0.baseradius < $1.baseradius }
            case "radius": sortedObjects = inputObjects.sorted { $0.radius < $1.radius }
            case "speed": sortedObjects = inputObjects.sorted { $0.speed < $1.speed }
            case "confidence": sortedObjects = inputObjects.sorted { $0.confidence.spatial < $1.confidence.spatial }
            case "lifespan": sortedObjects = inputObjects.sorted { $0.lifespan < $1.lifespan }
            default: sortedObjects = inputObjects.sorted { $0.dataValue(list[0]) < $1.dataValue(list[0]) }
            }
        } else {
            switch list[0] {
            case "width": sortedObjects = inputObjects.sorted { $0.width > $1.width }
            case "height": sortedObjects = inputObjects.sorted { $0.height > $1.height }
            case "depth": sortedObjects = inputObjects.sorted { $0.depth > $1.depth }
            case "length": sortedObjects = inputObjects.sorted { $0.length > $1.length }
            case "angle": sortedObjects = inputObjects.sorted { $0.angle > $1.angle }
            case "yaw": sortedObjects = inputObjects.sorted { $0.yaw > $1.yaw }
            case "azimuth": sortedObjects = inputObjects.sorted { $0.azimuth > $1.azimuth }
            case "footprint": sortedObjects = inputObjects.sorted { $0.footprint > $1.footprint }
            case "frontface": sortedObjects = inputObjects.sorted { $0.frontface > $1.frontface }
            case "sideface": sortedObjects = inputObjects.sorted { $0.sideface > $1.sideface }
            case "surface": sortedObjects = inputObjects.sorted { $0.surface > $1.surface }
            case "volume": sortedObjects = inputObjects.sorted { $0.volume > $1.volume }
            case "perimeter": sortedObjects = inputObjects.sorted { $0.perimeter > $1.perimeter }
            case "baseradius": sortedObjects = inputObjects.sorted { $0.baseradius > $1.baseradius }
            case "radius": sortedObjects = inputObjects.sorted { $0.radius > $1.radius }
            case "speed": sortedObjects = inputObjects.sorted { $0.speed > $1.speed }
            case "confidence": sortedObjects = inputObjects.sorted { $0.confidence.spatial > $1.confidence.spatial }
            case "lifespan": sortedObjects = inputObjects.sorted { $0.lifespan > $1.lifespan }
            default: sortedObjects = inputObjects.sorted { $0.dataValue(list[0]) > $1.dataValue(list[0]) }
            }
        }
        for object in sortedObjects {
            if let idx = fact.objects.firstIndex(where: {$0 === object}) {
                add(index: idx)
            }
        }
        succeeded = !output.isEmpty
    }
    
    // steps: amount of backtrace steps in pipeline to compare relations with that input
    func sortByRelation(_ attribute: String, backtraceSteps: Int = 1) {
        var ascending = false
        var steps: Int = backtraceSteps
        var inputObjects: [SpatialObject] = []
        var sortedObjects: [SpatialObject]
        for i in input {
            inputObjects.append(fact.objects[i])
        }
        let list = attribute.split(separator: " ").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.count == 0 { return }
        let attr = list[0]
        if list.count > 1 {
            for i in 1..<list.count {
                if list[i] == "<" {
                    ascending = true
                } else {
                    steps = Int(list[i]) ?? steps
                }
            }
        }
        let preIndices = fact.backtrace(abs(steps))
        if ascending {
            sortedObjects = inputObjects.sorted { $0.relationValue(attr, pre: preIndices) < $1.relationValue(attr, pre: preIndices) }
        } else {
            sortedObjects = inputObjects.sorted { $0.relationValue(attr, pre: preIndices) > $1.relationValue(attr, pre: preIndices) }
        }
        for object in sortedObjects {
            if let idx = fact.objects.firstIndex(where: {$0 === object}) {
                add(index: idx)
            }
        }
        succeeded = !output.isEmpty
    }
    
    func produce(_ terms: String) {
        let list = terms.split(separator: ":").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        var assignments = ""
        let rule = list[0]
        if list.count > 1 {
            assignments = list[1]
        }
        var indices:[Int] = [] // new produced object indices
        var newObjects = [Dictionary<String, Any>]()
        switch rule {
        case "group", "aggregate":
            if input.count > 0 {
                var inputObjects: [SpatialObject] = []
                var sortedObjects: [SpatialObject]
                for i in input {
                    inputObjects.append(fact.objects[i])
                }
                sortedObjects = inputObjects.sorted { $0.volume > $1.volume }
                let largestObject = sortedObjects.first
                var minY:Float = 0.0
                var maxY:Float = largestObject!.height
                var minX:Float = -largestObject!.width/2.0
                var maxX:Float = largestObject!.width/2.0
                var minZ:Float = -largestObject!.depth/2.0
                var maxZ:Float = largestObject!.depth/2.0
                var groupId = "group:" + largestObject!.id
                for j in 1..<sortedObjects.count {
                    let localPts = largestObject!.intoLocal(pts: sortedObjects[j].points(local: false))
                    for pt in localPts {
                        minX = Float.minimum(minX, Float(pt.x))
                        maxX = Float.maximum(maxX, Float(pt.x))
                        minY = Float.minimum(minY, Float(pt.y))
                        maxY = Float.maximum(maxY, Float(pt.y))
                        minZ = Float.minimum(minZ, Float(pt.z))
                        maxZ = Float.maximum(maxZ, Float(pt.z))
                    }
                    groupId = groupId + "+" + sortedObjects[j].id
                }
                let w = maxX - minX
                let h = maxY - minY
                let d = maxZ - minZ
                let dx = minX + w/2.0
                let dy = minY/2.0
                let dz = minZ + d/2.0
                let objIdx = fact.indexOf(id: groupId) ?? -1
                let group = objIdx < 0 ? SpatialObject(id: groupId) : fact.objects[objIdx]
                group.setPosition(largestObject!.pos)
                group.rotShift(-largestObject!.angle, dx:dx, dy:dy, dz:dz)
                group.angle = largestObject!.angle
                group.width = w
                group.height = h
                group.depth = d
                group.cause = .rule_produced
                group.existence = .conceptual
                if objIdx < 0 {
                    newObjects.append(group.asDict())
                    indices.append(fact.objects.count)
                    fact.changes.insert(fact.objects.count)
                    fact.objects.append(group)
                } else {
                    indices.append(objIdx)
                }
            }

        case "copy", "duplicate":
            for i in input {
                let copyId = "copy:" + fact.objects[i].id
                var idx = fact.indexOf(id: copyId)
                if idx == nil {
                    idx = fact.objects.count
                    let objIdx = fact.indexOf(id: copyId) ?? -1
                    let copy = objIdx < 0 ? SpatialObject(id: fact.objects[i].id) : fact.objects[objIdx]
                    copy.fromAny(fact.objects[i].toAny())
                    copy.id = copyId
                    copy.cause = .rule_produced
                    copy.existence = .conceptual
                    copy.setPosition(fact.objects[i].pos)
                    copy.angle = fact.objects[i].angle
                    if objIdx < 0 {
                        newObjects.append(copy.asDict())
                        fact.objects.append(copy)
                        indices.append(idx!)
                        fact.changes.insert(idx!)
                    } else {
                        indices.append(objIdx)
                    }
                } else {
                    indices.append(idx!)
                }
            }
        case "by":
            var processedBys: Set<String> = []
            for i in input {
                let rels = fact.relationsWith(i, predicate: "by")
                for rel in rels {
                    let idx = fact.indexOf(id: rel.subject.id)
                    if input.contains(idx!) && !processedBys.contains(rel.subject.id + "-" + fact.objects[i].id) {
                        let nearest = fact.objects[i].pos.nearest(rel.subject.points())
                        let byId = "by:" + rel.subject.id + "-" + fact.objects[i].id
                        let objIdx = fact.indexOf(id: byId) ?? -1
                        let obj = objIdx < 0 ? SpatialObject(id: byId) : fact.objects[objIdx]
                        obj.cause = .rule_produced
                        obj.existence = .conceptual
                        obj.setPosition(nearest.first!)
                        obj.angle = fact.objects[i].angle
                        let w = max(rel.delta, fact.adjustment.maxGap)
                        obj.width = w
                        obj.depth = w
                        var h = rel.subject.height
                        if nearest[0].x == nearest[1].x && nearest[0].z == nearest[1].z {
                            h = Float(nearest[1].y - nearest[0].y)
                        }
                        obj.height = h
                        if objIdx < 0 {
                            newObjects.append(obj.asDict())
                            indices.append(fact.objects.count)
                            fact.changes.insert(fact.objects.count)
                            fact.objects.append(obj)
                        } else {
                            indices.append(objIdx)
                        }
                        processedBys.insert(fact.objects[i].id + "-" + rel.subject.id)
                    }
                }
            }
        case "on":
            for i in input {
                let rels = fact.relationsWith(i, predicate: "on")
                for rel in rels {
                    let onId = "on:" + rel.subject.id + "-" + rel.object.id
                    let objIdx = fact.indexOf(id: onId) ?? -1
                    let obj = objIdx < 0 ? SpatialObject(id: onId) : fact.objects[objIdx]
                    obj.cause = .rule_produced
                    obj.existence = .conceptual
                    let h = max(rel.delta, fact.adjustment.maxGap)
                    obj.height = h
                    var pos = rel.subject.pos
                    pos.y = pos.y - UFloat(h/2.0)
                    obj.setPosition(pos)
                    obj.angle = rel.subject.angle
                    obj.width = rel.subject.width
                    obj.depth = rel.subject.depth
                    if objIdx < 0 {
                        newObjects.append(obj.asDict())
                        indices.append(fact.objects.count)
                        fact.changes.insert(fact.objects.count)
                        fact.objects.append(obj)
                    } else {
                        indices.append(objIdx)
                    }
                }
            }
        case "at":
            for i in input {
                let rels = fact.relationsWith(i, predicate: "at")
                for rel in rels {
                    let atId = "at:" + rel.subject.id + "-" + rel.object.id
                    let objIdx = fact.indexOf(id: atId) ?? -1
                    let obj = objIdx < 0 ? SpatialObject(id: atId) : fact.objects[objIdx]
                    obj.cause = .rule_produced
                    obj.existence = .conceptual
                    var pos = rel.subject.pos
                    var shift = CGPoint(x: 0, y: 0)
                    var w = rel.subject.width
                    let h = rel.subject.height
                    let d = max(rel.delta, fact.adjustment.maxGap)
                    let meetingIdx = fact.indexOf(id: rel.subject.id) ?? -1
                    if fact.does(subject: rel.object, have: "ahead", with: meetingIdx) {
                        shift.x = Double((rel.subject.depth + d)/2.0)
                        shift = shift.rotate(UFloat(rel.subject.angle) + .pi/2)
                        obj.angle = rel.subject.angle
                    } else if fact.does(subject: rel.object, have: "behind", with: meetingIdx) {
                        shift.x = Double((rel.subject.depth + d)/2.0)
                        shift = shift.rotate(UFloat(rel.subject.angle) + .pi/2)
                        obj.angle = rel.subject.angle
                    } else if fact.does(subject: rel.object, have: "left", with: meetingIdx) {
                        shift.x = Double((rel.subject.width + d)/2.0)
                        shift = shift.rotate(UFloat(rel.subject.angle))
                        w = rel.subject.depth
                        obj.angle = rel.subject.angle + .pi/2
                    } else if fact.does(subject: rel.object, have: "right", with: meetingIdx) {
                        shift.x = Double((rel.subject.width + d)/2.0)
                        shift = shift.rotate(UFloat(rel.subject.angle) + .pi)
                        w = rel.subject.depth
                        obj.angle = rel.subject.angle + .pi/2
                    }
                    pos.x = pos.x + UFloat(shift.x)
                    pos.z = pos.z + UFloat(shift.y)
                    obj.setPosition(pos)
                    obj.depth = d
                    obj.width = w
                    obj.height = h
                    if objIdx < 0 {
                        newObjects.append(obj.asDict())
                        indices.append(fact.objects.count)
                        fact.changes.insert(fact.objects.count)
                        fact.objects.append(obj)
                    } else {
                        indices.append(objIdx)
                    }
                }
            }
        default:
            let pred = SpatialPredicate.named(rule)            
            if PredicateCategories.sectors.contains(pred) {
                let sector = BBoxSector.named(rule)
                for i in input {
                    let sectorId = rule + ":" + fact.objects[i].id
                    let objIdx = fact.indexOf(id: sectorId) ?? -1
                    let obj = objIdx < 0 ? SpatialObject(id: sectorId) : fact.objects[objIdx]
                    obj.cause = .rule_produced
                    obj.existence = .conceptual
                    let dims = fact.objects[i].sectorLenghts(sector)
                    obj.width = Float(dims.x)
                    obj.height = Float(dims.y)
                    obj.depth = Float(dims.z)
                    var shift:SCNVector3 = .init()
                    if sector.contains(.o) {
                        shift.y = (UFloat(fact.objects[i].height) + dims.y)/2.0
                    } else if sector.contains(.u) {
                        shift.y = (UFloat(-fact.objects[i].height) - dims.y)/2.0
                    }
                    if sector.contains(.r) {
                        shift.x = (UFloat(-fact.objects[i].width) - dims.x)/2.0
                    } else if sector.contains(.l) {
                        shift.x = (UFloat(fact.objects[i].width) + dims.x)/2.0
                    }
                    if sector.contains(.a) {
                        shift.z = (UFloat(fact.objects[i].depth) + dims.z)/2.0
                    } else if sector.contains(.b) {
                        shift.z = (UFloat(-fact.objects[i].depth) - dims.z)/2.0
                    }
                    obj.angle = fact.objects[i].angle
                    var vector = CGPoint(x: Double(shift.x), y: Double(-shift.z))
                    vector = vector.rotate(UFloat(fact.objects[i].angle))
                    shift.x = UFloat(vector.x)
                    shift.z = UFloat(-vector.y)
                    let center = fact.objects[i].center
                    obj.setCenter(center + shift)
                    if objIdx < 0 {
                        newObjects.append(obj.asDict())
                        indices.append(fact.objects.count)
                        fact.changes.insert(fact.objects.count)
                        fact.objects.append(obj)
                    } else {
                        indices.append(objIdx)
                    }
                }
            } else {
                error.append("Unknown \(rule) rule in produce()")
                return
            }
        }
        if !indices.isEmpty {
            fact.base["objects"] = (fact.base["objects"] as! [Dictionary<String, Any>]) + newObjects
            if assignments != "" {
                assign(assignments, indices: indices)
            }
            output = input
            for i in indices {
                if !output.contains(i) {
                    output.append(i)
                }
            }
        } else {
            output = input
        }
        fact.load()
        succeeded = error.isEmpty
    }
    
    func backtrace(_ term:String) {
        let steps = Int(term) ?? 1
        output = fact.backtrace(abs(steps))
        succeeded = !output.isEmpty
    }
    
    func reload() {
        fact.syncToObjects()
        fact.load()
        output = (0..<fact.objects.count).indices.map { $0 }
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
        if operation.starts(with: "isa") {
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
        if operation.starts(with: "reload") {
            return true
        }
        if operation.starts(with: "sort") {
            return true
        }
        return false
    }
    
    public func asDict() -> Dictionary<String, Any> {
        let dict = [
            "operation": operation,
            "input": input,
            "output": output,
            "error": error,
            "succeeded": succeeded
        ] as [String : Any]
        return dict
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
    
    public static func == (lhs: SpatialInference, rhs: SpatialInference) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
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
