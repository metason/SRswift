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
    var type:String = "" // class
    var supertype:String = "" // superclass
    var look:String = "" // textual description of appearance: color, bright/dark, dull/shiny, metallic, transparent, ...
    var data:Dictionary<String,Any>? = nil // auxiliary data
    var created:Date // creation time
    var updated:Date // last update time
    /// spatial characteristics
    private var position:SCNVector3 = SCNVector3() // base center point at bottom, use setPosition() or setCenter()
    var width:Float = 0.0
    var height:Float = 0.0
    var depth:Float = 0.0
    var angle:Float = 0.0 // rotation around y axis in radiants, counter-clockwise
    var immobile:Bool = false
    var velocity:SCNVector3 = SCNVector3() // velocity vector, is calculated via setPosition() over time
    var confidence = ObjectConfidence()
    var shape:ObjectShape = .unknown
    var visible:Bool = false // in screen
    var focused:Bool = false // in center of screen, for some time
    var context:SpatialReasoner? = nil // optional, defines fact base and adjustment settings
    
    /// derived attributes
    var center:SCNVector3 {
        return position + SCNVector3(0.0, height/2.0, 0.0)
    }
    var yaw:Float { // in degrees counter-clockwise of WCS
        return angle * 180.0 / .pi
    }
    var azimuth:Float { // in degrees clockwise of GCS as ±360°
        if context != nil {
            return -(yaw + Float(atan2(context!.north.dy, context!.north.dx) * 180.0 / .pi) - 90.0).truncatingRemainder(dividingBy: 360.0)
        }
        return 0.0
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
    var real:Bool {
        return existence == .real
    }
    var virtual:Bool {
        return existence == .virtual
    }
    var conceptual:Bool {
        return existence == .conceptual
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
    // circle radius on 2D base / floorground, radius from position encircling base area
    var baseradius:Float {
        return Float(CGPoint(x:Double(width)/2.0, y:Double(depth)/2.0).length())
    }
    var motion:MotionState {
        if immobile {
            return .stationary
        }
        if confidence.spatial > 0.5 {
            if velocity.length() > adjustment.maxGap {
                return .moving
            }
            return .idle
        }
        return .unknown
    }
    var moving:Bool {
        return motion == .moving
    }
    var speed:Float {
        return velocity.length()
    }
    var observing:Bool {
        return cause == .self_tracked
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
        return context?.adjustment ?? defaultAdjustment
    }
    
    static let booleanAttributes: [String] = ["immobile", "moving", "focused", "visible", "equilateral", "thin", "long", "real", "virtual", "conceptual"]
    static let numericAttributes: [String] = ["width", "height", "depth", "w", "h", "d", "position", "x", "y", "z", "angle", "confidence"]
    static let stringAttributes: [String] = ["id", "label", "type", "supertype", "existence", "cause", "shape", "look"]

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

    func index() -> Int {
        if context != nil {
            return context!.objects.firstIndex{$0 === self} ?? -1
        }
        return -1
    }
    
    static func isBoolean(attribute: String) -> Bool {
        return booleanAttributes.contains(attribute)
    }
    
    static func createDetectedObject(id: String, label: String = "", width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.label = label.lowercased()
        object.type = label
        object.cause = .object_detected
        object.existence = .real
        object.confidence.setValue(0.25)
        object.immobile = false
        object.shape = .unknown
        return object
    }
    
    static func createVirtualObject(id: String, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.cause = .user_generated
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
        object.cause = .plane_detected
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
        object.cause = .user_captured
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
        person.cause = .self_tracked
        person.existence = .real
        person.confidence.setValue(1.0)
        person.immobile = false
        person.supertype = "Creature"
        person.type = "Person"
        person.shape = .changing
        return person
    }
    
    // set auxiliary data
    func setData(key:String, value:Any) {
        if data != nil {
            data![key] = value
        } else {
            data = [key: value]
        }
    }
    
    func dataValue(_ key:String) -> Float {
        if data != nil {
            let value =  data![key]
            if value != nil {
                if let val = value as? Float {
                    return val
                }
            }
        }
        return 0
    }
    
    // Object Serialization
    // Hint: Codable extension not used to have more control
    
    // full-fledged representation for fact base
    public func asDict() -> Dictionary<String, Any>? {
        var output = [
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
            "real": real,
            "virtual": virtual,
            "conceptual": conceptual,
            "moving": moving,
            "perimeter": perimeter,
            "footprint": footprint,
            "frontface": frontface,
            "sideface": sideface,
            "surface": surface,
            "baseradius": baseradius,
            "volume": volume,
            "radius": radius,
            "angle": angle,
            "yaw": yaw,
            "azimuth": azimuth,
            "lifespan": lifespan,
            "updateInterval": updateInterval,
            "confidence": confidence.asDict(),
            "immobile": immobile,
            "velocity": [velocity.x, velocity.y, velocity.z],
            "motion": motion.rawValue,
            "shape": shape.rawValue,
            "look": look,
            "visible": visible,
            "focused": focused
        ] as [String : Any]
        if data != nil {
            output.merge(data!) { (current, _) in current } // keeping current
        }
        return output
    }
    
    // for export
    public func toAny() -> Dictionary<String, Any>? {
        var output = [
            "id": id,
            "existence": existence.rawValue,
            "cause": cause.rawValue,
            "label": label,
            "type": type,
            "supertype": supertype,
            "position": [position.x, position.y, position.z],
            "width": width,
            "height": height,
            "depth": depth,
            "angle": angle,
            "immobile": immobile,
            "velocity": [velocity.x, velocity.y, velocity.z],
            "confidence": confidence.value,
            "shape": shape.rawValue,
            "look": look,
            "visible": visible,
            "focused": focused
        ] as [String : Any]
        if data != nil {
            output.merge(data!) { (current, _) in current } // keeping current
        }
        return output
    }
    
    // import/update from JSON data
    public func fromAny(_ input: Dictionary<String, Any>) {
        let id = input["id"] as? String ?? ""
        if !id.isEmpty {
            if self.id != id {
                print("import/update from another id!")
            }
            self.id = id
        }
        var pos = SCNVector3()
        let position = input["position"] as? [Float] ?? []
        if position.count == 3 {
            pos.x = CGFloat(position[0])
            pos.y = CGFloat(position[1])
            pos.z = CGFloat(position[2])
        } else {
            let x = input["x"] as? Float ?? Float(self.position.x)
            let y = input["y"] as? Float ?? Float(self.position.y)
            let z = input["z"] as? Float ?? Float(self.position.z)
            pos.x = CGFloat(x)
            pos.y = CGFloat(y)
            pos.z = CGFloat(z)
        }
        setPosition(pos)
        self.width = input["width"] as? Float ?? input["w"] as? Float ?? self.width
        self.height = input["height"] as? Float ?? input["h"] as? Float ?? self.height
        self.depth = input["depth"] as? Float ?? input["d"] as? Float ?? self.depth
        self.angle = input["angle"] as? Float ?? self.angle
        self.label = input["label"] as? String ?? self.label
        self.type = input["type"] as? String ?? self.type
        self.supertype = input["supertype"] as? String ?? self.supertype
        let confidence = input["confidence"] as? Float ?? self.confidence.value
        self.confidence.setValue(confidence)
        let cause = input["cause"] as? String ?? self.cause.rawValue
        self.cause = ObjectCause.named(cause)
        let existence = input["existence"] as? String ?? self.existence.rawValue
        self.existence = SpatialExistence.named(existence)
        self.immobile = input["existence"] as? Bool ?? self.immobile
        let shape = input["shape"] as? String ?? self.shape.rawValue
        self.shape = ObjectShape.named(shape)
        self.look = input["look"] as? String ?? self.look
        for dict in input {
            let key = dict.key
            if !SpatialObject.stringAttributes.contains(key) && !SpatialObject.numericAttributes.contains(key) && !SpatialObject.booleanAttributes.contains(key) {
                setData(key: key, value: dict.value)
            }
        }
        self.updated = Date()
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
        setPosition(.init(x: center.x, y: center.y - UFloat(height/2.0), z: center.z))
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
            p0 = p0.rotate(UFloat(angle))
            p1 = p1.rotate(UFloat(angle))
            p2 = p2.rotate(UFloat(angle))
            p3 = p3.rotate(UFloat(angle))
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
            p0 = p0.rotate(UFloat(angle))
            p1 = p1.rotate(UFloat(angle))
            p2 = p2.rotate(UFloat(angle))
            p3 = p3.rotate(UFloat(angle))
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
            p0 = p0.rotate(UFloat(angle))
            p1 = p1.rotate(UFloat(angle))
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
            p2 = p2.rotate(UFloat(angle))
            p3 = p3.rotate(UFloat(angle))
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
            p1 = p1.rotate(UFloat(angle))
            p2 = p2.rotate(UFloat(angle))
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
            p0 = p0.rotate(UFloat(angle))
            p3 = p3.rotate(UFloat(angle))
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
            p0 = p0.rotate(UFloat(angle))
            p1 = p1.rotate(UFloat(angle))
            p2 = p2.rotate(UFloat(angle))
            p3 = p3.rotate(UFloat(angle))
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
        let vx = Float(pt.x - position.x)
        let vy = Float(pt.z - position.z)
        let rotsin = sinf(-angle)
        let rotcos = cosf(-angle)
        let x = vx * rotcos - vy * rotsin
        let y = vx * rotsin + vy * rotcos
        return SCNVector3(x: UFloat(x), y: pt.y-position.y, z: UFloat(y))
    }
    

    
    // transfer points into local coordinate system
    func intoLocal(pts:[SCNVector3]) -> [SCNVector3] {
        var result = [SCNVector3]()
        let rotsin = sinf(-angle)
        let rotcos = cosf(-angle)
        for pt in pts {
            let vx = Float(pt.x - position.x)
            let vy = Float(pt.z - position.z)
            let x = vx * rotcos - vy * rotsin
            let y = vx * rotsin + vy * rotcos
            result.append(SCNVector3(x: UFloat(x), y: pt.y-position.y, z: UFloat(y)))
        }
        return result
    }
    
    // point must be transformed upfront into local object coordinate system
    func sectorOf(point: SCNVector3, nearby:Bool = false) -> BBoxSector {
        let epsilon = UFloat(context?.adjustment.maxGap ?? defaultAdjustment.maxGap)/2.0
        var zone = BBoxSector()
        if point.x < UFloat(width)/2.0 + epsilon && -point.x < UFloat(width)/2.0 + epsilon &&
            point.z < UFloat(depth)/2.0 + epsilon && -point.z < UFloat(depth)/2.0 + epsilon &&
            point.y < UFloat(height) + epsilon && point.y > -epsilon {
            zone.insert(.i)
        }
        if point.x + epsilon > UFloat(width)/2.0 {
            zone.insert(.l)
        } else if -point.x + epsilon > UFloat(width)/2.0 {
            zone.insert(.r)
        }
        if point.z + epsilon > UFloat(depth)/2.0 {
            zone.insert(.a)
        } else if -point.z + epsilon > UFloat(depth)/2.0 {
            zone.insert(.b)
        }
        if point.y + epsilon > UFloat(height) {
            zone.insert(.o)
        } else if point.y - epsilon < 0.0 {
            zone.insert(.u)
        }
        if nearby && !zone.isEmpty {
            if zone.contains(.l) || zone.contains(.r) {
                let size = sectorLenghts(.r)
                if point.x > size.x + UFloat(width/2.0) {
                    zone.remove(.l)
                }
                if -point.x > size.x + UFloat(width/2.0) {
                    zone.remove(.r)
                }
            }
            if zone.contains(.o) || zone.contains(.u) {
                let size = sectorLenghts(.o)
                if point.y > size.y + UFloat(height) {
                    zone.remove(.o)
                }
                if -point.y > size.y {
                    zone.remove(.u)
                }
            }
            if zone.contains(.a) || zone.contains(.b) {
                let size = sectorLenghts(.a)
                if point.z > size.z + UFloat(depth/2.0) {
                    zone.remove(.a)
                }
                if -point.z > size.z + UFloat(depth/2.0) {
                    zone.remove(.b)
                }
            }
        }
        return zone
    }
    
    func sectorLenghts(_ sector:BBoxSector = .i) -> SCNVector3 {
        var result = SCNVector3(x: UFloat(width), y: UFloat(height), z: UFloat(depth))
        if sector.contains(.a) || sector.contains(.b) {
            switch adjustment.sectorSchema {
            case .fixed: result.z = UFloat(adjustment.fixSectorLenght)
            case .area: result.z = UFloat(min(height*width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.z = UFloat(min(depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.z = UFloat(min(height+width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.z = UFloat(min(radius*adjustment.nearbyFactor, adjustment.nearbyLimit))
            case .wide: result.z = UFloat(adjustment.wideSectorLenght)
            }
        }
        if sector.contains(.l) || sector.contains(.r) {
            switch adjustment.sectorSchema {
            case .fixed: result.x = UFloat(adjustment.fixSectorLenght)
            case .area: result.x = UFloat(min(height*depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.x = UFloat(min(width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.x = UFloat(min(height+depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.x = UFloat(min(radius*adjustment.nearbyFactor, adjustment.nearbyLimit))
            case .wide: result.x = UFloat(adjustment.wideSectorLenght)
            }
        }
        if sector.contains(.o) || sector.contains(.u) {
            switch adjustment.sectorSchema {
            case .fixed: result.y = UFloat(adjustment.fixSectorLenght)
            case .area: result.y = UFloat(min(width*depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.y = UFloat(min(height*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.y = UFloat(min(width+depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.y = UFloat(min(radius*adjustment.nearbyFactor, adjustment.nearbyLimit))
            case .wide: result.y = UFloat(adjustment.wideSectorLenght)
            }
        }
        return result
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
        var isConnected = false
        
        /// calculations in local object space
        let localPts = intoLocal(pts: subject.points())
        var zones = [BBoxSector]()
        for pt in localPts {
            zones.append(sectorOf(point: pt))
        }
        let center = intoLocal(pt: subject.center)
        var centerZone = sectorOf(point: center)
        
        /// nearness evaluated by center
        if centerDistance - radiusSum < adjustment.nearbyLimit && centerDistance < ((adjustment.nearbyFactor + 1.0) * radiusSum) {
            isNear = true
            gap = centerDistance
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .near, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else {
            relation = SpatialRelation(subject: subject, predicate: .far, object: self, delta: centerDistance, angle: theta)
            result.append(relation)
        }
        /// basic adjacancy in relation to object bbox
        if centerZone.contains(.l) {
            gap = Float(center.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .left, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.r) {
            gap = Float(-center.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .right, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.a) {
            gap = Float(center.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .ahead, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.b) {
            gap = Float(-center.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .behind, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.o) {
            gap = Float(center.y) - subject.height/2.0 - height
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .above, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.u) {
            gap = Float(-center.y) - subject.height/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .below, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        
        /// side-related adjacancy in relation to object bbox
        centerZone = sectorOf(point: center, nearby: true)
        if isNear && centerZone != .i {
            var aligned = false
            if abs(theta.truncatingRemainder(dividingBy: .pi/2.0)) < adjustment.maxAngleDelta {
                aligned = true
            }
            var min:Float = Float.greatestFiniteMagnitude
            if centerZone == .l {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.x) - width/2.0)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .leftside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .r {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.x) - width/2.0)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .rightside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .o {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.y) - height)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    if min <= adjustment.maxGap {
                        relation = SpatialRelation(subject: subject, predicate: .ontop, object: self, delta: min, angle: theta)
                        result.append(relation)
                        if context?.deduce.connectivity ?? true {
                            relation = SpatialRelation(subject: subject, predicate: .on, object: self, delta: min, angle: theta)
                            result.append(relation)
                            isConnected = true
                        }
                    } else {
                        relation = SpatialRelation(subject: subject, predicate: .upperside, object: self, delta: min, angle: theta)
                        result.append(relation)
                    }
                    
                }
                
            } else if centerZone == .u {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.y))
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    if min <= adjustment.maxGap {
                        relation = SpatialRelation(subject: subject, predicate: .beneath, object: self, delta: min, angle: theta)
                    } else {
                        relation = SpatialRelation(subject: subject, predicate: .lowerside, object: self, delta: min, angle: theta)
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
                    relation = SpatialRelation(subject: subject, predicate: .frontside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .b {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.z) - depth/2.0)
                }
                if min > 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .backside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            }
            // FIXME: .touching / .by
            let groundRadi = baseradius + subject.baseradius
            var pt = center
            pt.y = 0.0
            let groundDistance = pt.length()
            min = groundDistance - groundRadi
//                if min < adjustment.maxgap {
//                    canNotOverlap = true
//                    minDistance = min
//                    relation = SpatialRelation(subject: subject, predicate: .touching, object: self, delta: min, angle: theta)
//                    result.append(relation)
//                    if !isConnected && context?.deduce.connectivity ?? true {
//                        relation = SpatialRelation(subject: subject, predicate: .by, object: self, delta: min, angle: theta)
//                        result.append(relation)
//                        isConnected = true
//                    }
//                }
            if min >= -adjustment.maxGap && min <= adjustment.maxGap {
                print("oha: \(min)")
                relation = SpatialRelation(subject: subject, predicate: aligned ? .meeting : .touching, object: self, delta: min, angle: theta)
                result.append(relation)
                if aligned {
                    if !isConnected && context?.deduce.connectivity ?? true {
                        relation = SpatialRelation(subject: subject, predicate: .at, object: self, delta: min, angle: theta)
                        result.append(relation)
                        isConnected = true
                    }
                }
            }
        }
        /// check for topology
        if isNear { // centerDistance < radius + subject.radius ?
            if zones.allSatisfy({ $0.contains(.i) }) {
                isDisjoint = false
                relation = SpatialRelation(subject: subject, predicate: .inside, object: self, delta: centerDistance, angle: theta)
                result.append(relation)
                if context?.deduce.connectivity ?? true {
                    relation = SpatialRelation(subject: subject, predicate: .in, object: self, delta: centerDistance, angle: theta)
                    result.append(relation)
                }
            } else {
                if (subject.radius - radius) > centerDistance / 2.0 && subject.width > width && subject.height > height && subject.depth > depth {
                    isDisjoint = false
                    relation = SpatialRelation(subject: subject, predicate: .containing, object: self, delta: 0.0, angle: theta)
                    result.append(relation)
                } else {
                    let cnt = zones.count(where: { $0.contains(.i) })
                    if cnt > 0 && !canNotOverlap {
                        isDisjoint = false
                        relation = SpatialRelation(subject: subject, predicate: .overlapping, object: self, delta: centerDistance, angle: theta)
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
                        if minX < -width/2.0 && maxX > width/2.0 && minZ < depth/2.0 && maxZ > -depth/2.0 && minY < height && maxY > 0 {
                            crossings += 1
                        }
                        if minZ < -depth/2.0 && maxZ > depth/2.0 && minX < width/2.0 && maxX > -width/2.0 && minY < height && maxY > 0 {
                            crossings += 1
                        }
                        if minY < 0.0 && maxY > height && minX < width/2.0 && maxX > -width/2.0 && minZ < depth/2.0 && maxZ > -depth/2.0 {
                            crossings += 1
                        }
                        if crossings  > 0 {
                            isDisjoint = false
                            relation = SpatialRelation(subject: subject, predicate: .crossing, object: self, delta: centerDistance, angle: theta)
                            result.append(relation)

                        }
                    }
                }
            }
        }
        if isDisjoint {
            gap = centerDistance
            relation = SpatialRelation(subject: subject, predicate: .disjoint, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        if isNear && isDisjoint && !centerZone.contains(.o) && !centerZone.contains(.u) {
            relation = SpatialRelation(subject: subject, predicate: .beside, object: self, delta: minDistance, angle: theta)
            result.append(relation)
        }
        /// orientation
        if abs(theta) < adjustment.maxAngleDelta {
            gap = Float(center.z)
            relation = SpatialRelation(subject: subject, predicate: .aligned, object: self, delta: gap, angle: theta)
            result.append(relation)
            let frontGap = Float(center.z) + subject.depth/2.0 - depth/2.0
            if abs(frontGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .frontaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let backGap = Float(center.z) - subject.depth/2.0 + depth/2.0
            if abs(backGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .backaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let rightGap = Float(center.x) - subject.width/2.0 + width/2.0
            if abs(rightGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .rightaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let leftGap = Float(center.x) + subject.width/2.0 - width/2.0
            if abs(leftGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .leftaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
        } else {
            if abs(theta.truncatingRemainder(dividingBy: .pi)) < adjustment.maxAngleDelta {
                gap = centerDistance - radiusSum
                relation = SpatialRelation(subject: subject, predicate: .opposite, object: self, delta: gap, angle: theta)
                result.append(relation)
            } else if abs(theta.truncatingRemainder(dividingBy: .pi/2.0)) < adjustment.maxAngleDelta {
                relation = SpatialRelation(subject: subject, predicate: .orthogonal, object: self, delta: 0.0, angle: theta)
                result.append(relation)
            }
        }
        if context?.deduce.visibility ?? true {
            if type == "Person" || (cause == .self_tracked && existence == .real) {
                let rad = Float(atan2(subject.center.x, subject.center.z))
                var angle:Float = rad * 180.0 / Float.pi
                let hourAngle:Float = 30.0 // 360.0/12.0
                if angle < 0.0 {
                    angle = angle - hourAngle/2.0
                } else {
                    angle = angle + hourAngle/2.0
                }
                let cnt = Int(angle/hourAngle)
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
                    relation = SpatialRelation(subject: subject, predicate: pred, object: self, delta: centerDistance, angle: rad)
                    result.append(relation)
                    if centerDistance <= 1.25 { // 70cm arm length plus 25cm shoulder plus 30cm leaning forward
                        relation = SpatialRelation(subject: subject, predicate: .tangible, object: self, delta: centerDistance, angle: rad)
                        result.append(relation)
                    }
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

        val = (center - subject.center).length()
        if val < adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .samecenter, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = (position - subject.position).length()
        if val < adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .sameposition, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = abs(width - subject.width)
        if val < adjustment.maxGap {
            sameWidth = true
            relation = SpatialRelation(subject: subject, predicate: .samewidth, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = abs(depth - subject.depth)
        if val < adjustment.maxGap {
            sameDepth = true
            relation = SpatialRelation(subject: subject, predicate: .samedepth, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = abs(height - subject.height)
        if val < adjustment.maxGap {
            sameHeight = true
            relation = SpatialRelation(subject: subject, predicate: .sameheight, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = subject.depth * subject.width
        minVal = (depth-adjustment.maxGap) + (width-adjustment.maxGap)
        maxVal = (depth+adjustment.maxGap) + (width+adjustment.maxGap)
        if val > minVal && val < maxVal {
            let gap = depth*width - val
            relation = SpatialRelation(subject: subject, predicate: .sameperimeter, object: self, delta: 2.0*gap, angle: theta)
            result.append(relation)
        }
        if sameWidth && sameDepth && sameHeight {
            val = subject.volume - volume
            relation = SpatialRelation(subject: subject, predicate: .samecuboid, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = abs(length - subject.length)
        if val < adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .samelength, object: self, delta: val, angle: theta)
            result.append(relation)
        }
        val = subject.height * subject.width
        minVal = (height-adjustment.maxGap) * (width-adjustment.maxGap)
        maxVal = (height+adjustment.maxGap) * (width+adjustment.maxGap)
        if val > minVal && val < maxVal {
            let gap = height*width - val
            relation = SpatialRelation(subject: subject, predicate: .samefront, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        val = subject.height * subject.depth
        minVal = (height-adjustment.maxGap) * (depth-adjustment.maxGap)
        maxVal = (height+adjustment.maxGap) * (depth+adjustment.maxGap)
        if val > minVal && val < maxVal {
            let gap = height*depth - val
            relation = SpatialRelation(subject: subject, predicate: .sameside, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        val = subject.width * subject.depth
        minVal = (width-adjustment.maxGap) * (depth-adjustment.maxGap)
        maxVal = (width+adjustment.maxGap) * (depth+adjustment.maxGap)
        if val > minVal && val < maxVal {
            let gap = width*depth - val
            relation = SpatialRelation(subject: subject, predicate: .samefootprint, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        val = (subject.width * subject.width) + (subject.depth * subject.depth) + (subject.height * subject.height)
        minVal = ((width-adjustment.maxGap) * (width-adjustment.maxGap)) + ((depth-adjustment.maxGap) * (depth-adjustment.maxGap)) + ((height-adjustment.maxGap) * (height-adjustment.maxGap))
        maxVal = ((width+adjustment.maxGap) * (width+adjustment.maxGap)) + ((depth+adjustment.maxGap) * (depth+adjustment.maxGap)) + ((height+adjustment.maxGap) * (height+adjustment.maxGap))
        if val > minVal && val < maxVal {
            let gap = ((width*width) + (depth*depth) + (height*height)) - val
            relation = SpatialRelation(subject: subject, predicate: .samesurface, object: self, delta: 2.0*gap, angle: theta)
            result.append(relation)
        }
        val = subject.width * subject.depth * subject.height
        minVal = (width-adjustment.maxGap) * (depth-adjustment.maxGap) * (height-adjustment.maxGap)
        maxVal = (width+adjustment.maxGap) * (depth+adjustment.maxGap) * (height+adjustment.maxGap)
        if val > minVal && val < maxVal {
            let gap = width*depth*height - val
            relation = SpatialRelation(subject: subject, predicate: .samevolume, object: self, delta: gap, angle: theta)
            result.append(relation)
            val = (position - subject.position).length()
            let angleDiff = abs(angle - subject.angle)
            if sameWidth && sameDepth && sameHeight && val < adjustment.maxGap && angleDiff < adjustment.maxAngleDelta {
                relation = SpatialRelation(subject: subject, predicate: .congruent, object: self, delta: gap, angle: theta)
                result.append(relation)
            }
        }
        if shape == subject.shape && shape != .unknown && subject.shape != .unknown {
            let gap = width*depth*height - val
            relation = SpatialRelation(subject: subject, predicate: .sameshape, object: self, delta: gap, angle: theta)
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

        objVal = length
        subjVal = subject.length
        diff = subjVal - objVal
        var shorterAdded = false
        if diff > adjustment.maxGap*adjustment.maxGap*adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .longer, object: self, delta: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.maxGap*adjustment.maxGap*adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, delta: diff, angle: theta)
            result.append(relation)
            shorterAdded = true
        }
        objVal = height
        subjVal = subject.height
        diff = subjVal - objVal
        if diff > adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .taller, object: self, delta: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.maxGap && !shorterAdded {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, delta: diff, angle: theta)
            result.append(relation)
        }
        if subject.mainDirection() == 2 {
            objVal = footprint
            subjVal = subject.footprint
            diff = subjVal - objVal
            if diff > adjustment.maxGap*adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .wider, object: self, delta: diff, angle: theta)
                result.append(relation)
            } else if -diff > adjustment.maxGap*adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .thinner, object: self, delta: diff, angle: theta)
                result.append(relation)
            }
        }
        objVal = volume
        subjVal = subject.volume
        diff = subjVal - objVal
        if diff > adjustment.maxGap*adjustment.maxGap*adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .bigger, object: self, delta: diff, angle: theta)
            result.append(relation)
            relation = SpatialRelation(subject: subject, predicate: .exceeding, object: self, delta: diff, angle: theta)
            result.append(relation)
        } else if -diff > adjustment.maxGap*adjustment.maxGap*adjustment.maxGap {
            relation = SpatialRelation(subject: subject, predicate: .smaller, object: self, delta: diff, angle: theta)
            result.append(relation)
        }
        if height > subject.height && footprint > subject.footprint {
            relation = SpatialRelation(subject: subject, predicate: .fitting, object: self, delta: diff, angle: theta)
            result.append(relation)
        }
        return result
    }
    
    // sector
    func sector(subject:SpatialObject, nearby:Bool = false) -> SpatialRelation {
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let center = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: center, nearby: nearby)
        let theta = subject.angle - angle
        let pred = SpatialPredicate.named(centerZone.description)
        return SpatialRelation(subject:subject, predicate: pred, object:self, delta: centerDistance, angle:theta)
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
                // FIXME: checking center is not enough!
                let xgap = Float(centerSubject.x - centerObject.x)
                let zgap = Float(centerSubject.z - centerObject.z)
                if abs(xgap) > adjustment.maxGap {
                    if xgap > 0.0 {
                        let relation = SpatialRelation(subject: subject, predicate: .seenleft, object: self, delta: abs(xgap), angle: 0.0)
                        result.append(relation)
                    } else {
                        let relation = SpatialRelation(subject: subject, predicate: .seenright, object: self, delta: abs(xgap), angle: 0.0)
                        result.append(relation)
                    }
                }
                // FIXME: turn by view angle
                if abs(zgap) > adjustment.maxGap {
                    if zgap > 0.0 {
                        let relation = SpatialRelation(subject: subject, predicate: .atrear, object: self, delta: abs(zgap), angle: 0.0)
                        result.append(relation)
                    } else {
                        let relation = SpatialRelation(subject: subject, predicate: .infront, object: self, delta: abs(zgap), angle: 0.0)
                        result.append(relation)
                    }
                }
            }
        }
        return result
    }
    
    func relate(subject:SpatialObject, topology:Bool = false, similarity:Bool = false, comparison:Bool = false) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        if topology || context?.deduce.topology ?? false || context?.deduce.connectivity ?? false {
            result.append(contentsOf: topologies(subject:subject))
        }
        if similarity || context?.deduce.similarity ?? false {
            result.append(contentsOf: similarities(subject:subject))
        }
        if comparison || context?.deduce.comparability ?? false {
            result.append(contentsOf: comparisons(subject:subject))
        }
        if context?.observer != nil && context?.deduce.visibility ?? false {
            result.append(contentsOf: asseen(subject:subject, observer:context!.observer!))
        }
        return result
    }
    
    func relationValue(_ relval: String, pre: [Int]) -> Float {
        let list = relval.split(separator: ".").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.count != 2 && context == nil {
            return 0.0
        }
        let predicate = list[0]
        let attribute = list[1]
        var result: Float = 0.0
        // FIXME: take min instead of last?
        for i in pre {
            let rels = context!.relationsWith(i, predicate: predicate)
            for rel in rels {
                if rel.subject === self {
                    if attribute == "angle" {
                        result = rel.angle
                    } else {
                        result = rel.delta
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
        let box = SCNBox(width: UFloat(width), height: UFloat(height), length: UFloat(depth), chamferRadius: 0.0)
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
        textNode.position.x =  -((max.x - min.x)/2.0 * UFloat(fontSize))
        textNode.position.y = -UFloat(height/2.0)
        textNode.position.z = UFloat(depth/2.0 + 0.2)
        textNode.renderingOrder = 1
        textNode.eulerAngles.x = -.pi/2.0
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        group.addChildNode(textNode)
        group.eulerAngles.y = UFloat(angle)
        group.position = center
        return group
    }
    
    func nearbySphere() -> SCNNode {
        let r = (adjustment.nearbyFactor + 1.0)*radius
        let sphere = SCNSphere(radius: UFloat(r))
        sphere.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        sphere.firstMaterial?.transparency = 0.5
        let node = SCNNode(geometry: sphere)
        node.name = "Nearby sphere of " + (label.count > 0 ? label : id)
        node.position = center
        return node
    }
    
    func sectorCube(_ sector:BBoxSector = .i, _ withLabel:Bool = false) -> SCNNode {
        let dims = sectorLenghts(sector)
        let box = SCNBox(width: dims.x, height: dims.y, length: dims.z, chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        box.firstMaterial?.transparency = 0.5
        let node = SCNNode(geometry: box)
        node.name = sector.description + " sector"
        var shift:SCNVector3 = .init()
        if sector.contains(.o) {
            shift.y = (UFloat(height) + dims.y)/2.0
        } else if sector.contains(.u) {
            shift.y = (UFloat(-height) - dims.y)/2.0
        }
        if sector.contains(.r) {
            shift.x = (UFloat(-width) - dims.x)/2.0
        } else if sector.contains(.l) {
            shift.x = (UFloat(width) + dims.x)/2.0
        }
        if sector.contains(.a) {
            shift.z = (UFloat(depth) + dims.z)/2.0
        } else if sector.contains(.b) {
            shift.z = (UFloat(-depth) - dims.z)/2.0
        }
        node.position = center + shift
        if withLabel {
            let text = SCNText(string: sector.description, extrusionDepth:0.0)
            text.firstMaterial?.diffuse.contents = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.0)
            text.firstMaterial?.lightingModel = .constant
            let textNode = SCNNode(geometry: text)
            let fontSize = Float(0.01)
            let (min, max) =  textNode.boundingBox
            textNode.position.x =  -((max.x - min.x)/2.0 * UFloat(fontSize))
            textNode.position.y = -UFloat(20*fontSize)
            textNode.position.z = UFloat(0.0)
            textNode.renderingOrder = 1
            //textNode.eulerAngles.x = -.pi/2.0
            textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
            node.addChildNode(textNode)
        }
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
