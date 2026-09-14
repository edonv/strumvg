//
//  NoteDuration.swift
//  strumvg
//
//  Created by Edon Valdman on 9/13/26.
//

import Foundation

public enum NoteDuration: Int, Sendable, Hashable, CaseIterable, Comparable {
    case half = 2
    case quarter = 4
    case eighth = 8
    case sixteenth = 16
    
    public var beamBarCount: Int {
        switch self {
        case .quarter: 0
        case .eighth: 1
        case .sixteenth: 2
        }
    }
    
    public var stemLengthRatio: CGFloat {
        switch self {
        case .half: 0.5
        default: 1
        }
    }
    
    package var restPathReuseID: String {
        switch self {
        case .quarter: "quarterRest"
        case .eighth: "eighthRest"
        case .sixteenth: "sixteenthRest"
        }
    }
    
    public static func <(lhs: NoteDuration, rhs: NoteDuration) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
