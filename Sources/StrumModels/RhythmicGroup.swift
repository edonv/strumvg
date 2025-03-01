//
//  RhythmicGroup.swift
//  strumvg
//
//  Created by Edon Valdman on 2/23/25.
//

import Foundation

public struct RhythmicGroup: RawRepresentable {
    public let strums: [Strum]
    
    public init(strums: [Strum]) {
        self.strums = strums
    }
    
    /// Initializes from a portion of a pattern string.
    /// - Parameter rawValue: A portion of a pattern string to be grouped together. Each strum (even those without header characters) must be wrapped in curly braces.
    public init?(rawValue: String) {
        self.strums = rawValue
            .components(separatedBy: "}")
            .map { $0.trimmingPrefix("{") }
            .map(String.init)
            .compactMap { Strum(rawValue: $0) }
//        let strumStrs: [String] = rawValue.reduce(into: []) { partial, char in
//            <#code#>
//        }
    }
    
    public var rawValue: String {
        strums
            .map(\.rawValue)
            .joined()
    }
}
