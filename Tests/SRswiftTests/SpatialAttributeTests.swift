//
//  SpatialObjectTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 16.11.2024.
//

import Testing
//import SceneKit
@testable import SRswift

@Suite("Spatial Object: Derived Attributes")
struct SpatialAttributeTests {

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
    
    @Test("baseradius < radius")
    func radi() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 0.2, depth: 1.1)
        #expect(object.baseradius < object.radius)
    }
    
    @Test("is detected")
    func detected() async throws {
        let object = SpatialObject.createDetectedObject(id: "1", label: "Table", width: 1.6, height: 0.8, depth: 0.9)
        //print(object.asDict())
        #expect(object.label == "table")
        #expect(object.cause == .object_detected)
        #expect(object.existence == .real)
        #expect(object.long == false)
    }

    @Test("wall is building element")
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
        #expect(object.cause == .user_generated)
        #expect(object.existence == .virtual)
        #expect(object.confidence.spatial == 1.0)
    }
    
    @Test("is moving")
    func ismoving() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        object.confidence.setSpatial(0.6)
        object.velocity = .init(x: 0.2, y: 0.0, z: 0.1)
        #expect(object.motion == .moving)
    }
    
    @Test("has azimuth 210°")
    func azimuth() async throws {
        let object = SpatialObject(id: "2", position: .init(x: 0, y: 0, z: 0), width: 0.1, height: 1.0, depth: 0.1)
        object.setYaw(-30.0)
        let sp = SpatialReasoner() // set context
        sp.load([object])
        print(object.azimuth)
        #expect(object.azimuth == 210.0)
    }
    
    @Test("filter(virtual AND NOT moving)")
    func filterAttr() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.existence = .virtual
        object.confidence.setSpatial(0.6)
        let sp = SpatialReasoner()
        sp.load([object])
        let done = sp.run("filter(virtual AND NOT moving) | log(base)")
        #expect(done)
        #expect(sp.result().count == 1)
    }
    
    @Test("filter(label == 'Wall')")
    func filterLabel() async throws {
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.existence = .virtual
        object.label = "Wall"
        object.confidence.label = 0.8
        let sp = SpatialReasoner()
        sp.load([object])
        let done = sp.run("filter(label == 'Wall' AND confidence.label > 0.7) | log(base)")
        #expect(done)
        #expect(sp.result().count == 1)
    }
}
