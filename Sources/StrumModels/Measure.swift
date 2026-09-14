//
//  Measure.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder

/// A measure (or bar) of strumming.
public struct Measure: Sendable, Hashable {
    /// An array of rhythmic groupings.
    public let groups: [RhythmicGroup]
    /// A specification describing how the groups' timings should be grouped.
    public let timing: Timing
    public let repeatStart: Bool
    public let repeatEnd: Bool
    
    public var strums: [Strum] {
        groups.flatMap(\.strums)
    }
    public var totalStrums: Int {
        strums.count
    }
    
    /// Create a `Measure` of strums.
    ///
    /// Internally, `strums` will be split into groups according to `timing` and its ``Timing/subdivision``.
    ///
    /// Additionally, if `strums` doesn't have enough strums to make a full final rhythmic group of subdivisions, the final group will be padded at the end with empty ``StrumKind/space`` strums.
    /// - Parameters:
    ///   - strums: The strums to include in the measure.
    ///   - timing: The timing for laying out the strums.
    ///   - repeatStart: If the measure should include the start of a repeat.
    ///   - repeatEnd: If the measure should include the end of a repeat.
    public init(
        strums: [Strum],
        timing: Timing,
        repeatStart: Bool = false,
        repeatEnd: Bool = false
    ) {
        // Group the strums based on `timing`
        self.groups = strums
            .reduce(into: [[Strum]]()) { partialResult, strum in
                guard !partialResult.isEmpty else {
                    partialResult.append([strum])
                    return
                }
                
                var lastIndex = partialResult.count - 1
                // append an empty array once limit is reached
                if partialResult[lastIndex].count + 1 > timing.stemsPerGroup {
                    partialResult.append([])
                    lastIndex += 1
                }
                
                partialResult[lastIndex].append(strum)
                
                // if this is the final strum and there's still room in the rhythmic grouping,
                // then pad the end with spaces
                if partialResult.flatMap({ $0 }).count == strums.count {
                    while timing.stemsPerGroup > partialResult[lastIndex].count {
                        partialResult[lastIndex].append(.init(kind: .space))
                    }
                }
            }
            .map(RhythmicGroup.init)
        
        self.timing = timing
        self.repeatStart = repeatStart
        self.repeatEnd = repeatEnd
    }
}
