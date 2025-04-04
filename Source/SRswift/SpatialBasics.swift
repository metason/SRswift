//
//  SpatialBasics.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 25.11.2024.
//

import Foundation

// Calculation schema to determine nearby radius
public enum NearbySchema {
    case fixed // use nearbyFactor as fix nearby radius
    case circle // use base circle radius of bbox multiplied with nearbyFactor
    case sphere // use sphere radius of bbox multiplied with nearbyFactor
    case perimeter // use base perimeter multiplied with nearbyFactor
    case area // use area multiplied with nearbyFactor
}

// Calculation schema to determine sector size for extruding bbox area
public enum SectorSchema {
    case fixed // use sectorFactor as fix sector lenght for extruding area
    case dimension // use same dimension as object bbox multiplied with sectorFactor
    case perimeter // use base perimeter multiplied with sectorFactor
    case area // use area multiplied with sectorFactor
    case nearby // use nearby settings of spatial adjustment for extruding
}

// Set adjustment parameters before executing pipeline or calling relate() method.
// SpatialReasoner has its own local adjustment that should be set upfront.
public class SpatialAdjustment {
    // Max deviations
    public var maxGap:Float = 0.02 /// max distance of deviation in all directions in meters
    public var maxAngleDelta:Float = 0.05 * .pi /// max angle delta in both directions in radiants
    // Sector size
    public var sectorSchema:SectorSchema = .nearby
    public var sectorFactor:Float = 1.0 /// multiplying result of claculation schema
    public var sectorLimit:Float = 2.5 /// maximal length
    // Vicinity
    public var nearbySchema:NearbySchema = .circle
    public var nearbyFactor:Float = 2.0 /// multiplying radius sum of object and subject (relative to size) as max distance
    public var nearbyLimit:Float = 2.5 /// maximal absolute distance
    // Proportions
    public var longRatio:Float = 4.0 /// one dimension is factor larger than both others
    public var thinRatio:Float = 10.0 /// one dimension is 1/factor smaller than both others
    
    /// get/set max delta of orientation in degrees
    public var yaw:Float {
        return maxAngleDelta * 180.0 / .pi
    }
    public func setYaw(_ degrees:Float) {
        maxAngleDelta = degrees * .pi / 180.0
    }
    
    public init(gap:Float = 0.02, angle:Float = 0.05 * .pi, sectorSchema:SectorSchema = .nearby, sectorFactor:Float = 1.0, sectorLimit:Float = 2.5, nearbySchema:NearbySchema = .circle, nearbyFactor:Float = 2.0, nearbyLimit:Float = 2.5) {
        self.maxGap = gap
        self.maxAngleDelta = angle
        self.sectorSchema = sectorSchema
        self.sectorFactor = sectorFactor
        self.sectorLimit = sectorLimit
        self.nearbySchema = nearbySchema
        self.nearbyFactor = nearbyFactor
        self.nearbyLimit = nearbyLimit
    }
}

// Default adjustment only used when no SpatialReasoner builds context
nonisolated(unsafe) public var defaultAdjustment = SpatialAdjustment()
nonisolated(unsafe) public var tightAdjustment = SpatialAdjustment(gap:0.002, angle:0.01 * .pi, sectorFactor:0.5)

public class SpatialPredicateCategories {
    public var topology = true
    public var connectivity = true
    public var comparability = false
    public var similarity = false
    public var sectoriality = false
    public var visibility = false
    public var geography = false
}

public class ObjectConfidence { // plausability values between 0.0 and 1.0
    public var pose:Float = 0.0 // plausability of position and orientation of (partially) detected part
    public var dimension:Float = 0.0  // plausability of size of spatial object
    public var label:Float = 0.0  // plausability of classification: label, type
    public var look:Float = 0.0  // plausability of look and shape
    public var spatial:Float {
        return (pose + dimension)/2.0
    }
    public func setSpatial(_ value:Float) {
        pose = value
        dimension = value
    }
    public func asDict() -> Dictionary<String, Float> {
        return ["pose":pose, "dimension":dimension, "label":label, "look":look]
    }
}

// Searchable, metric, spatio-temporal attributes
public enum SpatialAtribute: String {
    case none
    case width
    case height
    case depth
    case length
    case angle
    case yaw
    case azimuth // deviation from north direction
    case footprint // base surface
    case frontface // front surface
    case sideface // side surface
    case surface // total bbox surface
    case volume
    case perimeter
    case baseradius // radius of 2D floorground circle
    case radius // radius of sphere including 3D bbox around center
    case speed
    case confidence
    case lifespan
}

public enum SpatialExistence: String {
    case undefined
    case real // visual, detected, real object
    case virtual // visual, created, virtual object
    case conceptual // non-visual, conceptual area, e.g., corner, zone, sensing area, region of interest, interaction field
    case aggregational // non-visual part-of group, container
    
    public static func named(_ name: String) -> SpatialExistence {
        return SpatialExistence(rawValue: name) ?? .undefined
    }
}

public enum ObjectCause : String {
    case unknown
    case plane_detected // on-device plane detection
    case object_detected // on-device object detection
    case self_tracked // device of user registered and tracked in space
    case user_captured // captured by user
    case user_generated // generated by user
    case rule_produced // produced by rule or by program logic
    case remote_created // created by remote service
    
    public static func named(_ name: String) -> ObjectCause {
        return ObjectCause(rawValue: name) ?? .unknown
    }
}

public enum MotionState: String {
    case unknown
    case stationary // immobile
    case idle // idle
    case moving // moving
}

public enum ObjectShape : String {
    case unknown
    case planar // plane, thin box
    case cubical // box
    case spherical
    case cylindrical // along longest dimension when long
    case conical
    case irregular // complex shape
    case changing // changing shape, e.g., of creature
    
    public static func named(_ name: String) -> ObjectShape {
        return ObjectShape(rawValue: name) ?? .unknown
    }
}

// TODO: operable?
public enum ObjectHandling : String {
    case none
    case movable
    case slidable
    case liftable
    case portable
    case rotatable
    case openable
    //case tangible // ?? user-dep.
}

