//
//  Pattern.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

public struct Pattern: RawRepresentable {
    public let groups: [RhythmicGroup]
    public let timing: Timing
    
    public var totalStrums: Int {
        groups.flatMap(\.strums).count
    }
    
    init(groups: [RhythmicGroup], timing: Timing) {
        self.groups = groups
        self.timing = timing
    }
    
    /// - Returns: A validated `Pattern`, or `nil` if the `timing` component is missing.
    public init?(rawValue: String) {
        // Strums
        
        /// Each strum element on their own lines
        let groupStrumsByRhythm = rawValue
            // Trim only newlines in case there is intentional leading whitespace in the strums
            .trimmingCharacters(in: .newlines)
            // 1/4
            .replacing(/((?:(?:[^\{\}])|(?:\{.\})){1})(?=.*-4$)/) { match in
                return "\(match.output.1)\n"
            }
            // 1/8
//            .replace(/((?:(?:[^\{\}])|(?:\{.\})){1,2})(?=.*(-8)$)/g, '{$1}$2\n')
            .replacing(/((?:(?:[^\{\}])|(?:\{.\})){1,2})(?=.*-8$)/) { match in
                return "\(match.output.1)\n"
            }
            // 1/16
//            .replace(/((?:(?:[^\{\}])|(?:\{.\})){1,4})(?=.*(-16)$)/g, '{$1}$2\n')
            .replacing(/((?:(?:[^\{\}])|(?:\{.\})){1,4})(?=.*-16$)/) { match in
                return "\(match.output.1)\n"
            }
            // 1/4t, 1/8t, 1/16t
//            .replace(/((?:(?:[^\{\}])|(?:\{.\})){1,3})(?=.*(-(?:4|8|16)t)$)/g, '{$1}$2\n');
            .replacing(/((?:(?:[^\{\}])|(?:\{.{2}\})){1,3})(?=.*-(?:4|8|16)t$)/) { match in
                return "\(match.output.1)\n"
            }
            // remove original trailing noteLength
            .replacing(/\n-(?:4|8|16)t?$/, with: "")
            // group all individual strum chars in curly braces
            .replacing(/([^\{\}\n])(?!.*\})(?=.*$)/.anchorsMatchLineEndings()) { match in
                return "{\(match.output.1)}"
            }
            // Trim only newlines in case there is intentional leading whitespace in the strums
            .trimmingCharacters(in: .newlines)
        
//        print(groupStrumsByRhythm)
        
        // Split by inserted new lines to get each group separately
        self.groups = groupStrumsByRhythm
            .components(separatedBy: "\n")
            // .components(separatedBy:) can result in empty items
            .filter { !$0.isEmpty }
            .compactMap(RhythmicGroup.init(rawValue:))
        
        // Timing
        
        let timingRegex = /-(?<time>\d+)(?<triplet>t)?$/
        
        guard let timingMatch = try? timingRegex.firstMatch(in: rawValue)?.output,
              let durationInt = Int(timingMatch.time),
              let duration = NoteDuration(rawValue: durationInt) else { return nil }
        
        self.timing = .init(duration: duration, triplet: timingMatch.triplet != nil)
    }
    
    public var rawValue: String {
        groups
            .flatMap(\.strums)
            .map(\.rawValue)
            .joined()
        + "-\(timing.duration.rawValue)\(timing.triplet ? "t" : "")"
    }
}
