//
//  SpatialUtils.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//
//  Minimal utils for spatial reasoning, adapt if some already exist in your project

import Foundation
import SceneKit

// UFloat: Universal Float
// macOS uses CGFloats for describing CGPoint and SCNVector3, iOS uses Floats.
// In order to share the same code, this typealias allows conversion between Floats and CGFloats
#if os(macOS)
typealias UFloat = CGFloat
#else 
typealias UFloat = Float
#endif

extension CGPoint {
    
    func length() -> UFloat {
        return UFloat(sqrt(x*x + y*y))
    }
    
    func rotate(_ radians: UFloat) -> CGPoint {
        let rotationSin:Double = Double(sin(radians))
        let rotationCos:Double = Double(cos(radians))
        let x:Double = self.x * rotationCos - self.y * rotationSin
        let y:Double = self.x * rotationSin + self.y * rotationCos
        return CGPoint(x: x, y: y)
    }
    
    func rotate(_ radians: UFloat, pivot: CGPoint) -> CGPoint {
        let shiftedX:Double = self.x - pivot.x
        let shiftedY:Double = self.y - pivot.y
        let rotationSin:Double = Double(sin(radians))
        let rotationCos:Double = Double(cos(radians))
        let x = Double(shiftedX * rotationCos - shiftedY * rotationSin) + pivot.x
        let y = Double(shiftedX * rotationSin + shiftedY * rotationCos) + pivot.y
        return CGPoint(x: x, y: y)
    }
}

extension SCNVector3 {
    
    func length() -> Float {
        return sqrtf(Float(x*x) + Float(y*y) + Float(z*z))
    }
    
    // sort list by distance from self
    func nearest(_ pts: [SCNVector3]) -> [SCNVector3] {
        return pts.sorted { ($0-self).length() < ($1-self).length() }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return left + (right * -1.0)
}

func *(vector: SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

/// Increments a SCNVector3 with the value of another.
func += ( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/// Decrements a SCNVector3 with the value of another.
func -= ( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

///Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/// Multiplies a SCNVector3 with another.
func *= ( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

///Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/// Divides a SCNVector3 by another.
func /= ( left: inout SCNVector3, right: SCNVector3) {
    left = left / right
}

/// Divides the x, y and z fields of a SCNVector3 by the same scalar value and returns the result as a new SCNVector3.
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / UFloat(scalar), vector.y / UFloat(scalar), vector.z / UFloat(scalar))
}

/// Divides the x, y and z of a SCNVector3 by the same scalar value.
func /= (vector: inout SCNVector3, scalar: Float) {
    vector = vector / scalar
}
