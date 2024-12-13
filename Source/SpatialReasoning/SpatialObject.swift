//
//  SpatialObject.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 03.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//
//  Spatial object with upright-aligned bounding box and oriented at up axis (y-axis)

import Foundation
import SceneKit

class SpatialObject {
    /// non-spatial characteristics, to distinguish object references
    var id:String = "" // unique id: UUID of source or own generated unique id
    var existence:SpatialExistence = .real
    var cause:ObjectCause = .unknown
    var label:String = "" // name or label
    var type:String = ""
    var supertype:String = ""
    var look:String = "" // textual description of appearance: color, bright/dark, dull/shiny, metallic, transparent, ...
    var created:Date // creation time
    var updated:Date // last update time
    /// spatial characteristics
    private var position:SCNVector3 = SCNVector3() // bottom center point, use setPosition()
    var width:Float = 0.0
    var height:Float = 0.0
    var depth:Float = 0.0
    var angle:Float = 0.0 // rotation around y axis in radiants
    var immobile:Bool = false
    var velocity:SCNVector3 = SCNVector3() // velocity vector, is calculated via setPosition()
    var confidence = ObjectConfidence()
    var shape:ObjectShape = .unknown
    var visible:Bool = false // in screen
    var focused:Bool = false // in center of screen, for some time
    ///context
    var container:SpatialReasoner? = nil // optional, max deviation defined in container instead of global
    
    /// derived attributes
    var center:SCNVector3 {
        return position + SCNVector3(0.0, height/2.0, 0.0)
    }
    var yaw:Float { // in degrees
        return angle * 180.0 / .pi
    }
    var thin:Bool {
        return thin() > 0
    }
    var long:Bool {
        return long() > 0
    }
    var equilateral:Bool {
        if long(ratio: 1.1) == 0 {
            return true
        }
        return false
    }
    var perimeter:Float { // footprint perimeter
        return (depth+width) * 2.0
    }
    var footprint:Float { // base area, floor space
        return depth*width
    }
    var frontface:Float { // front area
        return height*width
    }
    var sideface:Float { // side area
        return height*depth
    }
    var surface:Float { // total surface of bbox
        return (height*width + depth*width + height*depth) * 2.0
    }
    var volume:Float {
        return depth*width*height
    }
    // sphere radius from center comprising body volume
    var radius:Float {
        return SCNVector3(x:UFloat(width)/2.0, y:UFloat(depth)/2.0, z:UFloat(height)/2.0).length()
    }
    // circle radius on 2D floorground, radius from position encircling base area
    var groundradius:Float {
        return Float(CGPoint(x:Double(width)/2.0, y:Double(depth)/2.0).length())
    }
    var motion:MotionState {
        if immobile {
            return .stationary
        }
        if confidence.spatial > 0.5 {
            if velocity.length() > adjustment.gap {
                return .moving
            }
            return .idle
        }
        return .unknown
    }
    var moving:Bool {
        return motion == .moving
    }
    var length:Float {
        let alignment = long(ratio: 1.1)
        if alignment == 1 {
            return width
        } else if alignment == 2 {
            return height
        }
        return depth
    }
    var lifespan:Double {
        let now = Date()
        return now.timeIntervalSince(created)
    }
    var updateInterval:Double {
        let now = Date()
        return now.timeIntervalSince(updated)
    }
    var adjustment:SpatialAdjustment {
        return container?.adjustment ?? defaultAdjustment
    }
    nonisolated(unsafe) static var north = SCNVector3(0.0, 0.0, -1.0) // north direction
    static let booleanAttributes: [String] = ["immobile", "moving", "focused", "visible", "equilateral", "thin", "long"]
    
    init(id: String, position: SCNVector3, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0, angle: Float = 0.0, label: String = "", confidence: Float = 0.0) {
        self.id = id
        self.label = label
        self.position = position
        self.angle = angle
        self.width = width
        self.height = height
        self.depth = depth
        self.confidence.setSpatial(confidence)
        self.created = Date()
        self.updated = Date()
    }
    
    static func isBoolean(attribute: String) -> Bool {
        return booleanAttributes.contains(attribute)
    }
    
    static func createDetectedObject(id: String, label: String = "", width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.label = label.lowercased()
        object.type = label
        object.cause = .objectdetected
        object.existence = .real
        object.confidence.setValue(0.25)
        object.immobile = false
        object.shape = .unknown
        return object
    }
    
