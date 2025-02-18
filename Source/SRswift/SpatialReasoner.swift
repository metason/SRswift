//
//  SpatialReasoner.swift
//  SpatialReasoner
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//
//  Spatial reasoning engine

import Foundation
#if os(macOS)
import SceneKit
#endif

public class SpatialReasoner {

    // settings
    public var adjustment = SpatialAdjustment()
    public var deduce = SpatialPredicateCategories()
    public var north = CGVector(dx: 0.0, dy: -1.0) // north direction, e.g., defined by ARKit

    // data
    public var objects:[SpatialObject] = []
    public var observer:SpatialObject? = nil
    private var relMap:[Int: [SpatialRelation]] = [:] // index:[SpatialRelation]
    public var chain:[SpatialInference] = []
    public var base:Dictionary<String, Any> = [:] // fact base, objects will be duplicated here for r/w access of expression eval
    public var snapTime:Date = Date() // load time or update time of fact base
    
    // logging
    public var pipeline:String = "" // last used inference pipeline
    public var name:String = "" // used as title for log
    public var description:String = "" // used in log output
    var logCnt:Int = 0
    public var logFolder:URL? = nil // if nil then Downloads folder will be used

    public init() {
        
    }
    
    public func load(_ objs: [SpatialObject]? = nil) {
        if objs != nil {
            objects = objs!
        }
        observer = nil
        relMap = [:]
        base["objects"] = []
        if !objects.isEmpty {
            let indices:[Int] = (0..<objects.count).indices.map { $0 }
            var objList = [Any]()
            for idx in indices {
                objects[idx].context = self
                objList.append(objects[idx].asDict() as Any)
                if objects[idx].observing {
                    observer = objects[idx]
                }
            }
            base["objects"] = objList
        }
        snapTime = Date()
        base["snaptime"] = snapTime.description
    }
    
    func objectWith(id:String) -> SpatialObject? {
        for idx in  0..<objects.count {
            if objects[idx].id == id {
                return objects[idx]
            }
        }
        return nil
    }
    
    func indexOf(id:String) -> Int? {
        for idx in  0..<objects.count {
            if objects[idx].id == id {
                return idx
            }
        }
        return nil
    }
    
    func setData(key:String, value:Any) {
        var dict = base["data"] as? Dictionary<String, Any>
        if dict != nil {
            dict![key] = value
        } else {
            dict = [key: value]
        }
        base["data"] = dict
    }
    
    // sync to spatial objects from dictionaries
    func syncToObjects() {
        objects = []
        observer = nil
        relMap = [:]
        // base["objects"] as! [Dictionary<String, Any>]
        for idx in  0..<(base["objects"] as! [Dictionary<String, Any>]).count {
            let obj = SpatialObject(id: (base["objects"] as! [Dictionary<String, Any>])[idx]["id"] as! String)
            obj.fromAny((base["objects"] as! [Dictionary<String, Any>])[idx])
            objects.append(obj)
            if obj.observing {
                observer = obj
            }
        }
    }
                       
    public func load(_ objs: [Dictionary<String, Any>]) {
        base["objects"] = objs
        syncToObjects()
        base["snaptime"] = snapTime.description
        snapTime = Date()
    }
    
    public func load(_ json: String) {
        let data = json.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if data != nil {
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            if let jsonObj = jsonObj as? [Dictionary<String, Any>] {
                load(jsonObj)
            }
        }
    }
    
    public func takeSnapshot() -> Dictionary<String, Any> {
       return base
    }
    
    public func loadSnapshot(_ snapshot: Dictionary<String, Any>) {
        base = snapshot
        syncToObjects()
    }
    
    func record(_ inference: SpatialInference) {
        chain.append(inference)
        base["chain"] = (base["chain"] as! [Dictionary<String, Any>]) + [inference.asDict()]
    }
    
    func backtrace() -> [Int] {
        for idx in (0..<chain.count).reversed() {
            if chain[idx].isManipulating()  {
                return chain[idx].input
            }
        }
        return []
    }

