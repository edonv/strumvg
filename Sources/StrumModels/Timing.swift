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
    
    /// The ``EffectiveDuration`` that should be rendered, based on the combination of ``duration`` and ``subdivision``.
    package var effectiveDuration: EffectiveDuration {
        // .half + .four (2/4) = 8th notes
        // .half + .three (2/3) = 4th notes
        // .half + .two (2/2) = 4th notes
        // .half + .one (2[/1]) = 2nd notes
        
        .init(timing: self)
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

// MARK: - EffectiveDuration

extension Timing {
    /// The "effective duration" that a ``Timing`` value represents, based on the combination of its ``Timing/duration`` and ``Timing/subdivision``.
    package struct EffectiveDuration: Sendable, Hashable {
        /// The denominator of the note duration fraction.
        package let duration: Int
        package let beamBarCount: Int
        package let stemLengthRatio: CGFloat
        
        /// Just for testing.
        internal init(
            duration: Int,
            beamBarCount: Int,
            stemLengthRatio: CGFloat
        ) {
            self.duration = duration
            self.beamBarCount = beamBarCount
            self.stemLengthRatio = stemLengthRatio
        }
        
        package init(timing: Timing) {
            switch timing.subdivision {
            case .one:
                self.duration = timing.duration.rawValue
                self.beamBarCount = timing.duration.beamBarCount
                self.stemLengthRatio = timing.duration.stemLengthRatio
            default:
                let noteDurationDiff = switch timing.subdivision {
                case .one: 0
                case .two, .three: 1
                case .four: 2
                }
                
                let index = NoteDuration.allCases.firstIndex(of: timing.duration)!
                let effectiveIndex = index + noteDurationDiff
                
                if effectiveIndex < NoteDuration.allCases.count {
                    self.duration = NoteDuration.allCases[effectiveIndex].rawValue
                    self.beamBarCount = NoteDuration.allCases[effectiveIndex].beamBarCount
                } else {
                    let extraBeamsPastLastCase = effectiveIndex - NoteDuration.allCases.count - 1
                    self.duration = Int(
                        pow(
                            Float(2),
                            Float(NoteDuration.allCases.count + extraBeamsPastLastCase)
                        )
                    )
                    self.beamBarCount = NoteDuration.allCases.last!.beamBarCount + extraBeamsPastLastCase
                }
                
                self.stemLengthRatio = timing.duration.stemLengthRatio
            }
        }
    }
}
