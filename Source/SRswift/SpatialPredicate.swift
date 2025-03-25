//
//  SpatialPredicate.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 12.11.2024.
//

import Foundation

// Spatial predicate categories

//nonisolated(unsafe) let proximity:[SpatialPredicate] = [.near, .far]


// Spatial predicates used for: Subject - predicate - Object
public enum SpatialPredicate : String, CaseIterable {
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

public struct PredicateCategories {
    nonisolated(unsafe) public static let proximity:[SpatialPredicate] = [.near, .far]
    nonisolated(unsafe) public static let directionality:[SpatialPredicate] = [.left, .right, .above, .below, .ahead, .behind]
    nonisolated(unsafe) public static let adjacency:[SpatialPredicate] = [.leftside, .rightside, .ontop, .beneath, .upperside, .lowerside, .frontside, .backside]
    nonisolated(unsafe) public static let orientations:[SpatialPredicate] = [.orthogonal, .opposite, .aligned, .frontaligned, .backaligned, .rightaligned, .leftaligned]
    nonisolated(unsafe) public static let assembly:[SpatialPredicate] = [.disjoint, .inside, .containing, .overlapping, .crossing, .touching, .meeting, .beside, .fitting, .exceeding]
    nonisolated(unsafe) public static var connectivity:[SpatialPredicate] = [.on, .at, .by, .in] // contacts
    nonisolated(unsafe) public static let comparability:[SpatialPredicate] = [.smaller, .bigger, .shorter, .longer, .taller, .thinner, .wider]
    nonisolated(unsafe) public static let similarity:[SpatialPredicate] = [.sameheight, .samewidth, .samedepth, .samelength, .samefront, .sameside, .samefootprint, .samevolume, .sameperimeter, .samesurface, .sameposition, .samecenter, .samecuboid, .congruent, .sameshape]
    nonisolated(unsafe) public static let visibility:[SpatialPredicate] = [.seenleft, .seenright, .infront, .atrear, .tangible, .eightoclock, .nineoclock, .tenoclock, .elevenoclock, .twelveoclock, .oneoclock, .twooclock, .threeoclock, .fouroclock]
    nonisolated(unsafe) public static let geography:[SpatialPredicate] = [.north, .south, .east, .west, .northwest, .northeast, .southwest, .southeast]
    nonisolated(unsafe) public static let sectors:[SpatialPredicate] = [ .i, .a, .b, .o, .u, .l, .r, .al, .ar, .bl, .br, .ao, .au, .bo, .bu, .lo, .lu, .ro, .ru, .alo, .aro, .blo, .bro, .alu, .aru, .blu, .bru]
    public static var topology:[SpatialPredicate] {
        return PredicateCategories.proximity + PredicateCategories.directionality + PredicateCategories.adjacency + PredicateCategories.orientations + PredicateCategories.assembly
    }
    
