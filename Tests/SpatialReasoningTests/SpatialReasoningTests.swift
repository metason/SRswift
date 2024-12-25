//
//  SpatialReasoningTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//

import Foundation
import Testing
@testable import SpatialReasoning

@Suite("Spatial Reasoning: Queries")
struct SpatialReasoningTests {
    
    @Test("parse keywords")
    func parse() async throws {
        let query = "near AND (left OR right)"
        let words = query.keywords()
        print(words)
        #expect(words.count == 3)
    }
    
    @Test("immobile == true")
    func predicate1() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        object.immobile = true
        let dict = object.asDict()
        let condition = "immobile == true"
        let predicate = SpatialInference.attributePredicate(condition)
        let result = predicate!.evaluate(with: dict)
        #expect(result)
    }

    @Test("long AND immobile")
    func predicate2() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        object.immobile = true
        let dict = object.asDict()
        //print(dict as Any)
        let condition = "(long AND immobile) OR (long AND volume > 1.5)"
        let predicate = SpatialInference.attributePredicate(condition)
        let result = predicate!.evaluate(with: dict)
        #expect(result)
    }
    
    @Test("filter | pick")
    func filter1() async throws {
        let obj1 = SpatialObject(id: "1", position: .init(x: -1.5, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        let obj2 = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.8, height: 1.0, depth: 0.6)
        let obj3 = SpatialObject(id: "3", position: .init(x: 0, y: 1.2, z: 0.75), width: 0.7, height: 0.7, depth: 0.7)
        let sr = SpatialReasoner()
        sr.load([obj1, obj2, obj3])
        let done = sr.run("deduce(topology comparability) | filter(volume < 20.4) | log(3D) | pick(ahead AND smaller) | log()")
        print(sr.base["objects"] as Any)
        #expect(done)
    }
    
    @Test("log(aligned meeting)")
    func log1() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.angle = .pi/2.0
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0.3, y: 0, z: 3.8), name: "observer")
        observer.angle = .pi + 0.24
        let sp = SpatialReasoner()
        sp.load([subject, object, observer])
        let done = sp.run("log(base 3D aligned meeting opposite)")
        #expect(done)
    }
    
    @Test("log() room")
    func log2() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 0), height: 2.3)
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 2.5), height: 2.3)
        let wall3 = SpatialObject.createBuildingElement(id: "wall3", from: .init(x: 2, y: 0, z: 2.5), to: .init(x: -2, y: 0, z: 2.5), height: 2.3)
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 2.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let floor = SpatialObject.createBuildingElement(id: "floor", position: .init(x: 0, y: -0.2, z: 1.25), width: 4.5, height: 0.2, depth: 3.0)
        let door = SpatialObject.createBuildingElement(id: "door", from: .init(x: 0.4, y: 0, z: 0), to: .init(x: 1.3, y: 0, z: 0), height: 2.05)
        let window = SpatialObject.createBuildingElement(id: "window", from: .init(x: 2, y: 0.7, z: 1), to: .init(x: 2, y: 0.7, z: 2.2), height: 1.35)
        let table = SpatialObject(id: "table", position: .init(x: -0.65, y: 0, z: 0.9), width: 1.4, height: 0.72, depth: 0.9)
        let book = SpatialObject(id: "book", position: .init(x: -0.75, y: 0.725, z: 0.72), width: 0.22, height: 0.02, depth: 0.32)
        book.angle = 0.4
        let picture = SpatialObject(id: "picture", position: .init(x: -1.99, y: 1, z: 1.4), width: 0.9, height: 0.6, depth: 0.02)
        picture.angle = .pi / 2.0
        let sp = SpatialReasoner()
        sp.load([wall1, wall2, wall3, wall4, floor, door, window, table, book, picture])
        let pipeline = """
            deduce(topology connectivity)
            | filter(supertype BEGINSWITH 'Building') 
            | log(base 3D above inside)
        """
        let done = sp.run(pipeline)
        #expect(done)
    }
    
    @Test("select()")
    func log3() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.angle = .pi/2.0
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0.3, y: 0, z: 2.3), name: "observer")
        observer.angle = .pi + 0.24
        let sp = SpatialReasoner()
        sp.load([subject, object, observer])
        let pipeline = """
            deduce(topology)
            | select(ahead ? volume > 0.3) 
            | sort(footprint <)
            | log(base 3D near infront)
        """
        let done = sp.run(pipeline)
        #expect(done)
    }
}
