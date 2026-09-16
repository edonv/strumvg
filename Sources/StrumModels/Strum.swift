//
//  Strum.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import Parsing

/// An instance of a strum in a pattern.
///
/// It contains a reference of the type of strum and an optional heading character.
public struct Strum: Sendable, Hashable {
    public let kind: Kind
    public let headingChar: Character?
    
    public var direction: Direction? {
        kind.direction
    }
    
    public var variant: Variant {
        kind.variant
    }
    
    public init(kind: Kind, heading: Character? = nil) {
        self.kind = kind
        self.headingChar = heading
    }
    
    public static var down: Strum { .init(kind: .down) }
    public static var up: Strum { .init(kind: .up) }
    public static var space: Strum { .init(kind: .space) }
    public static var downMuted: Strum { .init(kind: .downMuted) }
    public static var upMuted: Strum { .init(kind: .upMuted) }
    public static var downArpeggio: Strum { .init(kind: .downArpeggio) }
    public static var upArpeggio: Strum { .init(kind: .upArpeggio) }
    public static var rest: Strum { .init(kind: .rest) }

    public static func other(_ char: Character) -> Strum {
        .init(kind: .other(char))
    }
    
    /// Returns a copy of this `Strum` with an updated ``headingChar``.
    public func withHeading(_ heading: Character) -> Strum {
        .init(kind: kind, heading: heading)
    }
    
    public static func parser() -> AnyParserPrinter<Substring, Strum> {
        OneOf {
            ParsePrint {
                "{"
                Prefix(1)
                    .map(.string)
                Kind.parser()
                "}"
            }
            .map(.convert { (str: String, kind: Kind) in
                Strum(kind: kind, heading: str.first)
            } unapply: { strum in
                guard let heading = strum.headingChar else { return nil }
                return ("\(heading)", strum.kind)
            })
            
            Kind.parser()
                .map(.convert(apply: { kind in
                    Strum(kind: kind)
                }, unapply: { strum in
                    guard strum.headingChar == nil else { return nil }
                    return strum.kind
                }))
        }
        .eraseToAnyParserPrinter()
    }
}
