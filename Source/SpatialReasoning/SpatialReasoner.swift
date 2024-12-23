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

class SpatialReasoner {

    var objects: [SpatialObject] = []
    var observer:SpatialObject? = nil
    var relMap: [Int: [SpatialRelation]] = [:] // index:[SpatialRelation]
    var chain: [SpatialInference] = []
    var base:Dictionary<String, Any> = [:] // fact base, objects will be added
    var adjustment = SpatialAdjustment()
    var deduce = SpatialPredicateCategories()
    
    // logging
    var name:String = "" // used as title for log
    var description:String = "" // used in log output
    var logCnt:Int = 0
    var logFolder:URL? = nil // if nil then Downloads folder will be used

    func load(_ objs: [SpatialObject]) {
        objects = objs
        observer = nil
        relMap = [:]
        base["objects"] = []
        if !objs.isEmpty {
            let indices: [Int] = (0..<objs.count).indices.map { $0 }
            var objList = [Any]()
            for idx in indices {
                objs[idx].context = self
                objList.append(objs[idx].asDict() as Any)
                if objs[idx].observing {
                    observer = objs[idx]
                }
            }
            base["objects"] = objList
        }
    }
                       
    func load(_ objs: [Dictionary<String, Any>]) {
       
    }
    
    func load(_ json: String) {
       
    }
    
    func record(_ inference: SpatialInference) {
        chain.append(inference)
        base["chain"] = base["chain"] as? [String:Any] ?? [] + [inference.asDict()]
    }

    func run(_ pipeline: String) -> Bool {
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
        if !chain.isEmpty {
            return chain.last!.succeeded
        } else if pipeline.contains("log(") {
            return true
        }
        return false
    }
    
    func result() -> [SpatialObject] {
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
        relMap[idx] = relations
        return relations
    }
    
    // find for existence of predicate in spatial relations
    static func find(_ predicate:String, in relations:[SpatialRelation]) -> SpatialRelation? {
        for relation in relations {
            if relation.predicate.rawValue == predicate {
                return relation
            }
        }
        return nil
    }
    
    // does subject has relation of predicate with object
    func does(subject:SpatialObject, have predicate:String, with objIdx:Int) -> Bool {
        for relation in  relationsOf(objIdx){
            if relation.subject === subject && relation.predicate.rawValue == predicate {
                return true
            }
        }
        return false
    }
    
    func deduce(_ categories: String) {
        deduce.topology = categories.contains("topo")
        deduce.connectivity = categories.contains("connect")
        deduce.comparability = categories.contains("compar")
        deduce.directionality = categories.contains("direct")
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
        
        for i in (0..<chain.count) {
            if i > 0 {
                md = md + "| "
            }
            md = md + chain[i].operation + "\n"
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
                    mmdRels = mmdRels + "    " + relation.subject.id + " -- " + relation.predicate.rawValue + " --> " + relation.object.id + "\n"
                    if contacts.contains(relation.predicate) {
                        mmdContacts = mmdContacts + "    " + relation.subject.id + " -- " + relation.predicate.rawValue + " --> " + relation.object.id + "\n"
                    }
                }
                if contacts.contains(relation.predicate) {
                    mmdContacts = mmdContacts + "    " + relation.subject.id + " -- " + relation.predicate.rawValue + " --> " + relation.object.id + "\n"
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
        
        do {
            let fileURL = logFolder!.appendingPathComponent("log\(logCnt).md")
            try md.write(to: fileURL, atomically: true, encoding: .utf16)
        } catch {
            print(error)
        }
        //print(md)
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
        let color:CGColor = CGColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        for object in objects {
            nodes.append(object.bboxCube(color: color))
        }
        SpatialObject.export3D(to: fileURL, nodes: nodes)
#endif
    }
    
}
