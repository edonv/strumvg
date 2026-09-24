//
//  SVGAngleValue.swift
//  strumvg
//
//  Created by Edon Valdman on 9/24/26.
//

import Foundation

/// https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/angle
public struct SVGAngleValue: Sendable, Hashable {
    public let angle: Double
    public let unit: Unit
    
    private init(angle: Double, unit: Unit) {
        self.angle = angle
        self.unit = unit
    }
    
    internal static var parsingRegex: some RegexComponent<(Substring, angle: Substring, unit: Substring)> {
        /(?<angle>(?:\+|-)?\d+\.?\d*)(?<unit>deg|grad|rad|turn)/
    }
    internal init?(stringValue: String) {
        if stringValue == "0" {
            self.init(angle: 0, unit: .deg)
            return
        }
        
        guard let match = stringValue.wholeMatch(of: SVGAngleValue.parsingRegex) else { return nil }
        
        guard let angle = Double(match.output.angle),
              let unit = Unit(rawValue: String(match.output.unit)) else { return nil }
        
        self.init(angle: angle, unit: unit)
    }
    
    var stringValue: String {
        "\(angle)\(unit.rawValue)"
    }
    
    public static func deg(_ angle: Double) -> SVGAngleValue { .init(angle: angle, unit: .deg) }
    public static func grad(_ angle: Double) -> SVGAngleValue { .init(angle: angle, unit: .grad) }
    public static func rad(_ angle: Double) -> SVGAngleValue { .init(angle: angle, unit: .rad) }
    public static func turn(_ angle: Double) -> SVGAngleValue { .init(angle: angle, unit: .turn) }
    
    public enum Unit: String, Sendable, Hashable {
        case deg, grad, rad, turn
    }
}

// MARK: Codable

extension SVGAngleValue: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        guard let value = SVGAngleValue(stringValue: string) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Angle value is in an invalid format."
                )
            )
        }
        
        self = value
    }
}
