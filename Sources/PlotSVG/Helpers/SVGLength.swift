//
//  SVGLength.swift
//  strumvg
//
//  Created by Edon Valdman on 3/1/25.
//

import Foundation

public struct SVGLength: /*RawRepresentable,*/ Hashable {
    public let length: Double
    public let unit: UnitType
    
    init(_ length: Double, unit: UnitType) {
        self.length = length
        self.unit = unit
    }
    
//    public init?(rawValue: String) {
//        var trimmed = rawValue
//        
//        if rawValue.hasSuffix("%") {
//            trimmed = trimmed
//                .trimmingCharacters(in: .init(["%"]))
//            unit = .percentage
//        } else if rawValue.
//        
//        let trimmed = rawValue
//            .replacingOccurrences(of: "%", with: "")
//    }
    
    public var rawValue: String {
        "\(length.formatted(SVGNumberFormat))\(unit.rawValue)"
    }
    
    public enum UnitType: String, Hashable {
        /// No unit type was provided (i.e., a unitless value was specified), which indicates a value in user units.
        case number = ""
        /// A percentage value was specified.
        case percentage = "%"
        /// A value was specified using the em units defined in CSS2.
        case em
        /// A value was specified using the ex units defined in CSS2.
        case ex
        /// A value was specified using the px units defined in CSS2.
        case px
        /// A value was specified using the cm units defined in CSS2.
        case cm
        /// A value was specified using the mm units defined in CSS2.
        case mm
        /// A value was specified using the in units defined in CSS2.
        case `in`
        /// A value was specified using the pt units defined in CSS2.
        case pt
        /// A value was specified using the pc units defined in CSS2.
        case pc
    }
    
    /// No unit type was provided (i.e., a unitless value was specified), which indicates a value in user units.
    public static func number(_ length: Double) -> SVGLength {
        return .init(length, unit: .number)
    }
    /// A percentage value was specified.
    public static func percentage(_ length: Double) -> SVGLength {
        return .init(length, unit: .percentage)
    }
        /// A value was specified using the em units defined in CSS2.
    public static func em(_ length: Double) -> SVGLength {
        return .init(length, unit: .em)
    }
        /// A value was specified using the ex units defined in CSS2.
    public static func ex(_ length: Double) -> SVGLength {
        return .init(length, unit: .ex)
    }
        /// A value was specified using the px units defined in CSS2.
    public static func px(_ length: Double) -> SVGLength {
        return .init(length, unit: .px)
    }
        /// A value was specified using the cm units defined in CSS2.
    public static func cm(_ length: Double) -> SVGLength {
        return .init(length, unit: .cm)
    }
        /// A value was specified using the mm units defined in CSS2.
    public static func mm(_ length: Double) -> SVGLength {
        return .init(length, unit: .mm)
    }
        /// A value was specified using the in units defined in CSS2.
    public static func `in`(_ length: Double) -> SVGLength {
        return .init(length, unit: .in)
    }
        /// A value was specified using the pt units defined in CSS2.
    public static func pt(_ length: Double) -> SVGLength {
        return .init(length, unit: .pt)
    }
        /// A value was specified using the pc units defined in CSS2.
    public static func pc(_ length: Double) -> SVGLength {
        return .init(length, unit: .pc)
    }

}

extension SVGLength: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value, unit: .number)
    }
}