    public func run(_ pipeline: String) -> Bool {
        self.pipeline = pipeline
        logCnt = 0
        chain = []
        base["chain"] = [Any]()
        let list = pipeline.split(separator: "|").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        let indices: [Int] = (0..<objects.count).indices.map { $0 }
        for op in list {
            if op.starts(with: "log(") {
                let startIdx = op.index(op.startIndex, offsetBy: 4)
                let endIdx = op.index(op.endIndex, offsetBy: -1)
                log(String(op[startIdx..<endIdx]))
            } else if op.starts(with: "adjust(") {
                let startIdx = op.index(op.startIndex, offsetBy: 7)
                let endIdx = op.index(op.endIndex, offsetBy: -1)
                let ok = adjust(String(op[startIdx..<endIdx]))
                if !ok {
                    logError()
                    break
                }
            } else if op.starts(with: "deduce(") {
                let startIdx = op.index(op.startIndex, offsetBy: 7)
                let endIdx = op.index(op.endIndex, offsetBy: -1)
                deduce(String(op[startIdx..<endIdx]))
            } else {
                let inference = SpatialInference(input: !chain.isEmpty ? chain.last!.output : indices, operation: op, in: self)
                record(inference)
                if inference.hasFailed() {
                    logError()
                    break
                }
            }
        }
        syncToObjects()
        if !chain.isEmpty {
            return chain.last!.succeeded
        } else if pipeline.contains("log(") {
            return true
        }
        return false
    }
    
    public func result() -> [SpatialObject] {
        var list:[SpatialObject] = []
        if !chain.isEmpty {
            for idx in chain.last!.output {
                list.append(objects[idx])
            }
        }
        return list
    }
    
    func logError() {
        print(chain.last?.error as Any)
    }
    
    public static func printRelations(_ relations: [SpatialRelation]) {
        for relation in relations {
            print("\(relation.subject.id) \(relation.predicate) \(relation.object.id) | " + String(format: "𝛥:%.2f  ", relation.delta) + String(format: "𝜶:%.1f°", relation.yaw))
        }
    }
    
    func relationsOf(_ idx:Int) -> [SpatialRelation] {
        if relMap.keys.contains(idx) {
            return relMap[idx]!
        }
        var relations = [SpatialRelation]()
        for subject in objects {
            if subject !== objects[idx] {
                relations.append(contentsOf: objects[idx].relate(subject: subject))
            }
        }
        //SpatialReasoner.printRelations(relations)
        relMap[idx] = relations
        return relations
    }
    
    func relationsWith(_ objIdx:Int, predicate:String) -> [SpatialRelation] {
        var rels = [SpatialRelation]()
        if objIdx >= 0 {
            for relation in relationsOf(objIdx) {
                if relation.predicate.rawValue == predicate {
                    rels.append(relation)
                }
            }
        }
        return rels
    }
    
    // does subject has relation of predicate with object
    func does(subject:SpatialObject, have predicate:String, with objIdx:Int) -> Bool {
        for relation in relationsOf(objIdx) {
            if relation.subject === subject && relation.predicate.rawValue == predicate {
                return true
            }
        }
        return false
    }
    
