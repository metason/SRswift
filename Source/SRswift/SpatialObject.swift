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

public class SpatialObject {
    /// non-spatial characteristics, to distinguish object references
    public var id:String = "" // unique id: UUID of source or own generated unique id
    public var existence:SpatialExistence = .real
    public var cause:ObjectCause = .unknown
    public var label:String = "" // name or label
    public var type:String = "" // class
    public var look:String = "" // textual description of appearance: color, bright/dark, dull/shiny, metallic, transparent, ...
    public var data:Dictionary<String,Any>? = nil // auxiliary data
    public var created:Date // creation time
    public var updated:Date // last update time
    /// spatial characteristics
    private var position:SCNVector3 = SCNVector3() // base center point at bottom, use setPosition() or setCenter()
    public var width:Float = 0.0
    public var height:Float = 0.0
    public var depth:Float = 0.0
    public var angle:Float = 0.0 // rotation around y axis in radiants, counter-clockwise
    public var immobile:Bool = false
    public var velocity:SCNVector3 = SCNVector3() // velocity vector, is calculated via setPosition() over time
    public var confidence = ObjectConfidence()
    public var shape:ObjectShape = .unknown
    public var visible:Bool = false // in screen
    public var focused:Bool = false // in center of screen, for some time
    public var context:SpatialReasoner? = nil // optional, defines fact base and adjustment settings
    
    /// derived attributes
    public var center:SCNVector3 {
        return position + SCNVector3(0.0, height/2.0, 0.0)
    }
    public var pos:SCNVector3 {
        return position
    }
    public var yaw:Float { // in degrees counter-clockwise of WCS
        return angle * 180.0 / .pi
    }
    public var azimuth:Float { // in degrees clockwise of GCS as ±360°
        if context != nil {
            return -(yaw + Float(atan2(context!.north.dy, context!.north.dx) * 180.0 / .pi) - 90.0).truncatingRemainder(dividingBy: 360.0)
        }
        return 0.0
    }
    public var thin:Bool {
        return thin() > 0
    }
    public var long:Bool {
        return long() > 0
    }
    public var equilateral:Bool {
        if long(ratio: 1.1) == 0 {
            return true
        }
        return false
    }
    public var real:Bool {
        return existence == .real
    }
    public var virtual:Bool {
        return existence == .virtual
    }
    public var conceptual:Bool {
        return existence == .conceptual
    }
    public var perimeter:Float { // footprint perimeter
        return (depth+width) * 2.0
    }
    public var footprint:Float { // base area, floor space
        return depth*width
    }
    public var frontface:Float { // front area
        return height*width
    }
    public var sideface:Float { // side area
        return height*depth
    }
    public var surface:Float { // total surface of bbox
        return (height*width + depth*width + height*depth) * 2.0
    }
    public var volume:Float {
        return depth*width*height
    }
    // sphere radius from center comprising body volume
    public var radius:Float {
        return SCNVector3(x:UFloat(width)/2.0, y:UFloat(depth)/2.0, z:UFloat(height)/2.0).length()
    }
    // circle radius on 2D base / floorground, radius from position encircling base area
    public var baseradius:Float {
        return Float(CGPoint(x:Double(width)/2.0, y:Double(depth)/2.0).length())
    }
    public var motion:MotionState {
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
    public var moving:Bool {
        return motion == .moving
    }
    public var speed:Float {
        return velocity.length()
    }
    public var observing:Bool {
        return cause == .self_tracked
    }
    public var length:Float {
        let alignment = long(ratio: 1.1)
        if alignment == 1 {
            return width
        } else if alignment == 2 {
            return height
        }
        return depth
    }
    public var lifespan:Double {
        let now = Date()
        return now.timeIntervalSince(created)
    }
    public var updateInterval:Double {
        let now = Date()
        return now.timeIntervalSince(updated)
    }
    public var adjustment:SpatialAdjustment {
        return context?.adjustment ?? defaultAdjustment
    }
    
    public static let booleanAttributes: [String] = ["immobile", "moving", "focused", "visible", "equilateral", "thin", "long", "real", "virtual", "conceptual"]
    public static let numericAttributes: [String] = ["width", "height", "depth", "w", "h", "d", "position", "x", "y", "z", "angle", "confidence"]
    public static let stringAttributes: [String] = ["id", "label", "type", "existence", "cause", "shape", "look"]

    public init(id: String, position: SCNVector3 = SCNVector3(), width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0, angle: Float = 0.0, label: String = "", confidence: Float = 0.0) {
        self.id = id
        self.label = label
        self.position = position
        self.angle = angle
        self.width = width
        self.height = height
        self.depth = depth
        self.confidence.setSpatial(confidence)
        self.created = Date()
        self.updated = self.created
    }
    
    public init(id: String, x: Float = 0.0, y: Float = 0.0, z: Float = 0.0, w: Float = 1.0, h: Float = 1.0, d: Float = 1.0, angle: Float = 0.0, label: String = "", confidence: Float = 0.0) {
        self.id = id
        self.label = label
        self.position = SCNVector3(x:UFloat(x), y:UFloat(y), z:UFloat(z))
        self.angle = angle
        self.width = w
        self.height = h
        self.depth = d
        self.confidence.setSpatial(confidence)
        self.created = Date()
        self.updated = self.created
    }

    func index() -> Int {
        if context != nil {
            return context!.objects.firstIndex{$0 === self} ?? -1
        }
        return -1
    }
    
    public static func isBoolean(attribute: String) -> Bool {
        return booleanAttributes.contains(attribute)
    }
    
    public static func createDetectedObject(id: String, label: String = "", width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.label = label.lowercased()
        object.type = label
        object.cause = .object_detected
        object.existence = .real
        object.confidence.setSpatial(0.25)
        object.immobile = false
        object.shape = .unknown
        return object
    }
    
    public static func createVirtualObject(id: String, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: .init(x: 0, y: 0, z: 0), width: width, height: height, depth: depth)
        object.cause = .user_generated
        object.existence = .virtual
        object.confidence.setSpatial(1.0)
        object.immobile = false
        return object
    }
    
