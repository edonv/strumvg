//
//  Timing.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder
import Parsing

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
            case .quarter:
                return 1
            case .eighth:
                return 2
            case .sixteenth:
                return 4
            }
        }
    }
    
    public static func parser() -> AnyParserPrinter<Substring, Timing> {
        ParsePrint(.memberwise(Timing.init)) {
            "-"
            
            NoteDuration.parser()
            
            Optionally { "t" }
                .map(.convert { captured in
                    captured != nil
                } unapply: {
                    $0 ? () : Optional.some(nil)
                })
        }
        .eraseToAnyParserPrinter()
    }
    
    /// `/-(?<time>4|8|16)(?<triplet>t)?/`
    internal static var regex: Regex<(Substring, time: Substring, triplet: Substring?)> {
        /-(?<time>4|8|16)(?<triplet>t)?/
    }
    
    internal var rhythmGroupingRegexCountRange: ClosedRange<Int> {
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
