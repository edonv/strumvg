//
//  NoteDuration.swift
//  strumvg
//
//  Created by Edon Valdman on 9/13/26.
//

import Foundation

public enum NoteDuration: Int, CaseIterable, Sendable, Hashable {
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
    
    package var restPathReuseID: String {
        switch self {
        case .quarter: "quarterRest"
        case .eighth: "eighthRest"
        case .sixteenth: "sixteenthRest"
        }
    }
}
