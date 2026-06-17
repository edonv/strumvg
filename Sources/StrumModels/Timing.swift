//
//  Timing.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder

public enum NoteDuration: Int, Sendable, Hashable {
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

public struct Timing: RawRepresentable, Sendable, Hashable {
    public let duration: NoteDuration
    public let triplet: Bool
    
    public init(duration: NoteDuration, triplet: Bool) {
        self.duration = duration
        self.triplet = triplet
    }
    
    /// `rawValue` can include other content, but will initialize from first match of a valid pattern.
    public init?(rawValue: String) {
        let timingRegex = Timing.regex
        
        guard let timingMatch = try? timingRegex.firstMatch(in: rawValue)?.output,
              let durationInt = Int(timingMatch.time),
              let duration = NoteDuration(rawValue: durationInt) else { return nil }
        
        self.init(duration: duration, triplet: timingMatch.triplet != nil)
    }
    
    public var rawValue: String {
        "-\(duration.rawValue)\(triplet ? "t" : "")"
    }
    
    /// The (maximum) number of note stems per group, depending on the type of `Timing`.
    public var stemsPerGroup: Int {
        switch self.triplet {
        case true:
            return 3
        case false:
            switch duration {
            // TODO: this should be 1, but currently, if there's an odd number of strums, the last one won't have a stem. currently, it gets padded to have an odd number
            case .quarter:
                return 2
            case .eighth:
                return 2
            // TODO: this should be 4, but currently, if there's an odd number of strums, the last one won't have a stem. currently, it gets padded to have an even number. sets of 4 should be rendered linked
            case .sixteenth:
                return 2
            }
        }
    }
    
    /// `/-(?<time>4|8|16)(?<triplet>t)?/`
    internal static var regex: Regex<(Substring, time: Substring, triplet: Substring?)> {
        /-(?<time>4|8|16)(?<triplet>t)?/
    }
    
    private var rhythmGroupingRegexCountRange: ClosedRange<Int> {
        switch self.triplet {
        case true:
            1...stemsPerGroup
        case false:
            switch duration {
            case .quarter: 1...1
            case .eighth: 1...2
            case .sixteenth: 1...4
            }
        }
    }
    
    internal var rhythmicGroupingRegex: Regex<(Substring, Substring)> {
        Regex {
            Capture {
                Repeat(self.rhythmGroupingRegexCountRange) {
                    ChoiceOf {
                        CharacterClass.anyOf("{}")
                            .inverted
                        Regex {
                            "{"
                            Repeat(CharacterClass.anyNonNewline, 1...2)
                            "}"
                        }
                    }
                }
            }
            
            Lookahead {
                // /.*-4$/
                ZeroOrMore(CharacterClass.anyNonNewline)
                
                self.rawValue
                
                Anchor.endOfSubject
            }
        }
    }
}
