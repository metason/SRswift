//
//  SpatialObject+SceneKit.swift
//  SpatialReasoning
//
//  SceneKit visualization extension
//

import SceneKit
import Foundation

extension SpatialObject {

    func bboxCube(color: CGColor) -> SCNNode {
        let name = label.count > 0 ? label : id
        let group = SCNNode()
        group.name = name

        let box = SCNBox(width: CGFloat(width),
                         height: CGFloat(height),
                         length: CGFloat(depth),
                         chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.transparency = 1.0 - color.alpha

        let boxNode = SCNNode(geometry: box)
        group.addChildNode(boxNode)

        // Create a front-facing label
        let text = SCNText(string: name, extrusionDepth: 0.0)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant

        let textNode = SCNNode(geometry: text)
        let fontSize: Float = 0.005
        let (minBound, maxBound) = textNode.boundingBox
        textNode.position.x = -((maxBound.x - minBound.x) / 2.0 * CGFloat(fontSize))
        textNode.position.y = -CGFloat(height / 2.0)
        textNode.position.z = CGFloat(depth / 2.0 + 0.2)
        textNode.renderingOrder = 1
        textNode.eulerAngles.x = -.pi / 2.0
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)

        group.addChildNode(textNode)
        group.eulerAngles.y = CGFloat(angle)
        group.position = center
        return group
    }

    func nearbySphere() -> SCNNode {
        let r = (maxDeviation.nearbyFactor + 1.0) * radius
        let sphere = SCNSphere(radius: CGFloat(r))
        sphere.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        sphere.firstMaterial?.transparency = 0.5

        let node = SCNNode(geometry: sphere)
        node.name = "Nearby sphere of " + (label.count > 0 ? label : id)
        node.position = center
        return node
    }

    func sectorCube(_ sector: BBoxSector = .i) -> SCNNode {
        let box = SCNBox(width: CGFloat(width),
                         height: CGFloat(height),
                         length: CGFloat(depth),
                         chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = CGColor(gray: 0.1, alpha: 0.5)
        box.firstMaterial?.transparency = 0.5

        let node = SCNNode(geometry: box)
        node.name = sector.description + " sector"

        var shift: SCNVector3 = .init()
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

    static func export3D(to url: URL, nodes: [SCNNode]) {
        let scene = SCNScene()
        for node in nodes {
            scene.rootNode.addChildNode(node)
        }
        scene.write(to: url, options: nil, delegate: nil, progressHandler: nil)
    }
}
