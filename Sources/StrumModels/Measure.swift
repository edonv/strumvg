//
//  Measure.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder
import Parsing

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
    
    /// A ``Measure`` that might be missing `timing`. Used while parsing a ``Pattern``.
    internal struct Draft: Sendable, Hashable {
        let repeatStart: Bool
        let timing: Timing?
        let strums: [Strum]
        let repeatEnd: Bool
        
        func confirmingTiming() -> Measure? {
            guard let timing else { return nil }
            return .init(
                strums: strums,
                timing: timing,
                repeatStart: repeatStart,
                repeatEnd: repeatEnd
            )
        }
        
        func using(timing newTiming: Timing) -> Measure {
            if let timing {
                .init(
                    strums: strums,
                    timing: timing,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd
                )
            } else {
                .init(
                    strums: strums,
                    timing: newTiming,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd
                )
            }
        }
        
        /// This parser is reached with a string that has already had its barlines stripped from it, but will still have repeat signs and might not have its Timing portion on its end.
        ///
        /// The incoming format will be `[:][timing-]<pattern>[:]`.
        static func parser() -> AnyParserPrinter<Substring, Draft> {
            ParsePrint(.memberwise(Draft.init)) {
                // repeatStart
                repeatSignParser()
                
                Optionally {
                    Timing.parser()
                }
                
                Many {
                    Strum.parser()
                }
                
                // repeatEnd
                repeatSignParser()
            }
            .eraseToAnyParserPrinter()
        }
        
        private static func repeatSignParser() -> AnyParserPrinter<Substring, Bool> {
            Optionally { ":" }
                .map(.convert { captured in
                    captured != nil
                } unapply: { repeats in
                    repeats ? () : Optional.some(nil)
                })
                .eraseToAnyParserPrinter()
        }
    }
}
