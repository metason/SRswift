//
//  SectorVis.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 23.11.2024.
//

import Testing
import SceneKit
@testable import SRswift

@Suite("BBox Sector Vis")
struct SectorVis {

    let enable3Dexport = true
    let objectOpaque = CGColor(red: 1, green: 0, blue: 0, alpha: 0.0)
    let subjectOpaque = CGColor(red: 0, green: 0, blue: 1, alpha: 0.0)
    let objectTransparent = CGColor(red: 1, green: 0, blue: 0, alpha: 0.5)
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
    
    @Test("i")
    func i() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.5, height: 0.5, depth: 0.5)
        export([object.bboxCube(color: objectTransparent), object.sectorCube(.i, true)])
        #expect(true)
    }
    
    @Test("o_u")
    func ou() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.5, height: 0.7, depth: 0.5)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o, true), object.sectorCube(.u, true)])
        #expect(true)
    }
    
    @Test("l_r_a_b")
    func lrab() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.l, true), object.sectorCube(.r, true), object.sectorCube(.a, true), object.sectorCube(.b, true)])
        #expect(true)
    }
    
    @Test("al_ar_bl_br")
    func al_ar_bl_br() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.al, true), object.sectorCube(.ar, true), object.sectorCube(.bl, true), object.sectorCube(.br, true)])
        #expect(true)
    }
    
    @Test("ao_au_bo_bu")
    func ao_au_bo_bu() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.ao, true), object.sectorCube(.au, true), object.sectorCube(.bo, true), object.sectorCube(.bu, true)])
        #expect(true)
    }
    
    @Test("lo_lu_ro_ru")
    func lo_lu_ro_ru() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.lo, true), object.sectorCube(.lu, true), object.sectorCube(.ro, true), object.sectorCube(.ru, true)])
        #expect(true)
    }
    
    @Test("alo_aro_blo_bro")
    func alo_aro_blo_bro() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.alo, true), object.sectorCube(.aro, true), object.sectorCube(.blo, true), object.sectorCube(.bro, true)])
        #expect(true)
    }
    @Test("alu_aru_blu_bru")
    func alu_aru_blu_bru() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 0.7, height: 0.5, depth: 0.7)
        export([object.bboxCube(color: objectTransparent), object.sectorCube(.alu, true), object.sectorCube(.aru, true), object.sectorCube(.blu, true), object.sectorCube(.bru, true)])
        #expect(true)
    }
    
    @Test("subj in sector o of obj")
    func sectorO() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.61, z: -0.2), width: 0.4, height: 0.4, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.o, true)])
        //print(relation.predicate)
        #expect(relation.predicate == .o)
    }
    
    @Test("subj in sector al of obj")
    func sectorAL() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 1.2, y: 0.21, z: 1.4), width: 0.4, height: 0.4, depth: 0.4)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.al)])
        #expect(relation.predicate == .al)
    }
    
    @Test("subj in sector bru of obj")
    func sectorBRU() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -1.2, y: -1.21, z: -1.4), width:0.5, height: 0.5, depth: 0.5)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.1, height: 1.1, depth: 1.1)
        let relation = object.sector(subject: subject)
        export([subject.bboxCube(color: subjectOpaque), object.bboxCube(color: objectOpaque), object.sectorCube(.bru)])
        #expect(relation.predicate == .bru)
    }
    
    // Visualization scenarios
    
    @Test("nearby sectors of obj")
    func nearSectors() async throws {
        defaultAdjustment.sectorSchema = .nearby
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.8, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("nearby sectors of thin obj")
    func nearSectorsThin() async throws {
        defaultAdjustment.sectorSchema = .nearby
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.05, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b), object.nearbySphere()])
        #expect(true)
    }
    
    @Test("nearby sectors of long obj")
    func nearSectorsLong() async throws {
        defaultAdjustment.sectorSchema = .nearby
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 0.08, height: 1.05, depth: 0.06)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("fixed sectors of obj")
    func fixedSectors() async throws {
        defaultAdjustment.sectorSchema = .fixed
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.8, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("fixed sectors of thin obj")
    func fixedSectorsThin() async throws {
        defaultAdjustment.sectorSchema = .fixed
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.05, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b), object.nearbySphere()])
        #expect(true)
    }
    
    @Test("fixed sectors of long obj")
    func fixedSectorsLong() async throws {
        defaultAdjustment.sectorSchema = .fixed
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 0.08, height: 1.05, depth: 0.06)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("dimension sectors of obj")
    func dimensionSectors() async throws {
        defaultAdjustment.sectorSchema = .dimension
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.8, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
    
    @Test("dimension sectors of thin obj")
    func dimensionSectorsThin() async throws {
        defaultAdjustment.sectorSchema = .dimension
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 0.05, depth: 0.6)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b), object.nearbySphere()])
        #expect(true)
    }
    
    @Test("dimension sectors of long obj")
    func dimensionSectorsLong() async throws {
        defaultAdjustment.sectorSchema = .dimension
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 0.08, height: 1.05, depth: 0.06)
        export([object.bboxCube(color: objectOpaque), object.sectorCube(.o), object.sectorCube(.u), object.sectorCube(.l), object.sectorCube(.r), object.sectorCube(.a), object.sectorCube(.b)])
        #expect(true)
    }
}
