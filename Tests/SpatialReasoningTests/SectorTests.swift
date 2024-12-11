//
//  SectorTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 23.11.2024.
//

import Testing
import SceneKit
@testable import SpatialReasoning

@Suite("BBox Sectors: Directional relations")
struct SectorTests {

    let enable3Dexport = false
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

    @Test("subj in main sectors of obj")
    func sectorMains() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.8, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("subj in sector o of obj")
    func sectorO() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.61, z: 0.1), width: 0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.direction(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.o)])
        #expect(relation.predicate == .o)
    }
    
    @Test("subj in sector al of obj")
    func sectorAL() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.2, y: 0.21, z: 1.4), width: 0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.direction(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.al)])
        #expect(relation.predicate == .al)
    }
    
    @Test("subj in sector bru of obj")
    func sectorBRU() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.2, y: -1.21, z: -1.4), width:0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.direction(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.bru)])
        #expect(relation.predicate == .bru)
    }
}
