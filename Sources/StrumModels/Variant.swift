//
//  Variant.swift
//  strumvg
//
//  Created by Edon Valdman on 2/27/25.
//

import Foundation

public enum Variant {
    case normal
    case muted
    case arpeggio
    case rest
    case space
    case other(Character)
    
    internal func character(for direction: Direction?) -> Character {
        switch (self, direction) {
        case (.normal, .down): "D"
        case (.normal, .up): "u"
        case (.muted, .down): "M"
        case (.muted, .up): "m"
        case (.arpeggio, .down): "A"
        case (.arpeggio, .up): "a"
        case (.space, _): " "
        case (.rest, _): "r"
        case (.other(let c), _): c
        default: " "
        }
    }
}
