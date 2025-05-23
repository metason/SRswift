//
//  ARKitSR.swift
//  SRswift
//
//  Created by Philipp Ackermann on 20.05.2025.
//

import Foundation
import ARKit
import SRswift

class ARKitSR {
    
    static func planes2obj(anchors: [ARAnchor], floorHeight: Float = -1.6) -> [SpatialObject] {
        var list: [SpatialObject] = []
        for anchor in anchors {
            if let plane = anchor as? ARPlaneAnchor {
                var addObject = true
                let obj = SpatialObject(id: plane.identifier.uuidString)
                let anchorTransform = plane.transform
                let translation = float4x4(translation: SIMD3(plane.center[0], plane.center[1], plane.center[2]))
                var yAngle:Float = 0.0
                if #available(iOS 16.0, *) {
                    yAngle = plane.planeExtent.rotationOnYAxis
                }
                let rotation = float4x4.makeRotY(yAngle)
                let planeTransform = simd_mul(translation, rotation)
                let resultTransform = simd_mul(anchorTransform, planeTransform)
                let pos = resultTransform.position()
                obj.shape = .cubical
                if plane.alignment == .horizontal {
                    obj.width = plane.extent[0]
                    obj.height = 0.02
                    obj.depth = plane.extent[2]
                    obj.angle = resultTransform.quaternion().orientation.y
                } else if plane.alignment == .vertical {
                    obj.width = plane.extent[0]
                    obj.height = plane.extent[2]
                    obj.depth = 0.02
                    obj.angle = anchorTransform.quaternion().orientation.y
                }
                switch plane.classification {
                case .floor:
                    obj.type = "floor"
                    obj.height = 0.3
                    obj.setPosition(pos - .init(x: 0, y: 0.3, z: 0))
                case .ceiling:
                    obj.type = "ceiling"
                    obj.height = 0.3
                    obj.setPosition(pos)
                case .wall:
                    obj.type = "ceiling"
                    // TODO shift
                    let deg = obj.angle * 180.0 / .pi + 90.0
                    let shift = SCNVector3(0.15, 0.0, 0.0).rotY(pivot: SCNVector3(), degrees: -deg)
                    obj.setCenter(pos + shift)
                    obj.depth = 0.3
                case .seat:
                    if plane.alignment == .horizontal {
                        obj.type = "seat"
                        let h = pos.y - floorHeight
                        obj.height = Float(h)
                        obj.setCenter(pos - SCNVector3(0, h/2.0, 0))
                    } else {
                        obj.setCenter(pos)
                        addObject = false
                    }
                case .table:
                    if plane.alignment == .horizontal {
                        obj.type = "table"
                        let h = pos.y - floorHeight
                        obj.height = Float(h)
                        obj.setCenter(pos - SCNVector3(0, h/2.0, 0))
                        obj.shape = determineShape(plane)
                    } else {
                        obj.setCenter(pos)
                    }
                case .window:
                    obj.type = "window"
                    obj.setCenter(pos)
                case.door:
                    obj.type = "door"
                    obj.setCenter(pos)
                default:
                    obj.setCenter(pos)
                }
                obj.label = obj.type
                obj.existence = .real
                obj.cause = .plane_detected
                if addObject {
                    list.append(obj)
                }
            }
        }
        return list
    }
    
    static func determineShape(_ plane:ARPlaneAnchor) -> ObjectShape {
        if plane.geometry.boundaryVertices.count > 6 {
            let center = SCNVector3(plane.center[0], plane.center[1], plane.center[2])
            var sum:Float = 0.0
            let points = plane.geometry.boundaryVertices
            for i in 0..<points.count {
                let pt = SCNVector3(points[i].x, points[i].y, points[i].z)
                sum = sum + (pt - center).length()
            }
            let average = sum / Float(points.count)
            let delta = average * 0.125
            var isCircle = true
            for i in 0..<points.count {
                let pt = SCNVector3(points[i].x, points[i].y, points[i].z)
                if abs((pt - center).length() - average) > delta {
                    isCircle = false
                }
            }
            if isCircle {
                return .cylindrical
            }
        }
        return .cubical
    }
    
    static func user2obj(pointOfView: SCNNode, floorHeight: Float = -1.6) -> SpatialObject {
        let obj = SpatialObject(id: "ego", width: 0.5, height: 1.8, depth: 0.36)
        obj.label = "user"
        let q = pointOfView.orientation  // quaterion
        let yaw = Float(atan2f((2*q.y*q.w)-(2*q.x*q.z), 1-(2*pow(q.y,2))-(2*pow(q.z,2)))) // heading towards north
        obj.angle = Float(yaw) + .pi
        /// shift user center behind device camera
        let deg = obj.angle * 180.0 / .pi + 90.0
        let shift = SCNVector3(0.48, 0.0, 0.0).rotY(pivot: SCNVector3(), degrees: -deg)
        let pos = SCNVector3(x: pointOfView.position.x, y: floorHeight, z: pointOfView.position.z)
        obj.setPosition(pos + shift)
        obj.existence = .real
        obj.cause = .self_tracked
        return obj
    }
    
    static func item2obj(_ item: ItemElement) -> SpatialObject {
        let obj = SpatialObject(id: item.id, width: item.width(), height: item.height(), depth: item.depth())
        obj.type = item.type
        obj.setPosition(item.pivot())
        obj.setYaw(item.ptsOrientation())
        obj.label = item.subtype
        obj.cause = .user_generated
        obj.existence = .virtual
        obj.confidence.setSpatial(1.0)
        return obj
    }
    
    static func items2obj(items: [ItemElement]) -> [SpatialObject] {
        var list: [SpatialObject] = []
        for item in items {
            list.append(item2obj(item))
        }
        return list
    }

}