    public static func createBuildingElement(id: String, type: String = "", position: SCNVector3, width: Float = 1.0, height: Float = 1.0, depth: Float = 1.0) -> SpatialObject {
        let object = SpatialObject(id: id, position: position, width: width, height: height, depth: depth)
        object.label = type.lowercased()
        object.type = type
        object.cause = .plane_detected
        object.existence = .real
        object.confidence.setSpatial(0.5)
        object.immobile = true
        object.shape = .cubical
        return object
    }
    
    public static func createBuildingElement(id: String, type: String = "", from: SCNVector3, to: SCNVector3, height: Float = 1.0, depth: Float = 0.25) -> SpatialObject {
        let midVector = SCNVector3((to.x - from.x) / 2.0, (to.y - from.y) / 2.0, (to.z - from.z) / 2.0)
        let midVectorLength = midVector.length()
        let factor = UFloat(depth / midVectorLength / 2.0)
        let normal = CGPoint(x: Double(midVector.x*factor), y: Double(midVector.z*factor)).rotate(UFloat(.pi/2.0))
        let pos = from + midVector - SCNVector3(normal.x, 0.0, normal.y)
        let object = SpatialObject(id: id, position: pos, width: midVectorLength*2.0, height: height, depth: depth)
        object.angle = -Float(atan2(midVector.z, midVector.x))
        object.label = type.lowercased()
        object.type = type
        object.cause = .user_captured
        object.existence = .real
        object.confidence.setSpatial(0.9)
        object.immobile = true
        object.shape = .cubical
        return object
    }
    
    public static func createPerson(id: String, position: SCNVector3, name: String = "") -> SpatialObject {
        /// create with average dimension of a person
        let person = SpatialObject(id: id, position: position, width: 0.46, height: 1.72, depth: 0.34)
        person.label = name
        person.cause = .self_tracked
        person.existence = .real
        person.confidence.setSpatial(1.0)
        person.immobile = false
        person.type = "Person"
        person.shape = .changing
        return person
    }
    
    // set auxiliary data
    public func setData(key: String, value: Any) {
        if data != nil {
            data![key] = value
        } else {
            data = [key: value]
        }
    }
    
    public func dataValue(_ key: String) -> Float {
        if data != nil {
            let value =  data![key]
            if value != nil {
                if let val = value as? Float {
                    return val
                }
                if let val = value as? NSNumber {
                    return val.floatValue
                }
            }
        }
        return 0
    }
    
    // Object Serialization
    // Hint: Codable extension not used to have more control
    
