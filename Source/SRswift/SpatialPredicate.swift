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
    
    public static func of(_ predicate:SpatialPredicate) -> String {
        if proximity.contains(predicate) { return "proximity" }
        if directionality.contains(predicate) { return "directionality" }
        if adjacency.contains(predicate) { return "adjacency" }
        if orientations.contains(predicate) { return "orientations" }
        if assembly.contains(predicate) { return "assembly" }
        if connectivity.contains(predicate) { return "connectivity" }
        if comparability.contains(predicate) { return "comparability" }
        if similarity.contains(predicate) { return "similarity" }
        if visibility.contains(predicate) { return "visibility" }
        if geography.contains(predicate) { return "geography" }
        if sectors.contains(predicate) { return "sectors" }
        return "unknown"
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
    public var category:String {
        return PredicateCategories.of(code)
    }
    
    public func asDict() -> Dictionary<String, Any> {
        let dict = [
            "code": code.rawValue,
            "predicate": predicate,
            "preposition": preposition,
            "synonyms": synonyms,
            "inverse": inverse,
            "antonym": antonym,
            "verb": verb,
            "category": category
        ] as [String : Any]
        return dict
    }
}



public struct SpatialTerms {
    nonisolated(unsafe) static var list: [PredicateTerm] = [
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
        .init(code: .leftaligned, predicate: "left aligned", preposition: "with", inverse: "left aligned"),
        .init(code: .rightaligned, predicate: "right aligned", preposition: "with", inverse: "right aligned"),
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
        .init(code: .sameperimeter, predicate: "same perimeter", preposition: "as", synonyms: "similar perimeter", inverse: "same perimeter", verb: "has"),
        .init(code: .samesurface, predicate: "same surface", preposition: "as", synonyms: "similar surface", inverse: "same surface", verb: "has"),
        .init(code: .sameposition, predicate: "same position", preposition: "as", synonyms: "similar position", inverse: "same position", verb: "has"),
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
        .init(code: .wider, predicate: "thicker", preposition: "than", synonyms: "wider, broader", inverse: "thinner"),
        /// visibility
        .init(code: .seenleft, predicate: "seen left", preposition: "of", synonyms: "visible to the left", inverse: "seen right"),
        .init(code: .seenright, predicate: "seen right", preposition: "of", synonyms: "visible to the right", inverse: "seen left"),
        .init(code: .infront, predicate: "in front", preposition: "of", synonyms: "", inverse: "at rear"),
        .init(code: .atrear, predicate: "at rear", preposition: "of", inverse: "in front"),
        .init(code: .tangible, predicate: "tangible", preposition: "by", inverse: ""),
        .init(code: .eightoclock, predicate: "at eight'o'clock", preposition: "from", synonyms: "at 8 o'clock", inverse: ""),
        .init(code: .nineoclock, predicate: "at nine'o'clock", preposition: "from", synonyms: "at 9 o'clock", inverse: ""),
        .init(code: .tenoclock, predicate: "at ten'o'clock", preposition: "from", synonyms: "at 10 o'clock", inverse: ""),
        .init(code: .elevenoclock, predicate: "at eleven'o'clock", preposition: "from", synonyms: "at 11 o'clock", inverse: ""),
        .init(code: .twelveoclock, predicate: "at twelve'o'clock", preposition: "from", synonyms: "at 12 o'clock", inverse: ""),
        .init(code: .oneoclock, predicate: "at one'o'clock", preposition: "from", synonyms: "at 1 o'clock", inverse: ""),
        .init(code: .twooclock, predicate: "at two'o'clock", preposition: "from", synonyms: "at 2 o'clock", inverse: ""),
        .init(code: .threeoclock, predicate: "at three'o'clock", preposition: "from", synonyms: "at 3 o'clock", inverse: ""),
        .init(code: .fouroclock, predicate: "at four'o'clock", preposition: "from", synonyms: "at 4 o'clock", inverse: ""),
        /// geography
        .init(code: .north, predicate: "north", preposition: "of", inverse: "south"),
        .init(code: .northeast, predicate: "northeast", preposition: "of", inverse: "southwest"),
        .init(code: .east, predicate: "east", preposition: "of", inverse: "west"),
        .init(code: .southeast, predicate: "southeast", preposition: "of", inverse: "northwest"),
        .init(code: .south, predicate: "south", preposition: "of", inverse: "north"),
        .init(code: .southwest, predicate: "southwest", preposition: "of", inverse: "northeast"),
        .init(code: .west, predicate: "west", preposition: "of", inverse: "east"),
        .init(code: .northwest, predicate: "northwest", preposition: "of", inverse: "southeast")
    ]
    
    public static func createSectorTerms() {
        list.append(contentsOf: SpatialTerms.sectorTerms())
    }
    
    public static func sectorSyn(_ pred:SpatialPredicate) -> String {
        let predString = pred.rawValue
        if predString == "i" { return "inside, inner" }
        var str = ""
        var cnt = 0
        for i in 0..<predString.count {
            if cnt > 0 {
                str += "-"
            }
            let char = predString[predString.index(predString.startIndex, offsetBy: i)]
            switch char {
            case "a": str += "ahead"
            case "b": str += "behind"
            case "l": str += "left"
            case "r": str += "right"
            case "o": str += "over"
            case "u": str += "under"
            default: break
            }
            cnt += 1
        }
        return str
    }
    public static func sectorTerms() -> [PredicateTerm] {
        var sectors: [PredicateTerm] = []
        for pred in PredicateCategories.sectors {
            sectors.append(.init(code: pred, predicate: "in sector \(pred.rawValue)", preposition: "of", synonyms: sectorSyn(pred)))
        }
        return sectors
    }
    
    public static func get(_ name: String) -> PredicateTerm? {
        for term in list {
            if term.code.rawValue == name {
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
    
    public static func inverse(_ predicate: String) -> SpatialPredicate {
        let term = SpatialTerms.get(predicate)
        if term != nil && !term!.inverse.isEmpty {
            let result = SpatialTerms.get(term!.inverse)
            if result != nil {
                return result!.code            }
        }
        return .undefined
    }
    
    public static func negation(_ predicate: String) -> SpatialPredicate {
        let term = SpatialTerms.get(predicate)
        if term != nil && !term!.antonym.isEmpty {
            let result = SpatialTerms.get(term!.antonym)
            if result != nil {
                return result!.code            }
        }
        return .undefined
    }
    
    public static func save() {
#if os(macOS)
        let urls = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        if urls.count > 0 {
            let url = urls.first!
            var terms = [Dictionary<String, Any>]()
            for term in SpatialTerms.list {
                terms.append(term.asDict())
            }
            do {
                let fileURL = url.appendingPathComponent("SpatialTerms.json")
                let jsonData = try JSONSerialization.data(withJSONObject: terms, options: [.prettyPrinted, .sortedKeys])
                try jsonData.write(to: fileURL, options: [.atomic])
            } catch {
                print(error)
            }
        }
#endif
    }
}

