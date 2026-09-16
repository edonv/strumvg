//
//  ParsingError.swift
//  strumvg
//
//  Created by Edon Valdman on 9/14/26.
//

import Foundation

public enum ParsingError: Error {
    case firstMeasureMissingTiming
    
    public var localizedDescription: String {
        switch self {
        case .firstMeasureMissingTiming:
            "Pattern's first measure missing timing. Timing portion is required on first measure."
        }
    }
}
