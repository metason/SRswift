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
    var position:SCNVector3 = SCNVector3() // bottom center point, use setPosition()
    var width:Float = 0.0
    var height:Float = 0.0
    var depth:Float = 0.0
    var angle:Float = 0.0 // rotation around y axis in radiants
    var immobile:Bool = false
    var velocity:SCNVector3 = SCNVector3() // velocity vector, is calculated via setPosition()
    var confidence = ObjectConfidence()
    var shape:ObjectShape = .unknown
    var visible:Bool = false // in screen
    var focused:Bool = false // in center of screen, for some timex
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
    var equilateral:Bool {
        if thin(ratio: 1.1) == 0 {
            return true
        }
        return false
    }
    var perimeter:Float {
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
    // radius from center comprising body volume
    var radius:Float {
        return SCNVector3(x:UFloat(width)/2.0, y:UFloat(depth)/2.0, z:UFloat(height)/2.0).length()
    }
    // radius of 2D floorground, radius from position encircling base area
    var groundradius:Float {
        return Float(CGPoint(x:Double(width)/2.0, y:Double(depth)/2.0).length())
    }
    var motion:MotionState {
        if immobile {
            return .stationary
        }
        if confidence.spatial > 0.5 {
            if velocity.length() > maxDeviation.gap {
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
        let alignment = thin(ratio: 1.1)
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
    var maxDeviation:FuzzyDeviation {
        return container?.maxDeviation ?? fuzzyDeviation
    }
    nonisolated(unsafe) static var north = SCNVector3(0.0, 0.0, -1.0) // north direction
    static let booleanAttributes: [String] = ["immobile", "moving", "focused", "visible", "equilateral", "thin"]
    
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
        return thin()
    }
    
    // if not thin returns 0, else axis direction x-y-z as 1-2-3
    func thin(ratio:Float = fuzzyDeviation.thinRatio) -> Int {
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
}
