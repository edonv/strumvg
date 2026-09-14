//
//  Pattern.swift
//  strumvg
//
//  Created by Edon Valdman on 6/12/26.
//

import Foundation
import RegexBuilder

/// A strumming pattern.
public struct Pattern: Sendable, Hashable {
    public let measures: [Measure]
    
    public init(measures: [Measure]) {
        self.measures = measures
    }
    
    /// An initializer only used internally when parsing a pattern.
    ///
    /// It might fail due to error.
    private init(drafts: [Measure.Draft]) throws {
        self.measures = try drafts.reduce(into: []) { partialResult, draft in
            // Sometimes, it captures an empty measure at the end
            if partialResult.count == drafts.count - 1
                && draft.strums.isEmpty {
                return
            }
            
            guard let prevTiming = partialResult.last?.timing else {
                if let measure = draft.confirmingTiming() {
                    partialResult.append(measure)
                    return
                } else {
                    throw ParsingError.firstMeasureMissingTiming
                }
            }
            
            partialResult.append(
                draft.using(timing: prevTiming)
            )
        }
    }
    
    private var drafts: [Measure.Draft] {
        measures.reduce(into: []) { partialResult, measure in
            let timing: Timing?
            if partialResult.isEmpty
                || partialResult.last?.timing != measure.timing {
                timing = measure.timing
            } else {
                timing = nil
            }
            
            partialResult.append(
                .init(
                    repeatStart: measure.repeatStart,
                    timing: timing,
                    strums: measure.strums,
                    repeatEnd: measure.repeatEnd
                )
            )
        }
    }
    
    /// Validates that for every ``repeatStart`` theres a ``repeatEnd``.
    /// - Returns: Boolean describing if the patterns repeats are valid.
    private func validateRepeats() -> Bool {
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
                    return false
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
                    return false
                }
            } else if lookingForRepeatEnd
                        && i == measures.count - 1 {
                // if this measure is not start or end of a repeat,
                // AND it's searching for an end,
                // AND it's the last measure:
                // FAIL
                return false
            } else {
                // otherwise continue
            }
            
            i += 1
        }
        
        return true
    }
}
