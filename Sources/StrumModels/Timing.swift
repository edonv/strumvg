//
//  Timing.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

public enum NoteDuration: Int {
    case quarter = 4
    case eighth = 8
    case sixteenth = 16
    
    public var horizontalStrokeCount: Int {
        switch self {
        case .quarter: 0
        case .eighth: 1
        case .sixteenth: 2
        }
    }
}

public struct Timing {
    public let duration: NoteDuration
    public let triplet: Bool
}
