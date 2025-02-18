//
//  SpatialRelation.swift
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 11.11.2024.
//  Copyright © 2024 Philipp Ackermann. All rights reserved.
//
//  Spatial relation as triple: subject - spatial predicate - object

import Foundation

public class SpatialRelation {
    public var subject:SpatialObject // target subject
    public var predicate:SpatialPredicate // proposition matching spatial condition and max deviation
    public var object:SpatialObject // reference object
    public var delta:Float = 0.0 // difference of predicate value between subject and object, e.g. distance
    public var angle:Float = 0.0 // angle deviation of object direction in radiants
    public var yaw:Float { // deviation in degrees
        return angle * 180.0 / .pi
    }
    public var subjectID:String {
        return subject.id
    }
    public var objectID:String {
        return object.id
    }
    
    public init(subject: SpatialObject, predicate: SpatialPredicate, object: SpatialObject, delta:Float = 0.0, angle:Float = 0.0) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
        self.delta = delta
        self.angle = angle
    }

    public func desc() -> String {
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
        str = str + String(format: " (\(predicate.rawValue) 𝛥:%.2f  𝜶:%.1f°)", delta, yaw)
        return str
    }
}
