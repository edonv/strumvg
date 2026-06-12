//
//  Pattern.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder

public struct Pattern: RawRepresentable {
    public let groups: [RhythmicGroup]
    public let timing: Timing
    
    public var totalStrums: Int {
        groups.flatMap(\.strums).count
    }
    
    public init(groups: [RhythmicGroup], timing: Timing) {
        self.groups = groups
        self.timing = timing
    }
    
    /// - Returns: A validated `Pattern`, or `nil` if the `timing` component is missing.
    public init?(rawValue: String) {
        // Timing
        
        guard let timing = Timing(rawValue: rawValue) else { return nil }
        self.timing = timing
        
        // Strums
        
        /// Each strum element on their own lines
        let groupStrumsByRhythm = rawValue
            // Trim only newlines in case there is intentional leading whitespace in the strums
            .trimmingCharacters(in: .newlines)
            // Regex for whatever `timing` is
            .replacing(timing.rhythmicGroupingRegex) { match in
                "\(match.output.1)\n"
            }
            // remove original trailing noteLength
            .replacing {
                "\n"
                Timing.regex
                Anchor.endOfSubject
            } with: { _ in "" }
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
    }
    
    public var rawValue: String {
        groups
            .flatMap(\.strums)
            .map(\.rawValue)
            .joined()
        + "-\(timing.duration.rawValue)\(timing.triplet ? "t" : "")"
    }
}
