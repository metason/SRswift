//
//  SpatialRelationsTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//

import Testing
import SceneKit
@testable import SpatialReasoning

@Suite("Spatial Relations: Predicates")
struct SpatialTest {
    
    let enable3Dexport = true
    let objectOpaque = CGColor(red: 1, green: 0, blue: 0, alpha: 0.0)
    let subjectOpaque = CGColor(red: 0, green: 0, blue: 1, alpha: 0.0)
    let objectTransparent = CGColor(red: 1, green: 0, blue: 0, alpha: 0.3)
    let subjectTransparent = CGColor(red: 0, green: 0, blue: 1, alpha: 0.3)
    
    // write USDZ file to Downloads folder
    func export(_ nodes:[SCNNode]) {
        if enable3Dexport {
            let urls = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
            if urls.count > 0 {
                let filename = (Test.current?.displayName ?? "scene").appending(".usdz")
                let fileURL:URL = urls.first!.appendingPathComponent(filename)
                SpatialObject.export3D(to: fileURL, nodes: nodes)
            }
        }
    }
    
    func printRelations(_ relations: [SpatialRelation]) {
        for relation in relations {
            print("\(relation.subject.id) \(relation.predicate) \(relation.object.id) | " + String(format: "𝛥:%.2f  ", relation.gap) + String(format: "𝜶:%.1f°", relation.yaw))
        }
    }

    @Test("subj is near to obj")
    func near() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.75, y: 0.0, z: 0.01), width: 1.2, height: 1.2, depth: 1.2)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        //print(subject.asDict())
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), subject.nearbySphere(), object.nearbySphere()])
        #expect(relations.contains(where: { $0.predicate == .near }))
    }
    
    @Test("subj is far from obj (not near)")
    func notnear() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 3.5, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), subject.nearbySphere(), object.nearbySphere()])
        #expect(relations.contains(where: { $0.predicate == .near }) == false)
    }
    
    @Test("subj is inside obj")
    func inside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.0, y: 0.0, z: 0), width: 0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .inside }))
    }
    
    @Test("door is inside wall")
    func door() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 0), height: 2.3)
        let door = SpatialObject.createBuildingElement(id: "door", from: .init(x: 0.4, y: 0, z: 0), to: .init(x: 1.3, y: 0, z: 0), height: 2.05)
        let relations = wall1.relate(subject: door, topology: true)
        printRelations(relations)
        export([wall1.bboxCube(color: subjectTransparent), door.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .inside }))
    }
    
    @Test("window is inside wall")
    func window() async throws {
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 2.5), height: 2.3)
        let window = SpatialObject.createBuildingElement(id: "window", from: .init(x: 2, y: 0.7, z: 1), to: .init(x: 2, y: 0.7, z: 2.2), height: 1.35)
        let relations = wall2.relate(subject: window, topology: true)
        printRelations(relations)
        export([wall2.bboxCube(color: subjectTransparent), window.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .inside }))
    }
    
    @Test("subj is below obj")
    func below() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: -1.10, z: 0.05), width: 1.0, height: 1.0, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .below }))
    }
    
    @Test("subj is above obj")
    func above() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.61, z: 0.1), width: 1.0, height: 1.0, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .above }))
    }
    
    @Test("subj is on top of obj")
    func ontop() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.01, z: 0), width: 0.8, height: 0.6, depth: 0.25)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .ontop }))
    }

    @Test("subj is overlapping obj")
    func overlapping() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.4, y: 0.4, z: 0.2), width: 1.1, height: 1.1, depth: 1.1)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .overlapping }))
    }
    
    @Test("subj is crossing obj horizontally")
    func crossingHor() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 0.45, z: 0), width: 2.8, height: 0.3, depth: 0.4)
        subject.setYaw(20.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .crossing }))
    }
    
    @Test("subj is crossing obj vertically")
    func crossingVert() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: -0.5, z: 0), width: 0.4, height: 1.8, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .crossing }))
    }
    
    @Test("subj is congruent with obj")
    func congruent() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.3, y: 0, z: 0.8), width: 1.01, height: 1.005, depth: 1.002, angle: .pi/4.0 - 0.05)
        let object = SpatialObject(id: "obj", position: .init(x: 0.3, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0, angle: .pi/4.0)
        let relations = object.relate(subject: subject, similarity: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .congruent }))
    }
    
    @Test("subj seen right from obj")
    func seenRight() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.5, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let observer = SpatialObject.createPerson(id: "observer", position: .init(x: 0.3, y: 0, z: -3.8), name: "user")
        let relations = object.asseen(subject: subject, observer: observer)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), observer.bboxCube(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0))])
        #expect(relations.contains(where: { $0.predicate == .seenright }))
    }
    
    @Test("subj seen left from obj")
    func seenLeft() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0.3, y: 0, z: 3.8), name: "user")
        observer.angle = .pi/2.0 + 0.24
        export([subject.bboxCube(color: subjectTransparent), object.bboxCube(color: objectTransparent), observer.bboxCube(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0))])
        let relations = object.asseen(subject: subject, observer: observer)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), observer.bboxCube(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0))])
        #expect(relations.contains(where: { $0.predicate == .seenleft }))
        let sp = SpatialReasoner()
        sp.load([subject, object, observer])
        let done = sp.run("log(seenleft seenright left right infront behind)")
    }
    
    @Test("subj in front of obj")
    func infront() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0, z: -1.1), width: 1.01, height: 1.03, depth: 1.02)
        subject.angle = .pi / 2.0 + 0.2
        let object = SpatialObject(id: "obj", position: .init(x: 0.1, y: 0, z: 0.0), width: 1.0, height: 1.0, depth: 1.0)
        let observer = SpatialObject.createPerson(id: "3", position: .init(x: 0.3, y: 0, z: -3.8), name: "user")
        let relations = object.asseen(subject: subject, observer: observer)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), observer.bboxCube(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0))])
        #expect(relations.contains(where: { $0.predicate == .infront }))
    }
    
    @Test("subj at rear of obj")
    func rear() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0, z: 0.95), width: 0.8, height: 0.8, depth: 0.8)
        let object = SpatialObject(id: "obj", position: .init(x: 0.1, y: 0, z: 0.0), width: 1.0, height: 1.0, depth: 1.0)
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0.3, y: 0, z: -3.8))
        let relations = object.asseen(subject: subject, observer: observer)
        printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), observer.bboxCube(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0))])
        #expect(relations.contains(where: { $0.predicate == .atrear }))
    }
    
    @Test("subj is at 11 o'clock")
    func at11clock() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.65, y: 0, z: 1.6), width: 0.4, height: 0.6, depth: 0.5)
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0, y: 0, z: 0), name: "user")
        let relations = observer.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), observer.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .elevenoclock }))
    }
    
    @Test("subj is at 3 o'clock")
    func at3clock() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.95, y: 0, z: 0.1), width: 0.4, height: 0.6, depth: 0.5)
        let observer = SpatialObject.createPerson(id: "3", position: .init(x: 0, y: 0, z: 0), name: "user")
        let relations = observer.relate(subject: subject, topology: true)
        printRelations(relations)
        export([subject.bboxCube(color: subjectTransparent), observer.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .threeoclock }))
    }
    
}
