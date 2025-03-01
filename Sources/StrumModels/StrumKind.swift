//
//  StrumKind.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

public struct StrumKind: RawRepresentable {
    public let direction: Direction?
    public let variant: Variant
    
//    case down
//    case up
//    case mutedDown
//    case mutedUp
//    case arpDown
//    case arpUp
//    case space
//    case rest
//    case other(Character)
    
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
