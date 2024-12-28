//
//  SpatialPredicate.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 12.11.2024.
//

import Foundation

// Spatial predicate categories

nonisolated(unsafe) let proximity:[SpatialPredicate] = [.near, .far]
nonisolated(unsafe) let directionality:[SpatialPredicate] = [.left, .right, .above, .below, .ahead, .behind]
nonisolated(unsafe) let adjacency:[SpatialPredicate] = [.leftside, .rightside, .ontop, .beneath, .upperside, .lowerside, .frontside, .backside]
nonisolated(unsafe) let orientations:[SpatialPredicate] = [.orthogonal, .opposite, .aligned, .frontaligned, .backaligned, .rightaligned, .leftaligned]
nonisolated(unsafe) let arrangements:[SpatialPredicate] = [.disjoint, .inside, .containing, .overlapping, .crossing, .touching, .meeting, .beside, .fitting, .exceeding]
nonisolated(unsafe) let topology = proximity + directionality + adjacency + orientations + arrangements
nonisolated(unsafe) let contacts:[SpatialPredicate] = [.on, .at, .by, .in]
nonisolated(unsafe) let connectivity = contacts
nonisolated(unsafe) let comparisons:[SpatialPredicate] = [.smaller, .bigger, .shorter, .longer, .taller, .thinner, .wider]
nonisolated(unsafe) let similarities:[SpatialPredicate] = [.sameside, .sameheight, .samewidth, .samefront, .sameside, .samefootprint, .samelength, .samevolume, .samecenter, .samecuboid, .congruent, .sameshape]
nonisolated(unsafe) let comparability = comparisons + similarities
nonisolated(unsafe) let visibility:[SpatialPredicate] = [.seenleft, .seenright, .infront, .atrear, .tangible, .eightoclock, .nineoclock, .tenoclock, .elevenoclock, .twelveoclock, .oneoclock, .twooclock, .threeoclock, .fouroclock]
nonisolated(unsafe) let geography:[SpatialPredicate] = [.north, .south, .east, .west, .northwest, .northeast, .southwest, .southeast]
nonisolated(unsafe) let sectors:[SpatialPredicate] = [ .i, .a, .b, .o, .u, .l, .r, .al, .ar, .bl, .br, .ao, .au, .bo, .bu, .lo, .lu, .ro, .ru, .alo, .aro, .blo, .bro, .alu, .aru, .blu, .bru]

// Spatial predicates used for: Subject - predicate - Object
public enum SpatialPredicate : String {
    case undefined // try to resolve by synonym or inverse
    // TOPOLOGY
    /// proximity: near by
    case near // A is near to B, is close
    case far // not near
    /// directionality: in relation to position and orientation of object comparing center
    case left
    case right
    case above
    case below
    case ahead
    case behind
    /// adjacency: near by and at one side
    case ontop // A is on top of B, very close contact
    case beneath // A is beneath of B, very close contact
    case upperside // A is at upper side of B
    case lowerside // A is at lower side of B
    case leftside // A is left side from B
    case rightside
    case frontside // A is at front side of B, ahead
    case backside
    /// orientations
    case orthogonal // A is orthogonal to B, perpendicular to
    case opposite // opposite alignement
    case aligned // equally aligned orientation, parallel with
    case frontaligned // same orientation and in same front plane
    case backaligned
    case leftaligned
    case rightaligned
    /// arrangements
    case disjoint // no space in common
    case inside // A is inside B
    case containing // A is containing/contains B
    case overlapping // (partially) overlapping, intersecting
    case crossing // intersecting by going through object
    //case dividing // crossing and dividing into parts
    case touching // touching edge-to-edge or edge-to-side = atedge
    case meeting // meeting side-by-side
    case beside // near but not above or below
    case fitting // is fitting into
    case exceeding // not fitting into
    // COMPARABILITY
    /// comparisons
    case smaller // volume
    case bigger // syn:larger
    case shorter // length, height
    case longer // length
    case taller // height
    case thinner //  width,depth --> footprint, syn:narrower,
    case wider // syn:thicker
    /// similarities, fuzzy comparision considering max deviation
    case samewidth
    case sameheight
    case samedepth
    case samefront
    case sameside
    case samefootprint
    case samelength // same length of main direction
    case samevolume
    case samecenter
    case samecuboid
    case congruent // A is congruent to B, similar w,h,d, center and orientation, identical
    case sameshape
    //case samecause
    // VISIBILITY
    /// perspectives: seen from user  / observer
    case seenleft // A is seen left of B by P
    case seenright
    case infront // (partially) covering
    case atrear // atback
    case tangible // within arm reach by user
    case eightoclock // at 8 o'clock
    case nineoclock
    case tenoclock
    case elevenoclock
    case twelveoclock
    case oneoclock
    case twooclock
    case threeoclock
    case fouroclock
    /// multistage relations
    case secondleft
    case secondright
    case mostleft
    case mostright
    // CONNECTIVITY
    /// contacts
    case on // on top of, unilateral
    case at // attached and aligned with, unilateral
    case by // connected, bilateral
    case `in` // within, unilateral
    // SECTORIALITY
    /// center within bbox sector
    case i
    case a
    case b
    case l
    case r
    case o
    case u
    case al
    case ar
    case bl
    case br
    case ao
    case au
    case bo
    case bu
    case lo
    case lu
    case ro
    case ru
    case alo
    case aro
    case blo
    case bro
    case alu
    case aru
    case blu
    case bru
    // GEOGRAPHY
    /// geographic direction
    case north
    case south
    case east
    case west
    case northwest
    case northeast
    case southwest
    case southeast
    