    func adjust(_ settings: String) -> Bool {
        var error:String = ""
        let list = settings.split(separator: ";").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        for setting in list {
            let parts = setting.split(separator: " ")
            let first = parts.count > 0 ? parts[0] : ""
            let second = parts.count > 1 ? parts[1] : ""
            let number = parts.count > 2 ? parts[2] : ""
            switch first {
            case "max":
                switch second {
                case "gap":
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.maxGap = val
                        } else {
                            error = "Invalid max gap value: \(number)"
                        }
                    }
                case "angle", "delta":
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.maxAngleDelta = val
                        } else {
                            error = "Invalid max angle value: \(number)"
                        }
                    }
                default:
                    error = "Unknown max setting: \(second)"
                }
            case "sector":
                var setFactor = true
                switch second {
                case "fixed":
                    adjustment.sectorSchema = .fixed
                case "dimension":
                    adjustment.sectorSchema = .dimension
                case "perimeter":
                    adjustment.sectorSchema = .perimeter
                case "area":
                    adjustment.sectorSchema = .area
                case "nearby":
                    adjustment.sectorSchema = .nearby
                case "factor":
                    setFactor = true
                case "limit":
                    setFactor = false
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.sectorLimit = val
                        } else {
                            error = "Invalid sector limit value: \(number)"
                        }
                    }
                default:
                    error = "Unknown sector setting: \(second)"
                }
                if setFactor && !number.isEmpty {
                    if let val = Float(number) {
                        adjustment.sectorLimit = val
                    } else {
                        error = "Invalid sector limit value: \(number)"
                    }
                }
            case "nearby":
                var setFactor = true
                switch second {
                case "fixed":
                    adjustment.nearbySchema = .fixed
                case "circle":
                    adjustment.nearbySchema = .circle
                case "sphere":
                    adjustment.nearbySchema = .sphere
                case "perimeter":
                    adjustment.nearbySchema = .perimeter
                case "area":
                    adjustment.nearbySchema = .area
                case "factor":
                    setFactor = true
                case "limit":
                    setFactor = false
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.nearbyLimit = val
                        } else {
                            error = "Invalid nearby limit value: \(number)"
                        }
                    }
                default:
                    error = "Unknown nearby setting: \(second)"
                }
                if setFactor && !number.isEmpty {
                    if let val = Float(number) {
                        adjustment.nearbyFactor = val
                    } else {
                        error = "Invalid nearby factor value: \(number)"
                    }
                }
            case "long":
                if second == "ratio" {
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.longRatio = val
                        } else {
                            error = "Invalid long ratio value: \(number)"
                        }
                    }
                }
            case "thin":
                if second == "ratio" {
                    if !number.isEmpty {
                        if let val = Float(number) {
                            adjustment.thinRatio = val
                        } else {
                            error = "Invalid thin ratio value: \(number)"
                        }
                    }
                }
            default:
                error = "Unknown adjust setting: \(first)"
            }
        }
        if !error.isEmpty {
            print("Error: \(error)")
            let errorState = SpatialInference(input: [], operation: "adjust(\(settings)", in: self)
            errorState.error = error
            return false
        }
        return true
    }
    
    func deduce(_ categories: String) {
        deduce.topology = categories.contains("topo")
        deduce.connectivity = categories.contains("connect")
        deduce.comparability = categories.contains("compar")
        deduce.similarity = categories.contains("simil")
        deduce.sectoriality = categories.contains("sector")
        deduce.visibility = categories.contains("visib")
        deduce.geography = categories.contains("geo")
    }
    
    func log(_ predicates: String) {
#if os(macOS)
        if logFolder == nil {
            let urls = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
            if urls.count > 0 {
                logFolder = urls.first!
            } else {
                logFolder = FileManager.default.homeDirectoryForCurrentUser
            }
        }
        logCnt += 1
        let allIndices: [Int] = (0..<objects.count).indices.map { $0 }
        var indices: [Int]
        if !chain.isEmpty {
            indices = chain.last!.output
        } else {
            indices = allIndices
        }
        var list = predicates.split(separator: " ").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.contains("base") {
            list.removeAll(where: { $0 == "base" })
            logBase()
        }
        if list.contains("3D") {
            list.removeAll(where: { $0 == "3D" })
            log3D()
        }
        
        var md = "# "
        var str = name.count > 0 ? name : "Spatial Reasoning Log"
        var mmdObjs: String = ""
        var mmdRels: String = ""
        var mmdContacts: String = ""
        var rels: String = ""
        md = md + str + "\n"
        str = description.count > 0 ? description : ""
        md = md + str + "\n## Inference Pipeline\n\n```\n"
        md = md + pipeline + "\n```\n\n## Inference Chain\n\n```\n"
        for i in (0..<chain.count) {
            if i > 0 {
                md = md + "| "
            }
            md = md + chain[i].operation + "  ->  \(chain[i].output)\n"
        }
        
        md = md + "```\n\n## Spatial Objects\n\n### Fact Base\n\n"
        
        for i in allIndices {
            str = objects[i].id
            md = md + "\(i).  __" + str + "__: " + objects[i].desc() + "\n"
        }
        
        md = md + "\n\n### Resulting Objects (Output)\n\n"
        for i in indices {
            str = objects[i].id
            mmdObjs = mmdObjs + "    " + str + "\n"
            md = md + "\(i).  __" + str + "__: " + objects[i].desc() + "\n"

            for relation in relationsOf(i) {
                var doAdd: Bool = false
                if list.count > 0 {
                    if list.contains(relation.predicate.rawValue) {
                        doAdd = true
                    }
                } else {
                    doAdd = true
                }
                if doAdd {
                    var leftLink = " -- "
                    if SpatialTerms.symmetric(relation.predicate) {
                        leftLink = " <-- "
                        let searchBy = relation.object.id + leftLink + relation.predicate.rawValue + " --> " + relation.subject.id
                        if mmdRels.contains(searchBy) {
                            doAdd = false
                        }
                    }
                    if doAdd {
                        mmdRels = mmdRels + "    " + relation.subject.id + leftLink + relation.predicate.rawValue + " --> " + relation.object.id + "\n"
                    }
                }
                if contacts.contains(relation.predicate) {
                    var doAddContact = true
                    var leftLink = " -- "
                    if relation.predicate == .by {
                        leftLink = " <-- "
                        let searchBy = relation.object.id + leftLink + relation.predicate.rawValue + " --> " + relation.subject.id
                        if mmdContacts.contains(searchBy) {
                            doAddContact = false
                        }
                    }
                    if doAddContact {
                        mmdContacts = mmdContacts + "    " + relation.subject.id + leftLink + relation.predicate.rawValue + " --> " + relation.object.id + "\n"
                    }
                }
                rels = rels + "* " + relation.desc() + "\n"
            }
        }
        //print("\(allIndices) : \(indices).")
        if !mmdRels.isEmpty {
            md = md + "\n## Spatial Relations Graph\n\n"
            md = md + "```mermaid\ngraph LR;\n" + mmdObjs + mmdRels + "```\n"
        }
        
        if !mmdContacts.isEmpty {
            md = md + "\n## Connectivity Graph\n\n"
            md = md + "```mermaid\ngraph TD;\n" + mmdContacts + "```\n"
        }

        md = md + "\n## Spatial Relations\n\n"
        md = md + rels + "\n"
        
        let multipleLogs = pipeline.components(separatedBy:"log(").count > 2
        do {
            let counterStr = multipleLogs ? String(logCnt) : ""
            let fileURL = logFolder!.appendingPathComponent("log\(counterStr).md")
            try md.write(to: fileURL, atomically: true, encoding: .utf16)
        } catch {
            print(error)
        }
#endif
    }
    
    func logBase() {
        do {
            let fileURL = logFolder!.appendingPathComponent("logBase.json")
            let jsonData = try JSONSerialization.data(withJSONObject: base, options: .prettyPrinted)
            try jsonData.write(to: fileURL, options: [.atomic])
        } catch {
            print(error)
        }
    }
    
    func log3D() {
#if os(macOS)
        let fileURL = logFolder!.appendingPathComponent("log3D.usdz")
        var nodes:[SCNNode] = []
        let defaultCcolor:CGColor = CGColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        for object in objects {
            var color = defaultCcolor
            if object.label.lowercased().starts(with: "subj") || object.id.lowercased().starts(with: "subj") {
                color = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
            }
            if object.observing || object.id.lowercased().starts(with: "user") || object.id.lowercased().starts(with: "ego") {
                color = CGColor(red: 0, green: 1, blue: 0, alpha: 0)
            }
            if object.cause == .rule_produced {
                color = CGColor(red: 1, green: 1, blue: 0, alpha: 0.8)
            }
            nodes.append(object.bboxCube(color: color))
            //nodes.append(object.pointNodes())
        }
        SpatialObject.export3D(to: fileURL, nodes: nodes)
#endif
    }
    
}
