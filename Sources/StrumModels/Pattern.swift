//
//  Pattern.swift
//  strumvg
//
//  Created by Edon Valdman on 6/12/26.
//

import Foundation
import RegexBuilder

/// A strumming pattern.
///
/// Raw value: `[measure]+` (separated by `"|"`), each measure can end with `-[timing]`
///
/// Can also have a timing identifier at the end of the full string to represent for the full pattern.
public struct Pattern: RawRepresentable {
    public let measures: [Measure]
    
    public init(measures: [Measure]) {
        self.measures = measures
    }
    
    /// - Returns: A validated `Pattern`, or `nil` if the format is invalid.
    public init?(rawValue: String) {
        let timingRegexMatches = rawValue.matches(of: Timing.regex)
        
        guard !timingRegexMatches.isEmpty else { return nil }
        
        var rhythmGroupsByMeasure = rawValue
            // Trim only newlines in case there is intentional leading whitespace in the strums
            .trimmingCharacters(in: .newlines)
            .split(separator: "|")
            // Initial clean-up
            .map { measureStr in
                measureStr
                    // Trim only newlines in case there is intentional leading whitespace in the strums
                    .trimmingCharacters(in: .newlines)
                    // Remove any remaining barlines in each measure
                    .replacingOccurrences(of: "|", with: "")
            }
        
        // if there is more than 1 group (or there's just 1 group AND the Timing segment is separated by a barline)
        if timingRegexMatches.count == 1
            && rhythmGroupsByMeasure.count > 1,
           let firstMatch = timingRegexMatches.first,
           let timing = Timing(rawValue: String(firstMatch.output.0)) {
            // remove only timing string
            if let index = rhythmGroupsByMeasure.firstIndex(of: timing.rawValue) {
                rhythmGroupsByMeasure.remove(at: index)
            }
            
            // append each measure string with the timing string
            rhythmGroupsByMeasure = rhythmGroupsByMeasure
                .map { segment in
                    guard !segment.contains(timing.rawValue) else { return segment }
                    return segment + timing.rawValue
                }
        }
        
        self.measures = rhythmGroupsByMeasure
//            .compactMap(Measure.init(rawValue:))
            .map { Measure(rawValue: $0)! }
    }
    
    public var rawValue: String {
        measures
            .map(\.rawValue)
            .joined(separator: "|")
    }
}
