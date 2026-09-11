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
public struct Strum: RawRepresentable, Sendable, Hashable {
    public typealias Kind = StrumKind
    
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
    
    public static func parser() -> AnyParserPrinter<Substring, Strum> {
        OneOf {
            ParsePrint {
                "{"
                Prefix(1)
                    .map(.string)
                Kind.parser()
                "}"
            }
            .map(.convert(apply: { (str: String, kind: Kind) in
                (kind, str.first)
            }, unapply: { (kind: Kind, heading: Character?) -> (String, Kind)? in
                guard let heading else { return nil }
                return ("\(heading)", kind)
            }))
            
            Kind.parser()
                .map(.convert(apply: { kind in
                    (kind, nil)
                }, unapply: { (kind: Kind, heading: Character?) in
                    guard heading == nil else { return nil }
                    return kind
                }))
        }
        .map(.memberwise(Strum.init))
        .eraseToAnyParserPrinter()
    }
}
