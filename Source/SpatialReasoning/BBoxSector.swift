//
//  BBoxSector.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 16.11.2024.
//

import Foundation

// Directional 3x3x3 BBox Sector Matrix (27 object-related boundary sectors)
struct BBoxSector : OptionSet, Hashable {
    let rawValue: Int
    static let i = BBoxSector(rawValue: 1 << 0) // i : inside, inner
    static let a = BBoxSector(rawValue: 1 << 1) // a : ahead
    static let b = BBoxSector(rawValue: 1 << 2) // b : behind
    static let l = BBoxSector(rawValue: 1 << 3) // l : left
    static let r = BBoxSector(rawValue: 1 << 4) // r : right
    static let o = BBoxSector(rawValue: 1 << 5) // o : over
    static let u = BBoxSector(rawValue: 1 << 6) // u : under
    static let al: BBoxSector = [.a, .l]
    static let ar: BBoxSector = [.a, .r]
    static let bl: BBoxSector = [.b, .l]
    static let br: BBoxSector = [.b, .r]
    static let ao: BBoxSector = [.a, .o]
    static let au: BBoxSector = [.a, .u]
    static let bo: BBoxSector = [.b, .o]
    static let bu: BBoxSector = [.b, .u]
    static let lo: BBoxSector = [.l, .o]
    static let lu: BBoxSector = [.l, .u]
    static let ro: BBoxSector = [.r, .o]
    static let ru: BBoxSector = [.r, .u]
    static let alo: BBoxSector = [.a, .l, .o]
    static let aro: BBoxSector = [.a, .r, .o]
    static let blo: BBoxSector = [.b, .l, .o]
    static let bro: BBoxSector = [.b, .r, .o]
    static let alu: BBoxSector = [.a, .l, .u]
    static let aru: BBoxSector = [.a, .r, .u]
    static let blu: BBoxSector = [.b, .l, .u]
    static let bru: BBoxSector = [.b, .r, .u]
    
    var hashValue: Int {
        return self.rawValue
    }
    
    // amount of divergency from inner zone in all 3 directions
    func divergencies() -> Int {
        if self.contains(.i) {
            return 0
        }
        return self.rawValue.nonzeroBitCount
    }
}

extension BBoxSector: CustomStringConvertible {

    static let debugDescriptions: [BBoxSector:String] = {
        var descriptions = [BBoxSector:String]()
        descriptions[.i] = "i"
        descriptions[.a] = "a"
        descriptions[.b] = "b"
        descriptions[.l] = "l"
        descriptions[.r] = "r"
        descriptions[.o] = "o"
        descriptions[.u] = "u"
        descriptions[.al] = "al"
        descriptions[.ar] = "ar"
        descriptions[.bl] = "bl"
        descriptions[.br] = "br"
        descriptions[.ao] = "ao"
        descriptions[.au] = "au"
        descriptions[.bo] = "bo"
        descriptions[.bu] = "bu"
        descriptions[.lo] = "lo"
        descriptions[.lu] = "lu"
        descriptions[.ro] = "ro"
        descriptions[.ru] = "ru"
        descriptions[.alo] = "alo"
        descriptions[.aro] = "aro"
        descriptions[.blo] = "blo"
        descriptions[.bro] = "bro"
        descriptions[.alu] = "alu"
        descriptions[.aru] = "aru"
        descriptions[.blu] = "blu"
        descriptions[.bru] = "bru"
        return descriptions
    }()

    public var description: String {
        let description = BBoxSector.debugDescriptions[self]
        return description ?? "undefined sector"
    }
    
}
