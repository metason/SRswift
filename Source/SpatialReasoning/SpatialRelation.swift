//
//  SpatialRelation.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//
//  Spatial relation as triple: subject - spatial predicate - object

import Foundation

class SpatialRelation {
    var subject:SpatialObject // target subject
    var predicate:SpatialPredicate // proposition matching spatial condition and max deviation
    var object:SpatialObject // reference object
    var gap:Float = 0.0 // distance gap: absolute minimimal distance between subject and object
    var angle:Float = 0.0 // deviation of front direction in radiants
    var yaw:Float { // deviation in degrees
        return angle * 180.0 / .pi
    }
    var subjectID:String {
        return subject.id
    }
    var objectID:String {
        return object.id
    }
    
    init(subject:SpatialObject, predicate:SpatialPredicate, object:SpatialObject, gap:Float = 0.0, angle:Float = 0.0) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
        self.gap = gap
        self.angle = angle
    }

    func desc() -> String {
        var str:String = subject.id
        if !subject.label.isEmpty {
            str = subject.label
        } else if !subject.type.isEmpty {
            str = subject.type
        }
        str = str + " " + SpatialTerms.termWithVerbAndPreposition(predicate) + " "
        if !object.label.isEmpty {
            str = str + object.label
        } else if !object.type.isEmpty {
            str = str + object.type
        } else {
            str = str +  object.id
        }
        str = str + String(format: " (\(predicate.rawValue) 𝛥:%.2f  𝜶:%.1f°)", gap, yaw)
        return str
    }
}
