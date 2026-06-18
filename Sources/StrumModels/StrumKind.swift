//
//  StrumKind.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

/// A type of strum.
public struct StrumKind: RawRepresentable, Sendable, Hashable {
    /// The variation of the strum.
    public let variant: Variant
    /// The direction of the strum, optionally.
    public let direction: Direction?
    
    public static let down = StrumKind(variant: .normal, direction: .down)
    public static let up = StrumKind(variant: .normal, direction: .up)
    public static let space = StrumKind(variant: .space, direction: nil)
    public static let downMuted = StrumKind(variant: .muted, direction: .down)
    public static let upMuted = StrumKind(variant: .muted, direction: .up)
    public static let downArpeggio = StrumKind(variant: .arpeggio, direction: .down)
    public static let upArpeggio = StrumKind(variant: .arpeggio, direction: .up)
    public static let rest = StrumKind(variant: .rest, direction: nil)
    
    public static func other(_ char: Character) -> StrumKind {
        StrumKind(variant: .other(char), direction: nil)
    }
    
    internal init(variant: Variant, direction: Direction?) {
        self.variant = variant
        self.direction = direction
    }
    
    public init(rawValue: Character) {
        switch rawValue {
        case "D", "d":
            self.direction = .down
            self.variant = .normal
        case "u", "U":
            self.direction = .up
            self.variant = .normal
        case "M":
            self.direction = .down
            self.variant = .muted
        case "m":
            self.direction = .up
            self.variant = .muted
        case "A":
            self.direction = .down
            self.variant = .arpeggio
        case "a":
            self.direction = .up
            self.variant = .arpeggio
        case " ":
            self.direction = nil
            self.variant = .space
        case "r":
            self.direction = nil
            self.variant = .rest
        default:
            self.direction = nil
            self.variant = .other(rawValue)
        }
    }
    
    public var rawValue: Character {
        self.variant.character(for: self.direction)
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
