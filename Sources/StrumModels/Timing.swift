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
    
    package var restPathReuseID: String {
        switch self {
        case .quarter: "quarterRest"
        case .eighth: "eighthRest"
        case .sixteenth: "sixteenthRest"
        }
    }
}

public struct Timing: RawRepresentable {
    public let duration: NoteDuration
    public let triplet: Bool
    
    public init(duration: NoteDuration, triplet: Bool) {
        self.duration = duration
        self.triplet = triplet
    }
    
    /// `rawValue` can include other content, but will initialize from first match of a valid pattern.
    public init?(rawValue: String) {
        let timingRegex = /-(?<time>\d+)(?<triplet>t)?/
        
        guard let timingMatch = try? timingRegex.firstMatch(in: rawValue)?.output,
              let durationInt = Int(timingMatch.time),
              let duration = NoteDuration(rawValue: durationInt) else { return nil }
        
        self.init(duration: duration, triplet: timingMatch.triplet != nil)
    }
    
    public var rawValue: String {
        "-\(duration.rawValue)\(triplet ? "t" : "")"
    }
}
