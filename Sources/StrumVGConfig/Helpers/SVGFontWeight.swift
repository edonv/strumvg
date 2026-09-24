//
//  SVGFontWeight.swift
//  strumvg
//
//  Created by Edon Valdman on 9/24/26.
//

import Foundation

/// https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-weight#values
public struct SVGFontWeight: Sendable, Hashable {
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
    
    internal static func number(_ number: Int) -> SVGFontWeight { .init(value: .number(number)) }
    internal static let normal: SVGFontWeight = .init(value: .normal)
    internal static let bold: SVGFontWeight = .init(value: .bold)
    internal static let lighter: SVGFontWeight = .init(value: .lighter)
    internal static let bolder: SVGFontWeight = .init(value: .bolder)
}

// MARK: Codable

extension SVGFontWeight: Codable {
    public func encode(to encoder: any Encoder) throws {
        switch value {
        case .number(let int):
            try int.encode(to: encoder)
        default:
            try stringValue.encode(to: encoder)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self),
           let weight = SVGFontWeight(stringValue: string) {
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

extension SVGFontWeight: Schemable {
    public static var schema: some JSONSchemaComponent<SVGFontWeight> {
        JSONComposition.OneOf(into: SVGFontWeight.self) {
            JSONInteger()
                .title("Weight value number")
                .minimum(JSONNumberLiteral(1 as Int))
                .maximum(JSONNumberLiteral(1000 as Int))
                .map { SVGFontWeight(value: .number($0)) }
            
            JSONString()
                .title("Standardized weight name")
                .enumValues {
                    "normal"
                    "bold"
                    "lighter"
                    "bolder"
                }
                .compactMap { string in
                    SVGFontWeight(stringValue: string)
                }
            
            JSONString()
                .title("Weight value number in a string")
                .pattern("(\\d{1,3})|(1000)")
                .compactMap(Int.init)
                .map { SVGFontWeight(value: .number($0)) }
        }
    }
}

// MARK: ConfigReader

import Configuration

extension ConfigReader {
    func svgFontWeight(
        forKey key: ConfigKey,
        isSecret: Bool = false,
        default defaultValue: SVGFontWeight,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> SVGFontWeight {
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
           let weight = SVGFontWeight(stringValue: string) {
            return weight
        } else if let int {
            return .number(int)
        } else {
            return defaultValue
        }
    }
}

