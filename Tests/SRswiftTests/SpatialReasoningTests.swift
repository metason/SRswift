//
//  SpatialReasoningTests.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//

import Foundation
import Testing
@testable import SRswift

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
        let sr = SpatialReasoner()
        sr.load([subject, object, observer])
        let done = sr.run("log(base 3D aligned meeting opposite)")
        #expect(done)
    }
    
    @Test("opposite walls")
    func oppositewalls() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: -1), to: .init(x: 2, y: 0, z: -1), height: 2.3, depth: 0.4)
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 2, y: 0, z: 2.5), to: .init(x: -2, y: 0, z: 2.5), height: 2.3, depth: 0.4)
        //let ref = SpatialObject.createVirtualObject(id: "ref", width: 0.1, height: 0.1, depth: 0.1)
        let sr = SpatialReasoner()
        sr.adjustment.sectorSchema = .fixed
        sr.adjustment.sectorFactor = 1.0
        sr.adjustment.nearbySchema = .fixed
        sr.adjustment.nearbyFactor = 1.0
        sr.load([wall1, wall2])
        let pipeline = """
            deduce(topology connectivity)
            | select(opposite)
            | log(base 3D beside)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 2)
    }
    
    @Test("walls by")
    func walls() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 0), height: 2.3)
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 3.5), height: 2.3)
        let wall3 = SpatialObject.createBuildingElement(id: "wall3", from: .init(x: 2, y: 0, z: 3.5), to: .init(x: -2, y: 0, z: 3.5), height: 2.3)
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 3.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let sr = SpatialReasoner()
        sr.load([wall1, wall2, wall3, wall4])
        let pipeline = """
            adjust(sector fixed 1.0; nearby fixed 1.0)
            | deduce(topology connectivity)
            | log(base 3D beside)
        """
        let done = sr.run(pipeline)
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
        let sr = SpatialReasoner()
        sr.adjustment.sectorSchema = .fixed
        sr.adjustment.nearbyFactor = 1.0
        sr.load([wall1, wall2, wall3, wall4, floor, door, window, table, book, picture])
        let pipeline = """
            deduce(topology connectivity)
            | log(base 3D ontop inside)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("as seen")
    func asseen() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.angle = .pi/2.0
        let observer = SpatialObject.createPerson(id: "ego", position: .init(x: 0.3, y: 0, z: 3.8), name: "ego")
        observer.angle = .pi + 0.24
        let sr = SpatialReasoner()
        sr.load([subject, object, observer])
        let pipeline = """
            deduce(topology visibility)
            | log(base 3D left right seenleft seenright)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("select()")
    func log3() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.angle = .pi/2.0
        let observer = SpatialObject.createPerson(id: "user", position: .init(x: 0.3, y: 0, z: 2.3), name: "observer")
        observer.angle = .pi + 0.24
        let sr = SpatialReasoner()
        sr.load([subject, object, observer])
        let pipeline = """
            deduce(topology)
            | select(ahead ? volume > 0.3) 
            | sort(footprint <)
            | log(base 3D near infront)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("sort()")
    func sort() async throws {
        let subject1 = SpatialObject(id: "subj1", position: .init(x: -0.55, y: 0, z: -2.1), width: 1.01, height: 1.03, depth: 1.02)
        let subject2 = SpatialObject(id: "subj2", position: .init(x: -0.95, y: 0, z: 1.5), width: 0.4, height: 0.5, depth: 0.3)
        let subject3 = SpatialObject(id: "subj3", position: .init(x: 2.2, y: 0.3, z: 1.2), width: 0.4, height: 0.2, depth: 0.3)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: -0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.angle = .pi/2.0
        let observer = SpatialObject.createPerson(id: "ego", position: .init(x: 0.3, y: 0, z: 2.3))
        observer.angle = .pi + 0.24
        let sr = SpatialReasoner()
        sr.load([object, subject1, subject2, subject3, observer])
        let pipeline = """
            deduce(topology)
            | filter(id == 'ego') 
            | pick(disjoint) 
            | sort(disjoint.delta <)
            | slice(1)
            | log(base 3D disjoint)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("second left")
    func secondleft() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: 0), to: .init(x: 4, y: 0, z: 0), height: 2.3)
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 4, y: 0, z: 0), to: .init(x: 4, y: 0, z: 4.5), height: 2.3)
        let wall3 = SpatialObject.createBuildingElement(id: "wall3", from: .init(x: 4, y: 0, z: 4.5), to: .init(x: -2, y: 0, z: 4.5), height: 2.3)
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 4.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let floor = SpatialObject.createBuildingElement(id: "floor", position: .init(x: 1, y: -0.2, z: 2.25), width: 6.5, height: 0.2, depth: 5.0)
        let door = SpatialObject.createBuildingElement(id: "door", from: .init(x: 1.4, y: 0, z: 0), to: .init(x: 2.3, y: 0, z: 0), height: 2.05)
        let window = SpatialObject.createBuildingElement(id: "window", from: .init(x: 4, y: 0.7, z: 1), to: .init(x: 4, y: 0.7, z: 2.2), height: 1.35)
        let table = SpatialObject(id: "table", position: .init(x: -0.65, y: 0, z: 0.9), width: 1.4, height: 0.72, depth: 0.9)
        let book = SpatialObject(id: "book", position: .init(x: -0.75, y: 0.725, z: 0.72), width: 0.22, height: 0.02, depth: 0.32)
        book.angle = 0.4
        let picture = SpatialObject(id: "picture", position: .init(x: -1.99, y: 1, z: 1.4), width: 0.9, height: 0.6, depth: 0.02)
        picture.angle = .pi / 2.0
        let observer = SpatialObject.createPerson(id: "ego", position: .init(x: -0.1, y: 0, z: 2.3))
        let pict1 = SpatialObject(id: "pict1", position: .init(x: -1, y: 1, z: 4.49), width: 0.7, height: 0.6, depth: 0.02, angle: .pi)
        let pict2 = SpatialObject(id: "pict2", position: .init(x: 0.2, y: 0.8, z: 4.49), width: 0.6, height: 1.2, depth: 0.02, angle: .pi)
        let pict3 = SpatialObject(id: "pict3", position: .init(x: 1.2, y: 1.0, z: 4.49), width: 0.5, height: 1, depth: 0.02, angle: .pi)
        let pict4 = SpatialObject(id: "pict4", position: .init(x: 2.3, y: 1.1, z: 4.49), width: 0.4, height: 0.6, depth: 0.02, angle: .pi)
        let pict5 = SpatialObject(id: "pict5", position: .init(x: 3.2, y: 1.0, z: 4.49), width: 0.7, height: 0.8, depth: 0.02, angle: .pi)
        pict1.type = "picture"
        pict2.type = "picture"
        pict3.type = "picture"
        pict4.type = "picture"
        pict5.type = "picture"
        let sr = SpatialReasoner()
        sr.adjustment.sectorSchema = .fixed
        sr.adjustment.nearbyFactor = 4.0
        sr.load([wall1, wall2, wall3, wall4, floor, door, window, table, book, picture, observer, pict1, pict2, pict3, pict4, pict5])
        let pipeline = """
            deduce(topology)
            | filter(id == 'ego') 
            | pick(ahead AND left AND disjoint) 
            | filter(type == 'picture') 
            | sort(disjoint.delta > 2)
            | slice(2)
            | log(base 3D)

        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 1)
        #expect(sr.result().first?.id == "pict4")
    }
    
    @Test("calc()")
    func calc() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 0.5, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            calc(vol = objects[0].volume; avgh = average(objects.height))
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("map()")
    func map() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            map(weight = volume * 140.0; type = 'bed')
            | sort(weight >)
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(subject.type == "bed")
    }
    
    @Test("reload()")
    func reload() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            map(weight = volume * 140.0; type = 'bed')
            | sort(weight >)
            | reload()
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(subject.type == "bed")
    }
    
    @Test("produce(copy)")
    func duplicate() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.55, y: 0, z: 0.8), width: 1.01, height: 1.03, depth: 1.02)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            produce(copy : height = 0.02; label = 'copy')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(group)")
    func aggregate() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: -0.75, y: 0.2, z: 1.2), width: 1.01, height: 1.03, depth: 1.02, angle: 0.3)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0.4, z: 1.4), width: 1.0, height: 1.0, depth: 0.5, angle: -0.4)
        let ref = SpatialObject(id: "ref", position: .init(x: 0.0, y: 0, z: 0.0), width: 0.2, height: 0.2, depth: 0.2)
        let sr = SpatialReasoner()
        sr.load([subject, object, ref])
        let pipeline = """
            filter(id != 'ref')
            | produce(group : label = 'group')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(by : edge)")
    func produceby() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0.83, y: 0, z: -0.2), width: 0.4, height: 0.8, depth: 0.5)
        subject.setYaw(45.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            filter(id != 'ref')
            | produce(by : label = 'edge')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(by : corner)")
    func produceCorner() async throws {
        let wall1 = SpatialObject.createBuildingElement(id: "wall1", from: .init(x: -2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 0), height: 2.3)
        let wall2 = SpatialObject.createBuildingElement(id: "wall2", from: .init(x: 2, y: 0, z: 0), to: .init(x: 2, y: 0, z: 3.5), height: 2.3)
        let wall3 = SpatialObject.createBuildingElement(id: "wall3", from: .init(x: 2, y: 0, z: 3.5), to: .init(x: -2, y: 0, z: 3.5), height: 2.3)
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 3.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let sr = SpatialReasoner()
        sr.load([wall1, wall2, wall3, wall4])
        let pipeline = """
            produce(by : label = 'corner'; h = 0.02)
            | log(base 3D overlapping)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(on : zone)")
    func produceon() async throws {
        let subject = SpatialObject(id: "subj", position: .init(x: 0, y: 1.01, z: 0), width: 0.8, height: 0.6, depth: 0.25)
        subject.setYaw(30.0)
        let object = SpatialObject(id: "obj", position: .init(x: 0, y: 0.0, z: 0), width: 1.0, height: 1.0, depth: 1.0)
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            produce(on : label = 'zone')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(at : zone) [back]")
    func produceatback() async throws {
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 2.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let picture = SpatialObject(id: "picture", position: .init(x: -1.98, y: 1, z: 1.4), width: 0.9, height: 0.6, depth: 0.02)
        picture.angle = .pi / 2.0
        let sr = SpatialReasoner()
        sr.load([wall4, picture])
        let pipeline = """
            produce(at : label = 'zone')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("produce(at : zone) [left]")
    func produceatleft() async throws {
        let wall4 = SpatialObject.createBuildingElement(id: "wall4", from: .init(x: -2, y: 0, z: 2.5), to: .init(x: -2, y: 0, z: 0), height: 2.3)
        let box = SpatialObject(id: "box", position: .init(x: -1.58, y: 1, z: 1.4), width: 0.8, height: 0.6, depth: 0.4)
        let sr = SpatialReasoner()
        sr.load([wall4, box])
        let pipeline = """
            produce(at : label = 'zone')
            | log(base 3D)
        """
        let done = sr.run(pipeline)
        #expect(done)
    }
    
    @Test("isa base type")
    func isaBaseType() async throws {
        let ontoURL = URL(string: "https://service.metason.net/ar/onto/test.owl")
        if ontoURL != nil {
            SpatialTaxonomy.load(from: ontoURL!)
        }
        sleep(1) // async loading of taxonomy, therefore we wait 1 sec
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.type = "Bed"
        let sr = SpatialReasoner()
        sr.load([object])
        let pipeline = """
            isa('Bed')
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 1)

    }
    
    @Test("isa super type")
    func isaSuperType() async throws {
        let ontoURL = URL(string: "https://service.metason.net/ar/onto/test.owl")
        if ontoURL != nil {
            SpatialTaxonomy.load(from: ontoURL!)
        }
        sleep(1)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.type = "Single Bed"
        let sr = SpatialReasoner()
        sr.load([object])
        let pipeline = """
            isa('Bed')
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 1)
    }
    
    @Test("isa synonym type")
    func isaSynonymType() async throws {
        let ontoURL = URL(string: "https://service.metason.net/ar/onto/test.owl")
        if ontoURL != nil {
            SpatialTaxonomy.load(from: ontoURL!)
        }
        sleep(1)
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.type = "Computer"
        let sr = SpatialReasoner()
        sr.load([object])
        let pipeline = """
            isa(tool)
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 1)
    }
    
    @Test("isa OR type")
    func isaORType() async throws {
        let ontoURL = URL(string: "https://service.metason.net/ar/onto/test.owl")
        if ontoURL != nil {
            SpatialTaxonomy.load(from: ontoURL!)
        }
        sleep(1)
        let subject = SpatialObject(id: "subj", position: .init(x: 0.83, y: 0, z: -0.2), width: 0.4, height: 0.8, depth: 0.5)
        subject.label = "chair"
        let object = SpatialObject(id: "obj", position: .init(x: 0.5, y: 0, z: 0.8), width: 1.0, height: 1.0, depth: 1.0)
        object.type = "Computer"
        let sr = SpatialReasoner()
        sr.load([subject, object])
        let pipeline = """
            isa(tool OR furniture)
            | log(base)
        """
        let done = sr.run(pipeline)
        #expect(done)
        #expect(sr.result().count == 2)
    }
}
