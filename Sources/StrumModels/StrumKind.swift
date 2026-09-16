//
//  StrumKind.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import Parsing

extension Strum {
    /// A type of strum.
    public struct Kind: RawRepresentable, Sendable, Hashable {
        /// The variation of the strum.
        public let variant: Variant
        /// The direction of the strum, optionally.
        public let direction: Direction?
        
        public static let down = Kind(variant: .normal, direction: .down)
        public static let up = Kind(variant: .normal, direction: .up)
        public static let space = Kind(variant: .space, direction: nil)
        public static let downMuted = Kind(variant: .muted, direction: .down)
        public static let upMuted = Kind(variant: .muted, direction: .up)
        public static let downArpeggio = Kind(variant: .arpeggio, direction: .down)
        public static let upArpeggio = Kind(variant: .arpeggio, direction: .up)
        public static let rest = Kind(variant: .rest, direction: nil)
        
        public static func other(_ char: Character) -> Kind {
            Kind(variant: .other(char), direction: nil)
        }
        
        internal init(variant: Variant, direction: Direction?) {
            self.variant = variant
            self.direction = direction
        }
        
        public init(rawValue: Character) {
            switch rawValue {
            case "D", "d":
                self = .down
            case "u", "U":
                self = .up
            case "M":
                self = .downMuted
            case "m":
                self = .upMuted
            case "A":
                self = .downArpeggio
            case "a":
                self = .upArpeggio
            case " ":
                self = .space
            case "r":
                self = .rest
            default:
                self = .other(rawValue)
            }
        }
        
        public var rawValue: Character {
            self.variant.character(for: self.direction)
        }
        
        public static func parser() -> AnyParserPrinter<Substring, Kind> {
            OneOf(input: Substring.self, output: Kind.self) {
                OneOf {
                    "D"
                    "d"
                }
                .map { .down }
                
                OneOf {
                    "u"
                    "U"
                }
                .map { .up }
                
                "M".map { .downMuted }
                "m".map { .upMuted }
                
                "A".map { .downArpeggio }
                "a".map { .upArpeggio }
                
                " ".map { .space }
                "r".map { .rest }
                
                // Any character that is not a repeat sign or barline
                Prefix(1)
                    .filter { str in
                        ![":", "|"].contains(str)
                    }
                    .compactMap(\.first)
                    .map(Kind.other)
            }
            .printing { kind, substring in
                substring.prepend(kind.rawValue)
            }
            .eraseToAnyParserPrinter()
        }
    }
}

/**
 - `D`/`d`: Down-stroke
 - `u`/`U`: Up-stroke
 - `M`: Muted down-stroke
 - `m`: Muted up-stroke
 - `A`: Arpeggio down-stroke
 - `a`: Arpeggio up-stroke
 - <code>&nbsp;</code>: Pause
 - `r`: Rest
 - Any other character (except for `-`) is just inserted
*/
