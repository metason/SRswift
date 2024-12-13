//
//  SpatialObject+Reasoning.swift
//  SpatialReasoning
//
//  Extension containing topology and adjacency logic for SpatialObject
//

import Foundation
import SceneKit

extension SpatialObject {
    // MARK: - Primary Methods

    /// Evaluates different topological relationships between `self` and `subject`
    func topologies(subject: SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        var gap: Float = 0.0
        var minDistance: Float = 0.0

        // Global calculations
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let radiusSum = radius + subject.radius
        var canNotOverlap = centerDistance > radiusSum
        let theta = subject.angle - angle
        var isNear = false
        var isDisjoint = true

        // Local space calculations
        let localPts = intoLocal(pts: subject.points())
        var zones = [BBoxSector]()
        for pt in localPts {
            zones.append(sectorOf(point: pt))
        }
        let centerLocal = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: centerLocal)

        // 1. Evaluate nearness
        evaluateNearness(
            subject: subject,
            centerDistance: centerDistance,
            radiusSum: radiusSum,
            theta: theta,
            isNear: &isNear,
            minDistance: &minDistance,
            result: &result
        )

        // 2. Basic adjacency
        evaluateBasicAdjacency(
            subject: subject,
            centerLocal: centerLocal,
            centerZone: centerZone,
            theta: theta,
            minDistance: &minDistance,
            result: &result
        )

        // 3. Side-related adjacency
        evaluateSideRelatedAdjacency(
            subject: subject,
            localPts: localPts,
            centerZone: centerZone,
            theta: theta,
            isNear: isNear,
            maxDeviation: maxDeviation,
            canNotOverlap: &canNotOverlap,
            minDistance: &minDistance,
            result: &result
        )

        // 4. Check for topology (inside, containing, overlapping, crossing)
        evaluateTopology(
            subject: subject,
            localPts: localPts,
            zones: zones,
            centerDistance: centerDistance,
            radiusSum: radiusSum,
            theta: theta,
            canNotOverlap: canNotOverlap,
            isDisjoint: &isDisjoint,
            result: &result
        )

        // 5. If disjoint
        if isDisjoint {
            gap = centerDistance - radiusSum
            let relation = SpatialRelation(
                subject: subject,
                predicate: .disjoint,
                object: self,
                gap: gap,
                angle: theta
            )
            result.append(relation)
        }

        // 6. Beside if near but disjoint and not above/below
        if isNear, isDisjoint, !centerZone.contains(.o), !centerZone.contains(.u) {
            let relation = SpatialRelation(
                subject: subject,
                predicate: .beside,
                object: self,
                gap: minDistance,
                angle: theta
            )
            result.append(relation)
        }

        // 7. Evaluate orientation (aligned, opposite, orthogonal)
        evaluateOrientation(
            subject: subject,
            centerDistance: centerDistance,
            radiusSum: radiusSum,
            theta: theta,
            centerLocal: centerLocal,
            result: &result
        )

        // 8. Clock predicate for Person or self-tracked real object
        evaluateClockPredicate(
            subject: subject,
            centerDistance: centerDistance,
            theta: theta,
            result: &result
        )

