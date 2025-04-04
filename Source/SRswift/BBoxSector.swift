//
//  BBoxSector.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 16.11.2024.
//

import Foundation

// Directional 3x3x3 BBox Sector Matrix (27 object-related boundary sectors)
public struct BBoxSector : OptionSet, Hashable, Sendable {
    public let rawValue: Int
    public static let none = BBoxSector([]) // none : no sector specified
    public static let i = BBoxSector(rawValue: 1 << 0) // i : inside, inner
    public static let a = BBoxSector(rawValue: 1 << 1) // a : ahead
    public static let b = BBoxSector(rawValue: 1 << 2) // b : behind
    public static let l = BBoxSector(rawValue: 1 << 3) // l : left
    public static let r = BBoxSector(rawValue: 1 << 4) // r : right
    public static let o = BBoxSector(rawValue: 1 << 5) // o : over
    public static let u = BBoxSector(rawValue: 1 << 6) // u : under
    public static let al: BBoxSector = [.a, .l]
    public static let ar: BBoxSector = [.a, .r]
    public static let bl: BBoxSector = [.b, .l]
    public static let br: BBoxSector = [.b, .r]
    public static let ao: BBoxSector = [.a, .o]
    public static let au: BBoxSector = [.a, .u]
    public static let bo: BBoxSector = [.b, .o]
    public static let bu: BBoxSector = [.b, .u]
    public static let lo: BBoxSector = [.l, .o]
    public static let lu: BBoxSector = [.l, .u]
    public static let ro: BBoxSector = [.r, .o]
    public static let ru: BBoxSector = [.r, .u]
    public static let alo: BBoxSector = [.a, .l, .o]
    public static let aro: BBoxSector = [.a, .r, .o]
    public static let blo: BBoxSector = [.b, .l, .o]
    public static let bro: BBoxSector = [.b, .r, .o]
    public static let alu: BBoxSector = [.a, .l, .u]
    public static let aru: BBoxSector = [.a, .r, .u]
    public static let blu: BBoxSector = [.b, .l, .u]
    public static let bru: BBoxSector = [.b, .r, .u]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var hashValue: Int {
        return self.rawValue
    }
    
    // amount of divergency from inner zone in all 3 directions
    public func divergencies() -> Int {
        if self.contains(.i) {
            return 0
        }
        return self.rawValue.nonzeroBitCount
    }
}

extension BBoxSector: CustomStringConvertible {

    public static let debugDescriptions: [BBoxSector:String] = {
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
        return description ?? "no sector"
    }
    
}
