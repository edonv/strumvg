//
//  Timing.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation
import RegexBuilder
import Parsing

public struct Timing: Sendable, Hashable {
    public let duration: NoteDuration
    public let triplet: Bool
    
    public init(duration: NoteDuration, triplet: Bool) {
        self.duration = duration
        self.triplet = triplet
    }
    
    
    /// The (maximum) number of note stems per group, depending on the type of `Timing`.
    public var stemsPerGroup: Int {
        switch self.triplet {
        case true:
            return 3
        case false:
            switch duration {
            case .quarter:
                return 1
            case .eighth:
                return 2
            case .sixteenth:
                return 4
            }
        }
    }
    
    public static func parser() -> AnyParserPrinter<Substring, Timing> {
        ParsePrint(.memberwise(Timing.init)) {
            "-"
            
            NoteDuration.parser()
            
            Optionally { "t" }
                .map(.convert { captured in
                    captured != nil
                } unapply: {
                    $0 ? () : Optional.some(nil)
                })
        }
        .eraseToAnyParserPrinter()
    }
}
