//
//  PreserveAspectRatioOptions.swift
//  strumvg
//
//  Created by Edon Valdman on 3/1/25.
//

import Foundation

public struct PreserveAspectRatio: RawRepresentable, Hashable {
    internal let option: Options
    internal let meetOrSlice: MeetSlice?
    
    internal init(option: Options, meetOrSlice: MeetSlice?) {
        self.option = option
        self.meetOrSlice = meetOrSlice
    }
    
    public init?(rawValue: String) {
        let components = rawValue.components(separatedBy: " ")
        
        guard (1...2).contains(components.count),
            let option = Options(rawValue: components[0]) else { return nil }
        
        self.option = option
        self.meetOrSlice = MeetSlice(rawValue: components[1])
    }
    
    public var rawValue: String {
        [option.rawValue, meetOrSlice?.rawValue]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    public enum Options: String, Hashable {
        case none
        case xMinYMin
        case xMidYMin
        case xMaxYMin
        case xMinYMid
        case xMidYMid
        case xMaxYMid
        case xMinYMax
        case xMidYMax
        case xMaxYMax
    }
    
    public enum MeetSlice: String, Hashable, Codable {
        case meet, slice
    }
}
