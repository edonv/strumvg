//
//  RhythmicGroup.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import Parsing

extension Measure {
    /// A group of strums.
    ///
    /// One group is rendered with shared stems.
    public struct RhythmicGroup: Sendable, Hashable {
        public let strums: [Strum]
        
        public init(strums: [Strum]) {
            self.strums = strums
        }
        
        internal func appending(strums: [Strum]) -> RhythmicGroup {
            .init(strums: self.strums + strums)
        }
        
        package var containsHeaderText: Bool {
            strums.contains { $0.headingChar != nil }
        }
        
        public static func parser() -> AnyParserPrinter<Substring, RhythmicGroup> {
            Many {
                Strum.parser()
            }
            .map(.convert(apply: { strums in
                RhythmicGroup(strums: strums)
            }, unapply: { group in
                group.strums
            }))
            .eraseToAnyParserPrinter()
        }
    }
}
