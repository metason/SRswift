//
//  SpatialObjectTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 16.11.2024.
//

import Testing
import SceneKit
@testable import SpatialReasoning

@Suite("Spatial Object: Derived Attributes")
struct SpatialAttributeTests {
    
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

    @Test("is thin")
    func isthin() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 1.1, height: 0.1, depth: 1.2)
        //print(object.asDict())
        #expect(object.thin == true)
    }
    
    @Test("is not long")
    func notlong() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.1, depth: 1.2)
        //print(object.asDict())
        #expect(object.thin == false)
    }
    
    @Test("is long in y direction")
    func islong() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        #expect(object.long)
        #expect(object.mainDirection() == 2)
    }
    
    @Test("groundradius < radius")
    func radi() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 0.2, depth: 1.1)
        #expect(object.radius > object.groundradius)
    }
    
    @Test("is detected")
    func detected() async throws {
        let object = SpatialObject.createDetectedObject(id: "1", label: "Table", width: 1.6, height: 0.8, depth: 0.9)
        //print(object.asDict())
        #expect(object.label == "table")
        #expect(object.cause == .objectdetected)
        #expect(object.existence == .real)
        #expect(object.long == false)
    }

    @Test("is building element")
    func buildingElement() async throws {
        let object = SpatialObject.createBuildingElement(id: "1", type: "Wall", position: .init(x: 0, y: 0, z: 0), width: 3.2, height: 2.2, depth: 0.3)
        //print(object.asDict())
        #expect(object.length > 3.0)
        #expect(object.label == "wall")
        #expect(object.type == "Wall")
        #expect(object.existence == .real)
        #expect(object.shape == .cubical)
        #expect(object.motion == .stationary)
    }
    
    @Test("is virtual")
    func virtual() async throws {
        let object = SpatialObject.createVirtualObject(id: "1", width: 1.0, height: 0.0, depth: 0.3)
        #expect(object.cause == .usergenerated)
        #expect(object.existence == .virtual)
        #expect(object.confidence.spatial == 1.0)
    }
    
    @Test("is moving")
    func ismoving() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        object.confidence.setValue(0.6)
        object.velocity = .init(x: 0.2, y: 0.0, z: 0.1)
        #expect(object.motion == .moving)
    }
    
}