    public static func allInCategories() -> Bool {
        let amount = PredicateCategories.proximity.count + PredicateCategories.directionality.count + PredicateCategories.adjacency.count + PredicateCategories.orientations.count + PredicateCategories.assembly.count + PredicateCategories.connectivity.count + PredicateCategories.comparability.count + PredicateCategories.similarity.count + PredicateCategories.visibility.count + PredicateCategories.geography.count + PredicateCategories.sectors.count
        print("categroies: \(amount) == \(SpatialPredicate.allCases.count - 1)")
        return amount == SpatialPredicate.allCases.count - 1 // minus undefined
    }
    
}

public struct PredicateTerm {
    public var code:SpatialPredicate
    public var predicate:String // subject - predicate - object
    public var preposition:String
    public var synonyms:String = ""
    public var inverse:String = "" //  reverse, opposite predicate: object - predicate - subject
    public var antonym:String = "" // if not predicate then antonym
    public var verb:String = "is"
}



public struct SpatialTerms {
    nonisolated(unsafe) static let list: [PredicateTerm] = [
        /// proximity in WCS and OCS
        .init(code: .near, predicate: "near", preposition: "to", synonyms: "close, nearby", inverse: "near", antonym: "far"),
        .init(code: .far, predicate: "far", preposition: "from", synonyms: "far away", inverse: "far", antonym: "near"),
        /// alignment in OCS
        .init(code: .left, predicate: "left", preposition: "of", synonyms: "to the left", antonym: "right"),
        .init(code: .right, predicate: "right", preposition: "of", synonyms: "to the right", antonym: "left"),
        .init(code: .ahead, predicate: "ahead", preposition: "of", synonyms: "beforehand", inverse: "behind", antonym: "behind"),
        .init(code: .behind, predicate: "behind", preposition: "", synonyms: "after", inverse: "ahead", antonym: "ahead"),
        .init(code: .above, predicate: "above", preposition: "", synonyms: "over", inverse: "below", antonym: "below"),
        .init(code: .below, predicate: "below", preposition: "", synonyms: "under", inverse: "above", antonym: "above"),
        /// adjacancy in OCS
        .init(code: .ontop, predicate: "on top", preposition: "of", synonyms: "at the top, atop", inverse: "beneath"),
        .init(code: .beneath, predicate: "beneath", preposition: "", synonyms: "underneath", inverse: "on top"),
        .init(code: .upperside, predicate: "at upper side", preposition: "of", synonyms: "at upperside", inverse: "at lower side" ),
        .init(code: .lowerside, predicate: "at lower side", preposition: "of", inverse: "at upper side" ),
        .init(code: .leftside, predicate: "at left side", preposition: "of", synonyms: "at left-hand side"),
        .init(code: .rightside, predicate: "at right side", preposition: "of", synonyms: "at right-hand side"),
        .init(code: .frontside, predicate: "at front side", preposition: "of", synonyms: "at frontside, at forefront"),
        .init(code: .backside, predicate: "at back side", preposition: "of", synonyms: "at backside, at rear side"),
        /// orientation
        .init(code: .aligned, predicate: "aligned", preposition: "with", synonyms: "parallel", inverse: "aligned", antonym: "unaligned"),
        .init(code: .orthogonal, predicate: "orthogonal", preposition: "to", synonyms: "perpendicular", inverse: "orthogonal"),
        .init(code: .opposite, predicate: "opposite", preposition: "to", synonyms: "vis-a-vis, face to face", inverse: "opposite"),
        /// topology
        .init(code: .inside, predicate: "inside", preposition: "", synonyms: "within", inverse: "containing", antonym: "outside"),
        .init(code: .containing, predicate: "containing", preposition: "", synonyms: "contains", inverse: "inside"),
        .init(code: .crossing, predicate: "crossing", preposition: ""),
        .init(code: .overlapping, predicate: "overlapping", preposition: "", synonyms: "intersecting", inverse: "overlapping", antonym: "disjoint"),
        .init(code: .disjoint, predicate: "disjoint", preposition: "to", inverse: "disjoint", antonym: "overlapping"),
        .init(code: .touching, predicate: "touching", preposition: "", inverse: "touching"),
        .init(code: .frontaligned, predicate: "front aligned", preposition: "with", inverse: "front aligned"),
        .init(code: .backaligned, predicate: "back aligned", preposition: "with", inverse: "back aligned"),
        .init(code: .meeting, predicate: "meeting", preposition: "", inverse: "meeting"),
        .init(code: .beside, predicate: "beside", preposition: "", inverse: "beside"),
        .init(code: .fitting, predicate: "fitting", preposition: "into", inverse: "exceeding"),
        .init(code: .exceeding, predicate: "exceeding", preposition: "into", inverse: "fitting"),
        /// connectivity
        .init(code: .on, predicate: "on", preposition: "", inverse: "beneath"),
        .init(code: .at, predicate: "at", preposition: "", inverse: "meeting"),
        .init(code: .by, predicate: "by", preposition: "", inverse: "by"),
        .init(code: .in, predicate: "in", preposition: "", inverse: "containing"),
        /// similarity
        .init(code: .samewidth, predicate: "same width", preposition: "as", synonyms: "similar width", inverse: "same width", verb: "has"),
        .init(code: .sameheight, predicate: "same height", preposition: "as", synonyms: "similar height", inverse: "same height", verb: "has"),
        .init(code: .samedepth, predicate: "same depth", preposition: "as", synonyms: "similar depth", inverse: "same depth", verb: "has"),
        .init(code: .samelength, predicate: "same length", preposition: "as", synonyms: "similar length", inverse: "same length", verb: "has"),
        .init(code: .samefootprint, predicate: "same footprint", preposition: "as", synonyms: "similar base area", inverse: "same footprint", verb: "has"),
        .init(code: .samefront, predicate: "same front face", preposition: "as", synonyms: "similar front face", inverse: "same front face", verb: "has"),
        .init(code: .sameside, predicate: "same side face", preposition: "as", synonyms: "similar side face", inverse: "same side face", verb: "has"),
        .init(code: .samevolume, predicate: "same volume", preposition: "as", synonyms: "similar volume", inverse: "same volume", verb: "has"),
        .init(code: .samecuboid, predicate: "same cuboid", preposition: "as", synonyms: "similar cuboid", inverse: "same cuboid", verb: "has"),
        .init(code: .samecenter, predicate: "same center", preposition: "as", synonyms: "similar center", inverse: "same center", verb: "has"),
        .init(code: .sameshape, predicate: "same shape", preposition: "as", synonyms: "similar shape", inverse: "same shape", verb: "has"),
        .init(code: .congruent, predicate: "congruent", preposition: "as", inverse: "congruent"),
        /// comparisons
        .init(code: .smaller, predicate: "smaller", preposition: "than", synonyms: "tinier, minor", inverse: "bigger"),
        .init(code: .bigger, predicate: "bigger", preposition: "than", synonyms: "larger, major", inverse: "smaller"),
        .init(code: .shorter, predicate: "shorter", preposition: "than", inverse: "longer"),
        .init(code: .longer, predicate: "longer", preposition: "than", inverse: "shorter"),
        .init(code: .taller, predicate: "taller", preposition: "than", inverse: "shorter"),
        .init(code: .thinner, predicate: "thinner", preposition: "than", synonyms: "slimmer, narrower", inverse: "thicker"),
        .init(code: .wider, predicate: "thicker", preposition: "than", synonyms: "wider, broader", inverse: "thinner")

    ]
    