    // full-fledged representation for fact base
    public func asDict() -> Dictionary<String, Any> {
        var output = [
            "id": id,
            "existence": existence.rawValue,
            "cause": cause.rawValue,
            "label": label,
            "type": type,
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
    public func toAny() -> Dictionary<String, Any> {
        var output = [
            "id": id,
            "existence": existence.rawValue,
            "cause": cause.rawValue,
            "label": label,
            "type": type,
            "position": [position.x, position.y, position.z],
            "width": width,
            "height": height,
            "depth": depth,
            "angle": angle,
            "immobile": immobile,
            "velocity": [velocity.x, velocity.y, velocity.z],
            "confidence": confidence.spatial,
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
        var number:NSNumber?
        var pos = SCNVector3()
        let list = input["position"] as? [NSNumber] ?? []
        if list.count == 3 {
            pos.x = UFloat(list[0].floatValue)
            pos.y = UFloat(list[1].floatValue)
            pos.z = UFloat(list[2].floatValue)
        } else {
            number = input["x"] as? NSNumber
            let x = number?.floatValue ?? Float(self.position.x)
            number = input["y"] as? NSNumber
            let y = number?.floatValue ?? Float(self.position.y)
            number = input["z"] as? NSNumber
            let z = number?.floatValue ?? Float(self.position.z)
            pos.x = UFloat(x)
            pos.y = UFloat(y)
            pos.z = UFloat(z)
        }
        setPosition(pos)
        
        number = input["width"] as? NSNumber ?? input["w"] as? NSNumber
        self.width = number?.floatValue ?? self.width
        number = input["height"] as? NSNumber ?? input["h"] as? NSNumber
        self.height = number?.floatValue ?? self.height
        number = input["depth"] as? NSNumber ?? input["d"] as? NSNumber
        self.depth = number?.floatValue ?? self.depth
        number = input["angle"] as? NSNumber
        self.angle = number?.floatValue ?? self.angle
        self.label = input["label"] as? String ?? self.label
        self.type = input["type"] as? String ?? self.type
        number = input["confidence"] as? NSNumber
        let confidence = number?.floatValue ?? self.confidence.spatial
        self.confidence.setSpatial(confidence)
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
    
    public func desc() -> String {
        var str:String = ""
        if !label.isEmpty && label != id {
            str = str + "\(label), "
        }
        if !type.isEmpty {
            str = str + "\(type), "
        }

        str = str + String(format: "%.2f/", position.x) + String(format: "%.2f/", position.y) + String(format: "%.2f, ", position.z)
        str = str + String(format: "%.2fx", width) + String(format: "%.2fx", depth) + String(format: "%.2f, ", height)
        str = str + String(format: "𝜶:%.1f°", yaw)
        return str
    }
    
    public func setPosition(_ pos: SCNVector3) {
        let interval = updateInterval
        if interval > 0.003 && !immobile {
            let prevPos = position
            velocity = (pos - prevPos) / Float(interval)
        }
        position = pos
    }
    
    public func setCenter(_ ctr: SCNVector3) {
        setPosition(.init(x: ctr.x, y: ctr.y - UFloat(height/2.0), z: ctr.z))
    }
    
    public func rotShift(_ rad: Float, dx:Float, dy:Float = 0.0, dz:Float = 0.0) {
        //print("\(rad) \(dx) \(dy) \(dz)")
        let rotsin = sinf(rad)
        let rotcos = cosf(rad)
        let rx = dx * rotcos - dz * rotsin
        let rz = dx * rotsin + dz * rotcos
        let vector = SCNVector3(rx, dy, rz)
        position = position + vector
    }
    
    public func setYaw(_ degrees: Float) {
        angle = degrees * .pi / 180.0
    }
    
    // returns 0 when no dominant direction, else axis direction x-y-z as 1-2-3
    public func mainDirection() -> Int {
        return long()
    }
    
    // if not thin returns 0, else thiness direction x-y-z as 1-2-3
    public func thin(ratio: Float = defaultAdjustment.thinRatio) -> Int {
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
    public func long(ratio: Float = defaultAdjustment.longRatio) -> Int {
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
    
    public func lowerPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: Double(width)/2.0, y: Double(depth)/2.0)
        var p1 = CGPoint(x: Double(-width)/2.0, y: Double(depth)/2.0)
        var p2 = CGPoint(x: Double(-width)/2.0, y: Double(-depth)/2.0)
        var p3 = CGPoint(x: Double(width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p0 = p0.rotate(UFloat(-angle))
            p1 = p1.rotate(UFloat(-angle))
            p2 = p2.rotate(UFloat(-angle))
            p3 = p3.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y, z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y, z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y, z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y, z:UFloat(p3.y) + UFloat(vector.z))
        ]
    }
    
    public func upperPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: Double(width)/2.0, y: Double(depth)/2.0)
        var p1 = CGPoint(x: Double(-width)/2.0, y: Double(depth)/2.0)
        var p2 = CGPoint(x: Double(-width)/2.0, y: Double(-depth)/2.0)
        var p3 = CGPoint(x: Double(width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p0 = p0.rotate(UFloat(-angle))
            p1 = p1.rotate(UFloat(-angle))
            p2 = p2.rotate(UFloat(-angle))
            p3 = p3.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p3.y) + UFloat(vector.z))
        ]
    }
    
    public func frontPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: Double(width)/2.0, y: Double(depth)/2.0)
        var p1 = CGPoint(x: Double(-width)/2.0, y: Double(depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p0 = p0.rotate(UFloat(-angle))
            p1 = p1.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y, z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y, z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p0.y) + UFloat(vector.z))
        ]
    }
    
    public func backPoints(local:Bool = false) -> [SCNVector3] {
        var p2 = CGPoint(x: Double(-width)/2.0, y: Double(-depth)/2.0)
        var p3 = CGPoint(x: Double(width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p2 = p2.rotate(UFloat(-angle))
            p3 = p3.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y, z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y, z:UFloat(p3.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p3.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p2.y) + UFloat(vector.z))
        ]
    }
    
    public func rightPoints(local:Bool = false) -> [SCNVector3] {
        var p1 = CGPoint(x: Double(-width)/2.0, y: Double(depth)/2.0)
        var p2 = CGPoint(x: Double(-width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p1 = p1.rotate(UFloat(-angle))
            p2 = p2.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y, z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y, z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p1.y) + UFloat(vector.z))
        ]
    }
    
    public func leftPoints(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: Double(width)/2.0, y: Double(depth)/2.0)
        var p3 = CGPoint(x: Double(width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p0 = p0.rotate(UFloat(-angle))
            p3 = p3.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y, z:UFloat(p3.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y, z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p3.y) + UFloat(vector.z))
        ]
    }
    
    public func points(local:Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: Double(width)/2.0, y: Double(depth)/2.0)
        var p1 = CGPoint(x: Double(-width)/2.0, y: Double(depth)/2.0)
        var p2 = CGPoint(x: Double(-width)/2.0, y: Double(-depth)/2.0)
        var p3 = CGPoint(x: Double(width)/2.0, y: Double(-depth)/2.0)
        var vector = SCNVector3()
        if local == false {
            p0 = p0.rotate(UFloat(-angle))
            p1 = p1.rotate(UFloat(-angle))
            p2 = p2.rotate(UFloat(-angle))
            p3 = p3.rotate(UFloat(-angle))
            vector = position
        }
        return [
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y, z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y, z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y, z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y, z:UFloat(p3.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p0.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p0.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p1.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p1.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p2.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p2.y) + UFloat(vector.z)),
            SCNVector3(x:UFloat(p3.x) + UFloat(vector.x), y:vector.y+UFloat(height), z:UFloat(p3.y) + UFloat(vector.z))
        ]
    }
    
    public func distance(_ to: SCNVector3) -> Float {
        return (to - center).length()
    }
    
    public func baseDistance(_ to: SCNVector3) -> Float {
        var point = to
        point.y = position.y
        return (point - position).length()
    }
    
    // transfer point into local coordinate system
    public func intoLocal(pt: SCNVector3) -> SCNVector3 {
        let vx = Float(pt.x - position.x)
        let vz = Float(pt.z - position.z)
        let rotsin = sinf(angle)
        let rotcos = cosf(angle)
        let x = vx * rotcos - vz * rotsin
        let z = vx * rotsin + vz * rotcos
        return SCNVector3(x: UFloat(x), y: pt.y - position.y, z: UFloat(z))
    }
    
    // transfer points into local coordinate system
    public func intoLocal(pts: [SCNVector3]) -> [SCNVector3] {
        var result = [SCNVector3]()
        let rotsin = sinf(angle)
        let rotcos = cosf(angle)
        for pt in pts {
            let vx = Float(pt.x - position.x)
            let vz = Float(pt.z - position.z)
            let x = vx * rotcos - vz * rotsin
            let y = vx * rotsin + vz * rotcos
            result.append(SCNVector3(x: UFloat(x), y: pt.y - position.y, z: UFloat(y)))
        }
        return result
    }
    
    public func rotate(pts: [SCNVector3], by angle: Float) -> [SCNVector3] {
        var result = [SCNVector3]()
        let rotsin = UFloat(sinf(angle))
        let rotcos = UFloat(cosf(angle))
        for pt in pts {
            let x = pt.x * rotcos - pt.z * rotsin
            let y = pt.x * rotsin + pt.z * rotcos
            result.append(SCNVector3(x: UFloat(x), y: pt.y, z: UFloat(y)))
        }
        return result
    }
    
    // point must be transformed upfront into local object coordinate system
    // nearBy: check for point is nearby
    // epsilon: shift in bbox border, negative number decreases inner zone
    public func sectorOf(point: SCNVector3, nearBy:Bool = false, epsilon:Float = -100.0) -> BBoxSector {
        var zone = BBoxSector()
        if nearBy {
            var pt = point
            pt.y = pt.y - UFloat(height/2.0)
            let distance = pt.length()
            if distance > nearbyRadius() {
                return zone
            }
        }
        let delta = epsilon > -99.0 ? UFloat(epsilon) : UFloat(context?.adjustment.maxGap ?? defaultAdjustment.maxGap)
        if point.x <= UFloat(width)/2.0 + delta && -point.x <= UFloat(width)/2.0 + delta &&
            point.z <= UFloat(depth)/2.0 + delta && -point.z <= UFloat(depth)/2.0 + delta &&
            point.y <= UFloat(height) + delta && point.y >= -delta {
            zone.insert(.i)
            return zone
        }
        if point.x + delta > UFloat(width)/2.0 {
            zone.insert(.l)
        } else if -point.x + delta > UFloat(width)/2.0 {
            zone.insert(.r)
        }
        if point.z + delta > UFloat(depth)/2.0 {
            zone.insert(.a)
        } else if -point.z + delta > UFloat(depth)/2.0 {
            zone.insert(.b)
        }
        if point.y + delta > UFloat(height) {
            zone.insert(.o)
        } else if point.y - delta < 0.0 {
            zone.insert(.u)
        }
        return zone
    }
    
    public func nearbyRadius() -> Float {
        switch adjustment.nearbySchema {
        case .fixed:
            return adjustment.nearbyFactor
        case .circle:
            return min(baseradius*adjustment.nearbyFactor, adjustment.nearbyLimit)
        case .sphere:
            return min(radius*adjustment.nearbyFactor, adjustment.nearbyLimit)
        case .perimeter:
            return min((height+width)*adjustment.nearbyFactor, adjustment.nearbyLimit)
        case .area:
            return min(height*width*adjustment.nearbyFactor, adjustment.nearbyLimit)
        }
    }
    
    public func sectorLenghts(_ sector: BBoxSector = .i) -> SCNVector3 {
        //print(sector, adjustment.sectorFactor, adjustment.sectorLimit, width, height, depth, adjustment.sectorSchema)
        var result = SCNVector3(x: UFloat(width), y: UFloat(height), z: UFloat(depth))
        if sector.contains(.a) || sector.contains(.b) {
            switch adjustment.sectorSchema {
            case .fixed: result.z = UFloat(adjustment.sectorFactor)
            case .area: result.z = UFloat(min(height*width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.z = UFloat(min(depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.z = UFloat(min(height+width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.z = UFloat(min(nearbyRadius(), adjustment.sectorLimit))
            }
        }
        if sector.contains(.l) || sector.contains(.r) {
            switch adjustment.sectorSchema {
            case .fixed: result.x = UFloat(adjustment.sectorFactor)
            case .area: result.x = UFloat(min(height*depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.x = UFloat(min(width*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.x = UFloat(min(height+depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.x = UFloat(min(nearbyRadius(), adjustment.sectorLimit))
            }
        }
        if sector.contains(.o) || sector.contains(.u) {
            switch adjustment.sectorSchema {
            case .fixed: result.y = UFloat(adjustment.sectorFactor)
            case .area: result.y = UFloat(min(width*depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .dimension: result.y = UFloat(min(height*adjustment.sectorFactor, adjustment.sectorLimit))
            case .perimeter: result.y = UFloat(min(width+depth*adjustment.sectorFactor, adjustment.sectorLimit))
            case .nearby: result.y = UFloat(min(nearbyRadius(), adjustment.sectorLimit))
            }
        }
        return result
    }
    
    public func topologies(subject: SpatialObject) -> [SpatialRelation] {
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
        var isDisjoint = true
        var isConnected = false
        
        /// calculations in local object space
        let localPts = intoLocal(pts: subject.points())
        var zones = [BBoxSector]()
        for pt in localPts {
            zones.append(sectorOf(point: pt, nearBy: false, epsilon: 0.00001))
        }
        let localCenter = intoLocal(pt: subject.center)
        var centerZone = sectorOf(point: localCenter, nearBy: false, epsilon: -adjustment.maxGap)
        
        /// nearness evaluated by center
        if centerDistance < subject.nearbyRadius() + nearbyRadius() {
            gap = centerDistance
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .near, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else {
            relation = SpatialRelation(subject: subject, predicate: .far, object: self, delta: centerDistance, angle: theta)
            result.append(relation)
        }
        
        /// basic adjacancy in relation to center of object bbox
        if centerZone.contains(.l) {
            gap = Float(localCenter.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .left, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.r) {
            gap = Float(-localCenter.x) - width/2.0 - subject.width/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .right, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.a) {
            gap = Float(localCenter.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .ahead, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.b) {
            gap = Float(-localCenter.z) - depth/2.0 - subject.depth/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .behind, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        if centerZone.contains(.o) {
            gap = Float(localCenter.y) - subject.height/2.0 - height
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .above, object: self, delta: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.u) {
            gap = Float(-localCenter.y) - subject.height/2.0
            minDistance = gap
            relation = SpatialRelation(subject: subject, predicate: .below, object: self, delta: gap, angle: theta)
            result.append(relation)
        }
        
        /// side-related adjacancy in relation to object bbox
        centerZone = sectorOf(point: localCenter, nearBy: true, epsilon: -adjustment.maxGap)
        var aligned = false // orthogonal aligned
        var isBeside = false
        if centerZone != .i {
            if isAligned(angle: theta, alignment: .pi/2.0, epsilon: adjustment.maxAngleDelta) {
                aligned = true
            }
            var min:Float = Float.greatestFiniteMagnitude
            if centerZone == .l {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.x) - width/2.0)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    isBeside = true
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
                    isBeside = true
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
                        }
                    }
                    relation = SpatialRelation(subject: subject, predicate: .upperside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
                
            } else if centerZone == .u {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.y))
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    minDistance = min
                    if min <= adjustment.maxGap {
                        relation = SpatialRelation(subject: subject, predicate: .beneath, object: self, delta: min, angle: theta)
                        result.append(relation)
                    }
                    relation = SpatialRelation(subject: subject, predicate: .lowerside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .a {
                for pt in localPts {
                    min = Float.minimum(min, Float(pt.z) - depth/2.0)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    isBeside = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .frontside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            } else if centerZone == .b {
                for pt in localPts {
                    min = Float.minimum(min, Float(-pt.z) - depth/2.0)
                }
                if min >= 0.0 {
                    canNotOverlap = true
                    isBeside = true
                    minDistance = min
                    relation = SpatialRelation(subject: subject, predicate: .backside, object: self, delta: min, angle: theta)
                    result.append(relation)
                }
            }
            if isBeside {
                relation = SpatialRelation(subject: subject, predicate: .beside, object: self, delta: minDistance, angle: theta)
                result.append(relation)
            }
        }
        
        /// check for assembly
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
                }
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
                //print("min:max: \(minX):\(maxX) \(minY):\(maxY) \(minZ):\(maxZ) ")
                if !canNotOverlap {
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
                var ylap = height /// calc overlap in y
                if maxY < height && minY > 0 {
                    ylap = maxY - minY
                } else {
                    if minY > 0 {
                        ylap = abs(height - minY)
                    } else {
                        ylap = abs(maxY)
                    }
                }
                var xlap = width /// calc overlap in x
                if minX < width/2.0 + adjustment.maxGap && maxX > -width/2.0 - adjustment.maxGap {
                    if maxX < width/2.0 && minX > -width/2.0 {
                        xlap = maxX - minX
                    } else {
                        if minX > -width/2.0 - adjustment.maxGap {
                            xlap = abs(width/2.0 - minX)
                        } else {
                            xlap = abs(maxX + width/2.0)
                        }
                    }
                } else {
                    xlap = -1
                }
                var zlap = depth /// calc overlap in z
                if minZ < depth/2.0 + adjustment.maxGap && maxZ > -depth/2.0 - adjustment.maxGap {
                    if maxZ < depth/2.0 && minZ > -depth/2.0 {
                        zlap = maxZ - minZ
                    } else {
                        if minZ > -depth/2.0 {
                            zlap = abs(depth/2.0 - minZ)
                        } else {
                            zlap = abs(maxZ + depth/2.0)
                        }
                    }
                } else {
                    zlap = -1
                }
                
                if  minY < height + adjustment.maxGap && maxY > -adjustment.maxGap {
                    gap = min(xlap, zlap)
                    if !aligned && gap > 0.0 && gap < adjustment.maxGap {
                        if (abs(maxX + width/2.0) <  adjustment.maxGap) || (abs(minX - width/2.0) < adjustment.maxGap) ||
                            (abs(maxZ + depth/2.0) < adjustment.maxGap) || (abs(minZ - depth/2.0) < adjustment.maxGap) {
                            relation = SpatialRelation(subject: subject, predicate: .touching, object: self, delta: gap, angle: theta)
                            result.append(relation)
                            if !isConnected && context?.deduce.connectivity ?? true {
                                relation = SpatialRelation(subject: subject, predicate: .by, object: self, delta: gap, angle: theta)
                                result.append(relation)
                                isConnected = true
                            }
                        }
                    } else {
                        //print("alligned assembly \(subject.id) - ? - \(id): \(xlap) \(ylap) \(zlap)")
                        if xlap >= 0.0 && zlap >= 0.0 {
                            if ylap > adjustment.maxGap && gap < adjustment.maxGap { /// beside
                                if xlap > adjustment.maxGap || zlap > adjustment.maxGap {
                                    relation = SpatialRelation(subject: subject, predicate: .meeting, object: self, delta: max(xlap, zlap), angle: theta)
                                    result.append(relation)
                                    if !isConnected && context?.deduce.connectivity ?? true && subject.volume < volume {
                                        relation = SpatialRelation(subject: subject, predicate: .at, object: self, delta: gap, angle: theta)
                                        result.append(relation)
                                        isConnected = true
                                    }
                                } else {
                                    relation = SpatialRelation(subject: subject, predicate: .touching, object: self, delta: gap, angle: theta)
                                    result.append(relation)
                                    if !isConnected && context?.deduce.connectivity ?? true {
                                        relation = SpatialRelation(subject: subject, predicate: .by, object: self, delta: gap, angle: theta)
                                        result.append(relation)
                                        isConnected = true
                                    }
                                }
                            } else { /// ontop or underneath
                                gap = ylap
                                if xlap > adjustment.maxGap && zlap > adjustment.maxGap {
                                    relation = SpatialRelation(subject: subject, predicate: .meeting, object: self, delta: gap, angle: theta)
                                    result.append(relation)
                                } else {
                                    relation = SpatialRelation(subject: subject, predicate: .touching, object: self, delta: gap, angle: theta)
                                    result.append(relation)
                                }
                            }
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
        
        /// orientation
        if abs(theta) < adjustment.maxAngleDelta {
            gap = Float(localCenter.z)
            relation = SpatialRelation(subject: subject, predicate: .aligned, object: self, delta: gap, angle: theta)
            result.append(relation)
            let frontGap = Float(localCenter.z) + subject.depth/2.0 - depth/2.0
            if abs(frontGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .frontaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let backGap = Float(localCenter.z) - subject.depth/2.0 + depth/2.0
            if abs(backGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .backaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let rightGap = Float(localCenter.x) - subject.width/2.0 + width/2.0
            if abs(rightGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .rightaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
            let leftGap = Float(localCenter.x) + subject.width/2.0 - width/2.0
            if abs(leftGap) < adjustment.maxGap {
                relation = SpatialRelation(subject: subject, predicate: .leftaligned, object: self, delta: frontGap, angle: theta)
                result.append(relation)
            }
        } else {
            gap = centerDistance
            if isAligned(angle: theta, alignment: .pi, epsilon: adjustment.maxAngleDelta) {
                relation = SpatialRelation(subject: subject, predicate: .opposite, object: self, delta: gap, angle: theta)
                result.append(relation)
            } else if aligned {
                relation = SpatialRelation(subject: subject, predicate: .orthogonal, object: self, delta: gap, angle: theta)
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
    
    public func similarities(subject: SpatialObject) -> [SpatialRelation] {
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
    
    public func comparisons(subject:SpatialObject) -> [SpatialRelation] {
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
    public func sector(subject: SpatialObject, nearBy:Bool = false, epsilon:Float = 0.0) -> SpatialRelation {
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let localCenter = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: localCenter, nearBy: nearBy, epsilon: epsilon)
        let theta = subject.angle - angle
        let pred = SpatialPredicate.named(centerZone.description)
        return SpatialRelation(subject:subject, predicate: pred, object:self, delta: centerDistance, angle:theta)
    }
    
    public func asseen(subject: SpatialObject, observer: SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        let posVector = subject.position - position
        let posDistance = posVector.length()
        let radiusSum = baseradius + subject.baseradius
        /// check for nearby
        if posDistance < subject.nearbyRadius() + nearbyRadius() {
            var centerObject = observer.intoLocal(pt: self.center)
            var centerSubject = observer.intoLocal(pt: subject.center)
            if centerSubject.z > 0.0 && centerObject.z > 0.0 { // both are ahead of observer
                // turn both by view angle to become normal to observer
                let rad = Float(atan2(centerObject.x, centerObject.z))
                let list = rotate(pts: [centerObject, centerSubject], by: -rad)
                centerObject = list[0]
                centerSubject = list[1]
                let xgap = Float(centerSubject.x - centerObject.x)
                let zgap = Float(centerSubject.z - centerObject.z)
                if abs(xgap) > min(width/2.0, depth/2.0) && abs(zgap) < radiusSum { 
                    if xgap > 0.0 {
                        let relation = SpatialRelation(subject: subject, predicate: .seenleft, object: self, delta: abs(xgap), angle: 0.0)
                        result.append(relation)
                    } else {
                        let relation = SpatialRelation(subject: subject, predicate: .seenright, object: self, delta: abs(xgap), angle: 0.0)
                        result.append(relation)
                    }
                }
                if abs(zgap) > min(width/2.0, depth/2.0) && abs(xgap) < radiusSum {
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
    
    public func relate(subject: SpatialObject, topology:Bool = false, similarity:Bool = false, comparison:Bool = false) -> [SpatialRelation] {
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
    
    public func relationValue(_ relval: String, pre: [Int]) -> Float {
        let list = relval.split(separator: ".").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        if list.count != 2 && context == nil {
            return 0.0
        }
        let predicate = list[0]
        let attribute = list[1]
        var result: Float = 0.0
        // TODO: take min instead of last?
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
    
    public func bboxCube(color: CGColor) -> SCNNode {
        let name = label.isEmpty ? id : label
        let group = SCNNode()
        group.name = id
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
        textNode.position.x =  -((max.x - min.x)/2.0 * UFloat(fontSize))
        textNode.position.y = -UFloat(height*0.48)
        textNode.position.z = UFloat(depth/2.0 + 0.2)
        textNode.renderingOrder = 1
        textNode.eulerAngles.x = -.pi/2.0
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        group.addChildNode(textNode)
        group.eulerAngles.y = UFloat(angle)
        group.position = center
        return group
    }
    
    public func nearbySphere() -> SCNNode {
        let r = nearbyRadius()
        let sphere = SCNSphere(radius: Double(r))
        sphere.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        sphere.firstMaterial?.transparency = 0.5
        let node = SCNNode(geometry: sphere)
        node.name = "Nearby sphere of " + (label.count > 0 ? label : id)
        node.position = center
        return node
    }
    
    public func sectorCube(_ sector: BBoxSector = .i, _ withLabel:Bool = false) -> SCNNode {
        let dims = sectorLenghts(sector)
        let box = SCNBox(width: CGFloat(UFloat(dims.x)), height: CGFloat(dims.y), length: CGFloat(dims.z), chamferRadius: 0.0)
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
    
    public func pointNodes(_ pts: [SCNVector3] = []) -> SCNNode {
        let points = pts.isEmpty ? self.points() : pts
        let group = SCNNode()
        group.name = "BBox corners of " + (label.count > 0 ? label : id)
        for point in points {
            let geometry = SCNSphere(radius: 0.01)
            geometry.firstMaterial?.diffuse.contents = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.0)
            let node = SCNNode(geometry: geometry)
            node.position = point
            group.addChildNode(node)
        }
        return group
    }
    
    static func export3D(to url:URL, nodes: [SCNNode]) {
        let scene = SCNScene()
        for node in nodes {
            scene.rootNode.addChildNode(node)
        }
        scene.write(to: url, options: nil, delegate: nil, progressHandler: nil)
    }
    
}
