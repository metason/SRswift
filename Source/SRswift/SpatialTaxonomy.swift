//
//  SpatialTaxanomy.swift
//  SRswift
//
//  Created by Philipp Ackermann on 23.03.2025.
//

import Foundation

class SpatialObjectConcept : Hashable, Identifiable {

    init(label:String, parent:SpatialObjectConcept? = nil) {
        self.label = label
        self.parent = parent
    }
    
    var id:String {
        label
    }
    var label:String
    var synonyms:[String]? = nil
    var parent:SpatialObjectConcept? = nil
    var children:[SpatialObjectConcept]? = nil
    
    static func == (lhs: PredicateNode, rhs: PredicateNode) -> Bool {
        lhs.label == rhs.label
    }
    
}

public struct SpatialTaxanomy {
    nonisolated(unsafe) static let list: [PredicateTerm]
    
}