    public static func get(_ name: String) -> PredicateTerm? {
        for term in list {
            if term.predicate == name {
                return term
            }
        }
        return nil
    }
    
    public static func predicate(_ name: String) -> SpatialPredicate {
        let pred = SpatialPredicate.named(name)
        if pred != .undefined {
            return pred
        }
        for term in list {
            if term.predicate == name {
                return term.code
            }
            if term.synonyms == name {
                return term.code
            }
        }
        return .undefined
    }
    
    static public func searchPredicate(_ query: String) -> SpatialPredicate? {
        let pred = SpatialPredicate.named(query)
        if pred != .undefined {
            return pred
        }
        for term in list {
            if term.predicate == query {
                return term.code
            }
        }
        if query.count > 3 {
            for term in list {
                if term.synonyms.contains(query)  {
                    return term.code
                }
            }
        }
        return nil
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
        if PredicateCategories.sectors.contains(code) {
            return "is in sector " + code.rawValue + " of"
        }
        return "is " + code.rawValue + " of"
    }
    
    // predicate is symmetric / reciprocal / bi-directional
    public static func symmetric(_ code: SpatialPredicate) -> Bool {
        for term in list {
            if term.code == code {
                return term.predicate == term.inverse
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
    
    //TODO: implement dynamic loading of SpatialTerms
    public static func load() {
        
    }
    
    // TODO: make PredicateTerm Codable!
    public static func save() {
#if os(macOS)
        let urls = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        if urls.count > 0 {
            let url = urls.first!
            do {
                let fileURL = url.appendingPathComponent("SpatialTerms.json")
                let jsonData = try JSONSerialization.data(withJSONObject: SpatialTerms.list, options: .prettyPrinted)
                try jsonData.write(to: fileURL, options: [.atomic])
            } catch {
                print(error)
            }
        }
#endif
    }
}

