//
//  SVGFontWeightValue.swift
//  strumvg
//
//  Created by Edon Valdman on 9/24/26.
//

import Foundation

/// https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-weight#values
public struct SVGFontWeightValue: Sendable, Hashable {
    private var value: Value
    
    private init(value: Value) {
        self.value = value
    }
    
    fileprivate init?(stringValue: String) {
        switch stringValue {
        case "normal":
            self.value = .normal
        case "bold":
            self.value = .bold
        case "lighter":
            self.value = .lighter
        case "bolder":
            self.value = .bolder
        default:
            return nil
        }
    }
    
    package var stringValue: String {
        switch value {
        case .number(let int):
            "\(int)"
        case .normal:
            "normal"
        case .bold:
            "bold"
        case .lighter:
            "lighter"
        case .bolder:
            "bolder"
        }
    }
    
    private enum Value: Sendable, Hashable {
        case number(Int)
        case normal, bold, lighter, bolder
    }
    
    internal static func number(_ number: Int) -> SVGFontWeightValue { .init(value: .number(number)) }
    internal static let normal: SVGFontWeightValue = .init(value: .normal)
    internal static let bold: SVGFontWeightValue = .init(value: .bold)
    internal static let lighter: SVGFontWeightValue = .init(value: .lighter)
    internal static let bolder: SVGFontWeightValue = .init(value: .bolder)
}

// MARK: Codable

extension SVGFontWeightValue: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case .number(let int):
            try container.encode(int)
        default:
            try container.encode(stringValue)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self),
           let weight = SVGFontWeightValue(stringValue: string) {
            self = weight
        } else {
            let int = try container.decode(Int.self)
            self.value = .number(int)
        }
    }
}

// MARK: Schemable

import JSONSchemaBuilder
import OrderedJSON

extension SVGFontWeightValue: Schemable {
    public static var schema: some JSONSchemaComponent<SVGFontWeightValue> {
        JSONComposition.OneOf(into: SVGFontWeightValue.self) {
            JSONInteger()
                .title("Weight value number")
                .minimum(JSONNumberLiteral(1 as Int))
                .maximum(JSONNumberLiteral(1000 as Int))
                .map { SVGFontWeightValue(value: .number($0)) }
            
            JSONString()
                .title("Standardized weight name")
                .enumValues {
                    "normal"
                    "bold"
                    "lighter"
                    "bolder"
                }
                .compactMap { string in
                    SVGFontWeightValue(stringValue: string)
                }
            
            JSONString()
                .title("Weight value number in a string")
                .pattern("(^[1-9]\\d{0,2}$)|(^1000$)")
                .compactMap(Int.init)
                .map { SVGFontWeightValue(value: .number($0)) }
        }
        .examples {
            100
            200
            300
            400
            500
            600
            700
            800
            900
        }
    }
}

// MARK: ConfigReader

import Configuration

extension ConfigReader {
    func svgFontWeight(
        forKey key: ConfigKey,
        isSecret: Bool = false,
        default defaultValue: SVGFontWeightValue,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> SVGFontWeightValue {
        let string = string(
            forKey: key,
            isSecret: isSecret,
            fileID: fileID,
            line: line
        )
        
        let int = int(
            forKey: key,
            isSecret: isSecret,
            fileID: fileID,
            line: line
        )
        
        if let string,
           let weight = SVGFontWeightValue(stringValue: string) {
            return weight
        } else if let int {
            return .number(int)
        } else {
            return defaultValue
        }
    }
}

