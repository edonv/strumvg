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
public struct Pattern: RawRepresentable, Sendable, Hashable {
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
        
        // if the Timing segment is separated by a barline and there is either:
        // - only 1 measure
        // - more than 1 measure but only 1 Timing segment
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
        
        // validation that for every repeatStart theres a repeatEnd
        var i = 0
        var lookingForRepeatEnd = false
        while i < measures.count {
            let measure = measures[i]
            
            // if this measure is the start of a repeat...
            if measure.repeatStart {
                if measure.repeatEnd {
                    // and it's also the end repeat, continue
                } else if !lookingForRepeatEnd {
                    // and it's NOT the end of a repeat AND it's not actively searching for an end:
                    // start looking for an end in the next measure
                    lookingForRepeatEnd = true
                } else if lookingForRepeatEnd {
                    // and it's actively searching for an end:
                    // FAIL
                    return nil
                }
            } else if measure.repeatEnd {
                // if this measure is the end of a repeat...
                // and it's actively searching for an end:
                if lookingForRepeatEnd {
                    // stop searching, continue to next measure
                    lookingForRepeatEnd = false
                } else {
                    // was not searching:
                    // FAIL
                    return nil
                }
            } else if lookingForRepeatEnd
                        && i == measures.count - 1 {
                // if this measure is not start or end of a repeat,
                // AND it's searching for an end,
                // AND it's the last measure:
                // FAIL
                return nil
            } else {
                // otherwise continue
            }
            
            i += 1
        }
    }
    
    public var rawValue: String {
        measures
            .map(\.rawValue)
            .joined(separator: "|")
    }
}