    static func createVirtualObject(id: String, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.cause = .usergenerated
        object.existence = .virtual
        object.confidence.setSpatial(1.0)
        object.immobile = false
        return object
    }
    
    static func createBuildingElement(id: String, type: String = "", position: SCNVector3, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: position, width: width, height: height, depth: depth)
        object.label = type.lowercased()
        object.type = type
        object.supertype = "Building Element"
        object.cause = .planedetected
        object.existence = .real
        object.confidence.setValue(0.5)
        object.immobile = true
        object.shape = .cubical
        return object
    }
    
    static func createBuildingElement(id: String, type: String = "", from: SCNVector3, to: SCNVector3, height: Float = 1.0, depth: Float = 0.25) -> SpatialObject {
        let midVector = SCNVector3((to.x - from.x) / 2, (to.y - from.y) / 2, (to.z - from.z) / 2)
        let midVectorLength = midVector.length()
        let factor = UFloat(depth / midVectorLength / 2.0)
        let normal = CGPoint(x: UFloat(midVector.x*factor), y: UFloat(midVector.z*factor)).rotate(UFloat(.pi/2.0))
        let position = from + midVector - SCNVector3(normal.x, 0.0, normal.y)
        let object = SpatialObject(id: id, position: position, width: midVectorLength*2.0, height: height, depth: depth)
        object.angle = -Float(atan2(midVector.z, midVector.x))
        object.label = type.lowercased()
        object.type = type
        object.supertype = "Building Element"
        object.cause = .usercaptured
        object.existence = .real
        object.confidence.setValue(0.9)
        object.immobile = true
        object.shape = .cubical
        return object
    }
    
    static func createPerson(id: String, position: SCNVector3, name: String = "") -> SpatialObject {
        /// create with average dimension of a person
        let person = SpatialObject(id: id, position: position, width: 0.46, height: 1.72, depth: 0.34)
        person.label = name
        person.cause = .selftracked
        person.existence = .real
        person.confidence.setValue(1.0)
        person.immobile = false
        person.supertype = "Creature"
        person.type = "Person"
        person.shape = .changing
        return person
    }
    
    public func asDict() -> Dictionary<String, Any>? {
        let output = [
            "id": id,
            "existence": existence.rawValue,
            "cause": cause.rawValue,
            "label": label,
            "type": type,
            "supertype": supertype,
            "position": [position.x, position.y, position.z],
            "center": [center.x, center.y, center.z],
            "width": width,
            "height": height,
            "depth": depth,
            "length": length,
            "direction": mainDirection(),
            "thin": thin,
            "long": long,
            "equilateral": equilateral,
            "moving": moving,
            "perimeter": perimeter,
            "footprint": footprint,
            "frontface": frontface,
            "sideface": sideface,
            "surface": surface,
            "groundradius": groundradius,
            "volume": volume,
            "radius": radius,
            "angle": angle,
            "yaw": yaw,
            "lifespan": lifespan,
            "updateInterval": updateInterval,
            "confidence": confidence.asDict(),
            "immobile": immobile,
            "velocity": [velocity.x, velocity.y, velocity.z],
            "motion": motion.rawValue,
            "shape": shape.rawValue,
            "visible": visible,
            "focused": focused
        ] as [String : Any]
        return output
    }
    
    func desc() -> String {
        var str:String = ""
        if !label.isEmpty && label != id {
            str = str + "\(label), "
        }
        if !type.isEmpty {
            str = str + "\(type), "
        }
        if !supertype.isEmpty {
            str = str + "\(supertype), "
        }
        str = str + String(format: "%.2f/", position.x) + String(format: "%.2f/", position.y) + String(format: "%.2f, ", position.z)
        str = str + String(format: "%.2fx", width) + String(format: "%.2fx", depth) + String(format: "%.2f, ", height)
        str = str + String(format: "𝜶:%.1f°", yaw)
        return str
    }
    
    func setPosition(_ pos:SCNVector3) {
        let interval = updateInterval
        if interval > 0.003 && !immobile {
            let prevPos = position
            velocity = (pos - prevPos) / Float(interval)
        }
        position = pos
    }
    
    func setCenter(_ center:SCNVector3) {
        setPosition(.init(x: center.x, y: center.y - CGFloat(height/2.0), z: center.z))
    }
    
    func setYaw(_ degrees:Float) {
        angle = degrees * .pi / 180.0
    }
    
    // returns 0 when no dominant direction, else axis direction x-y-z as 1-2-3
    func mainDirection() -> Int {
        return long()
    }
    
    // if not thin returns 0, else thiness direction x-y-z as 1-2-3
    func thin(ratio:Float = defaultAdjustment.thinRatio) -> Int {
        let values: Array<Float> = [width, height, depth]
        let max = values.max() ?? 0.0
        let min = values.min() ?? 0.0
        if max >= min * ratio {
            if height == min && width > ratio*min && depth > ratio*min {
                return 2
            }
            if width == min && height > ratio*min && depth > ratio*min {
                return 1
            }
            if depth == min && width > ratio*min && height > ratio*min {
                return 3
            }
        }
        return 0
    }
    
    // if not long returns 0, else long axis direction x-y-z as 1-2-3
    func long(ratio:Float = defaultAdjustment.longRatio) -> Int {
        let values: Array<Float> = [width, height, depth]
        let max = values.max() ?? 0.0
        let min = values.min() ?? 0.0
        if max > 0.0 {
            if max >= min * ratio {
                if width < max {
                    if height < max {
                        return 3
                    } else {
                        return 2
                    }
                } else {
                    return 1
                }
            }
        }
        return 0
    }
    
    func lowerPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0, y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y, z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y, z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y, z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y, z:UFloat(p3.y + pos.z))
        ]
    }
    
    func upperPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0, y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p3.y + pos.z))
        ]
    }
    
    func frontPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0, y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y, z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y, z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p0.y + pos.z))
        ]
    }
    
    func backPoints(local:Bool = false) -> [SCNVector3] {
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y, z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y, z:UFloat(p3.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p3.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p2.y + pos.z))
        ]
    }
    
    func rightPoints(local:Bool = false) -> [SCNVector3] {
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y, z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y, z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p1.y + pos.z))
        ]
    }
    
    func leftPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0, y: UFloat(depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y, z:UFloat(p3.y + pos.z)),
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y, z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p3.y + pos.z))
        ]
    }
    
    func points(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0, y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()
        if local == false {
            let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }
        return [
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y, z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y, z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y, z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y, z:UFloat(p3.y + pos.z)),
            SCNVector3(x:UFloat(p0.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p0.y + pos.z)),
            SCNVector3(x:UFloat(p1.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p1.y + pos.z)),
            SCNVector3(x:UFloat(p2.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p2.y + pos.z)),
            SCNVector3(x:UFloat(p3.x + pos.x), y:pos.y+UFloat(height), z:UFloat(p3.y + pos.z))
        ]
    }
    
    func distance(_ to:SCNVector3) -> Float {
        return (to - position).length()
    }
    
    func baseDistance(_ to:SCNVector3) -> Float {
        var point = to
        point.y = position.y
        return (point - position).length()
    }
    
    // transfer point into local coordinate system
    func intoLocal(pt:SCNVector3) -> SCNVector3 {
        let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
        let rotated = CGPoint(x: UFloat(pt.x), y: UFloat(pt.z)).rotate(UFloat(-angle), pivot: pivot)
        return SCNVector3(x: UFloat(rotated.x)-position.x, y: pt.y-position.y, z: UFloat(rotated.y)-position.z)
    }
    
    // transfer points into local coordinate system
    func intoLocal(pts:[SCNVector3]) -> [SCNVector3] {
        var result = [SCNVector3]()
        let pivot = CGPoint(x:UFloat(position.x), y: UFloat(position.z))
        for pt in pts {
            let rotated = CGPoint(x: UFloat(pt.x), y: UFloat(pt.z)).rotate(UFloat(-angle), pivot: pivot)
            result.append(SCNVector3(x: UFloat(rotated.x)-position.x, y: pt.y-position.y, z: UFloat(rotated.y)-position.z))
        }
        return result
    }
    
    // point must be transformed upfront into local object coordinate system
    func sectorOf(point: SCNVector3) -> BBoxSector {
        var zone: BBoxSector = []
        var inner = 0
        if point.x > UFloat(width)/2.0 {
            zone.insert(.l)
        } else if -point.x > UFloat(width)/2.0 {
            zone.insert(.r)
        } else {
            inner += 1
        }
        if point.z > UFloat(depth)/2.0 {
            zone.insert(.a)
        } else if -point.z > UFloat(depth)/2.0 {
            zone.insert(.b)
        } else {
            inner += 1
        }
        if point.y > UFloat(height) {
            zone.insert(.o)
        } else if point.y < 0.0 {
            zone.insert(.u)
        } else {
            inner += 1
        }
        if inner == 3 {
            zone.insert(.i)
        }
        return zone
    }
    
    func topologies(subject:SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        var relation:SpatialRelation
        var gap:Float = 0.0
        var minDistance:Float = 0.0

        /// calculations in global world space
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let radiusSum = radius + subject.radius
        var canNotOverlap = centerDistance > radiusSum
        let theta = subject.angle - angle
        var isNear = false
        var isDisjoint = true
        
        /// calculations in local object space
        let localPts = intoLocal(pts: subject.points())
        var zones = [BBoxSector]()
        for pt in localPts {
            zones.append(sectorOf(point: pt))
        }
        let center = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: center)
        
        /// nearness evaluated by center
        if centerDistance - radiusSum < adjustment.nearbyLimit && centerDistance < ((adjustment.nearbyFactor + 1.0) * radiusSum) {
            isNear = true
            gap = centerDistance - radiusSum
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .near, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        /// basic adjacancy in relation to object bbox
        if centerZone.contains(.l) {
            gap = Float(center.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .left, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.r) {
            gap = Float(-center.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .right, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.a) {
            gap = Float(center.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .ahead, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.b) {
            gap = Float(-center.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .behind, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.o) {
            gap = Float(center.y) - subject.height/2.0 - height
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .above, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.u) {
            gap = Float(-center.y) - subject.height/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .below, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        /// side-related adjacancy in relation to object bbox
        if isNear && centerZone.divergencies() == 1 && centerZone != .i {
            var aligned = false
            if abs(theta.truncatingRemainder(dividingBy: .pi/2.0)) < adjustment.angle {
                aligned = true
            }
            var min:Float = Float.greatestFiniteMagnitude
            if centerZone == .l {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.x) - width/2.0)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .leftside, object: self, gap: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .r {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.x) - width/2.0)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .rightside, object: self, gap: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .o {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.y) - height)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    if min <= adjustment.gap {
                        relation = SpatialRelation(subject: subject, predicate: .ontop, object: self, gap: min, angle: theta)
                    } else {
                        relation = SpatialRelation(subject: subject, predicate: .upperside, object: self, gap: min, angle: theta)
                    }
                    result.append(relation)
                }
                
            } else if centerZone == .u {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.y))
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    if min <= adjustment.gap {
                        relation = SpatialRelation(subject: subject, predicate: .beneath, object: self, gap: min, angle: theta)
                    } else {
                        relation = SpatialRelation(subject: subject, predicate: .lowerside, object: self, gap: min, angle: theta)
                    }
                    result.append(relation)
                }
            } else if centerZone == .a {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.z) - depth/2.0)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .frontside, object: self, gap: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .b {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.z) - depth/2.0)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .backside, object: self, gap: min, angle: theta)
                    result.append(relation)
                }
            }
            if min >= -adjustment.gap &&  min <= adjustment.gap {
                relation = SpatialRelation(subject: subject, predicate: aligned ? .meeting : .touching, object: self, gap: min, angle: theta)
                result.append(relation)
            }
        }
        /// check for topology
        if centerDistance < radius + subject.radius {
            if zones.allSatisfy({ $0 == .i }) {
                isDisjoint = false
                relation = SpatialRelation(subject: subject, predicate: .inside, object: self, gap: 0.0, angle: theta)
                result.append(relation)
            } else {
                var d = 0
                for z in zones {
                    d += z.divergencies()
                }
                if d == 3 * zones.count {
                    isDisjoint = false
                    relation = SpatialRelation(subject: subject, predicate: .containing, object: self, gap: 0.0, angle: theta)
                    result.append(relation)
                } else {
                    let cnt = zones.count(where: { $0.contains(.i) })
                    if cnt > 0 {
                        isDisjoint = false
                        relation = SpatialRelation(subject: subject, predicate: .overlapping, object: self, gap: 0.0, angle: theta)
                        result.append(relation)
                    } else if !canNotOverlap {
                        var crossings = 0
                        let minY = Float(localPts.first!.y)
                        let maxY = Float(localPts.last!.y)
                        var minX:Float = Float.greatestFiniteMagnitude
                        var maxX:Float = -Float.greatestFiniteMagnitude
                        var minZ:Float = Float.greatestFiniteMagnitude
                        var maxZ:Float = -Float.greatestFiniteMagnitude
                        for pt in localPts {
                            minX = Float.minimum(minX, Float(pt.x))
                            maxX = Float.maximum(maxX, Float(pt.x))
                            minZ = Float.minimum(minZ, Float(pt.z))
                            maxZ = Float.maximum(maxZ, Float(pt.z))
                        }
                        if minX < -width/2.0 && maxX > width/2.0 {
                            crossings += 1
                        }
                        if minZ < -depth/2.0 && maxZ > depth/2.0 {
                            crossings += 1
                        }
                        if minY < 0.0 && maxY > height {
                            crossings += 1
                        }
                        if crossings  > 0 {
                            isDisjoint = false
                            relation = SpatialRelation(subject: subject, predicate: .crossing, object: self, gap: 0.0, angle: theta)
                            result.append(relation)

                        }
                    }
                }
            }
        }
        if isDisjoint {
            gap = centerDistance - radiusSum
            relation = SpatialRelation(subject: subject, predicate: .disjoint, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        if isNear && isDisjoint && !centerZone.contains(.o) && !centerZone.contains(.u) {
            relation = SpatialRelation(subject: subject, predicate: .beside, object: self, gap: minDistance, angle: theta)
            result.append(relation)
        }
        /// orientation
        if abs(theta) < adjustment.angle {
            gap = Float(center.z)
            relation = SpatialRelation(subject: subject, predicate: .aligned, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else {
            if abs(theta.truncatingRemainder(dividingBy: .pi)) < adjustment.angle {
                gap = centerDistance - radiusSum
                relation = SpatialRelation(subject: subject, predicate: .opposite, object: self, gap: gap, angle: theta)
                result.append(relation)
            } else if abs(theta.truncatingRemainder(dividingBy: .pi/2.0)) < adjustment.angle {
                relation = SpatialRelation(subject: subject, predicate: .orthogonal, object: self, gap: 0.0, angle: theta)
                result.append(relation)
            }
        }
        if type == "Person" || (cause == .selftracked && existence == .real) {
            let rad = Float(atan2(subject.center.x, subject.center.z))
            var angle:Float = rad * 180.0 / Float.pi
            print(angle)
            let hourAngle:Float = 30.0 // 360.0/12.0
            if angle < 0.0 {
                angle = angle - hourAngle/2.0
            } else {
                angle = angle + hourAngle/2.0
            }
            let cnt = Int(angle/hourAngle)
            print(cnt)
            var doit = true
            var pred:SpatialPredicate = .twelveoclock
            switch cnt {
            case 4:
                pred = .eightoclock
            case 3:
                pred = .nineoclock
            case 2:
                pred = .tenoclock
            case 1:
                pred = .elevenoclock
            case 0:
                pred = .twelveoclock
            case -1:
                pred = .oneoclock
            case -2:
                pred = .twooclock
            case -3:
                pred = .threeoclock
            case -4:
                pred = .fouroclock
            default:
                doit = false
            }
            if doit {
                relation = SpatialRelation(subject: subject, predicate: pred, object: self, gap: centerDistance, angle: rad)
                result.append(relation)
                if centerDistance <= 1.25 { // 70cm arm length plus 25cm shoulder plus 30cm leaning forward
                    relation = SpatialRelation(subject: subject, predicate: .tangible, object: self, gap: centerDistance, angle: rad)
                    result.append(relation)
                }
            }
        }
        return result
    }
    
    func similarities(subject:SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        var relation:SpatialRelation
        let theta = subject.angle - angle
        var val:Float = 0.0
        var minVal:Float = 0.0
        var maxVal:Float = 0.0
        var sameWidth:Bool = false
        var sameDepth:Bool = false
        var sameHeight:Bool = false

        val = (position - subject.position).length()
        if val < adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .samecenter, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        val = abs(width - subject.width)
        if val < adjustment.gap {
            sameWidth = true
            relation = SpatialRelation(subject: subject, predicate: .samewidth, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        val = abs(depth - subject.depth)
        if val < adjustment.gap {
            sameDepth = true
            relation = SpatialRelation(subject: subject, predicate: .samedepth, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        val = abs(height - subject.height)
        if val < adjustment.gap {
            sameHeight = true
            relation = SpatialRelation(subject: subject, predicate: .sameheight, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        if sameWidth && sameDepth && sameHeight {
            val = subject.volume - volume
            relation = SpatialRelation(subject: subject, predicate: .samecuboid, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        val = abs(length - subject.length)
        if val < adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .samelength, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        val = subject.height * subject.width
        minVal = (height-adjustment.gap) * (width-adjustment.gap)
        maxVal = (height+adjustment.gap) * (width+adjustment.gap)
        if val > minVal && val < maxVal {
            let gap = height*width - val
            relation = SpatialRelation(subject: subject, predicate: .samefront, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        val = subject.height * subject.depth
        minVal = (height-adjustment.gap) * (depth-adjustment.gap)
        maxVal = (height+adjustment.gap) * (depth+adjustment.gap)
        if val > minVal && val < maxVal {
            let gap = height*depth - val
            relation = SpatialRelation(subject: subject, predicate: .sameside, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        val = subject.width * subject.depth
        minVal = (width-adjustment.gap) * (depth-adjustment.gap)
        maxVal = (width+adjustment.gap) * (depth+adjustment.gap)
        if val > minVal && val < maxVal {
            let gap = width*depth - val
            relation = SpatialRelation(subject: subject, predicate: .samefootprint, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
        val = subject.width * subject.depth * subject.height
        minVal = (width-adjustment.gap) * (depth-adjustment.gap) * (height-adjustment.gap)
        maxVal = (width+adjustment.gap) * (depth+adjustment.gap) * (height+adjustment.gap)
        if val > minVal && val < maxVal {
            let gap = width*depth*height - val
            relation = SpatialRelation(subject: subject, predicate: .samevolume, object: self, gap: gap, angle: theta)
            result.append(relation)
            val = (position - subject.position).length()
            let angleDiff = abs(angle - subject.angle)
            if sameWidth && sameDepth && sameHeight && val < adjustment.gap && angleDiff < adjustment.angle {
                relation = SpatialRelation(subject: subject, predicate: .congruent, object: self, gap: gap, angle: theta)
                result.append(relation)
            }
        }
        if shape == subject.shape && shape != .unknown && subject.shape != .unknown {
            val = (position - subject.position).length()
            relation = SpatialRelation(subject: subject, predicate: .sameshape, object: self, gap: val, angle: theta)
            result.append(relation)
        }
        return result
    }
    
    func comparisons(subject:SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        var relation:SpatialRelation
        let theta = subject.angle - angle
        var objVal:Float = 0.0
        var subjVal:Float = 0.0
        var diff:Float = 0.0

        objVal = volume
        subjVal = subject.volume
        diff = subjVal - objVal
        if diff > adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .bigger, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .smaller, object: self, gap: diff, angle: theta)
            result.append(relation)
        }
        objVal = length
        subjVal = subject.length
        diff = subjVal - objVal
        var shorterAdded = false
        if diff > adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .longer, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, gap: diff, angle: theta)
            result.append(relation)
            shorterAdded = true
        }
        objVal = height
        subjVal = subject.height
        diff = subjVal - objVal
        if diff > adjustment.gap {
            relation = SpatialRelation(subject: subject, predicate: .taller, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.gap && !shorterAdded {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, gap: diff, angle: theta)
            result.append(relation)
        }
        if mainDirection() == 1 {
            objVal = footprint
            subjVal = subject.footprint
            diff = subjVal - objVal
            if diff > adjustment.gap {
                relation = SpatialRelation(subject: subject, predicate: .wider, object: self, gap: diff, angle: theta)
                result.append(relation)
            } else if -diff > adjustment.gap {
                relation = SpatialRelation(subject: subject, predicate: .thinner, object: self, gap: diff, angle: theta)
                result.append(relation)
            }
            
        }
        return result
    }
    
    // sector
    func direction(subject:SpatialObject) -> SpatialRelation {
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let center = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: center)
        let theta = subject.angle - angle
        print(centerZone.description)
        let pred = SpatialPredicate.named(centerZone.description)
        return SpatialRelation(subject:subject, predicate: pred, object:self, gap: centerDistance, angle:theta)
    }
    
    func relate(subject:SpatialObject, topology:Bool = true, similarity:Bool = true, comparison:Bool = true) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        if topology {
            result.append(contentsOf: topologies(subject:subject))
        }
        if similarity {
            result.append(contentsOf: similarities(subject:subject))
        }
        if comparison {
            result.append(contentsOf: comparisons(subject:subject))
        }
        return result
    }
    
    func asseen(subject:SpatialObject, observer:SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let radiusSum = radius + subject.radius
        
        if centerDistance - radiusSum < adjustment.nearbyLimit && centerDistance < ((adjustment.nearbyFactor + 1.0) * radiusSum) {
            let centerObject = observer.intoLocal(pt: self.center)
            let centerSubject = observer.intoLocal(pt: subject.center)
            if centerSubject.z > 0.0 && centerObject.z > 0.0 { // both are ahead of observer
                let xgap = Float(centerSubject.x - centerObject.x)
                let zgap = Float(centerSubject.z - centerObject.z)
                if abs(xgap) > adjustment.gap {
                    if xgap > 0.0 {
                        let relation = SpatialRelation(subject: subject, predicate: .seenleft, object: self, gap: abs(xgap), angle: 0.0)
                        result.append(relation)
                    } else {
                        let relation = SpatialRelation(subject: subject, predicate: .seenright, object: self, gap: abs(xgap), angle: 0.0)
                        result.append(relation)
                    }
                }
                if abs(zgap) > adjustment.gap {
                    if zgap > 0.0 {
                        let relation = SpatialRelation(subject: subject, predicate: .atrear, object: self, gap: abs(zgap), angle: 0.0)
                        result.append(relation)
                    } else {
                        let relation = SpatialRelation(subject: subject, predicate: .infront, object: self, gap: abs(zgap), angle: 0.0)
                        result.append(relation)
                    }
                }
            }
        }
        return result
    }
    
    // ---- Visualization functions ----------------------------
    
    func bboxCube(color:CGColor) -> SCNNode {
        let name = id
        let group = SCNNode()
        group.name = name
        let box = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(depth), chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.transparency = 1.0 - color.alpha
        let boxNode = SCNNode(geometry: box)
        group.addChildNode(boxNode)
        /// set name at front
        let text = SCNText(string: name, extrusionDepth:0.0)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant
        let textNode = SCNNode(geometry: text)
        let fontSize = Float(0.005)
        let (min, max) =  textNode.boundingBox
        textNode.position.x =  -((max.x - min.x)/2.0 * CGFloat(fontSize))
        textNode.position.y = -CGFloat(height/2.0)
        textNode.position.z = CGFloat(depth/2.0 + 0.2)
        textNode.renderingOrder = 1
        textNode.eulerAngles.x = -.pi/2.0
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        group.addChildNode(textNode)
        group.eulerAngles.y = CGFloat(angle)
        group.position = center
        return group
    }
    
    func nearbySphere() -> SCNNode {
        let r = (adjustment.nearbyFactor + 1.0)*radius
        let sphere = SCNSphere(radius: CGFloat(r))
        sphere.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        sphere.firstMaterial?.transparency = 0.5
        let node = SCNNode(geometry: sphere)
        node.name = "Nearby sphere of " + (label.count > 0 ? label : id)
        node.position = center
        return node
    }
    
    func sectorCube(_ sector:BBoxSector = .i) -> SCNNode {
        let box = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(depth), chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        box.firstMaterial?.transparency = 0.5
        let node = SCNNode(geometry: box)
        node.name = sector.description + " sector"
        var shift:SCNVector3 = .init()
        if sector.contains(.o) {
            shift.y = CGFloat(height)
        } else if sector.contains(.u) {
            shift.y = CGFloat(-height)
        }
        if sector.contains(.r) {
            shift.x = CGFloat(-width)
        } else if sector.contains(.l) {
            shift.x = CGFloat(width)
        }
        if sector.contains(.a) {
            shift.z = CGFloat(depth)
        } else if sector.contains(.b) {
            shift.z = CGFloat(-depth)
        }
        node.position = center + shift
        return node
    }
    
    static func export3D(to url:URL, nodes:[SCNNode]) {
        let scene = SCNScene()
        for node in nodes {
            scene.rootNode.addChildNode(node)
        }
        scene.write(to: url, options: nil, delegate: nil, progressHandler: nil)
    }
    
}
