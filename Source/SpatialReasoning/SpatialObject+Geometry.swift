//
//  SpatialObject+Geometry.swift
//  SpatialReasoning
//

import Foundation
import SceneKit

extension SpatialObject {
    
    func lowerPoints(local: Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0,   y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0,  y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0,  y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0,   y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y, z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y, z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y, z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y, z: UFloat(p3.y + pos.z))
        ]
    }
    
    func upperPoints(local: Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0,   y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0,  y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0,  y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0,   y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p3.y + pos.z))
        ]
    }

    func frontPoints(local: Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y,                 z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y,                 z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p0.y + pos.z))
        ]
    }

    func backPoints(local: Bool = false) -> [SCNVector3] {
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y,                 z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y,                 z: UFloat(p3.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p3.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p2.y + pos.z))
        ]
    }

    func rightPoints(local: Bool = false) -> [SCNVector3] {
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y,                 z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y,                 z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p1.y + pos.z))
        ]
    }

    func leftPoints(local: Bool = false) -> [SCNVector3] {
        var p0 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y,                 z: UFloat(p3.y + pos.z)),
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y,                 z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p3.y + pos.z))
        ]
    }

    func points(local: Bool = false) -> [SCNVector3] {
        // 8 corners (4 lower + 4 upper)
        var p0 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(depth)/2.0)
        var p1 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(depth)/2.0)
        var p2 = CGPoint(x: UFloat(-width)/2.0, y: UFloat(-depth)/2.0)
        var p3 = CGPoint(x: UFloat(width)/2.0,  y: UFloat(-depth)/2.0)
        var pos = SCNVector3()

        if !local {
            let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
            p0 = p0.rotate(UFloat(angle), pivot: pivot)
            p1 = p1.rotate(UFloat(angle), pivot: pivot)
            p2 = p2.rotate(UFloat(angle), pivot: pivot)
            p3 = p3.rotate(UFloat(angle), pivot: pivot)
            pos = position
        }

        return [
            // Lower rectangle
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y,                 z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y,                 z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y,                 z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y,                 z: UFloat(p3.y + pos.z)),
            // Upper rectangle
            SCNVector3(x: UFloat(p0.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p0.y + pos.z)),
            SCNVector3(x: UFloat(p1.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p1.y + pos.z)),
            SCNVector3(x: UFloat(p2.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p2.y + pos.z)),
            SCNVector3(x: UFloat(p3.x + pos.x), y: pos.y + UFloat(height), z: UFloat(p3.y + pos.z))
        ]
    }

    func distance(_ to: SCNVector3) -> Float {
        return (to - position).length()
    }

    func baseDistance(_ to: SCNVector3) -> Float {
        var point = to
        point.y = position.y
        return (point - position).length()
    }

    func intoLocal(pt: SCNVector3) -> SCNVector3 {
        let pivot = CGPoint(x: UFloat(position.x), y: UFloat(position.z))
        let rotated = CGPoint(x: UFloat(pt.x), y: UFloat(pt.z))
            .rotate(UFloat(-angle), pivot: pivot)
        return SCNVector3(
            x: rotated.x - position.x,
            y: pt.y - position.y,
            z: rotated.y - position.z
        )
    }

    func intoLocal(pts: [SCNVector3]) -> [SCNVector3] {
        return pts.map { intoLocal(pt: $0) }
    }

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
}
