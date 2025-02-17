//
//  SectorTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 23.11.2024.
//

import Testing
import SceneKit
@testable import SpatialReasoner

@Suite("BBox Sectors: Directional relations")
struct SectorTests {
    
    @Test("subj in sector o of obj")
    func sectorO() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.61, z: 0.1), width: 0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        #expect(relation.predicate == .o)
    }
    
    @Test("subj in sector al of obj")
    func sectorAL() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.2, y: 0.21, z: 1.4), width: 0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        #expect(relation.predicate == .al)
    }
    
    @Test("subj in sector bru of obj")
    func sectorBRU() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.2, y: -1.21, z: -1.4), width:0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        #expect(relation.predicate == .bru)
    }
    
    @Test("subj in sector i of obj")
    func sectorI() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 0, z: 0.1), width: 1.0, height: 1.0, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        #expect(relation.predicate == .i)
    }
    
    @Test("subj not in nearby sector of obj")
    func nosector() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 8, y: 0, z: 0.1), width: 1.0, height: 1.0, depth: 1.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject, nearBy: true)
        #expect(relation.predicate == .undefined)
    }

}
