//
//  CGFloat+ExpressibleByArgument.swift
//  strumvg
//
//  Created by Edon Valdman on 3/13/25.
//

import Foundation
import ArgumentParser

extension CGFloat: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard let f = Double(argument).map({ CGFloat($0) }) else { return nil }
        self = f
    }
}
