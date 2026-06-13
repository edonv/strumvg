//
//  Measure.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder

/// A measure (or bar) of strumming.
///
/// Raw value: `[pattern]-[noteLength]`
public struct Measure: RawRepresentable, Sendable, Hashable {
    /// An array of rhythmic groupings.
    public let groups: [RhythmicGroup]
    /// A specification describing how the groups' timings should be grouped.
    public let timing: Timing
    
    public var totalStrums: Int {
        groups.flatMap(\.strums).count
    }
    
    public init(groups: [RhythmicGroup], timing: Timing) {
        self.groups = groups
        self.timing = timing
    }
    
    /// - Returns: A validated `Measure`, or `nil` if the `timing` component is missing.
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
            .replacing(/([^\{\}\n])(?![^\{\}\n]?\})(?=.*$)/.anchorsMatchLineEndings()) { match in
                return "{\(match.output.1)}"
            }
            // Trim only newlines in case there is intentional leading whitespace in the strums
            .trimmingCharacters(in: .newlines)
        
//        print(groupStrumsByRhythm)
        
        // Split by inserted new lines to get each group separately
        var groupsTemp = groupStrumsByRhythm
            .components(separatedBy: "\n")
            // .components(separatedBy:) can result in empty items
            .filter { !$0.isEmpty }
            .compactMap(RhythmicGroup.init(rawValue:))
        
        // If the measure doesn't have the correct number of strums for the appropriate `timing`,
        // add extra spaces to fill it out
        if !groupsTemp.isEmpty,
           let lastGroup = groupsTemp.last,
           lastGroup.strums.count < timing.stemsPerGroup {
            groupsTemp[groupsTemp.count - 1] = lastGroup.appending(
                strums: .init(
                    repeating: .init(kind: .space),
                    count: timing.stemsPerGroup - lastGroup.strums.count
                )
            )
        }
        
        self.groups = groupsTemp
    }
    
    public var rawValue: String {
        groups
            .flatMap(\.strums)
            .map(\.rawValue)
            .joined()
        + "\(timing.rawValue)"
    }
}
