//
//  RelationVis.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 25.12.2024.
//

import Testing
import SceneKit
@testable import SpatialReasoning

struct RelationVis {
    
    let enable3Dexport = true
    let objectOpaque = CGColor(red: 1, green: 0, blue: 0, alpha: 0.0)
    let subjectOpaque = CGColor(red: 0, green: 0, blue: 1, alpha: 0.0)
    let objectTransparent = CGColor(red: 1, green: 0, blue: 0, alpha: 0.4)
    let subjectTransparent = CGColor(red: 0, green: 0, blue: 1, alpha: 0.4)
    
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
    
    @Test("left")
    func left() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.8, y: 0.4, z: -0.1), width: 0.7, height: 0.4, depth: 0.7)
        subject.angle = 0.45
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .left }))
    }
    
    @Test("right")
    func right() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -3.4, y: 0.3, z: 0.1), width: 0.7, height: 0.7, depth: 0.7)
        subject.angle = .pi / 2.0
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .right }))
    }
    
    @Test("ahead")
    func ahead() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0.3, z: 1.5), width: 0.7, height: 0.7, depth: 0.7)
        subject.angle = .pi / 2.0
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .ahead }))
    }
    
    @Test("behind")
    func behind() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0.3, z: -3.5), width: 0.7, height: 0.7, depth: 0.7)
        subject.angle = 0.45
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .behind }))
    }
    
    @Test("above")
    func above() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 2.61, z: 0.2), width: 0.7, height: 0.4, depth: 0.7)
        subject.angle = 0.2
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .above }))
    }
    
    @Test("below")
    func below() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: -1.10, z: 0.05), width: 1.6, height: 0.2, depth: 1.6)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .below }))
    }
    
    @Test("leftside")
    func leftside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.2, y: 0.4, z: -0.1), width: 0.7, height: 0.4, depth: 0.7)
        subject.angle = .pi / 2.0
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .leftside }))
    }
    
    @Test("rightside")
    func rightside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.2, y: 0.3, z: 0.1), width: 0.7, height: 0.7, depth: 0.7)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .rightside }))
    }
    
    @Test("frontside")
    func frontside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0.4, z: 1.3), width: 0.4, height: 0.4, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .frontside }))
    }
    
    @Test("backside")
    func backside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0.3, z: -1.4), width: 0.6, height: 0.6, depth: 0.6)
        subject.angle = .pi / 2.0
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .backside }))
    }
    
    @Test("upperside")
    func upperside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.41, z: 0.1), width: 1.0, height: 0.7, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .upperside }))
    }
    
    @Test("lowerside")
    func lowerside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: -0.80, z: 0.05), width: 1.0, height: 0.5, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .lowerside }))
    }
    
    @Test("ontop")
    func ontop() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.01, z: 0), width: 0.8, height: 0.6, depth: 0.25)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .ontop }))
    }
    
    @Test("beneath")
    func beneath() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: -0.31, z: 0.05), width: 1.9, height: 0.3, depth: 1.9)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .beneath }))
    }
    
    @Test("beside")
    func beside() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.06, y: 0, z: -0.1), width: 0.4, height: 0.8, depth: 0.5)
        subject.setYaw(45.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .beside }))
    }
    
    
    @Test("aligned")
    func aligned() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.1, y: 0, z: -0.15), width: 1.0, height: 1.0, depth: 0.15)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.3)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .aligned }))
    }
    
    @Test("frontaligned")
    func frontaligned() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.1, y: 0, z: 0.07), width: 1.0, height: 1.0, depth: 0.125)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.3)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .frontaligned }))
    }
    
    @Test("backaligned")
    func backaligned() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.3, y: 0, z: -0.1), width: 1.0, height: 1.0, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.6)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .backaligned }))
    }
    
    @Test("rightaligned")
    func rightaligned() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.2, y: 0, z: -1.2), width: 0.6, height: 0.6, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.6)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .rightaligned }))
    }
    
    @Test("leftaligned")
    func leftaligned() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.2, y: 0, z: -1.2), width: 0.6, height: 0.6, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.6)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .leftaligned }))
    }
    
    @Test("orthogonal")
    func orthogonal() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.3, y: 0, z: 0.72), width: 1.0, height: 1.0, depth: 0.12)
        subject.angle = .pi / 2
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.3)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .orthogonal }))
    }
    
    @Test("opposite")
    func opposite() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.0, y: 0, z: 1.52), width: 1.0, height: 1.0, depth: 0.12)
        subject.angle = .pi
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.3)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .opposite }))
    }
    
    @Test("on")
    func ison() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.01, z: -0.15), width: 0.6, height: 0.3, depth: 0.25)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .on }))
    }
    
    @Test("at")
    func isat() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 0.43, z: 0.335), width: 0.5, height: 0.33, depth: 0.15)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.5)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .at }))
    }
    
    @Test("by")
    func isby() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.6, y: 0, z: 0.65), width: 1.0, height: 1.0, depth: 0.2)
        subject.angle = -.pi / 2
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 0.3)
        let relations = object.relate(subject: subject, topology: true)
        SpatialReasoner.printRelations(relations)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque)])
        #expect(relations.contains(where: { $0.predicate == .by }))
    }

    @Test("in")
    func isin() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.0, y: 0.2, z: -0.1), width: 0.5, height: 0.4, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relations = object.relate(subject: subject, topology: true)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectTransparent)])
        #expect(relations.contains(where: { $0.predicate == .in }))
    }
    
    @Test("in_o")
    func in_o() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.25, y: 1.2, z: -0.25), width: 0.4, height: 0.4, depth: 0.3)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relation = object.sector(subject: subject)
        export([object.bboxCube(color: objectOpaque), subject.bboxCube(color: subjectOpaque), object.sectorCube(.o, true)])
        #expect(relation.predicate == .o )
    }
    
    @Test("in_br")
    func in_br() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.05, y: 0.2, z: -1.15), width: 0.4, height: 0.4, depth: 0.3)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relation = object.sector(subject: subject)
        export([object.bboxCube(color: objectOpaque), subject.bboxCube(color: subjectOpaque), object.sectorCube(.br, true)])
        #expect(relation.predicate == .br )
    }
    
    @Test("in_bru")
    func in_bru() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.05, y: -0.8, z: -1.15), width: 0.4, height: 0.4, depth: 0.3)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let relation = object.sector(subject: subject)
        export([object.bboxCube(color: objectOpaque), subject.bboxCube(color: subjectOpaque), object.sectorCube(.bru, true)])
        #expect(relation.predicate == .bru )
    }

}
