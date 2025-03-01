//
//  Strum.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

public struct Strum: RawRepresentable {
    public typealias Kind = StrumKind
    
    public let kind: Kind
    public let headingChar: Character?
    
    public var direction: Direction? {
        kind.direction
    }
    
    public var variant: Variant {
        kind.variant
    }
    
    public init(kind: Kind, heading: Character?) {
        self.kind = kind
        self.headingChar = heading
    }
    
    public init?(rawValue: String) {
        // rawValue might be wrapping in {}
        var content = rawValue
            .trimmingCharacters(in: .init(["{", "}"]))
        
        if rawValue != " " {
            content = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard content.count <= 2,
              let kindChar = content.popLast() else { return nil }
        
        self.kind = .init(rawValue: kindChar)
        // If there's an element left
        self.headingChar = content.first
    }
    
    public var rawValue: String {
        if let headingChar {
            return "{\(headingChar)\(kind.rawValue)}"
        } else {
            return "\(kind.rawValue)"
        }
    }
}