    static func named(_ name:String) -> SpatialPredicate {
        return SpatialPredicate(rawValue: name) ?? .undefined
    }
}

struct PredicateTerm {
    var code:SpatialPredicate
    var predicate:String
    var preposition:String
    var inverse:String
    var antonym:String
    var synonym:String
    var verb:String = "is"
}

// TODO: terms
/* observer-related
 case facing // facing towards user
 case focusing // gazing; +/-10 = 20 degrees
 case seenleft // A is seen left of B (by observer)
 case seenright
 case infront // (partially) covering
 case atrear
 */

struct SpatialTerms {
    nonisolated(unsafe) static let list: [PredicateTerm] = [
        /// alignment
        .init(code: .left, predicate: "left", preposition: "of", inverse: "right", antonym: "", synonym: "to the left"),
        .init(code: .right, predicate: "right", preposition: "of", inverse: "left", antonym: "", synonym: "to the right"),
        .init(code: .above, predicate: "above", preposition: "", inverse: "below", antonym: "", synonym: "over"),
        .init(code: .below, predicate: "below", preposition: "", inverse: "above", antonym: "", synonym: "under"),
        /// adjacancy/proximity
        .init(code: .ahead, predicate: "ahead", preposition: "of", inverse: "behind", antonym: "", synonym: "before"),
        .init(code: .behind, predicate: "behind", preposition: "", inverse: "ahead", antonym: "", synonym: "after"),
        .init(code: .ontop, predicate: "on top", preposition: "of", inverse: "beneath", antonym: "", synonym: "at the top"),
        .init(code: .beneath, predicate: "beneath", preposition: "", inverse: "on top", antonym: "", synonym: "underneath"),
        .init(code: .upperside, predicate: "at upper side", preposition: "of", inverse: "at lower side", antonym: "", synonym: ""),
        .init(code: .lowerside, predicate: "at lower side", preposition: "of", inverse: "at upper side", antonym: "", synonym: ""),
        .init(code: .leftside, predicate: "at left side", preposition: "of", inverse: "at right side", antonym: "", synonym: "at left-hand side"),
        .init(code: .rightside, predicate: "at right side", preposition: "of", inverse: "at left side", antonym: "", synonym: "at right-hand side"),
        .init(code: .frontside, predicate: "at front side", preposition: "of", inverse: "at back side", antonym: "", synonym: "at forefront"),
        .init(code: .backside, predicate: "at back side", preposition: "of", inverse: "at front side", antonym: "", synonym: "at rear side"),
        /// orientation
        .init(code: .aligned, predicate: "aligned", preposition: "with", inverse: "aligned", antonym: "", synonym: "parallel"),
        .init(code: .orthogonal, predicate: "orthogonal", preposition: "to", inverse: "orthogonal", antonym: "", synonym: "perpendicular"),
        .init(code: .opposite, predicate: "opposite", preposition: "", inverse: "opposite", antonym: "", synonym: "vis-a-vis"),
        /// topology
        .init(code: .inside, predicate: "inside", preposition: "", inverse: "containing", antonym: "", synonym: "within"),
        .init(code: .containing, predicate: "containing", preposition: "", inverse: "inside", antonym: "", synonym: "contains"),
        .init(code: .crossing, predicate: "crossing", preposition: "", inverse: "", antonym: "", synonym: ""),
        .init(code: .overlapping, predicate: "overlapping", preposition: "", inverse: "overlapping", antonym: "disjoint", synonym: "intersecting"),
        .init(code: .disjoint, predicate: "disjoint", preposition: "to", inverse: "disjoint", antonym: "overlapping", synonym: ""),
        .init(code: .touching, predicate: "touching", preposition: "", inverse: "touching", antonym: "", synonym: ""),
        .init(code: .frontaligned, predicate: "front aligned", preposition: "with", inverse: "front aligned", antonym: "", synonym: ""),
        .init(code: .meeting, predicate: "meeting", preposition: "", inverse: "meeting", antonym: "", synonym: ""),
        .init(code: .near, predicate: "near", preposition: "to", inverse: "near", antonym: "far", synonym: "close"),
        .init(code: .near, predicate: "nearby", preposition: "", inverse: "near", antonym: "far", synonym: ""),
        .init(code: .beside, predicate: "beside", preposition: "", inverse: "beside", antonym: "", synonym: ""),
        .init(code: .fitting, predicate: "fitting", preposition: "into", inverse: "exceeding", antonym: "", synonym: ""),
        .init(code: .exceeding, predicate: "exceeding", preposition: "into", inverse: "fitting", antonym: "", synonym: ""),
        /// connectivity
        .init(code: .on, predicate: "on", preposition: "", inverse: "beneath", antonym: "", synonym: ""),
        .init(code: .at, predicate: "at", preposition: "", inverse: "at", antonym: "", synonym: ""),
        .init(code: .by, predicate: "by", preposition: "", inverse: "by", antonym: "", synonym: ""),
        .init(code: .in, predicate: "in", preposition: "", inverse: "containing", antonym: "", synonym: ""),
        /// similarity
        .init(code: .samewidth, predicate: "same width", preposition: "as", inverse: "same width", antonym: "", synonym: "similar width", verb: "has"),
        .init(code: .sameheight, predicate: "same height", preposition: "as", inverse: "same height", antonym: "", synonym: "similar height", verb: "has"),
        .init(code: .samedepth, predicate: "same depth", preposition: "as", inverse: "same depth", antonym: "", synonym: "similar depth", verb: "has"),
        .init(code: .samelength, predicate: "same length", preposition: "as", inverse: "same length", antonym: "", synonym: "similar length", verb: "has"),
        .init(code: .samefootprint, predicate: "same footprint", preposition: "as", inverse: "same footprint", antonym: "", synonym: "similar base area", verb: "has"),
        .init(code: .samefront, predicate: "same front face", preposition: "as", inverse: "same front face", antonym: "", synonym: "similar front face", verb: "has"),
        .init(code: .sameside, predicate: "same side face", preposition: "as", inverse: "same side face", antonym: "", synonym: "similar side face", verb: "has"),
        .init(code: .samevolume, predicate: "same volume", preposition: "as", inverse: "same volume", antonym: "", synonym: "similar volume", verb: "has"),
        .init(code: .samecuboid, predicate: "same cuboid", preposition: "as", inverse: "same cuboid", antonym: "", synonym: "similar cuboid", verb: "has"),
        .init(code: .samecenter, predicate: "same center", preposition: "as", inverse: "same center", antonym: "", synonym: "similar center", verb: "has"),
        .init(code: .sameshape, predicate: "same shape", preposition: "as", inverse: "same shape", antonym: "", synonym: "similar shape", verb: "has"),
        .init(code: .congruent, predicate: "congruent", preposition: "as", inverse: "congruent", antonym: "", synonym: ""),
        /// comparisons
        .init(code: .smaller, predicate: "smaller", preposition: "than", inverse: "bigger", antonym: "", synonym: "tinier"),
        .init(code: .bigger, predicate: "bigger", preposition: "than", inverse: "smaller", antonym: "", synonym: "larger"),
        .init(code: .shorter, predicate: "shorter", preposition: "than", inverse: "longer", antonym: "", synonym: ""),
        .init(code: .longer, predicate: "longer", preposition: "than", inverse: "shorter", antonym: "", synonym: ""),
        .init(code: .taller, predicate: "taller", preposition: "than", inverse: "shorter", antonym: "", synonym: ""),
        .init(code: .thinner, predicate: "thinner", preposition: "than", inverse: "wider", antonym: "", synonym: "narrower"),
        .init(code: .wider, predicate: "wider", preposition: "than", inverse: "thinner", antonym: "", synonym: "thicker"),

    ]
    
