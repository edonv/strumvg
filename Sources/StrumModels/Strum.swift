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
