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
nonisolated(unsafe) let assembly:[SpatialPredicate] = [.disjoint, .inside, .containing, .overlapping, .crossing, .touching, .meeting, .beside]
nonisolated(unsafe) let topology = proximity + directionality + adjacency + orientations + assembly
nonisolated(unsafe) let contacts:[SpatialPredicate] = [.on, .at, .by, .in]
nonisolated(unsafe) let connectivity = contacts
nonisolated(unsafe) let comparability:[SpatialPredicate] = [.smaller, .bigger, .shorter, .longer, .taller, .thinner, .wider, .fitting, .exceeding]
nonisolated(unsafe) let similarity:[SpatialPredicate] = [.sameheight, .samewidth, .samedepth, .samelength, .samefront, .sameside, .samefootprint, .samevolume, .samecenter, .samecuboid, .congruent, .sameshape]
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
    /// assembly
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
    // SIMILARITY
    /// fuzzy comparision considering max deviation
    case samewidth
    case sameheight
    case samedepth
    case sameperimeter
    case samefront
    case sameside
    case samefootprint
    case samelength // same length of main direction
    case samesurface
    case samevolume
    case samecenter
    case sameposition // on base
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
    
    public static func named(_ name: String) -> SpatialPredicate {
        return SpatialPredicate(rawValue: name) ?? .undefined
    }
}