    static func predicate(_ name: String) -> SpatialPredicate {
        let pred = SpatialPredicate.named(name)
        if pred != .undefined {
            return pred
        }
        for term in list {
            if term.predicate == name {
                return term.code
            }
            if term.synonym == name {
                return term.code
            }
        }
        return .undefined
    }
    
    static func term(_ code: SpatialPredicate) -> String {
        for term in list {
            if term.code == code {
                return term.predicate
            }
        }
        if code != .undefined {
            return code.rawValue
        }
        return "undefined"
    }
    
    static func termWithPreposition(_ code: SpatialPredicate) -> String {
        for term in list {
            if term.code == code {
                if term.preposition.isEmpty {
                    return term.predicate
                }
                return term.predicate + " " + term.preposition
            }
        }
        return "undefined"
    }
    
    static func termWithVerbAndPreposition(_ code: SpatialPredicate) -> String {
        for term in list {
            if term.code == code {
                if term.preposition.isEmpty {
                    return term.verb + " " + term.predicate
                }
                return term.verb + " " + term.predicate + " " + term.preposition
            }
        }
        return "undefined"
    }
    
    static func inverse(_ predicate: String) -> SpatialPredicate {
        return .undefined
    }
    
    static func negation(_ predicate: String) -> SpatialPredicate {
        return .undefined
    }
}