        return result
    }

    /// Evaluates "similarities" (e.g. same width, height, volume) between `self` and `subject`
    func similarities(subject: SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        let theta = subject.angle - angle
        
        var sameWidth: Bool = false
        var sameDepth: Bool = false
        var sameHeight: Bool = false
        
        // Evaluate same center
        evaluateSameCenter(subject: subject, theta: theta, result: &result)
        
        // Evaluate same width, depth, height
        evaluateSameWidth(subject: subject, theta: theta, sameWidth: &sameWidth, result: &result)
        evaluateSameDepth(subject: subject, theta: theta, sameDepth: &sameDepth, result: &result)
        evaluateSameHeight(subject: subject, theta: theta, sameHeight: &sameHeight, result: &result)
        
        // Evaluate same cuboid
        evaluateSameCuboid(
            subject: subject,
            theta: theta,
            sameWidth: sameWidth,
            sameDepth: sameDepth,
            sameHeight: sameHeight,
            result: &result
        )

        // Evaluate same length
        evaluateSameLength(subject: subject, theta: theta, result: &result)
        
        // Evaluate same front, side, footprint
        evaluateSameFront(subject: subject, theta: theta, result: &result)
        evaluateSameSide(subject: subject, theta: theta, result: &result)
        evaluateSameFootprint(subject: subject, theta: theta, result: &result)
        
        // Evaluate same volume (and possibly congruent)
        evaluateSameVolume(
            subject: subject,
            theta: theta,
            sameWidth: sameWidth,
            sameDepth: sameDepth,
            sameHeight: sameHeight,
            result: &result
        )
        
        // Evaluate same shape
        evaluateSameShape(subject: subject, theta: theta, result: &result)

        return result
    }

    /// Evaluates comparative relations (bigger, smaller, taller, etc.) between `self` and `subject`
    func comparisons(subject: SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        var relation: SpatialRelation
        let theta = subject.angle - angle
        var objVal: Float = 0.0
        var subjVal: Float = 0.0
        var diff: Float = 0.0

        // bigger/smaller
        objVal = volume
        subjVal = subject.volume
        diff = subjVal - objVal
        if diff > maxDeviation.gap {
            relation = SpatialRelation(subject: subject, predicate: .bigger, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > maxDeviation.gap {
            relation = SpatialRelation(subject: subject, predicate: .smaller, object: self, gap: diff, angle: theta)
            result.append(relation)
        }

        // longer/shorter
        objVal = length
        subjVal = subject.length
        diff = subjVal - objVal
        var shorterAdded = false
        if diff > maxDeviation.gap {
            relation = SpatialRelation(subject: subject, predicate: .longer, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > maxDeviation.gap {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, gap: diff, angle: theta)
            result.append(relation)
            shorterAdded = true
        }

        // taller/shorter
        objVal = height
        subjVal = subject.height
        diff = subjVal - objVal
        if diff > maxDeviation.gap {
            relation = SpatialRelation(subject: subject, predicate: .taller, object: self, gap: diff, angle: theta)
            result.append(relation)
        } else if -diff > maxDeviation.gap && !shorterAdded {
            relation = SpatialRelation(subject: subject, predicate: .shorter, object: self, gap: diff, angle: theta)
            result.append(relation)
        }

        // wider/thinner if mainDirection() == 1
        if mainDirection() == 1 {
            objVal = footprint
            subjVal = subject.footprint
            diff = subjVal - objVal
            if diff > maxDeviation.gap {
                relation = SpatialRelation(subject: subject, predicate: .wider, object: self, gap: diff, angle: theta)
                result.append(relation)
            } else if -diff > maxDeviation.gap {
                relation = SpatialRelation(subject: subject, predicate: .thinner, object: self, gap: diff, angle: theta)
                result.append(relation)
            }
        }
        return result
    }

    /// Finds the direction (sector) of the subject relative to self
    func direction(subject: SpatialObject) -> SpatialRelation {
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let center = intoLocal(pt: subject.center)
        let centerZone = sectorOf(point: center)
        let theta = subject.angle - angle
        print(centerZone.description)
        let pred = SpatialPredicate.named(centerZone.description)
        return SpatialRelation(subject: subject, predicate: pred, object: self, gap: centerDistance, angle: theta)
    }

    /// Relates both topologies, similarities, comparisons
    func relate(subject: SpatialObject, topology: Bool = true, similarity: Bool = true, comparison: Bool = true) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        if topology {
            result.append(contentsOf: topologies(subject: subject))
        }
        if similarity {
            result.append(contentsOf: similarities(subject: subject))
        }
        if comparison {
            result.append(contentsOf: comparisons(subject: subject))
        }
        return result
    }

    /// 'As seen' is a perspective-based relationship from self to subject, with observer in mind
    func asseen(subject: SpatialObject, observer: SpatialObject) -> [SpatialRelation] {
        var result = [SpatialRelation]()
        let centerVector = subject.center - center
        let centerDistance = centerVector.length()
        let radiusSum = radius + subject.radius

        if centerDistance - radiusSum < maxDeviation.nearbyLimit,
           centerDistance < ((maxDeviation.nearbyFactor + 1.0) * radiusSum) {
            let centerObject = observer.intoLocal(pt: self.center)
            let centerSubject = observer.intoLocal(pt: subject.center)
            // both ahead of observer
            if centerSubject.z > 0.0, centerObject.z > 0.0 {
                let xgap = Float(centerSubject.x - centerObject.x)
                let zgap = Float(centerSubject.z - centerObject.z)
                if abs(xgap) > maxDeviation.gap {
                    let relation = SpatialRelation(
                        subject: subject,
                        predicate: (xgap > 0.0) ? .seenleft : .seenright,
                        object: self,
                        gap: abs(xgap),
                        angle: 0.0
                    )
                    result.append(relation)
                }
                if abs(zgap) > maxDeviation.gap {
                    let relation = SpatialRelation(
                        subject: subject,
                        predicate: (zgap > 0.0) ? .atrear : .infront,
                        object: self,
                        gap: abs(zgap),
                        angle: 0.0
                    )
                    result.append(relation)
                }
            }
        }
        return result
    }

    // MARK: - Private Evaluate Helpers

    private func evaluateNearness(
        subject: SpatialObject,
        centerDistance: Float,
        radiusSum: Float,
        theta: Float,
        isNear: inout Bool,
        minDistance: inout Float,
        result: inout [SpatialRelation]
    ) {
        if centerDistance - radiusSum < maxDeviation.nearbyLimit,
           centerDistance < ((maxDeviation.nearbyFactor + 1.0) * radiusSum) {
            isNear = true
            let gap = centerDistance - radiusSum
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .near, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateBasicAdjacency(
        subject: SpatialObject,
        centerLocal: SCNVector3,
        centerZone: BBoxSector,
        theta: Float,
        minDistance: inout Float,
        result: inout [SpatialRelation]
    ) {
        var gap: Float = 0.0

        // left / right
        if centerZone.contains(.l) {
            gap = Float(centerLocal.x) - width / 2.0 - subject.width / 2.0
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .left, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.r) {
            gap = Float(-centerLocal.x) - width / 2.0 - subject.width / 2.0
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .right, object: self, gap: gap, angle: theta)
            result.append(relation)
        }

        // ahead / behind
        if centerZone.contains(.a) {
            gap = Float(centerLocal.z) - depth / 2.0 - subject.depth / 2.0
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .ahead, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.b) {
            gap = Float(-centerLocal.z) - depth / 2.0 - subject.depth / 2.0
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .behind, object: self, gap: gap, angle: theta)
            result.append(relation)
        }

        // above / below
        if centerZone.contains(.o) {
            gap = Float(centerLocal.y) - subject.height / 2.0 - height
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .above, object: self, gap: gap, angle: theta)
            result.append(relation)
        } else if centerZone.contains(.u) {
            gap = Float(-centerLocal.y) - subject.height / 2.0
            minDistance = gap
            let relation = SpatialRelation(subject: subject, predicate: .below, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSideRelatedAdjacency(
        subject: SpatialObject,
        localPts: [SCNVector3],
        centerZone: BBoxSector,
        theta: Float,
        isNear: Bool,
        maxDeviation: FuzzyDeviation,
        canNotOverlap: inout Bool,
        minDistance: inout Float,
        result: inout [SpatialRelation]
    ) {
        guard isNear, centerZone.divergencies() == 1, centerZone != .i else {
            return
        }

        var aligned = false
        if abs(theta.truncatingRemainder(dividingBy: .pi / 2.0)) < maxDeviation.angle {
            aligned = true
        }

        var minVal: Float = Float.greatestFiniteMagnitude

        func appendTouchingOrMeeting() {
            if minVal >= -maxDeviation.gap, minVal <= maxDeviation.gap {
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: aligned ? .meeting : .touching,
                    object: self,
                    gap: minVal,
                    angle: theta
                )
                result.append(relation)
            }
        }

        // handle each centerZone case
        switch centerZone {
        case .l:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(pt.x) - width / 2.0)
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .leftside,
                    object: self,
                    gap: minVal,
                    angle: theta
                )
                result.append(relation)
            }

        case .r:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(-pt.x) - width / 2.0)
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .rightside,
                    object: self,
                    gap: minVal,
                    angle: theta
                )
                result.append(relation)
            }

        case .o:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(pt.y) - height)
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                if minVal <= maxDeviation.gap {
                    let relation = SpatialRelation(subject: subject, predicate: .ontop, object: self, gap: minVal, angle: theta)
                    result.append(relation)
                } else {
                    let relation = SpatialRelation(subject: subject, predicate: .upperside, object: self, gap: minVal, angle: theta)
                    result.append(relation)
                }
            }

        case .u:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(-pt.y))
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                if minVal <= maxDeviation.gap {
                    let relation = SpatialRelation(subject: subject, predicate: .beneath, object: self, gap: minVal, angle: theta)
                    result.append(relation)
                } else {
                    let relation = SpatialRelation(subject: subject, predicate: .lowerside, object: self, gap: minVal, angle: theta)
                    result.append(relation)
                }
            }

        case .a:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(pt.z) - depth / 2.0)
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .frontside,
                    object: self,
                    gap: minVal,
                    angle: theta
                )
                result.append(relation)
            }

        case .b:
            for pt in localPts {
                minVal = Float.minimum(minVal, Float(-pt.z) - depth / 2.0)
            }
            if minVal > 0.0 {
                canNotOverlap = true
                minDistance = minVal
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .backside,
                    object: self,
                    gap: minVal,
                    angle: theta
                )
                result.append(relation)
            }

        default:
            break
        }

        // meeting or touching logic
        appendTouchingOrMeeting()
    }

    private func evaluateTopology(
        subject: SpatialObject,
        localPts: [SCNVector3],
        zones: [BBoxSector],
        centerDistance: Float,
        radiusSum: Float,
        theta: Float,
        canNotOverlap: Bool,
        isDisjoint: inout Bool,
        result: inout [SpatialRelation]
    ) {
        guard centerDistance < radius + subject.radius else { return }

        // fully inside
        if zones.allSatisfy({ $0 == .i }) {
            isDisjoint = false
            let relation = SpatialRelation(
                subject: subject,
                predicate: .inside,
                object: self,
                gap: 0.0,
                angle: theta
            )
            result.append(relation)
            return
        }

        // divergencies
        var d = 0
        for z in zones {
            d += z.divergencies()
        }

        // fully containing
        if d == 3 * zones.count {
            isDisjoint = false
            let relation = SpatialRelation(
                subject: subject,
                predicate: .containing,
                object: self,
                gap: 0.0,
                angle: theta
            )
            result.append(relation)
            return
        }

        // partially inside (overlapping)
        let cnt = zones.count(where: { $0.contains(.i) })
        if cnt > 0 {
            isDisjoint = false
            let relation = SpatialRelation(
                subject: subject,
                predicate: .overlapping,
                object: self,
                gap: 0.0,
                angle: theta
            )
            result.append(relation)
            return
        }

        // crossing
        if !canNotOverlap {
            var crossings = 0
            let minY = Float(localPts.first!.y)
            let maxY = Float(localPts.last!.y)
            var minX: Float = Float.greatestFiniteMagnitude
            var maxX: Float = -Float.greatestFiniteMagnitude
            var minZ: Float = Float.greatestFiniteMagnitude
            var maxZ: Float = -Float.greatestFiniteMagnitude

            for pt in localPts {
                minX = Float.minimum(minX, Float(pt.x))
                maxX = Float.maximum(maxX, Float(pt.x))
                minZ = Float.minimum(minZ, Float(pt.z))
                maxZ = Float.maximum(maxZ, Float(pt.z))
            }

            if minX < -width / 2.0, maxX > width / 2.0 {
                crossings += 1
            }
            if minZ < -depth / 2.0, maxZ > depth / 2.0 {
                crossings += 1
            }
            if minY < 0.0, maxY > height {
                crossings += 1
            }

            if crossings > 0 {
                isDisjoint = false
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .crossing,
                    object: self,
                    gap: 0.0,
                    angle: theta
                )
                result.append(relation)
            }
        }
    }

    private func evaluateOrientation(
        subject: SpatialObject,
        centerDistance: Float,
        radiusSum: Float,
        theta: Float,
        centerLocal: SCNVector3,
        result: inout [SpatialRelation]
    ) {
        if abs(theta) < maxDeviation.angle {
            // aligned
            let gap = Float(centerLocal.z)
            let relation = SpatialRelation(
                subject: subject,
                predicate: .aligned,
                object: self,
                gap: gap,
                angle: theta
            )
            result.append(relation)
        } else {
            // opposite
            if abs(theta.truncatingRemainder(dividingBy: .pi)) < maxDeviation.angle {
                let gap = centerDistance - radiusSum
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .opposite,
                    object: self,
                    gap: gap,
                    angle: theta
                )
                result.append(relation)
            }
            // orthogonal
            else if abs(theta.truncatingRemainder(dividingBy: .pi / 2.0)) < maxDeviation.angle {
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: .orthogonal,
                    object: self,
                    gap: 0.0,
                    angle: theta
                )
                result.append(relation)
            }
        }
    }

    private func evaluateClockPredicate(
        subject: SpatialObject,
        centerDistance: Float,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        if type == "Person" || (cause == .selftracked && existence == .real) {
            let rad = Float(atan2(subject.center.x, subject.center.z))
            var angleDeg: Float = rad * 180.0 / Float.pi
            print(angleDeg)
            let hourAngle: Float = 30.0 // 360.0 / 12.0

            // shift angle for half-hour offset
            if angleDeg < 0.0 {
                angleDeg -= hourAngle / 2.0
            } else {
                angleDeg += hourAngle / 2.0
            }

            let cnt = Int(angleDeg / hourAngle)
            print(cnt)
            var doit = true
            var pred: SpatialPredicate = .twelveoclock

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
                let relation = SpatialRelation(
                    subject: subject,
                    predicate: pred,
                    object: self,
                    gap: centerDistance,
                    angle: rad
                )
                result.append(relation)

                // tangible if within ~1.25m
                if centerDistance <= 1.25 {
                    let tangibleRelation = SpatialRelation(
                        subject: subject,
                        predicate: .tangible,
                        object: self,
                        gap: centerDistance,
                        angle: rad
                    )
                    result.append(tangibleRelation)
                }
            }
        }
    }

    // MARK: - Similarities Helpers

    private func evaluateSameCenter(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        let val = (position - subject.position).length()
        if val < maxDeviation.gap {
            let relation = SpatialRelation(subject: subject, predicate: .samecenter, object: self, gap: val, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameWidth(
        subject: SpatialObject,
        theta: Float,
        sameWidth: inout Bool,
        result: inout [SpatialRelation]
    ) {
        let val = abs(width - subject.width)
        if val < maxDeviation.gap {
            sameWidth = true
            let relation = SpatialRelation(subject: subject, predicate: .samewidth, object: self, gap: val, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameDepth(
        subject: SpatialObject,
        theta: Float,
        sameDepth: inout Bool,
        result: inout [SpatialRelation]
    ) {
        let val = abs(depth - subject.depth)
        if val < maxDeviation.gap {
            sameDepth = true
            let relation = SpatialRelation(subject: subject, predicate: .samedepth, object: self, gap: val, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameHeight(
        subject: SpatialObject,
        theta: Float,
        sameHeight: inout Bool,
        result: inout [SpatialRelation]
    ) {
        let val = abs(height - subject.height)
        if val < maxDeviation.gap {
            sameHeight = true
            let relation = SpatialRelation(subject: subject, predicate: .sameheight, object: self, gap: val, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameCuboid(
        subject: SpatialObject,
        theta: Float,
        sameWidth: Bool,
        sameDepth: Bool,
        sameHeight: Bool,
        result: inout [SpatialRelation]
    ) {
        guard sameWidth, sameDepth, sameHeight else { return }
        let val = subject.volume - volume
        let relation = SpatialRelation(subject: subject, predicate: .samecuboid, object: self, gap: val, angle: theta)
        result.append(relation)
    }

    private func evaluateSameLength(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        let val = abs(length - subject.length)
        if val < maxDeviation.gap {
            let relation = SpatialRelation(subject: subject, predicate: .samelength, object: self, gap: val, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameFront(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        let val = subject.height * subject.width
        let minVal = (height - maxDeviation.gap) * (width - maxDeviation.gap)
        let maxVal = (height + maxDeviation.gap) * (width + maxDeviation.gap)
        if val > minVal, val < maxVal {
            let gap = height * width - val
            let relation = SpatialRelation(subject: subject, predicate: .samefront, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameSide(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        let val = subject.height * subject.depth
        let minVal = (height - maxDeviation.gap) * (depth - maxDeviation.gap)
        let maxVal = (height + maxDeviation.gap) * (depth + maxDeviation.gap)
        if val > minVal, val < maxVal {
            let gap = height * depth - val
            let relation = SpatialRelation(subject: subject, predicate: .sameside, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameFootprint(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        let val = subject.width * subject.depth
        let minVal = (width - maxDeviation.gap) * (depth - maxDeviation.gap)
        let maxVal = (width + maxDeviation.gap) * (depth + maxDeviation.gap)
        if val > minVal, val < maxVal {
            let gap = width * depth - val
            let relation = SpatialRelation(subject: subject, predicate: .samefootprint, object: self, gap: gap, angle: theta)
            result.append(relation)
        }
    }

    private func evaluateSameVolume(
        subject: SpatialObject,
        theta: Float,
        sameWidth: Bool,
        sameDepth: Bool,
        sameHeight: Bool,
        result: inout [SpatialRelation]
    ) {
        let val = subject.width * subject.depth * subject.height
        let minVal = (width - maxDeviation.gap) * (depth - maxDeviation.gap) * (height - maxDeviation.gap)
        let maxVal = (width + maxDeviation.gap) * (depth + maxDeviation.gap) * (height + maxDeviation.gap)

        if val > minVal, val < maxVal {
            let gap = width * depth * height - val
            let relation = SpatialRelation(subject: subject, predicate: .samevolume, object: self, gap: gap, angle: theta)
            result.append(relation)

            // Possibly congruent
            let posDiff = (position - subject.position).length()
            let angleDiff = abs(angle - subject.angle)
            if sameWidth && sameDepth && sameHeight
                && posDiff < maxDeviation.gap
                && angleDiff < maxDeviation.angle
            {
                let congruentRelation = SpatialRelation(subject: subject, predicate: .congruent, object: self, gap: gap, angle: theta)
                result.append(congruentRelation)
            }
        }
    }

    private func evaluateSameShape(
        subject: SpatialObject,
        theta: Float,
        result: inout [SpatialRelation]
    ) {
        guard shape == subject.shape, shape != .unknown, subject.shape != .unknown else { return }
        let val = (position - subject.position).length()
        let relation = SpatialRelation(subject: subject, predicate: .sameshape, object: self, gap: val, angle: theta)
        result.append(relation)
    }
}