public struct PredicateTerm {
    public var code:SpatialPredicate
    public var predicate:String // subject - predicate - object
    public var preposition:String
    public var synonym:String = ""
    public var reverse:String = "" //  : object - predicate - subject
    public var antonym:String = "" // if not predicate then antonym
    //var opposite:String //  left : right
    public var verb:String = "is"
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

public struct SpatialTerms {
    nonisolated(unsafe) static let list: [PredicateTerm] = [
        /// proximity in WCS and OCS
        .init(code: .near, predicate: "near", preposition: "to", synonym: "close", reverse: "near", antonym: "far"),
        .init(code: .far, predicate: "far", preposition: "from", synonym: "close", reverse: "far", antonym: "near"),
        /// alignment in OCS
        .init(code: .left, predicate: "left", preposition: "of", synonym: "to the left"),
        .init(code: .right, predicate: "right", preposition: "of", synonym: "to the right"),
        .init(code: .ahead, predicate: "ahead", preposition: "of", synonym: "before"),
        .init(code: .behind, predicate: "behind", preposition: "", synonym: "after"),
        .init(code: .above, predicate: "above", preposition: "", synonym: "over", reverse: "below"),
        .init(code: .below, predicate: "below", preposition: "", synonym: "under", reverse: "above"),
        /// adjacancy in OCS
        .init(code: .ontop, predicate: "on top", preposition: "of", synonym: "at the top", reverse: "beneath"),
        .init(code: .beneath, predicate: "beneath", preposition: "", synonym: "underneath", reverse: "on top"),
        .init(code: .upperside, predicate: "at upper side", preposition: "of", reverse: "at lower side" ),
        .init(code: .lowerside, predicate: "at lower side", preposition: "of", reverse: "at upper side" ),
        .init(code: .leftside, predicate: "at left side", preposition: "of", synonym: "at left-hand side"),
        .init(code: .rightside, predicate: "at right side", preposition: "of", synonym: "at right-hand side"),
        .init(code: .frontside, predicate: "at front side", preposition: "of", synonym: "at forefront"),
        .init(code: .backside, predicate: "at back side", preposition: "of", synonym: "at rear side"),
        /// orientation
        .init(code: .aligned, predicate: "aligned", preposition: "with", synonym: "parallel", reverse: "aligned"),
        .init(code: .orthogonal, predicate: "orthogonal", preposition: "to", synonym: "perpendicular", reverse: "orthogonal"),
        .init(code: .opposite, predicate: "opposite", preposition: "", synonym: "vis-a-vis", reverse: "opposite"),
        /// topology
        .init(code: .inside, predicate: "inside", preposition: "", synonym: "within", reverse: "containing"),
        .init(code: .containing, predicate: "containing", preposition: "", synonym: "contains", reverse: "inside"),
        .init(code: .crossing, predicate: "crossing", preposition: ""),
        .init(code: .overlapping, predicate: "overlapping", preposition: "", synonym: "intersecting", reverse: "overlapping", antonym: "disjoint"),
        .init(code: .disjoint, predicate: "disjoint", preposition: "to", reverse: "disjoint", antonym: "overlapping"),
        .init(code: .touching, predicate: "touching", preposition: "", reverse: "touching"),
        .init(code: .frontaligned, predicate: "front aligned", preposition: "with", reverse: "front aligned"),
        .init(code: .meeting, predicate: "meeting", preposition: "", reverse: "meeting"),
        .init(code: .beside, predicate: "beside", preposition: "", reverse: "beside"),
        .init(code: .fitting, predicate: "fitting", preposition: "into", reverse: "exceeding"),
        .init(code: .exceeding, predicate: "exceeding", preposition: "into", reverse: "fitting"),
        /// connectivity
        .init(code: .on, predicate: "on", preposition: "", reverse: "beneath"),
        .init(code: .at, predicate: "at", preposition: "", reverse: "meeting"),
        .init(code: .by, predicate: "by", preposition: "", reverse: "by"),
        .init(code: .in, predicate: "in", preposition: "", reverse: "containing"),
        /// similarity
        .init(code: .samewidth, predicate: "same width", preposition: "as", synonym: "similar width", reverse: "same width", verb: "has"),
        .init(code: .sameheight, predicate: "same height", preposition: "as", synonym: "similar height", reverse: "same height", verb: "has"),
        .init(code: .samedepth, predicate: "same depth", preposition: "as", synonym: "similar depth", reverse: "same depth", verb: "has"),
        .init(code: .samelength, predicate: "same length", preposition: "as", synonym: "similar length", reverse: "same length", verb: "has"),
        .init(code: .samefootprint, predicate: "same footprint", preposition: "as", synonym: "similar base area", reverse: "same footprint", verb: "has"),
        .init(code: .samefront, predicate: "same front face", preposition: "as", synonym: "similar front face", reverse: "same front face", verb: "has"),
        .init(code: .sameside, predicate: "same side face", preposition: "as", synonym: "similar side face", reverse: "same side face", verb: "has"),
        .init(code: .samevolume, predicate: "same volume", preposition: "as", synonym: "similar volume", reverse: "same volume", verb: "has"),
        .init(code: .samecuboid, predicate: "same cuboid", preposition: "as", synonym: "similar cuboid", reverse: "same cuboid", verb: "has"),
        .init(code: .samecenter, predicate: "same center", preposition: "as", synonym: "similar center", reverse: "same center", verb: "has"),
        .init(code: .sameshape, predicate: "same shape", preposition: "as", synonym: "similar shape", reverse: "same shape", verb: "has"),
        .init(code: .congruent, predicate: "congruent", preposition: "as", reverse: "congruent"),
        /// comparisons
        .init(code: .smaller, predicate: "smaller", preposition: "than", synonym: "tinier", reverse: "bigger"),
        .init(code: .bigger, predicate: "bigger", preposition: "than", synonym: "larger", reverse: "smaller"),
        .init(code: .shorter, predicate: "shorter", preposition: "than", reverse: "longer"),
        .init(code: .longer, predicate: "longer", preposition: "than", reverse: "shorter"),
        .init(code: .taller, predicate: "taller", preposition: "than", reverse: "shorter"),
        .init(code: .thinner, predicate: "thinner", preposition: "than", synonym: "narrower", reverse: "wider"),
        .init(code: .wider, predicate: "wider", preposition: "than", synonym: "thicker", reverse: "thinner"),

    ]
    
    public static func predicate(_ name: String) -> SpatialPredicate {
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
    
    public static func term(_ code: SpatialPredicate) -> String {
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
    
    public static func termWithPreposition(_ code: SpatialPredicate) -> String {
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
    
    public static func termWithVerbAndPreposition(_ code: SpatialPredicate) -> String {
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
    
    // predicate is symmetric / reciprocal / bi-directional
    public static func symmetric(_ code: SpatialPredicate) -> Bool {
        for term in list {
            if term.code == code {
                return term.predicate == term.reverse
            }
        }
        return false
    }
    
    // TODO: inverse
    public static func inverse(_ predicate: String) -> SpatialPredicate {
        return .undefined
    }
    
    // TODO: negation
    public static func negation(_ predicate: String) -> SpatialPredicate {
        return .undefined
    }
}

