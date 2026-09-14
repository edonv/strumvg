//
//  Timing.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import Parsing

// MARK: - Timing

public struct Timing: Sendable, Hashable {
    public let duration: NoteDuration
    public let subdivision: Subdivision
    public let tuplet: Bool
    
    /// Creates a new `Timing` specification.
    /// - Parameters:
    ///   - duration: The note duration of each beat.
    ///   - subdivision: Defaults to ``Subdivision/one``.
    ///   - tuplet: A boolean describing if the subdivision of each beat should be labeled as a tuplet.
    public init(
        duration: NoteDuration,
        subdivision: Subdivision? = nil,
        tuplet: Bool
    ) {
        self.duration = duration
        self.subdivision = subdivision ?? .one
        self.tuplet = tuplet
    }
    
    /// The (maximum) number of note stems per group, depending on the type of `Timing`.
    ///
    /// Returns ``subdivision``'s count.
    public var stemsPerGroup: Int {
        subdivision.rawValue
    }
    
    public static func parser() -> AnyParserPrinter<Substring, Timing> {
        ParsePrint {
            NoteDuration.parser()
            
            Optionally {
                "/"
                Subdivision.parser()
            }
            
            Optionally { "t" }
                .map(.convert { captured in
                    captured != nil
                } unapply: {
                    $0 ? () : Optional.some(nil)
                })
            
            "-"
        }
        .map(.convert(apply: { (duration, subdivision, tuplet) in
            Timing(duration: duration, subdivision: subdivision, tuplet: tuplet)
        }, unapply: { timing in
            (timing.duration, timing.subdivision, timing.tuplet)
        }))
        .eraseToAnyParserPrinter()
    }
}

// MARK: - Subdivision

extension Timing {
    public enum Subdivision: Int, Sendable, Hashable, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
    }
}
